const {test} = require('node:test');
const assert = require('node:assert/strict');
const {readFileSync} = require('node:fs');
const {resolve} = require('node:path');
const vm = require('node:vm');
const code = readFileSync(resolve(__dirname, '../../../terraform/modules/locdoc-runtime/bootstrap.cjs'), 'utf8');
function bootstrap(overrides = {}) {
  let captured, exited, error;
  const handlers = {}, childHandlers = {}, signals = [];
  const env = {DB_HOST:'db.internal', DB_PORT:'5432', DB_NAME:'oms', DB_USER:'app@user', DB_PASSWORD:'p:@/#%?value', DATABASE_PROVIDER:'postgres', DB_SSL_ROOT_CERT:'/etc/ssl/certs/rds-ca.pem', ...overrides};
  const child = {kill:signal => signals.push(signal), on:(name, fn) => {childHandlers[name] = fn;}};
  const process = {env, execPath:'/usr/bin/node', on:(name, fn) => {handlers[name] = fn;}, exit:code => {exited = code; throw new Error('exit');}};
  try { vm.runInNewContext(code, {URL, process, console:{error:message => {error = message;}}, require:name => {
    assert.equal(name, 'node:child_process');
    return {spawn:(executable,args,options) => {captured = {executable,args,options}; return child;}};
  }}); } catch (e) {if (e.message !== 'exit') throw e;}
  return {captured, exited, error, handlers, childHandlers, signals};
}
test('preserves reserved credential characters and verifies RDS TLS', () => {
  const {captured} = bootstrap();
  const url = new URL(captured.options.env.DATABASE_URL);
  assert.equal(decodeURIComponent(url.username), 'app@user');
  assert.equal(decodeURIComponent(url.password), 'p:@/#%?value');
  assert.equal(url.searchParams.get('sslmode'), 'verify-full');
  assert.equal(url.searchParams.get('sslrootcert'), '/etc/ssl/certs/rds-ca.pem');
  assert.equal(captured.args.join(' '), 'dist/server.js');
});
test('missing credentials fail before app starts without printing values', () => {
  const result = bootstrap({DB_PASSWORD:''});
  assert.equal(result.exited, 1);
  assert.equal(result.captured, undefined);
  assert.equal(result.error, 'Missing required runtime setting: DB_PASSWORD');
});
test('forwards termination to OMS for graceful shutdown', () => {
  const result = bootstrap();
  result.handlers.SIGTERM();
  result.handlers.SIGINT();
  assert.deepEqual(result.signals, ['SIGTERM', 'SIGINT']);
});

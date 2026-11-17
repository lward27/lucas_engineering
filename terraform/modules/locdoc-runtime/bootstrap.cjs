// Credentials arrive through ECS secret injection, never Terraform values.
const {spawn} = require('node:child_process');
const required = ['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD', 'DATABASE_PROVIDER'];
for (const name of required) {
  if (!process.env[name]) { console.error(`Missing required runtime setting: ${name}`); process.exit(1); }
}
const scheme = process.env.DATABASE_PROVIDER === 'postgres' ? 'postgresql' : 'mysql';
const url = new URL(`${scheme}://localhost`);
url.hostname = process.env.DB_HOST;
url.port = process.env.DB_PORT;
url.username = encodeURIComponent(process.env.DB_USER);
url.password = encodeURIComponent(process.env.DB_PASSWORD);
url.pathname = '/' + process.env.DB_NAME;
if (scheme === 'postgresql') {
  url.searchParams.set('sslmode', 'verify-full');
  url.searchParams.set('sslrootcert', process.env.DB_SSL_ROOT_CERT);
}
process.env.DATABASE_URL = url.toString();
const child = spawn(process.execPath, ['dist/server.js'], {env:process.env, stdio:'inherit'});
for (const signal of ['SIGTERM', 'SIGINT']) process.on(signal, () => child.kill(signal));
child.on('error', () => { console.error('OMS process failed to start'); process.exit(1); });
child.on('exit', (code, signal) => process.exit(code ?? (signal === 'SIGTERM' ? 143 : 1)));

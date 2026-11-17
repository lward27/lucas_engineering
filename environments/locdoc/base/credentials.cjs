// Short-lived credential_process results let the SDK reload a rotated emulator
// session from the projected Secret without changing the GitOps Deployment.
const fs = require('node:fs');
const text = fs.readFileSync('/aws-session/emulator_credentials', 'utf8');
const fields = Object.fromEntries(text.split(/\r?\n/).filter(l => l.includes('=')).map(l => {
  const i = l.indexOf('='); return [l.slice(0, i).trim(), l.slice(i + 1).trim()];
}));
if (!fields.aws_access_key_id || !fields.aws_secret_access_key) process.exit(1);
process.stdout.write(JSON.stringify({Version: 1, AccessKeyId: fields.aws_access_key_id,
  SecretAccessKey: fields.aws_secret_access_key,
  Expiration: new Date(Date.now() + 60000).toISOString()}));

import assert from 'node:assert/strict';
import { randomUUID } from 'node:crypto';
import { createRequire } from 'node:module';
const require = createRequire('/app/package.json');
const { PutObjectCommand, GetObjectCommand, HeadObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const { DescribeSecretCommand } = require('@aws-sdk/client-secrets-manager');
const {createS3Client, createSecretsManagerClient} = await import('/app/dist/utils/awsClients.js');
assert.equal(process.env.NODE_ENV, 'development', 'Synthetic lab only');
assert.equal(process.env.OMS_MOCK_S3, 'true', 'Lab object gateway required');
assert.ok(['locdoc-oms-localstack-documents', 'locdoc-oms-aws-emulator-documents'].includes(process.env.AWS_BUCKET_NAME), 'Lab bucket allowlist');
const s3 = createS3Client();
const bucket = process.env.AWS_BUCKET_NAME;
const key = `SDP/terraform-lab-check/${randomUUID()} # ?.txt`;
const payload = 'Synthetic OMS Terraform end-to-end check';
let version;
try {
  const put = await s3.send(new PutObjectCommand({Bucket: bucket, Key: key, Body: Buffer.from(payload), ContentType: 'text/plain'}));
  version = put.VersionId;
  const obj = await s3.send(new GetObjectCommand({Bucket: bucket, Key: key}));
  assert.equal(await obj.Body.transformToString(), payload);
  const head = await s3.send(new HeadObjectCommand({Bucket: bucket, Key: key}));
  assert.equal(head.ContentLength, Buffer.byteLength(payload));
  const secret = await createSecretsManagerClient().send(new DescribeSecretCommand({SecretId: 'oms/precisely/system'}));
  assert.equal(secret.Name, 'oms/precisely/system');
  const health = await fetch('http://127.0.0.1:8080/api/health');
  assert.equal(health.status, 200, 'health status');
  const contacts = (await (await fetch('http://127.0.0.1:8080/api/dev/contacts')).json()).data;
  const demo = contacts.find(c => c.provider_id === '5eed0a00-0000-4000-8000-000000000001' && c.isProviderStaff);
  const other = contacts.find(c => c.provider_id === '5eed0b00-0000-4000-8000-000000000001' && c.isProviderStaff);
  assert.ok(demo && other);
  async function login(contact) {
    const csrf = await fetch('http://127.0.0.1:8080/api/csrf-token');
    const cookies = new Map(csrf.headers.getSetCookie().map(c => [c.slice(0, c.indexOf('=')), c.split(';')[0]]));
    const csrfToken = (await csrf.json()).body;
    const response = await fetch('http://127.0.0.1:8080/api/dev/login', {method: 'POST', headers: {'content-type':'application/json', cookie: [...cookies.values()].join('; '), 'x-csrf-token': csrfToken, origin: 'http://127.0.0.1:8080'}, body: JSON.stringify({contactId: contact.id})});
    assert.equal(response.status, 200, 'login status');
    for (const c of response.headers.getSetCookie()) cookies.set(c.slice(0, c.indexOf('=')), c.split(';')[0]);
    return [...cookies.values()].join('; ');
  }
  const path = '/api/mock-objects/' + key.split('/').map(encodeURIComponent).join('/');
  const unauth = await fetch('http://127.0.0.1:8080'+path);
  assert.notEqual(unauth.status, 200);
  const cookie = await login(demo);
  const response = await fetch('http://127.0.0.1:8080'+path, {headers: {cookie}});
  assert.equal(response.status, 200, 'object route status');
  assert.equal(await response.text(), payload);
  const otherCookie = await login(other);
  const isolated = await fetch('http://127.0.0.1:8080'+path, {headers: {cookie: otherCookie}});
  assert.notEqual(isolated.status, 200);
  console.log(JSON.stringify({bucket, application_s3_factory:'passed', head_object:'passed', application_secrets_manager_factory:'passed', health:'passed', synthetic_login:'passed', authenticated_object_route:'passed', unauthenticated_object_access:'denied', other_provider_object_access:'denied'}));
} catch (error) {
  console.error(JSON.stringify({error: error.name, message: String(error.message).slice(0,160), at: String(error.stack).split('\n')[1]}));
  process.exitCode = 1;
} finally {
  await s3.send(new DeleteObjectCommand({Bucket: bucket, Key: key, ...(version ? {VersionId: version} : {})}));
}

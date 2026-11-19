import assert from 'node:assert/strict';
import {createPrismaClient} from '/app/dist/utils/createPrismaClient.js';
assert.equal(process.env.NODE_ENV,'development','Isolated synthetic lab only');
assert.equal(process.env.DATABASE_PROVIDER,'postgres');
assert.equal(process.env.DB_SSL_MODE,'verify-full');
assert.ok(['locdoc-oms-localstack-documents','locdoc-oms-aws-emulator-documents'].includes(process.env.AWS_BUCKET_NAME));
const original={...process.env};
async function connect(overrides,expectError){
 Object.assign(process.env,original,overrides);
 const db=createPrismaClient({log:[],pg:{connectionTimeoutMillis:5000}});
 try{
  const result=await db.$queryRawUnsafe('SELECT ssl, version FROM pg_stat_ssl WHERE pid = pg_backend_pid()');
  if(expectError)assert.fail('Rejected database configuration unexpectedly connected');
  assert.equal(result[0].ssl,true);assert.match(result[0].version,/^TLSv1\.[23]$/);
 }catch(error){if(!expectError)throw error;assert.match(String(error.message),expectError);}
 finally{await db.$disconnect();}
}
await connect({});
await connect({DB_SSL_ROOT_CERT:'/etc/ssl/certs/rds-ca.pem'},/certificate|self.signed|verify|P1011/i);
const wrongHost=new URL(process.env.DATABASE_URL);wrongHost.hostname=process.env.OMS_TEST_DB_IP;
await connect({DATABASE_URL:wrongHost.toString()},/altname|hostname|IP.*match|certificate.*name/i);
await connect({DB_SSL_MODE:'disable'},/pg_hba|rejects connection|no encryption/i);
await connect({});
Object.assign(process.env,original);
console.log(JSON.stringify({database_tls:'verified',invalid_ca:'rejected',wrong_hostname:'rejected',plaintext:'rejected',healthy_after_negative_tests:true}));

// Prisma wraps an externally owned pg.Pool; end this bounded CLI after checks.
process.exit(0);

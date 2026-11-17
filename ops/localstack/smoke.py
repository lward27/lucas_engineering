"""Run with the LocalStack container's Python after applying the Terraform example.

kubectl --kubeconfig /home/wardl/.kube/config --context lucas_engineering \
  -n localstack exec -i deployment/localstack -- python - < ops/localstack/smoke.py
"""

import json
import uuid
import urllib.request

import boto3
from botocore.config import Config

endpoint = "http://localstack.localstack.svc.cluster.local:4566"
with urllib.request.urlopen(endpoint + "/_localstack/health", timeout=10) as response:
    assert response.status == 200

session = boto3.Session(
    aws_access_key_id="test",
    aws_secret_access_key="test",
    region_name="us-east-1",
)
config = Config(
    connect_timeout=5,
    read_timeout=10,
    retries={"max_attempts": 1},
    s3={"addressing_style": "path"},
)
s3 = session.client("s3", endpoint_url=endpoint, config=config)
sqs = session.client("sqs", endpoint_url=endpoint, config=config)
token = str(uuid.uuid4())
key = "smoke/" + token + ".txt"
bucket = "locdoc-dev-documents"
s3.put_object(Bucket=bucket, Key=key, Body=token.encode())
assert s3.get_object(Bucket=bucket, Key=key)["Body"].read().decode() == token
# Only remove the unique synthetic object created by this test.
s3.delete_object(Bucket=bucket, Key=key)
queue_url = sqs.get_queue_url(QueueName="locdoc-dev-document-jobs")["QueueUrl"]
assert queue_url.startswith(endpoint + "/"), queue_url
# Run this only against the idle starter queue. An approximate count cannot
# exclude concurrent producers; do not run it once application clients use it.
attrs = sqs.get_queue_attributes(
    QueueUrl=queue_url,
    AttributeNames=["ApproximateNumberOfMessages", "ApproximateNumberOfMessagesNotVisible"],
)["Attributes"]
if any(int(value) for value in attrs.values()):
    raise RuntimeError("Smoke receive requires an empty development queue")
sqs.send_message(QueueUrl=queue_url, MessageBody=token)
messages = sqs.receive_message(
    QueueUrl=queue_url, MaxNumberOfMessages=1, WaitTimeSeconds=2
).get("Messages", [])
assert len(messages) == 1 and messages[0]["Body"] == token
sqs.delete_message(QueueUrl=queue_url, ReceiptHandle=messages[0]["ReceiptHandle"])
print(json.dumps({
    "health": "passed",
    "in_cluster_service_dns": "passed",
    "s3_put_get": "passed",
    "sqs_send_receive": "passed",
    "sqs_private_endpoint": "passed",
    "synthetic_test_data_cleanup": "passed",
}))

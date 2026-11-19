"""Exercise the idle Terraform starter through client.py using the Python SDK.

Uses the SDK bundled with this workstation's AWS CLI. Do not run while
application clients use the starter queue. Removes only synthetic fixtures.
"""

import json
import os
import uuid

# This distro's AWS CLI exposes its bundled botocore after importing awscli.
# Use the SDK directly: its CLI argument parser has a Python 3.14 help-text bug
# affecting sqs send-message, before any API request is sent.
import awscli  # noqa: F401
from botocore.config import Config
from botocore.exceptions import ClientError
from botocore.session import Session

endpoint = os.environ["AWS_ENDPOINT_URL"]
config = Config(connect_timeout=5, read_timeout=10, retries={"max_attempts": 1},
                inject_host_prefix=False, s3={"addressing_style": "path"})
session = Session()


def client(service, **kwargs):
    return session.create_client(service, region_name="us-east-1", endpoint_url=endpoint,
                                 verify=os.environ["AWS_CA_BUNDLE"], config=config, **kwargs)


assert client("sts").get_caller_identity()["Account"] == "000000000000"
try:
    client("sts", aws_access_key_id="test", aws_secret_access_key="test").get_caller_identity()
except ClientError as error:
    assert error.response["Error"]["Code"] in ["AccessDenied", "InvalidClientTokenId", "SignatureDoesNotMatch"]
else:
    raise AssertionError("Wrong credentials unexpectedly accepted")

token = str(uuid.uuid4())
key = "smoke/" + token + ".txt"
bucket = "emulator-dev-documents"
s3 = client("s3")
s3.put_object(Bucket=bucket, Key=key, Body=token.encode())
assert s3.get_object(Bucket=bucket, Key=key)["Body"].read().decode() == token
s3.delete_object(Bucket=bucket, Key=key)

sqs = client("sqs")
queue = sqs.get_queue_url(QueueName="emulator-dev-document-jobs")["QueueUrl"]
attrs = sqs.get_queue_attributes(QueueUrl=queue, AttributeNames=[
    "ApproximateNumberOfMessages", "ApproximateNumberOfMessagesNotVisible"])["Attributes"]
assert not any(int(value) for value in attrs.values()), "Smoke test requires an idle, empty queue"
sqs.send_message(QueueUrl=queue, MessageBody=token)
messages = sqs.receive_message(QueueUrl=queue, MaxNumberOfMessages=1, WaitTimeSeconds=2)["Messages"]
assert len(messages) == 1 and messages[0]["Body"] == token
sqs.delete_message(QueueUrl=queue, ReceiptHandle=messages[0]["ReceiptHandle"])

ddb = client("dynamodb")
table = "emulator-dev-documents"
item = {"id": {"S": token}, "note": {"S": "synthetic smoke fixture"}}
item_key = {"id": {"S": token}}
ddb.put_item(TableName=table, Item=item)
assert ddb.get_item(TableName=table, Key=item_key, ConsistentRead=True)["Item"] == item
ddb.delete_item(TableName=table, Key=item_key)
print(json.dumps({"sts_account_check": "passed", "wrong_credentials_rejected": "passed",
                  "s3_put_get": "passed", "sqs_send_receive": "passed",
                  "dynamodb_put_get": "passed", "synthetic_fixture_cleanup": "passed"}))

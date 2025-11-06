import boto3
import os
import dotenv
import botocore

dotenv.load_dotenv()

secret_access_key = os.getenv('SECRET_ACCESS_KEY')
access_key_id = os.getenv('ACCESS_KEY_ID')

s3 = boto3.resource('s3', 
                  aws_access_key_id=access_key_id,
                  aws_secret_access_key=secret_access_key)

#get the list of existing buckets
for bucket in s3.buckets.all():
    print(bucket.name)
# Create a new bucket
# s3.create_bucket(Bucket='aws-learning-demo-bucket-1',
#                  CreateBucketConfiguration={
#                      'LocationConstraint': 'ap-south-1'})

#download a file from a bucket
BUCKET_NAME = 'aws-learning-demo-bucket'
FILE_NAME = 'Resume_Suvojit Chandra_Educator.pdf'

try:
    s3.Bucket(BUCKET_NAME).download_file(
        FILE_NAME,  # Source file in S3
        f'downloads/{FILE_NAME}'  # Local destination path
    )
    print(f"File downloaded successfully from {BUCKET_NAME}")
except botocore.exceptions.ClientError as e:
    if e.response['Error']['Code'] == '404':
        print(f"File {FILE_NAME} not found in bucket {BUCKET_NAME}")
    else:
        print(f"Error downloading file: {e}")
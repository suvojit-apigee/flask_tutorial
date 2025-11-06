import boto3
import os
import dotenv

dotenv.load_dotenv()

access_key_id = os.getenv('ACCESS_KEY_ID')
secret_access_key = os.getenv('SECRET_ACCESS_KEY')

ssm = boto3.client('ssm',
                   aws_access_key_id=access_key_id,
                     aws_secret_access_key=secret_access_key)

# Retrieve the parameter named 'resume_url' from AWS SSM Parameter Store
parameter = ssm.get_parameter(
    Name='resume_url',
    WithDecryption=True )

print("Parameter Value: ", parameter['Parameter']['Value'])

#Retieve the parameter with list of values from AWS SSM Parameter Store
parameter = ssm.get_parameter(
    Name='color_list',
    WithDecryption=True )
print("Parameter Value: ", parameter['Parameter']['Value'])
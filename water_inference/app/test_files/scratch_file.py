
import boto3

s3_bucket = boto3.Session(
                region_name = 'us-east-1',
                aws_access_key_id="AKIA2XFXMY3RKNK5OCM2",
                aws_secret_access_key="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"
        ).client('s3')


text_object = "planet_images/production/txt/lat_-1.416096_long_35.097661/20200404_080700_25_1061.txt"
bucket_name = "w210-planet-data-api"

print(text_object)

text_obj = s3_bucket.get_object(Bucket=bucket_name, Key=text_object)
text_data = text_obj['Body'].read()

print(text_data)

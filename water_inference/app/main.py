from flask import Flask, request, jsonify
from flask_restplus import Api, Resource, Namespace
from resources.test_functions import get_test_probability
from resources.torch_settings import *
from PIL import Image
from rasterio.plot import reshape_as_raster, reshape_as_image
import json
import boto3
import io
import logging
import numpy as np
import rasterio
import traceback
import os
import time


app = Flask(__name__)
api = Api(title='Water Detection API', prefix='/api/v1',  description='apis for water detection', doc='/api/v1/swagger-ui.html')

api.init_app(app)

@api.route("/")
class hellow_world(Resource):
    
    def get(self):
        
        return {'hello': 'world'}


@api.route("/waypoint-test")
class testProbability(Resource):
    
    def __init__(self, data):
        self.data = request.get_json(force=True)


    def post(self):
        
        latitude = self.data["lat"]
        longitude = self.data["long"]
        location_name = self.data["name"]
        request_date = self.data["date"]
        
        prob, label = get_test_probability(latitude, longitude, location_name, request_date)

        return {"status": "success", "probability": prob, "label": label}

@api.route('/waypoint')
@api.doc(
    response={
        200: 'Successful',
        400: 'Incorrect fields in request',
        404: 'Not found'
    }
)
class getProbability(Resource):

    def __init__(self, data):
        self.data = request.get_json(force=True)
        #self.s3_bucket = boto3.resource('s3')
        self.bucket_name = "w210-planet-data-api"
        self.my_transforms = my_transforms
        self.device = device
        self.logger = logging.getLogger(__name__)
        self.prod_format = "tif"
        self.model = model

    def post(self):

        prefix = f"planet_images/production/{self.prod_format}/lat_{self.data['lat']}_long_{self.data['long']}" 
        prefix_data = f"planet_images/production/txt/lat_{self.data['lat']}_long_{self.data['long']}"
        self.logger.warning(prefix)

        s3_bucket = boto3.Session(
                region_name = 'us-east-1', 
                aws_access_key_id="AKIA2XFXMY3RKNK5OCM2", 
                aws_secret_access_key="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"
        ).client('s3') 

        try:
            objs = s3_bucket.list_objects_v2(Bucket=self.bucket_name, Prefix=prefix)['Contents']

            self.logger.warning(objs)

            latest_object = [obj['Key'] for obj in sorted(objs, key=lambda x: (-1)*int(x['Key'].split('/')[4].split('_')[0]))][0]

            self.logger.warning("Using {}".format(latest_object))

            if self.prod_format == "jpg":
                obj = s3_bucket.get_object(Bucket=self.bucket_name, Key=latest_object)
                body = obj['Body'].read()
                
                image = Image.open(io.BytesIO(body))
            
            elif self.prod_format == "tif":
                
                print("Using tif image set")
                #the_url = f"https://s3.us-east-1.amazonaws.com/{self.bucket_name}/{latest_object}"
                #the_url = f"s3://{self.bucket_name}/{latest_object}".strip()
                #the_url = f"https://{self.bucket_name}.s3.us-east-1.amazonaws.com/{latest_object}"
                #obj = s3_bucket.get_object(Bucket=self.bucket_name, Key=latest_object)
                #body = obj['Body'].read()
                #print(body)
                #the_url = 's3://w210-planet-data-api/20200305_163004_0f44_3B_AnalyticMS_SR_clip.tif'
                
                s3_bucket.download_file(self.bucket_name, latest_object, '/app/tmp/file.tif')

                with rasterio.open('/app/tmp/file.tif') as f:
                    dataset = f.read().astype(np.uint8)
                    dataset = reshape_as_image(dataset)
                    
                    image = Image.fromarray(dataset, 'RGBA')

                os.remove("/app/tmp/file.tif")
            
            else:
                return {"status": "fail", "message": "Internal Error: Image type not valid"}

            tensor = self.my_transforms(image).unsqueeze(0)
            tensor = tensor.to(self.device)


            with torch.no_grad():
                outputs = self.model(tensor)

                m = nn.Softmax(dim=1)
                softmax_out = m(outputs).detach().numpy()[0]

                final_label = np.argmax(softmax_out)
                final_prob = softmax_out[final_label]


            final_label = "Water" if final_label == 1 else "No Water"

            txt_objs = s3_bucket.list_objects_v2(Bucket=self.bucket_name, Prefix=prefix_data)['Contents']

            latest_date = latest_object.split('/')[4].split('_')[0]

            latest_txt_obj = [txt_obj["Key"] for txt_obj in txt_objs if latest_date in txt_obj["Key"]][0]

            print(latest_txt_obj)

            text_obj = s3_bucket.get_object(Bucket=self.bucket_name, Key=latest_txt_obj)
            text_data = text_obj['Body'].read()

            if isinstance(text_data, list):
                text_data = text_data[0]

            return {"status": "success", "probability": str(final_prob), "class": str(final_label), "data": json.loads(text_data.decode("utf-8"))}

        except Exception as e:
            self.logger.exception('Unable to write raw to s3')
            #traceback.print_tb(exc_traceback, limit=1, file=sys.stdout)
            
            return {"status": "fail", "message": str(e)}



if __name__ == "__main__":
    # Only for debugging while developing
    app.run(host='0.0.0.0', debug=True, port=80)

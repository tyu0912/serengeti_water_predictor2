#!/usr/bin/env python
# coding: utf-8

# # Imports and Setup

# In[24]:


import pandas as pd
# from pandas.io.json import json_normalize
import geopandas as gpd
from shapely.geometry import Point
import matplotlib.pyplot as plt
import json
from datetime import date, datetime, timedelta
import time
import os
import numpy as np
import requests
from requests.auth import HTTPBasicAuth
import pathlib
#from config import ACCESS_KEY,SECRET_KEY
# import polling
import boto3
from osgeo import gdal


# Generating Order
# API Key stored as an env variable
PL_API_KEY = '' # Jason
PL_API_KEY = '' # Conor
PLANET_API_KEY = PL_API_KEY #os.getenv('PL_API_KEY')
ORDERS_V2_URL = 'https://api.planet.com/compute/ops/orders/v2'

S3_BUCKET = 'w210-planet-data-api' # S3 Bucket
S3_ACCESS_KEY = '' # Conor
S3_SECRET_KEY = '' # Conor


# set up requests to work with api
auth = HTTPBasicAuth(PLANET_API_KEY, '')
HEADERS = {'content-type': 'application/json'}


item_type = "PSScene4Band"

# set up options for conversion to jpg
gdal_Translate_options_list = [
    '-ot Byte',
    '-of JPEG',
    '-b 1',
    '-b 2',
    '-b 3',
    '-b 4',
    '-scale min_val max_val'
] 
gdal_Translate_options_string = " ".join(gdal_Translate_options_list)


# # Load waypoints into a GeoDataFrame
# 

# In[25]:


# Load waypoints into a GeoDataFrame
# waypoint_data = {
#     'Waypoint' : ['Orangi River', 'Mara River', 'Sand River', 'Grumeti River', 'Lake Masek', 
#                   'Lake Magadi', 'Lake Empakaai', 'Lake Magadi 2', 'Mbalageti River', 'Ruwana River', 'Talek River'],
#     'latitude' : [-2.302313, -1.562928, -1.595733, -2.249034, -3.024818, -3.202214, -2.915433, -2.656248, -2.603015, -2.044819, -1.416096],
#     'longitude' : [34.830777, 34.997068, 35.069241, 34.486842, 35.038474, 35.536431, 35.841355, 34.788239, 34.720511, 34.230374, 35.097661]
# }
waypoint_data = {
    'Waypoint' : ['Orangi River'],
    'latitude' : [-2.302313],
    'longitude' : [34.830777]
}

waypoint_df = pd.DataFrame(waypoint_data)
waypoint_gdf = gpd.GeoDataFrame(waypoint_df, geometry=gpd.points_from_xy(waypoint_df.longitude, waypoint_df.latitude))

# Applying WGS84 to the CRS
waypoint_gdf.crs = {'init' :'epsg:4326'} 


# # Prep GeoDataFrame with buffers
# 

# In[26]:


# Converting geodataframe to Meters from Lat/Long
# Allows for square buffer to be applied (450m)
point_gdf_m = waypoint_gdf.to_crs(epsg=3395)

# Applying the buffer, cap_style = 3 --> Square Buffer, 383.5 = 256x256 chip size
buffer = point_gdf_m.buffer(383.5, cap_style=3)

# # Convert buffer back to WGS84 Lat/Long
buffer_wgs84 = buffer.to_crs(epsg=4326)


# In[27]:


# Merging GDF and DF to get the Waypoint names
joined_buffer_wgs84 = pd.concat([waypoint_df,buffer_wgs84], axis=1)
joined_buffer_wgs84 = joined_buffer_wgs84.rename(columns = {0:'polygon'}).set_geometry('polygon')

joined_buffer_wgs84_drop = joined_buffer_wgs84.drop(['geometry'], axis=1)
joined_buffer_wgs84_json = joined_buffer_wgs84_drop.to_json()

# transforming to json for inclusion into Planet API
buffer_wgs84_json_parsed = json.loads(joined_buffer_wgs84_json)
buffer_wgs84_json_api = buffer_wgs84_json_parsed['features']#[0]['geometry']['coordinates']

today = datetime.isoformat(datetime.utcnow())+'Z'#(datetime.today())
start_date = datetime.isoformat(datetime.utcnow() - timedelta(7)) + 'Z'


# In[28]:


# Getting Image ID's for each waypoint that has the analytic_sr dataset 
# Having to ping the Planet V1 API to return the image id's for our required filter
# Filter variables include: Center Coordinate, Date Range, Cloud Cover, Item Type and Asset Type


def build_order(index):
    geojson_geometry = {
    "type": "Point",
    "coordinates": [
        index['properties']['longitude'], index['properties']['latitude']
        ]
    }

    # get images that overlap with our AOI 
    geometry_filter = {
      "type": "GeometryFilter",
      "field_name": "geometry",
      "config": geojson_geometry
    }

    date_range_filter = {
      "type": "DateRangeFilter",
      "field_name": "acquired",
      "config": {
        "gte": start_date,
        "lte": today
      }
    }

    # only get images which have <10% cloud coverage
    cloud_cover_filter = {
      "type": "RangeFilter",
      "field_name": "cloud_cover",
      "config": {
        "lte": 0.1
      }
    }

    # combine our geo, date, cloud filters
    combined_filter = {
      "type": "AndFilter",
      "config": [geometry_filter, date_range_filter, cloud_cover_filter]
    }
    
    # API request object
    search_request = {
        "interval": "day",
        "item_types": [item_type],
        "asset_types" : "analytic_sr",
        "filter": combined_filter
    }
    
    search_result =       requests.post(
        'https://api.planet.com/data/v1/quick-search',
    #     'https://api.planet.com/data/v2',
        auth=HTTPBasicAuth(PLANET_API_KEY, ''),
        json=search_request)

    return search_result


# In[29]:


id_list = []

for index in buffer_wgs84_json_api:
    waypoint = index["properties"]["Waypoint"]
    order = build_order(index)
    
    time.sleep(3)
    order = order.json()['features']

    # appending Image ID to `joined_buffer_wgs84_drop_merge` if the analytic_sr is available
    # Will only return image id's that meet this requirement.
    for i in order:
        #print(order)
        if "assets.analytic_sr:download" in i["_permissions"]:
            id_list.append((waypoint,i["id"],i["properties"]))


# In[30]:


# Merging image id's to the dataframe to maintain continuity

image_ids = pd.DataFrame(np.asarray(id_list))
image_ids.rename(columns = {0:'Waypoint', 1:'Image_ID', 2: 'Image_Properties'}, inplace = True) 
image_ids = pd.concat([image_ids.drop(['Image_Properties'], axis=1), pd.json_normalize(image_ids['Image_Properties'])], axis=1)
joined_buffer_wgs84_drop_merge = pd.merge(joined_buffer_wgs84_drop, image_ids, on='Waypoint')


# In[31]:


# Converting list of tuple polygons to list of lists polygons
# This step is necessary to pull the Geometry from `joined_buffer_wgs84_drop_merge`
# and convert to a list of lists...appending to `joined_buffer_wgs84_drop_merge`.

def coord_lister(geom):
    coords = list(geom.exterior.coords)
    return (coords)

coordinates = joined_buffer_wgs84_drop_merge.polygon.apply(coord_lister)

res = []
for poly in coordinates:
    res_2 = list(map(list, poly)) 
    res.append(res_2)

joined_buffer_wgs84_drop_merge['poly_list'] = res
# joined_buffer_wgs84_drop_merge will be used as the basis for all remaining functions


# joined_buffer_wgs84_drop_merge['lat_lon_name'] = f'lat_{joined_buffer_wgs84_drop_merge["latitude"]}_long_{joined_buffer_wgs84_drop_merge["longitude"]}'
joined_buffer_wgs84_drop_merge['lat_lon_name'] = 'lat_'+joined_buffer_wgs84_drop_merge.latitude.map(str)+'_long_'+joined_buffer_wgs84_drop_merge.longitude.map(str)


joined_buffer_wgs84_drop_merge = joined_buffer_wgs84_drop_merge.sort_values(['lat_lon_name', 'updated'])     .drop_duplicates('lat_lon_name', keep='last')     .sort_index()

# joined_buffer_wgs84_drop_merge


# # Planet API Pull Function

# In[32]:


def upload_to_aws(local_file, s3_bucket, s3_file):
    s3 = boto3.client('s3')
    s3 = boto3.client('s3', aws_access_key_id=S3_ACCESS_KEY,
                      aws_secret_access_key=S3_SECRET_KEY)

    try:
        s3. upload_file(local_file, s3_bucket, s3_file)
        print("Upload Successful")
        return True
    except FileNotFoundError:
        print("The file was not found")
        return False
    except NoCredentialsError:
        print("Credentials not available")
        return False


# In[33]:


# Function to create the s3 key for the image of a given waypoint
def get_s3_key_for_image(waypoint_row, extension = 'tif'):
    return f"planet_images/test_conor/{waypoint_row['lat_lon_name']}/{waypoint_row['Image_ID']}_3B_AnalyticMS_SR_clip.{extension}"


# In[34]:


def s3_object_exists(Bucket, Key):
    try:
        s3_client = boto3.client('s3', aws_access_key_id=S3_ACCESS_KEY,
                          aws_secret_access_key=S3_SECRET_KEY)
        s3_client.head_object(Bucket=Bucket,
                              Key=Key)
        return True
    except:
        return False


# In[35]:


# Creating the url for clipping 
def place_order(request, auth, sleep_time=3):
    count = 0

    while True:

        try:
            response = requests.post(ORDERS_V2_URL, data=json.dumps(request), auth=auth, headers=HEADERS)
            order_id = response.json()['id']
            order_url = ORDERS_V2_URL + '/' + order_id
            break
        except:
            time.sleep(sleep_time) # used to rate limit requests
            count = count + 1
#             print(f'{(count - 1) * sleep_time}')
            continue

    return order_url


# In[36]:


def poll_for_success(order_url, auth, num_loops=100, sleep_time=10):
    count = 0
    state = ''

    while state not in ['success', 'partial', 'failed']:
        if count > 0:
            time.sleep(sleep_time) # used to rate limit requests
#             print(f'{(count - 1) * sleep_time}: {state}')

        r = requests.get(order_url, auth=auth)
        count += 1

        try:
            response = r.json()
        except:
            continue

        state = response['state']
        
    return response


# In[37]:


# def download_order(waypoint_row, auth, overwrite=False):
# # while loop with error handling instead?

#     print(waypoint_row)
#     c = 0
#     while True:
#         try:
#             response = poll_for_success(waypoint_row['order_url'], auth=auth)
#             break
#         except:
#             print(c)
#             time.sleep(20)
#             c = c+1
    
#     print(response['state'])
    
#     if response['state'] in ['success', 'partial']:

#         results = response['_links']['results']
#         results_urls = [r['location'] for r in results if '_3B_AnalyticMS_SR_clip.tif' in r['name']]
#         results_names = [r['name'] for r in results if '_3B_AnalyticMS_SR_clip.tif' in r['name']]

#         results_local_tif_path = [pathlib.Path(os.path.join('data', waypoint_row['lat_lon_name'], 
#                                                     f"{waypoint_row['Image_ID']}_3B_AnalyticMS_SR_clip.tif"))]
#         results_local_jpg_path = [pathlib.Path(os.path.join('data', waypoint_row['lat_lon_name'], 
#                                                     f"{waypoint_row['Image_ID']}_3B_AnalyticMS_SR_clip.jpg"))]
#         results_s3_tif_path = get_s3_key_for_image(waypoint_row, extension = 'tif')
#         results_s3_jpg_path = get_s3_key_for_image(waypoint_row, extension = 'jpg')


#         for url, name, local_tif_path, s3_tif_path, local_jpg_path, s3_jpg_path in zip(results_urls, results_names, 
#                                                           results_local_tif_path, results_s3_tif_path,
#                                                           results_local_jpg_path, results_s3_jpg_path):
#             if overwrite or not local_tif_path.exists():
#                 print(f'downloading {name} to {local_tif_path}')
#                 r = requests.get(url, allow_redirects=True)
#                 local_tif_path.parent.mkdir(parents=True, exist_ok=True)
#                 open(local_tif_path, 'wb').write(r.content)
                
#                 local_tif_file = os.path.relpath(local_tif_path)
#                 s3_tif_file = os.path.relpath(s3_tif_path)

#                 upload_to_aws(local_tif_file,
#                               S3_BUCKET,
#                               s3_tif_file)
                

#                 local_jpg_file = os.path.relpath(local_jpg_path)
#                 s3_jpg_file = os.path.relpath(s3_jpg_path)

#                 gdal.Translate(local_jpg_file, 
#                                local_tif_file,
#                                options=gdal_Translate_options_string)

#                 upload_to_aws(local_jpg_file,
#                               S3_BUCKET,
#                               s3_jpg_file)
                
#                 print(f'S3 Jpg exists: {s3_object_exists(Bucket=S3_BUCKET, Key=s3_jpg_file)}')

# #                 # Remove temp files
# #                 remove(local_jpg_file) 
# #                 remove(s3_jpg_file)

#     else:
#         print('download_failed')
#         results_s3_tif_path = 'download_failed'
    
#     return results_s3_tif_path


# In[38]:


def download_order(waypoint_row, auth, overwrite=False):
# while loop with error handling instead?

    print(waypoint_row)
    c = 0
    while True:
        try:
            response = poll_for_success(waypoint_row['order_url'], auth=auth)
            break
        except:
            print(c)
            time.sleep(20)
            c = c+1
    
    print(response['state'])
    
    if response['state'] in ['success', 'partial']:

        results = response['_links']['results']
        results_urls = [r['location'] for r in results if '_3B_AnalyticMS_SR_clip.tif' in r['name']][0]
        results_names = [r['name'] for r in results if '_3B_AnalyticMS_SR_clip.tif' in r['name']][0]

        results_local_tif_path = pathlib.Path(os.path.join('data', waypoint_row['lat_lon_name'], 
                                                    f"{waypoint_row['Image_ID']}_3B_AnalyticMS_SR_clip.tif"))
        results_local_jpg_path = pathlib.Path(os.path.join('data', waypoint_row['lat_lon_name'], 
                                                    f"{waypoint_row['Image_ID']}_3B_AnalyticMS_SR_clip.jpg"))
        results_s3_tif_path = get_s3_key_for_image(waypoint_row, extension = 'tif')
        results_s3_jpg_path = get_s3_key_for_image(waypoint_row, extension = 'jpg')

           
        if overwrite or not results_local_tif_path.exists():
            print(f'downloading {results_names} to {results_local_tif_path}')
            r = requests.get(results_urls, allow_redirects=True)
            results_local_tif_path.parent.mkdir(parents=True, exist_ok=True)
            open(results_local_tif_path, 'wb').write(r.content)

            local_tif_file = os.path.relpath(results_local_tif_path)
            s3_tif_file = os.path.relpath(results_s3_tif_path)

            upload_to_aws(local_tif_file,
                          S3_BUCKET,
                          s3_tif_file)


            local_jpg_file = os.path.relpath(results_local_jpg_path)
            s3_jpg_file = os.path.relpath(results_s3_jpg_path)
            print(f'S3 Jpg file: {s3_jpg_file}')

            gdal.Translate(local_jpg_file, 
                           local_tif_file,
                           options=gdal_Translate_options_string)

            upload_to_aws(local_jpg_file,
                          S3_BUCKET,
                          s3_jpg_file)

            print(f'Bucket: {S3_BUCKET}')
            print(f'key: {s3_jpg_file}')
            print(f'S3 Jpg exists: {s3_object_exists(Bucket=S3_BUCKET, Key=s3_jpg_file)}')

#                 # Remove temp files
#                 remove(local_jpg_file) 
#                 remove(s3_jpg_file)

    else:
        print('download_failed')
        results_s3_tif_path = 'download_failed'
    
    return results_s3_tif_path


# In[39]:


# Function goes here.  First step: identify image, polygon, and ro

def planet_api_pull(waypoint_row, overwrite = False):
    
    results_s3_path = get_s3_key_for_image(waypoint_row)
    print(results_s3_path)

    if overwrite or not s3_object_exists(Bucket=S3_BUCKET, Key=results_s3_path):
        
        # Creating the URLs to activate the images...prevents latency during download
        waypoint_row['id0_url'] = f"https://api.planet.com/data/v1/item-types/{item_type}/items/{waypoint_row['Image_ID']}/assets"


        # Returns JSON metadata for assets in this ID. 
        # Learn more: planet.com/docs/reference/data-api/items-assets/#asset
        waypoint_row['activation_link'] =               requests.get(
                waypoint_row['id0_url'], #link
                auth=HTTPBasicAuth(PLANET_API_KEY, '')
              )


        # Getting Result Links
        waypoint_row['links'] = waypoint_row['activation_link'].json()[u"analytic_sr"]["_links"]


        # Generating a list of activation links    
        waypoint_row['activation_link'] = waypoint_row['links']["activate"]


        # Request activation of the 'visual' asset:
        # for a in joined_buffer_wgs84_drop_merge['activation_link']:
        activate_result =         requests.get(waypoint_row['activation_link'],                      auth=HTTPBasicAuth(PLANET_API_KEY, ''))


        # Building the order lists starting with the product information
        waypoint_row['single_product'] = [
                {
                  'item_ids': [waypoint_row['Image_ID']], 
                  'item_type': 'PSScene4Band',
                  'product_bundle': 'analytic_sr'
                }
            ]


        # Setting the clipping boundaries
        waypoint_row['clip'] = [{
            'clip': {
                'aoi': {
                    'type':'Polygon',
                    'coordinates': [waypoint_row['poly_list']] 
                }
            }
        }]


        # create an order request with the clipping tool
        waypoint_row['request_clip'] = {
            'name': 'just clip',
            'products': waypoint_row['single_product'], #single_product,
            'tools': waypoint_row['clip']
        }
        
        print(waypoint_row)



        print('Placing Order')
        # Place the Order
        waypoint_row['order_url'] = place_order(waypoint_row['request_clip'], auth)

        print('Downloading Order')

        # Downloading the orders
        waypoint_row['results_s3_path'] = download_order(waypoint_row, auth, overwrite)

    else:
        print(f'{s3_tif_path} already exists, skipping {s3_tif_path}')
        waypoint_row['results_s3_path'] = [results_s3_path]

    print(waypoint_row)
    return waypoint_row


# # Get Images

# In[40]:


# joined_buffer_wgs84_drop_merge


# In[41]:


# # For Loop 
# results_df = pd.DataFrame()
# for index,waypoint_row in joined_buffer_wgs84_drop_merge.iterrows():
#     print(waypoint_row.Waypoint, waypoint_row.lat_lon_name)
# #     waypoint_row = joined_buffer_wgs84_drop_merge.loc[0]


# In[42]:


# For Loop 
results_df = pd.DataFrame()

for index,waypoint_row in joined_buffer_wgs84_drop_merge.iterrows():
#     print(waypoint_row.Waypoint, waypoint_row.lat_lon_name)

    row = planet_api_pull(waypoint_row, overwrite = False)
#     print('planet_api_pull complete!')

    results_df = results_df.append(row)


# In[43]:


# pathlib.Path(os.path.join('data'))


# In[44]:


# results_df[['Waypoint', 'latitude', 'longitude', 'results_s3_path']]


# In[45]:


results_df[['Waypoint', 'latitude', 'longitude', 'acquired', 'results_s3_path']].to_csv(pathlib.Path(os.path.join('data/results.csv')))
results_df.to_csv(pathlib.Path(os.path.join('data/results_all_cols.csv')))


# In[46]:


# results_df


# In[ ]:





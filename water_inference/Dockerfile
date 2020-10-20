FROM tiangolo/uwsgi-nginx-flask:python3.7


RUN apt-get update 
#RUN apt-get install -y binutils libproj-dev gdal-bin

RUN apt-get install -y vim gdal-bin libgdal-dev
ARG CPLUS_INCLUDE_PATH=/usr/include/gdal
ARG C_INCLUDE_PATH=/usr/include/gdal

RUN pip install timm flask-restplus==0.12.1 boto3==1.12.26 torch==1.2.0 torchvision==0.4.0 Pillow==6.1 GDAL==2.0.1 rasterio rasterio[s3]

COPY ./app /app

WORKDIR /app

RUN mkdir tmp

EXPOSE 80

#RUN pip install -r requirements.txt

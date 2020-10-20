### Re:Source - Water Detection in the Serengeti-Mara Ecosystem

Drought has the propensity to permanently alter valuable ecosystems, threaten the lives of both humans and wildlife, and can drastically alter the economic stability of a region. Such a scenario has been a perennial threat to the Serengeti National Park and its outer-lying regions. As a response, researchers venture into the field, facing unforeseen dangers, to collect valuable water data, while park rangers and volunteers keep animals hydrated by routinely distributing water to various locations within the 12,000 square mile park.

Re:Source, uses near-daily satellite imagery and the latest in computer vision to identify water availability in ponds and lakes, streams and rivers, especially for locations where water is needed but information is scarce. Access to this data enables park rangers and land managers to plan their expeditions and respond to ground conditions, without having to trek days into the wilderness. Additionally, the resulting data is displayed on an interactive map that provides a valuable resource for researchers and conservationists whose aim is to identify and respond to drought conditions.

The platform covers 11 target water sources that have high variability in water availability.


### Methodology

Leveraging near-daily 3 meter resolution, 4 band satellite images, Re:Source uses machine learning-based predictive models to estimate the availability of water.

The colors on the map show the availability of water at the target water sources, and selection of each water sources provides details of the percentage likelihood of water availability, along with some information about the age and clarity of the image we used to identify water at that location.  


### Training data: PlanetScope satellite imagery

Both the predictive model and the near-daily water predictions are powered by images obtained from Planet Labs [PlanetScope](https://www.planet.com/products/planet-imagery/) satellite images. The predictive model was trained on:

+ 5.8k images of the Serengeti-Mara Ecosystem that were manually annotated by the Re:Source team.
+ 40.5k images of the Amazon that were adapted from existing datasets posted to [Kaggle](https://www.kaggle.com/c/planet-understanding-the-amazon-from-space)
+ 4.9k images of Australia that were adapted from existing datasets posted to [Mendeley](https://data.mendeley.com/datasets/6gdybpjnwh/1)

The overall distribution of the training data was 80.6% No Water and 19.3% Water (there are lots of places in the Serengeti where water is not available)

For the manually annotatation of the Serengeti-Mara Ecosystem dataset, we used the [Figure 8](https://www.figure-eight.com/) platform.


### Modeling

We developed our models using PyTorch for the training and the Weights and Biases plugin to track our progress. In terms of models, we leveraged [Mixnet](https://github.com/tensorflow/tpu/tree/master/models/official/mnasnet/mixnet), a novel algorithm published by google in Dec 2019. The advantages of Mixnet over prior algorithms is that it can deliver comparative performance with fewer parameters. One of its main features that allows it to do this is that it uses variable kernel sizes which allow the capture of both macroscopic and microscopic details.

#### Model Evaluation

| Data  | Metric | ResNet-18 | MixNet_L
| ----- | ------ | --------- | --------
| Train | Prec.  | 0.822     | 0.869
|       | Recall | 0.411     | 0.778
|       | F1     | 0.549     | 0.821
| Val   | Prec   | 0.826     | 0.743
|       | Recall | 0.496     | 0.715
|       | F1     | 0.620     | 0.729



### Ongoing water identification and prediction

On a daily basis, the Re:Source platform downloads new images taken by the PlanetScope satellites, and, as needed by users, runs the images through the model prediction algorithm to identify the likelihood of surface water being present. The pipeline from satellite image to water prediction identified on the map is automated, giving our users the fastest-possible access to information from the field.

Due to the nature of the PlanetScope platform, new images are available near-daily.  PlanetScope satellites do not pass over the Serengeti-Mara Ecosystem every day, and clouds or other atmospheric obstructions restrict the availability and predictive value of images on some days.


### Infrastructure, API Framework, and Web Application

#### Infrastructure

We leverage AWS suite of tools for the development of this project. Primarily, we rely heavily on GPU-enabled EC2 instances as well as S3 storage buckets. The former served as our main VM for developing models, hosting services, and running automated scripts. The latter is where we stored and retrieved our data for development. The automated API call script to download new images is deployed to and runs daily as a cron job on an EC2 instance. 
  
#### API Framework

We use a RESTful framework to access model predictions. Particularly, a Python-Flask service was built around the final model which was then containerized and hosted in a docker container on an EC2 instance.

#### Web Application

The user interface (UI) was built using an [RShiny](https://shiny.rstudio.com/) framework which uses Shinyjs, an R-based javascript wrapper around javascript, to call and present the data in a dynamic and easy to use manner. The UI was also hosted via a docker container on an EC2 instance, which was assigned a fixed DNS hostname using AWS Route53 to allow for ease of access.



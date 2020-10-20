sudo rm -rf ./resource
sudo mkdir /resource

sudo cp -r ~/capstone_final_pct_water/shiny_resource/ ~/capstone_final_pct_water/docker_images/shiny_app/resource
sudo docker build -t shiny_app .

sudo docker run -d -p 7681:7681 -p 3838:3838 shiny_app



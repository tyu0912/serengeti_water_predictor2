FROM rocker/shiny-verse

RUN sudo apt -y update
RUN sudo apt -y upgrade
RUN sudo apt-get install -y libgdal-dev libproj-dev

RUN mkdir /resource
RUN mkdir /utils

COPY resource /resource
COPY utils /utils

RUN sudo /utils/rpkginstall.sh leaflet 
RUN sudo /utils/rpkginstall.sh formattable
RUN sudo /utils/rpkginstall.sh shiny
RUN sudo /utils/rpkginstall.sh shinythemes
RUN sudo /utils/rpkginstall.sh tidyverse
RUN sudo /utils/rpkginstall.sh data.table
RUN sudo /utils/rpkginstall.sh httr
RUN sudo /utils/rpkginstall.sh shinyjs
RUN sudo /utils/rpkginstall.sh rgdal

COPY run.R /resource

EXPOSE 7681 
EXPOSE 3838

WORKDIR /resource

CMD ["Rscript", "run.R"]

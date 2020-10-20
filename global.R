library(tidyverse)
library(leaflet)
library(httr)
library(rgdal)

if (getwd() == "/Users/piper/Desktop/capstone_final_pct_water") {
  setwd('./shiny_resource/')
}
# getwd()

# API Waypoint URL
url <- 'http://3.232.40.91/api/v1/waypoint' #prod api

initial_selection <- 'Talek River'

#Load Data for the Water Reports
path_to_data <-  './data/'

post_date = Sys.Date()
post_date_filter <- Sys.Date()

# serengeti_wpts_prediction_log <- read_rds(paste0(path_to_data, 'serengeti_national_park_demo.rds'))
serengeti_wpts_prediction_log <- read_rds(paste0(path_to_data, 'serengeti_national_park.rds'))

# serengeti_wpts_prediction_log <- serengeti_wpts_prediction_log %>%
#   mutate(probability_of_class = probability,
#          probability = if_else(class == 'Water', probability, 1-probability),
#          prediction = case_when(
#            probability > 0.85 ~ "Water",
#            probability > 0.55 ~ "Likely Water",
#            probability > 0.45 ~ "Uncertain",
#            probability > 0.15 ~ "Unlikely Water",
#            TRUE               ~ 'No Water'
#          ),
#          color = case_when(
#            probability > 0.85 ~ '#1F618D', #steel blue / Water
#            probability > 0.55 ~ '#2980B9', #light blue / Likely Water
#            probability > 0.45 ~ '#555555', #grey / Uncertain
#            probability > 0.15 ~ '#CD6155', #pink / Unlikely Water
#            TRUE               ~ '#943126' #red / No Water             
#          )
#   ) %>%
#   select(Location:status, probability_of_class, class, probability, post_date:prediction, iconUrl, everything()) #%>%
#   View()


serengeti_wpts_deduped <-
  serengeti_wpts_prediction_log %>%
  arrange(Location, rev(acquired)) %>%
  distinct(Location_Unique, .keep_all = TRUE) %>%
  mutate(choice = paste0('<font color="', color, '"><strong>&#9724;&nbsp;', Location_Unique, '</strong></font>')
                      
         )

wpts_to_get <- serengeti_wpts_deduped %>% 
  filter(post_date < post_date_filter) %>% 
  .$Location_Unique

for (waypoint in wpts_to_get) {

  post_body <- filter(serengeti_wpts_deduped, Location_Unique %in% waypoint) %>%
    select(lat = Lat, long = Long, name = Location) %>%
    mutate(date = as.character(post_date)) %>%
    as.list(.) %>%
    jsonlite::toJSON(., auto_unbox = TRUE, digits = 6)
  
  post_content <- list(status = 'API Problem')
  

  post_content <- content(POST(url, body = post_body, encode = "raw"), as="parsed")

  if (post_content$status == 'success') {
    
    post_date = Sys.Date()
    
    test_post <-
      as_tibble(post_content$data) %>%
      mutate(status = post_content$status,
             probability_of_class = as.numeric(post_content$probability),
             class = post_content$class,
             probability = if_else(class == 'Water', probability_of_class, 1-probability_of_class),
             post_date = post_date,
             prediction = case_when(
               probability > 0.85 ~ "Water",
               probability > 0.55 ~ "Likely Water",
               probability > 0.45 ~ "Uncertain",
               probability > 0.15 ~ "Unlikely Water",
               TRUE ~ 'No Water'
             ),
             color = case_when(
               probability > 0.85 ~ '#1F618D', #steel blue / Water
               probability > 0.55 ~ '#2980B9', #light blue / Likely Water
               probability > 0.45 ~ '#555555', #grey / Uncertain
               probability > 0.15 ~ '#CD6155', #pink / Unlikely Water
               TRUE ~ '#943126' #red / No Water
               ),
             acquired = lubridate::as_datetime(acquired)
      ) %>%
      select(status:color, everything())
    serengeti_wpts_prediction_log <-
      serengeti_wpts_deduped %>%
      select(Location:lat_lon_name) %>%
      inner_join(test_post, by = c('lat_lon_name' = 'lat_lon_name')) %>%
      mutate(choice = paste0('<font color="', color, '"><strong>&#9724;&nbsp;', Location_Unique, '</strong></font>')) %>% 
      bind_rows(serengeti_wpts_prediction_log)
  }
}
  
serengeti_wpts_deduped <-
  serengeti_wpts_prediction_log %>%
  arrange(Location, rev(acquired)) %>%
  distinct(Location_Unique, .keep_all = TRUE) %>% 
  mutate(choice = map(paste0('<font color="', color, '"><strong>&#9724;&nbsp;', Location_Unique, '</strong></font>'),
                      HTML)
         )


# serengeti_wpts_prediction_log <- serengeti_wpts_prediction_log %>%
#   mutate(  color = case_when(
#     probability <= 0.55 ~ '#555555', #red / It's not clear
#     class == 'Water' & probability > 0.85 ~ '#1F618D', #steel blue / Highly likely that there's water
#     class == 'Water' & probability <= 0.85 ~ '#2980B9', #light blue / Probably water
#     class != 'Water' & probability > 0.85 ~ '#943126', #black / Highly likely that there's no water
#     TRUE ~ '#CD6155', #grey / Probably no water
#   ))
# choice = paste0('<font color="', color, '"><strong>&#9724;&nbsp;', Location_Unique, '</strong></font>'))

write_rds(serengeti_wpts_prediction_log, paste0(path_to_data, 'serengeti_national_park.rds'))
write_csv(serengeti_wpts_prediction_log, paste0(path_to_data, 'serengeti_national_park.csv'))

 
# test <- serengeti_wpts_deduped %>%
#   transmute(choice = paste0('<font color="', color, '"><strong>&#9724;&nbsp;', Location_Unique, '&nbsp;&#9724;</strong></font>'),
#             choice2 = map(paste0('<font color="', color, '"><strong>&#9724;&nbsp;', Location_Unique, '</strong></font>'), HTML))
# transmute(choice = paste0('<font color="', color, '"><strong>&#x1f4a7;&nbsp;', Location_Unique, '&nbsp;&#128167;</strong></font>'))
# test <- map(test$choice, HTML)


legend <- tibble(
  probability = c(1, .8, .5, .2, 0),
  class = c('Water', 'Water', 'Water', 'No Water', 'No Water')) %>% 
    mutate(
      prediction = case_when(
        probability > 0.85 ~ "Water",
        probability > 0.55 ~ "Likely Water",
        probability > 0.45 ~ "Uncertain",
        probability > 0.15 ~ "Unlikely Water",
        TRUE ~ 'No Water'
      ),
      color = case_when(
        probability > 0.85 ~ '#1F618D', #steel blue / Water
        probability > 0.55 ~ '#2980B9', #light blue / Likely Water
        probability > 0.45 ~ '#555555', #grey / Uncertain
        probability > 0.15 ~ '#CD6155', #pink / Unlikely Water
        TRUE ~ '#943126' #red / No Water             
      )
    ) %>%
  transmute(legend = paste0('<font color="', color, '"><strong>&nbsp;&#9724;&nbsp;', prediction, '&nbsp;</strong></font>'))

# 
# test2 = list()
# 
# for (i in 1:length(test)) {
#   test2[i] = HTML(test[i])
# }
# 
# test3 <- lapply(test, HTML, use.names=FALSE)


circle_markers <- serengeti_wpts_deduped %>% 
  mutate(
    icon_color = case_when(
      probability > 0.85 ~ 'darkblue', #steel blue / Water
      probability > 0.55 ~ 'lightblue', #light blue / Likely Water
      probability > 0.45 ~ 'gray', #grey / Uncertain
      probability > 0.15 ~ 'lightred', #pink / Unlikely Water
      TRUE ~ 'darkred' #red / No Water             
    ),
  #   icon = awesomeIcons(
  #     icon = 'fa-tint',
  #     iconColor = icon_color,
  #     library = 'fa',
  #     markerColor = "white"
  #     # circle_markers$color %>% str_remove('#')
  # )
  ) %>% 
  select(Location_Unique, Lat, Long, color, choice, icon_color, prediction, probability, shadow_percent, cloud_cover, acquired)







icons = awesomeIcons(
  # icon = 'fa-satellite',
  icon = 'fa-tint',
  # iconColor = serengeti_wpts_deduped$color,
  iconColor = c("red", "darkred", "lightred", "blue", "darkblue", "lightblue", "cadetblue"),
  library = 'fa',
  markerColor = "white"
  # circle_markers$color %>% str_remove('#')
  )

# icons <- makeIcon(
#   iconUrl = 'images/FP_Satellite_icon/256px-FP_Satellite_icon.svg.png',
#   # iconUrl = serengeti_wpts_deduped$iconUrl,
#   iconWidth = 64, iconHeight = 64,
#   iconAnchorX = -5, iconAnchorY = 69
#   # shadowUrl = "http://leafletjs.com/examples/custom-icons/leaf-shadow.png",
#   # shadowWidth = 50, shadowHeight = 64,
#   # shadowAnchorX = 4, shadowAnchorY = 62
# )
# <a title="Maxxl² / CC BY-SA (https://creativecommons.org/licenses/by-sa/3.0)" href="https://commons.wikimedia.org/wiki/File:FP_Satellite_icon.svg"><img width="64" alt="FP Satellite icon" src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/FP_Satellite_icon.svg/64px-FP_Satellite_icon.svg.png"></a>


# serengeti <- readOGR("./data/v3_serengeti_ecosystem_merged/v3_serengeti_ecosystem_merged.shp",
#                             layer = "v3_serengeti_ecosystem_merged", 
#                             GDAL1_integer64_policy = TRUE)
# serengeti %>% write_rds('./data/v3_serengeti_ecosystem_merged/v3_serengeti_ecosystem_merged.shp.rds')

# serengeti_latlon <- spTransform(serengeti, CRS("+proj=longlat +datum=WGS84"))
# serengeti_latlon %>% write_rds('./data/v3_serengeti_ecosystem_merged/serengeti_latlon.rds')
# 
serengeti_latlon <- read_rds('./data/v3_serengeti_ecosystem_merged/serengeti_latlon.rds')







#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(httr)
library(tidyverse)
library(formattable)
# library(raster)



# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  
  ## Interactive Map ###########################################
  
  # Create the map
  output$map <- renderLeaflet({
    # circle_markers <- serengeti_wpts_deduped %>% select(Location_Unique, Lat, Long, color)
    target_marker <- circle_markers %>% filter(Location_Unique %in% input$waypoint)
    target_marker_icon <- awesomeIcons(
      icon = 'fa-tint',
      iconColor = target_marker$color,
      library = 'fa',
      markerColor = "white"
    )
    # serengeti <- rgdal::readOGR("./data/Serengeti_Ecosystem/v3_serengeti_ecosystem.shp",
    #                             layer = "v3_serengeti_ecosystem", 
    #                             GDAL1_integer64_policy = TRUE)
    # 
    # serengeti_latlon <- spTransform(serengeti, CRS("+proj=longlat +datum=WGS84"))
    # 
    # 
    
    leaflet() %>%
      addProviderTiles(providers$OpenTopoMap,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      setView(lng = 35.289331	, lat = -2.526037, zoom = 8) %>%
      addPolygons(data = serengeti_latlon, color = "white", weight = 4, smoothFactor = 0.9,
                  opacity = 1.0, fillOpacity = 0.0 #,
                  # highlightOptions = highlightOptions(color = "#ef6c00", weight = 2,
                  #                                     bringToFront = TRUE)
      ) %>% 
      addCircleMarkers(
        data = circle_markers,
        radius = 9,
        color = circle_markers$color,
        stroke = FALSE, 
        fillOpacity = .6
      ) %>%
      addCircleMarkers(
        data = circle_markers,
        radius = 5,
        color = circle_markers$color,
        stroke = FALSE, fillOpacity = 1
      ) %>%
      addCircleMarkers(
        data = circle_markers,
        radius = 10,
        color = 'white',
        weight = 2,
        fill = FALSE,
        opacity = 1,
        stroke = TRUE
      ) %>%
      addCircleMarkers(
        data = circle_markers,
        radius = 10,
        color = 'white',
        weight = 2,
        fill = TRUE,
        opacity = 0,
        stroke = TRUE,
        popup = ~paste0(
          '<font color="#ef6c00"><strong>&nbsp;Water Source: ', circle_markers$Location, '&nbsp;</font></strong>',
          # '<br><strong><font color="#ef6c00">&nbsp;Waypoint: </font><font color="', circle_markers$color, '">&nbsp;', circle_markers$Location, '&nbsp;</font></strong>',
          '<br>&nbsp;Status: &nbsp;<font color="', circle_markers$color, '"><strong>&nbsp;&#9724;&nbsp;', circle_markers$prediction, '&nbsp;</strong></font>',
          '<br>&nbsp;Model Probability: <font color="', circle_markers$color, '"><strong>', percent(circle_markers$probability, digits = 0), '&nbsp;chance of Water</strong></font>',
          '<br>&nbsp;Shadow Percent: <font color="', circle_markers$color, '"><strong>', percent(as.numeric(circle_markers$shadow_percent)/100, digits = 0), '</strong></font>',
          '<br>&nbsp;Image Cloud Cover: <font color="', circle_markers$color, '"><strong>',  percent(circle_markers$cloud_cover, digits = 0), '</strong></font>',
          '<br>&nbsp;As of: <strong>', as.character(circle_markers$acquired), '</strong>'
        ),
        label = circle_markers$choice
      ) %>%
      # addMarkers(data = target_marker, label = target_marker$choice)
      # addMarkers(data = target_marker, icon=icons, label= target_marker$choice) #%>%
      addAwesomeMarkers(data = target_marker, icon = target_marker_icon, label= target_marker$choice,
                        popup = ~paste0(
                          '<font color="#ef6c00"><strong>&nbsp;Water Source: ', target_marker$Location, '&nbsp;</font></strong>',
                          # '<br><strong><font color="#ef6c00">&nbsp;Waypoint: </font><font color="', target_marker$color, '">&nbsp;', target_marker$Location, '&nbsp;</font></strong>',
                          '<br>&nbsp;Status: &nbsp;<font color="', target_marker$color, '"><strong>&nbsp;&#9724;&nbsp;', target_marker$prediction, '&nbsp;</strong></font>',
                          '<br>&nbsp;Model Probability: <font color="', target_marker$color, '"><strong>', percent(target_marker$probability, digits = 0), '&nbsp;chance of Water</strong></font>',
                          '<br>&nbsp;Shadow Percent: <font color="', target_marker$color, '"><strong>', percent(as.numeric(target_marker$shadow_percent)/100, digits = 0), '</strong></font>',
                          '<br>&nbsp;Image Cloud Cover: <font color="', target_marker$color, '"><strong>',  percent(target_marker$cloud_cover, digits = 0), '</strong></font>',
                          '<br>&nbsp;As of: <strong>', as.character(target_marker$acquired), '</strong>'
                        )
      )
    
    
    
    
    
    
  })
  
  output$api_post <- renderText({
    
    waypoint <- if_else(is.na(input$waypoint), initial_selection, input$waypoint)
    # waypoint <- initial_selection
    serengeti_waypoint <- 
      serengeti_wpts_deduped %>% 
      filter(Location_Unique == waypoint)
    
    paste0(
      '<font color="#ef6c00"><strong>&nbsp;Water Source: ', serengeti_waypoint$Location, '&nbsp;</font></strong>',
      # '<br><strong><font color="#ef6c00">&nbsp;Waypoint: </font><font color="', serengeti_waypoint$color, '">&nbsp;', serengeti_waypoint$Location, '&nbsp;</font></strong>',
      '<br>&nbsp;Status: &nbsp;<font color="', serengeti_waypoint$color, '"><strong>&nbsp;&#9724;&nbsp;', serengeti_waypoint$prediction, '&nbsp;</strong></font>',
      '<br>&nbsp;Model Probability: <font color="', serengeti_waypoint$color, '"><strong>', percent(serengeti_waypoint$probability, digits = 0), '&nbsp;chance of Water</strong></font>',
      '<br>&nbsp;Shadow Percent: <font color="', serengeti_waypoint$color, '"><strong>', percent(as.numeric(serengeti_waypoint$shadow_percent)/100, digits = 0), '</strong></font>',
      '<br>&nbsp;Image Cloud Cover: <font color="', serengeti_waypoint$color, '"><strong>',  percent(serengeti_waypoint$cloud_cover, digits = 0), '</strong></font>',
      '<br>&nbsp;As of: <strong>', as.character(serengeti_waypoint$acquired), '</strong>'
    )
    
    
    # paste0(
    #   '<font color="#ef6c00"><strong>&nbsp;Waypoint: ', serengeti_waypoint$Location, '&nbsp;</font>',
    #   '</strong><br>&nbsp;As of: ', as.character(serengeti_waypoint$acquired),
    #   '<br><br>&nbsp;Status: ',
    #   '<br>&nbsp;', serengeti_waypoint$prediction,
    #   '<br><br>&nbsp;The model says: ',
    #   '<br>&nbsp;Probability: ', percent(serengeti_waypoint$probability, digits = 0),
    #   '<br>&nbsp;Class: ', serengeti_waypoint$class ,
    #   '<br>&nbsp;Status: ', serengeti_waypoint$status #,
    # post_status
    # )
    
  })
  
  observeEvent(input$hide_controls, {
    shinyjs::toggle("inputs", anim = TRUE)
    shinyjs::toggle("legend", anim = TRUE)
    shinyjs::toggle("show_controls", anim = FALSE)
  })
  
  observeEvent(input$show_controls, {
    shinyjs::toggle("inputs", anim = TRUE)
    shinyjs::toggle("legend", anim = TRUE)
    shinyjs::toggle("show_controls", anim = FALSE)
  })
  
  # Create the map
  output$tiny_map <- renderLeaflet({

    leaflet() %>%
      addProviderTiles(providers$OpenTopoMap,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      setView(lng = 34.689331	, lat = -2.526037, zoom = 8) %>%
      addCircleMarkers(
        data = circle_markers,
        radius = 9,
        color = circle_markers$color,
        stroke = FALSE, fillOpacity = .6
      ) %>%
      addCircleMarkers(
        data = circle_markers,
        radius = 5,
        color = circle_markers$color,
        stroke = FALSE, fillOpacity = 1
      ) %>%
      addCircleMarkers(
        data = circle_markers,
        radius = 10,
        color = 'black',
        weight = 1,
        fill = FALSE,
        opacity = 1,
        stroke = TRUE
      ) %>%
      addPolygons(data = serengeti_latlon, color = "#555555", weight = 3, smoothFactor = 0.9,
                  opacity = 1.0, fillOpacity = 0.0 #,
      )
    
    
  })  
  
})

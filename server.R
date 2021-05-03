# Server
# Keaton Wilson & Noah Giebink
# keatonwilson@me.com
# nwgiebink@gmail.com
# 2021-02-02

library(shiny)
library(leaflet)
library(leaflet.extras)
library(ggmap)


# Sourcing Scripts --------------------------------------------------------
source("./scripts/make_selection_map.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {


# Map Panel to Make Location Selection ------------------------------------
output$selection_map = renderLeaflet({
  make_selection_map()
})


# Grabbing Labels ---------------------------------------------------------

observeEvent(input$selection_map_marker_click, {
  click = input$selection_map_marker_click
  print(click)
  
  if(is.null(click))
    return()
  
  #pulls lat and lon from shiny click event
  lat <- click$lat
  lon <- click$lng
  
  selected = data.frame(lat = lat, lon = lon, layerId = "Selected")
  
  # leaflet proxy
  proxy <- leafletProxy("selection_map")
  if(click$id == "Selected"){
    proxy %>% removeShape(layerId = "Selected")
  } else {
    proxy %>% addCircleMarkers(data = selected, 
                               ~lon, ~lat,
                               radius = 6,
                               stroke = FALSE,
                               fillColor = "yellow",
                               fillOpacity = 0.8,
                               opacity = 0.5, 
                               layerId = "Selected"
    )
  }
})


# Filtering Simulation Data based on Clicked Point ----------------------------

# to_listen = reactive({
#   list(input$selection_map_marker_click, 
#        input$depth, 
#        input$season)
# })
# filtered_data = observeEvent(to_listen(), {
#                                
#                                if(!is.null(input$selection_map_marker_click)) {
#                                  # season filter
#                                  data = if(input$season == "Fall") {
#                                    read_csv("./data/autumn_data_downsampled.csv")
#                                  } else if (input$season == "Summer") {
#                                    read_csv("./data/summer_data_downsampled.csv")
#                                  } else {
#                                    read_csv("./data/spring_downsampled_6hours.csv")
#                                  }
#                                  
#                                  # depth filter
#                                  data = if(input$depth == "Mid-Water Depth") {
#                                    data %>% filter(str_detect(replicate, "MWD"))
#                                  } else {
#                                    data %>% filter(str_detect(replicate, "surface"))
#                                  }
#                                  
#                                  # site filter
#                                  data = data %>% 
#                                    filter(site == input$selection_map_marker_click$site)
#                                  
#                                  return(data)
#                                }
#   
# })


# Map Panel to View Simulation --------------------------------------------

# Base Simulation Map with Starting point
output$simulation_map = renderLeaflet({
  leaflet(spring_data_test_site %>% 
            filter(position == 1)) %>%
    addTiles() %>%
    addCircleMarkers(lng = ~lon, 
                     lat = ~lat, 
                     radius = 1, 
                     layerId = ~ site
                     )
})

# Updating Map as Simulation Progresses with leaflet Proxy
observe({
  spring_data_test_site = filtered_sim_data()
  leafletProxy("simulation_map", data = spring_data_test_site) %>%
    clearMarkers() %>%
    addCircleMarkers(lng = ~lon, 
                     lat = ~lat, 
                     radius = 1
    ) %>%
    flyToBounds(min(spring_data_test_site$lon), 
              min(spring_data_test_site$lat), 
              max(spring_data_test_site$lon), 
              max(spring_data_test_site$lat), 
              options = list(duration = 0.5)
              )
    
  
})

# Filter Data Based on Animation Map Selection -------------------------------------------------------------
#filter data depending on selected date
filtered_sim_data <- reactive({
  req(input$date_selector)
  spring_data_test_site %>%
    filter(date == input$date_selector)
})


# Map Panel to View Density Maps --------------------------------------------

# Hex Density Maps with Leaflet
output$density_map = renderLeaflet({
  leaflet(spring_data_test_site %>%
            rename(lng = lon) %>%
            filter(lat != 0)) %>%
    addTiles() %>%
    # leaflethex::addHexbin(
    #   opacity = 0.5,
    #   radius = 20, 
    #   lowEndColor = "darkblue", 
    #   highEndColor="yellow", 
    #   uniformSize = TRUE)
    addHeatmap(minOpacity = 0.01, cellSize = 15, max = 0.01, radius = 15, blur = 35)
})

# Hex Density Maps with Leaflet

world = map_data("world")
output$gg_density_map = renderPlot({
  ggplot(spring_data_test_site, aes(x = lon, y = lat)) +
    geom_map(
      data = world, map = world,
      aes(long, lat, map_id = region), 
      color = "black", 
      fill = "lightgray", 
      size = 0.1
    ) +
    geom_bin2d(bins = 1500, alpha = 0.8) +
    coord_map(xlim = c(-11, 3), ylim = c(50, 57))
})

})



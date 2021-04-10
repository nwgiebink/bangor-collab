# Server
# Keaton Wilson & Noah Giebink
# keatonwilson@me.com
# nwgiebink@gmail.com
# 2021-02-02

library(shiny)
library(leaflet)


# Sourcing Scripts --------------------------------------------------------
source("./scripts/make_selection_map.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {


# Map Panel to Make Location Selection ------------------------------------
output$selection_map = renderLeaflet({
  make_selection_map(data=spring_small)
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

# Filtering Data based on selections
to_listen = reactive({
  list(input$selection_map_marker_click, 
       input$depth, 
       input$season)
})
filtered_data = observeEvent(to_listen(), {
                               
                               if(!is.null(input$selection_map_marker_lick)) {
                                 # season filter
                                 data = if(input$season == "Fall") {
                                   read_csv("./data/autumn_data_downsampled.csv")
                                 } else if (input$season == "Summer") {
                                   read_csv("./data/summer_data_downsampled.csv")
                                 } else {
                                   read_csv("./data/spring_data_downsampled.csv")
                                 }
                                 
                                 # depth filter
                                 data = if(input$depth == "Mid-Water Depth") {
                                   data %>% filter(str_detect(replicate, "MWD"))
                                 } else {
                                   data %>% filter(str_detect(replicate, "surface"))
                                 }
                                 
                                 # site filter
                                 data = data %>% 
                                   filter(site == input$selection_map_marker_click$site)
                                 
                                 return(data)
                               }
  
})


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


})

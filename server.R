# Server
# Keaton Wilson & Noah Giebink
# keatonwilson@me.com
# nwgiebink@gmail.com
# 2021-02-02

library(shiny)
library(leaflet)
library(leaflet.extras)
library(ggmap)
library(shinybusy)


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

reactive_data = reactiveValues()

 observeEvent(input$load_data, {

     if(!is.null(input$selection_map_marker_click)) {
        
         show_modal_spinner(text = "Loading and filtering simulation data")
       
         season = if(input$season == "Autumn") {
           "autumn" 
         } else if(input$season == "Summer") {
           "summer"
         } else if(input$season == "Spring") {
           "spring"
         }
         
         depth = if(input$depth == "Surface") {
           "surface"
         } else if(input$depth == "Mid-water Depth") {
           "mwd"
         }
         
         file_string = paste0("./data/", season, "_", depth, "_downsampled.csv")
         
         # position math
         end_position = input$window*24
         
         # grabbing data
         all_data = read_csv(file_string)
         
         # site filter - and filtering out spurious lat 0º Data
         reactive_data$filtered_data = all_data %>%
           filter(site == input$selection_map_marker_click$id) %>%
           filter(lat != 0) %>%
           filter(position <= end_position)
       
         updateSliderInput(session = session, 
                     "date_selector", 
                     "Select a Date and Time-Step: ", 
                     min = min(reactive_data$filtered_data$position),
                     max = max(reactive_data$filtered_data$position),
                     value = min(reactive_data$filtered_data$position))
          
         remove_modal_spinner()          
       }
    

})

 # testing
 # test = read_csv("./data/summer_surface_downsampled.csv")
 # test_spring = read_csv("./data/spring_surface_downsampled.csv")
 # 
 # filtered = test %>% filter(site == 962) %>% filter(lat !=0)
 # min(filtered$lat)

# Map Panel to View Simulation --------------------------------------------

# Base Simulation Map with Starting point
output$simulation_map = renderLeaflet({
  req(reactive_data$filtered_data)
  leaflet(reactive_data$filtered_data %>% 
            filter(position == 1)) %>%
    addTiles() %>%
    addCircleMarkers(lng = ~lon, 
                     lat = ~lat, 
                     radius = 1, 
                     layerId = ~ site
                     ) %>%
    fitBounds(min(reactive_data$filtered_data$lon), 
                 min(reactive_data$filtered_data$lat), 
                 max(reactive_data$filtered_data$lon), 
                 max(reactive_data$filtered_data$lat)
                 )
})
 
 # Filter Data Based on Animation Map Selection -------------------------------------------------------------
 #filter data depending on selected date THIS IS JUST WITHIN SIMULATION PANEL
 # filtered_sim_data <- reactive({
 #   if(is.null(reactive_data$filtered_data)) {
 #     NULL
 #   } else {
 #   reactive_data$filtered_data %>%
 #     filter(date == input$date_selector)
 #   }
 # })
 
 
 observeEvent(input$date_selector, {
   if(is.null(reactive_data$filtered_data)) {
     reactive_data$filtered_data_by_date = NULL
   } else {
     reactive_data$filtered_data_by_date = reactive_data$filtered_data %>%
       filter(position == input$date_selector)
   }
 })

# Updating Map as Simulation Progresses with leaflet Proxy
observe({
  req(reactive_data$filtered_data_by_date)
  leafletProxy("simulation_map", data = reactive_data$filtered_data_by_date) %>%
    clearMarkers() %>%
    addCircleMarkers(lng = ~lon, 
                     lat = ~lat, 
                     radius = 1
    )
  
    # flyToBounds(min(reactive_data$filtered_data_by_date$lon), 
    #           min(reactive_data$filtered_data_by_date$lat), 
    #           max(reactive_data$filtered_data_by_date$lon), 
    #           max(reactive_data$filtered_data_by_date$lat), 
    #           options = list(duration = 0.5, 
    #                          animate = TRUE)
    #           )
    
  
})


# Map Panel to View Density Maps --------------------------------------------

# Hex Density Maps with Leaflet
output$density_map = renderLeaflet({
  leaflet(reactive_data$filtered_data %>%
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
  ggplot(reactive_data$filtered_data, aes(x = lon, y = lat)) +
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



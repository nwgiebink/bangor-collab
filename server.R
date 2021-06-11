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
library(sp)
library(rgdal)
# library("maptools")
library(KernSmooth)
library(raster)



# Sourcing Scripts --------------------------------------------------------
source("./scripts/make_selection_map.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {


# Importing Distinct Sites ------------------------------------------------
filtered_distinct_starting_sites = read_csv("./data/downsampled_and_filtered_starting_sites.csv")
  
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
         end_position = (input$window)*24
         
         print(end_position)
         
         # grabbing data
         all_data = read_csv(file_string)
         
         # site filter - and filtering out spurious lat 0º Data
         reactive_data$filtered_data = all_data %>%
           filter(site == input$selection_map_marker_click$id) %>%
           filter(lat != 0) %>%
           filter(position <= end_position) %>%
           mutate(hours_since_release = position - 1)
          
         remove_modal_spinner()
         
         print(reactive_data$filtered_data)
       }
    

})
 
 ## Render slider input based on server-generated values ----------------------
  output$date_selector = renderUI({
    sliderInput("date_selector_input", 
                "Select hour since release: ", 
                min = min(reactive_data$filtered_data$hours_since_release),
                max = max(reactive_data$filtered_data$hours_since_release),
                value = min(reactive_data$filtered_data$hours_since_release),
                animate = animationOptions(interval = 150, loop = FALSE), 
                step = 2
                
    )
  })
 
 ## Updating slider input based on animation ----------------------------------
 reactive({
   updateSliderInput(session = session, 
                     "date_selector_input", 
                     min = min(reactive_data$filtered_data$hours_since_release),
                     max = max(reactive_data$filtered_data$hours_since_release),
                     value = min(reactive_data$filtered_data$hours_since_release),
                     animate = animationOptions(interval = 150, loop = FALSE),
                     step = 2
                     )
 })

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
 
 observeEvent(input$date_selector_input, {
   if(is.null(reactive_data$filtered_data)) {
     reactive_data$filtered_data_by_date = NULL
   } else {
     reactive_data$filtered_data_by_date = reactive_data$filtered_data %>%
       filter(hours_since_release == input$date_selector_input)
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
  
})


# Map Panel to View Density Maps --------------------------------------------

# Kernel Density estimate Map
output$density_map = renderLeaflet({
  
  # Generating input needed by bkde2d
  density_data = reactive_data$filtered_data %>%
    filter(lat != 0) %>%
    filter(hours_since_release == max(hours_since_release)) %>%
    select(lon, lat)
  
  ## Create kernel density output
  kde <- bkde2D(as.matrix(density_data),
                bandwidth=c(.025, .038), gridsize = c(1000,1000))
  # Create Raster from Kernel Density output
  KernelDensityRaster <- raster(list(x=kde$x1 ,y=kde$x2 ,z = kde$fhat))
  
  #set low density cells as NA so we can make them transparent with the colorNumeric function
  KernelDensityRaster@data@values[which(KernelDensityRaster@data@values < 1)] <- NA
  
  #create pal function for coloring the raster
  palRaster <- colorNumeric("Spectral", domain = KernelDensityRaster@data@values, na.color = "transparent")
  
  # making map       
  leaflet(data = reactive_data$filtered_data %>% filter(position == 1)) %>%
    addTiles() %>%
    addRasterImage(KernelDensityRaster, 
                   colors = palRaster, 
                   opacity = .8) %>%
    addLegend(pal = palRaster, 
              values = KernelDensityRaster@data@values, 
              title = "Kernel Density of Points") %>%
    addCircleMarkers(lng = ~lon, 
               lat = ~lat, 
               radius = 3, 
               color = "blue"
               )
})


})




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
         } else if(input$depth == "Mid-water") {
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
           filter(lat != 0)
         
         # Fixing position/windowing issues
         # position 1 coords
         start_lat = reactive_data$filtered_data %>%
           filter(position == 1) %>%
           distinct(lat)
         
         start_lon = reactive_data$filtered_data %>%
           filter(position == 1) %>%
           distinct(lon)
         
         
         # Binding start lon and lat onto df
         # adding a column that shows where it first moves out of start location
         reactive_data$filtered_data = reactive_data$filtered_data %>%
           mutate(start_lat = start_lat, 
                  start_lon = start_lon
           ) %>%
           mutate(diff_from_start = case_when(lat != start_lat | lon != start_lon ~ TRUE, 
                                              TRUE ~ FALSE
           ))
         
         last_position_one_df = reactive_data$filtered_data %>%
           filter(diff_from_start == FALSE) %>%
           group_by(replicate) %>%
           filter(position == max(position)) %>%
           dplyr::select(replicate, last_position_one = position)
         
         # binding
         reactive_data$filtered_data = reactive_data$filtered_data %>%
           left_join(last_position_one_df) %>%
           mutate(new_position = case_when(diff_from_start == FALSE ~ 1, 
                                           position > last_position_one ~ position-last_position_one + 1
           ))
         
         # final wrangling
         reactive_data$filtered_data = reactive_data$filtered_data %>%
           filter(new_position <= end_position) %>%
           mutate(hours_since_release = new_position - 1)
         
         remove_modal_spinner()
         
         print(reactive_data$filtered_data, n = 200)
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
 

# Modal for tab-switching -------------------------------------------------
 observeEvent(input$navbar,{
   if(is.null(reactive_data$filtered_data) & input$navbar == "tab2" | is.null(input$selection_map_marker_click) & input$navbar == "tab3") {
     showModal(modalDialog(
       title = "You haven't selected a site or other simulation parameters",
       "Please set parameters before moving to the Simulation or Density Map Tab",
       easyClose = TRUE,
       footer = NULL
     ))
   }
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
                 ) %>%
    onRender(
      "function(el, x) {
            L.easyPrint({
              sizeModes: ['Current', 'A4Landscape', 'A4Portrait'],
              filename: 'sim_map',
              exportOnly: true,
              hideControlContainer: true
            }).addTo(this);
            }"
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
 
 
 # Saving map to reactive values for download later
 map = reactiveValues(sim_map = 0)

# Updating Map as Simulation Progresses with leaflet Proxy
observe({
  req(reactive_data$filtered_data_by_date)
    leafletProxy("simulation_map", data = reactive_data$filtered_data_by_date) %>%
    clearMarkers() %>%
    addCircleMarkers(lng = ~lon, 
                     lat = ~lat, 
                     radius = 1
    ) %>%
    addCircleMarkers(lng = subset(reactive_data$filtered_data, position == 1)$lon, 
                     lat = subset(reactive_data$filtered_data, position == 1)$lat, 
                     radius = 3, 
                     color = "black", 
                     opacity = 0.7
                     ) %>%
      onRender(
        "function(el, x) {
            L.easyPrint({
              sizeModes: ['Current', 'A4Landscape', 'A4Portrait'],
              filename: 'sim_map',
              exportOnly: true,
              hideControlContainer: true
            }).addTo(this);
            }"
      )
  
})


# Selection Summary -------------------------------------------------------

output$selection_summary = renderText({
  
  paste("You've chosen the<b>", input$depth, "</b>depth during<b>", input$season, 
        "</b>where particles stay in the water column for<b>", input$window, "</b>days." )
})


# Download Sim Map --------------------------------------------------------

output$download_sim = downloadHandler(
  filename = "sim_map.png",

  content = function(file_to_download) {
    mapview::mapshot(x = map$sim_map,
                     file = file_to_download)
  }
)


# Map Panel to View Density Maps --------------------------------------------

# Kernel Density estimate Map
output$density_map = renderLeaflet({
  
  selection_window = input$settlement_window*24 # number of hours to step back and include in density map
  cutoff = max(reactive_data$filtered_data$hours_since_release) #ending cumulative hour in the data set
  real_selection_window = cutoff - selection_window
  
  print(paste("Selection set to", real_selection_window, "to", cutoff, "hours."))
  
  # Generating input needed by bkde2d
  density_data = reactive_data$filtered_data %>%
    filter(lat != 0) %>%
    filter(hours_since_release >= real_selection_window) %>%
    dplyr::select(lon, lat)
  
  # number of points
  num_points = nrow(density_data)
  print(num_points)
  
  ## Create kernel density output
  kde <- bkde2D(as.matrix(density_data),
                #bandwidth=c(.025, .038), gridsize = c(1000,1000))
                bandwidth=c(.038, .038), gridsize = c(150,150))
  # Create Raster from Kernel Density output
  KernelDensityRaster <- raster(list(x=kde$x1, y=kde$x2, z = kde$fhat/num_points))
  
  #set low density cells as NA so we can make them transparent with the colorNumeric function
  KernelDensityRaster@data@values[which(KernelDensityRaster@data@values < 0.00001)] <- NA
  
  #create pal function for coloring the raster
  palRaster <- colorNumeric("Spectral", 
                            domain = KernelDensityRaster@data@values, 
                            na.color = "transparent", 
                            reverse = TRUE)
  
  # making map       
  leaflet(data = reactive_data$filtered_data %>% filter(position == 1)) %>%
    addTiles() %>%
    addRasterImage(KernelDensityRaster, 
                   colors = palRaster, 
                   opacity = .7) %>%
    addLegend(pal = palRaster, 
              values = KernelDensityRaster@data@values, 
              title = HTML("<p>Probability Density (%)</p>"), 
              labFormat = labelFormat(digits = 4, transform = function(x) 100*x)
              ) %>%
    addCircleMarkers(lng = ~lon, 
               lat = ~lat, 
               radius = 3, 
               color = "black"
               ) %>%
    onRender(
      "function(el, x) {
            L.easyPrint({
              sizeModes: ['Current', 'A4Landscape', 'A4Portrait'],
              filename: 'density_map',
              exportOnly: true,
              hideControlContainer: true
            }).addTo(this);
            }"
    )
})


})





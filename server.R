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


# Filter Data Based on Animation Map Selection -------------------------------------------------------------
#filter data depending on selected date
filtered_sim_data <- reactive({
  req(input$date_selector)
  spring_data_test_site %>%
    filter(date == input$date_selector)
})

# Map Panel to View Simulation --------------------------------------------

output$simulation_map = renderLeaflet({
  leaflet(spring_data_test_site %>% 
            filter(position == 1)) %>%
    addTiles() %>%
    addCircleMarkers(lng = ~lon, 
                     lat = ~lat, 
                     radius = 1
                     )
})

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
              max(spring_data_test_site$lat)
              )
    
  
})


})

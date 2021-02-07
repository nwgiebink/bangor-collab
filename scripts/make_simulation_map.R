# Simulation Mapping Function
# Keaton Wilson
# keatonwilson@me.com
# 2020-02-07


# Useful tutorial for building animated maps: https://towardsdatascience.com/eye-catching-animated-maps-in-r-a-simple-introduction-3559d8c33be1

# packages
library(tidyverse)
library(leaflet)

make_simulation_map = function(data = NULL) {
  # leaflet function to generate map
  leaflet() %>%
    addTiles()
  # addCircleMarkers(~lon, ~lat,
  #                  stroke = FALSE,
  #                  fillOpacity = 0.6, 
  #                  opacity = 0.5
  # )
}
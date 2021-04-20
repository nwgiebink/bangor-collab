# Selection Mapping Function
# Keaton Wilson
# keatonwilson@me.com
# 2020-02-05

# packages
library(tidyverse)
library(leaflet)

make_selection_map = function(data = distinct_starting_points) {
  # leaflet function to generate map
  leaflet(data) %>%
    addTiles() %>%
    addCircleMarkers(~lon, ~lat,
                     radius = 4,
                     stroke = FALSE,
                     fillOpacity = 0.8,
                     opacity = 0.5, 
                     layerId = ~ site
    )
}
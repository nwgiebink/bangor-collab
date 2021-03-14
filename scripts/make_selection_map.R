# Selection Mapping Function
# Keaton Wilson
# keatonwilson@me.com
# 2020-02-05

# packages
library(tidyverse)
library(leaflet)

make_selection_map = function(data = NULL) {
  # leaflet function to generate map
  leaflet(data) %>%
    addTiles() %>%
    addCircleMarkers(~lon, ~lat,
                     stroke = FALSE,
                     fillOpacity = 0.6,
                     opacity = 0.5,
                     radius = 1
    )
}
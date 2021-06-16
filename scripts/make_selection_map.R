# Selection Mapping Function
# Keaton Wilson
# keatonwilson@me.com
# 2020-02-05

# packages
library(tidyverse)
library(leaflet)

filtered_distinct_starting_sites = read_csv("./data/distinct_sites_for_selection_map.csv")

make_selection_map = function(data = filtered_distinct_starting_sites) {
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
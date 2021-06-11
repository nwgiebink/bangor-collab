# Selection Mapping Function
# Keaton Wilson
# keatonwilson@me.com
# 2020-02-05

# packages
library(tidyverse)
library(leaflet)

filtered_distinct_starting_sites = read_csv("./data/downsampled_and_filtered_starting_sites.csv")

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
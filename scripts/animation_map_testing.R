# Animation Map Function
# Keaton Wilson
# keatonwilson@me.com
# 2021-03-24

# packages
library(tidyverse)
library(leaflet)

# Testing and Loading in Data
spring_data = read_csv("./data/spring_data_downsampled.csv")

glimpse(spring_data)

spring_data_test_site = spring_data %>%
  filter(site == 20, str_detect(replicate, "MWD"))


make_base_simulation_map = function(data = spring_data_test_site) {

leaflet(spring_data_test_site) %>%
  addTiles() %>%
  addCircleMarkers(lng = ~lon, 
                   lat = ~lat,
                   radius = 1, 
                   label = ~date)

  
}
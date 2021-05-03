# Global Script for Larval Dispersal App
# Keaton Wilson & Noah Giebink
# keatonwilson@me.com giebink@email.arizona.edu
# 2021-01-30

# packages ----------------------------------------------------------------
library(shiny)
library(tidyverse)

# Reading in Starting Points ----------------------------------------------
# Starting sites for selection map
filtered_distinct_starting_sites = read_csv("./data/filtered_distinct_starting_sites.csv")

# Reading in example data for simulation map
# Testing and Loading in Data
spring_data = read_csv("./data/spring_downsampled_6hours.csv")

spring_data_test_site = spring_data %>%
  filter(site == 4890 & str_detect(replicate, "surface"))


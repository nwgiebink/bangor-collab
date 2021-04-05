# Global Script for Larval Dispersal App
# Keaton Wilson & Noah Giebink
# keatonwilson@me.com giebink@email.arizona.edu
# 2021-01-30

# packages ----------------------------------------------------------------
library(shiny)
library(tidyverse)

# Reading in Starting Points ----------------------------------------------
spring_small = read_csv("./data/distinct_starting_points.csv")

# Reading in example data for simulation map
# Testing and Loading in Data
spring_data = read_csv("./data/spring_data_downsampled.csv")

spring_data_test_site = spring_data %>%
  filter(site == 2280)
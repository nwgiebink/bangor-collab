# Bug Testing for Position/cohort/windowing 
# Keaton Wilson
# keatonwilson@me.com
# 2021-06-18

# packages
library(tidyverse)
library(leaflet)
library(leaflet.extras)
library(ggmap)
library(shinybusy)
library(sp)
library(rgdal)
# library("maptools")
library(KernSmooth)
library(raster)

# loading in some data
test_data = read_csv("./data/autumn_mwd_downsampled.csv")



# One site one replicate --------------------------------------------------

# filtering to one site
test_data_one_site = test_data %>% 
  filter(site == 1939)

# position 1 coords
start_lat = test_data_one_site %>%
  filter(position == 1) %>%
  distinct(lat)

start_lon = test_data_one_site %>%
  filter(position == 1) %>%
  distinct(lon)

# Testing
testing_df = test_data_one_site %>%
  mutate(start_lat = start_lat, 
         start_lon = start_lon
         ) %>%
  mutate(diff_from_start = case_when(lat != start_lat | lon != start_lon ~ TRUE, 
                                     TRUE ~ FALSE
                                     )) %>% 
  filter(replicate == "October_15_2014_MWD_lat_02")

# last "real" position 1 position index
last_position_1 = testing_df %>%
  filter(diff_from_start == FALSE) %>%
  filter(position == max(position)) %>% 
  pull(position)

# adding new position indices
testing_df %>%
  mutate(last_position_one = last_position_1) %>%
  mutate(new_position = case_when(diff_from_start == FALSE ~ 1, 
                                  position > last_position_one ~ position-last_position_one + 1
                                  )) %>%
  print(n = 200)



# All replicates in one site ----------------------------------------------
testing_all_reps = test_data_one_site %>%
  mutate(start_lat = start_lat, 
         start_lon = start_lon
  ) %>%
  mutate(diff_from_start = case_when(lat != start_lat | lon != start_lon ~ TRUE, 
                                     TRUE ~ FALSE
  ))

# Last 'real' position 1 position index for all replicates
last_position_one_df = testing_all_reps %>%
  filter(diff_from_start == FALSE) %>%
  group_by(replicate) %>%
  filter(position == max(position)) %>% 
  dplyr::select(replicate, last_position_one = position)

# binding to df above
testing_all_reps %>%
  left_join(last_position_one_df) %>%
  group_by(replicate) %>%
  mutate(new_position = case_when(diff_from_start == FALSE ~ 1, 
                                  position > last_position_one ~ position-last_position_one + 1
                                  ))

# All sites and replicates for a single data file -------------------------

# starting lat/long for all sites
starting_lat_lon = test_data %>%
  group_by(site) %>%
  filter(position == 1) %>%
  distinct(lat, lon) %>%
  rename(start_lat = lat, start_lon = lon)

testing_full_all_reps = test_data %>%
  left_join(starting_lat_lon) %>%
  mutate(diff_from_start = case_when(lat != start_lat | lon != start_lon ~ TRUE, 
                                     TRUE ~ FALSE
  ))

last_position_one_df = testing_full_all_reps %>%
  filter(diff_from_start == FALSE) %>%
  group_by(site, replicate) %>%
  filter(position == max(position)) %>%
  dplyr::select(replicate, last_position_one = position)


testing_full_all_reps %>%
  left_join(last_position_one_df) %>%
  group_by(replicate, site) %>%
  mutate(new_position = case_when(diff_from_start == FALSE ~ 1, 
                                  position > last_position_one ~ position-last_position_one + 1
  ))
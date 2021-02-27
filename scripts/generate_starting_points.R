# Script to get unique site locations
# Keaton Wilson
# keatonwilson@me.com
# 2021-02-24

# packages
library(tidyverse)


# Reading in Data ---------------------------------------------------------
spring = read_csv("./data/spring_full.csv")


# Wrangling ---------------------------------------------------------------
distinct_starting_points = spring %>%
  filter(position == 1) %>%
  distinct(lat, lon, site)

# Writing to Disk ---------------------------------------------------------
write_csv(distinct_starting_points, "./data/distinct_starting_points.csv")



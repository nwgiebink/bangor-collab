# Selection Point Mapping Viz for Checking
# Keaton Wilson
# keatonwilson@me.com
# 2021-03-18

# packages
library(tidyverse)

starting_points = read_csv("./data/distinct_starting_points.csv")

glimpse(starting_points)

ggplot(starting_points, aes(x = 1, y = lat)) +
  geom_point(size = 0.25)

ggplot(starting_points, aes(x = lon, y = lat)) +
  geom_point(size = 0.25)



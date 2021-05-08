# Splitting downsampled data into by water depth to speed up loading times
# Keaton Wilson
# keatonwilson@me.com
# 2021-05-08


# Packages ----------------------------------------------------------------
library(tidyverse)


# Autumn ------------------------------------------------------------------
autumn_mwd = read_csv("./data/autumn_downsampled_6hours.csv") %>%
  filter(str_detect(replicate, "MWD"))

autumn_surface = read_csv("./data/autumn_downsampled_6hours.csv") %>%
  filter(str_detect(replicate, "surface"))

# writing
write_csv(autumn_mwd, "./data/autumn_mwd_downsampled.csv")
write_csv(autumn_surface, "./data/autumn_surface_downsampled.csv")


# Spring ------------------------------------------------------------------
spring_mwd = read_csv("./data/spring_downsampled_6hours.csv") %>%
  filter(str_detect(replicate, "MWD"))

spring_surface = read_csv("./data/spring_downsampled_6hours.csv") %>%
  filter(str_detect(replicate, "surface"))

# writing
write_csv(spring_mwd, "./data/spring_mwd_downsampled.csv")
write_csv(spring_surface, "./data/spring_surface_downsampled.csv")


# Summer ------------------------------------------------------------------
summer_mwd = read_csv("./data/summer_downsampled_6hours.csv") %>%
  filter(str_detect(replicate, "MWD"))

summer_surface = read_csv("./data/summer_downsampled_6hours.csv") %>%
  filter(str_detect(replicate, "surface"))

# writing
write_csv(summer_mwd, "./data/summer_mwd_downsampled.csv")
write_csv(summer_surface, "./data/summer_surface_downsampled.csv")
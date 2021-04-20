# Get unique starting locations (all data)
# Keaton Wilson
# keatonwilson@me.com
# 2021-04-14

# packages
library(tidyverse)

# loading starting positions
distinct_starting_sites_all = read_csv("./data/distinct_starting_sites.csv")

# loading in site ids
site_id = readRDS("./data/downsampled_and_filtered_starting_sites.rds")

# filtering for site 1
df_filtered = distinct_starting_sites_all %>%
  filter(site %in% site_id)

# writing to csv
write_csv(df_filtered, "./data/filtered_distinct_starting_sites.csv")

  

# Get unique starting locations (all data)
# Keaton Wilson
# keatonwilson@me.com
# 2021-04-14

# packages
library(tidyverse)

# sourcing data prep
source("./scripts/data_prep.R")

# Running limited time series but every site

df = data_prep(path = "~/Desktop/bangor_spring_data/", 
               spatial_res = 1, 
               temporal_res = 120
               )

# filtering for site 1
df_filtered = df %>% 
  filter(position == 1) %>% tibble() %>%
  distinct(site, position, lat, lon)

# writing to csv
write_csv(df_filtered, "./data/distinct_starting_sites.csv")

  

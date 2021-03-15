# Global Script for Larval Dispersal App
# Keaton Wilson & Noah Giebink
# keatonwilson@me.com giebink@email.arizona.edu
# 2021-01-30

# packages ----------------------------------------------------------------
library(shiny)
library(tidyverse)

# spring <- read_csv('data/spring_data.csv')
# spring_small <- spring %>% filter(position==1)
# write.csv(spring_small, 'data/spring_small.csv')

spring_small <- read_csv('data/spring_small.csv')

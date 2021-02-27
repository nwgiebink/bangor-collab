# Global Script for Larval Dispersal App
# Keaton Wilson & Noah Giebink
# keatonwilson@me.com giebink@email.arizona.edu
# 2021-01-30

# packages ----------------------------------------------------------------
library(shiny)
library(tidyverse)

# Reading in Starting Points ----------------------------------------------
starting_points = read_csv("./data/distinct_starting_points.csv")


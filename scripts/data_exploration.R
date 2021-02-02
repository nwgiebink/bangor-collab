# matlab file processing
# Keaton Wilson
# keatonwilson@me.com
# 2021-01-30

# packages
library(tidyverse)
library(R.matlab)

# looking at one of the data files
test_df = readMat("./data/spring_data/March_01_2014_surface_lat_01.mat")

dim(test_df$lat)

# Each file contains a matric of coords (lat or lon), that is 6964 x 1441
# Each of the 20 sets of files is a simulation replication. 
# Each Column is an hour (24*2*30 +1 )
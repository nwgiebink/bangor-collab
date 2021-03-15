# Checking Summer Surface Data
# keatonwilson@me.com 
# Keaton Wilson
# 2021-03-07

# packages
library(tidyverse)
library(R.matlab)
library(stringr)
library(lubridate)

# get list of files to check
files_to_check = list.files("/Volumes/bangor_collab/bangor_spring_data/", full.names = TRUE)

# removing problematic file to see if the rest run
# files_to_check = files_to_check[str_detect(files_to_check, "July_03_2014_surface_lon_20.mat")]

# Running through, reading them in and printing so we can figure out which 
# might be corrupt

for(i in 1:length(files_to_check)) {
  tmp = tryCatch(
    
    expr = { readMat(files_to_check[i])
    }, 
    
    error = function(e) {
      message('Caught an Error!')
      print(e)
    }
    
  )
  
  print(paste("Finished with", files_to_check[i]))
}

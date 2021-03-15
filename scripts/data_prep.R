# data prep
# Noah Giebink
# nwgiebink@gmail.com
# 2021-02-14

# packages
library(tidyverse)
library(R.matlab)
library(stringr)
library(lubridate)

# function data_prep() ----
#' Description
#' convert directory of .mat files 
#' 
#' Requirements
#' matrix shape n sites * m positions
#' separate lat and lon files paired by naming scheme
#' e.g. lat: "March_01_2014_surface_lat_01.mat" lon: "March_01_2014_surface_lon_01.mat"
#' 
#' Arguments
#' path: location of .mat files e.g. './data/spring_data/'
#' spatial_res: spatial resolution, e.g. if spatial_res = 5, keep every fifth site
#' temporal_res: temporal resolution, e.g. if temporal_res = 12, keep two positions per day
#'
#' Data
#' Each simulation lasts for two months (i.e. particles are released during two months) 
#' and results (i.e. particles position) are saved hourly 
#' (so matrices of 6964 sites * 1441 positions) for both latitude and longitude 
#' (so for each simulation two matrices generated: one for lat and one for lon).


data_prep <- function(path, spatial_res, temporal_res){

# loop through 20 replicate files
file_names <- dir(path, pattern = '.mat')

# init progress bar
progress_bar <- txtProgressBar(min = 0, max = length(file_names)/2, style = 3)
progress = 0 # init progress bar value

# get all lat files to find corresponding lon matches
lats <- file_names[which(str_detect(file_names, 'lat'))]

replicates <- vector(mode='list', length = length(lats)) # init dfs list

for (f in lats) {
  # find matching lat and lon file names and put them together
  matches <- file_names[which(str_detect(word(file_names, 2, sep = '_'), word(f, 2, sep = '_')) & # same date
                                str_detect(file_names, word(f, 4, sep = '_')) & # same depth
                                str_detect(file_names, str_sub(f, -6, -1)))] # same replicate
  match_dfs <- c(readMat(paste0(path,matches[1])), readMat(paste0(path,matches[2])))

  # change to data frame: rows = sites, columns = positions
  lat <- data.frame(match_dfs[1])
  # maintain site provenance
  lat$site <- c(1:nrow(lat))
  # pivot to long format, columns: site, position, lat
  lat_tidy <- pivot_longer(lat, cols = lat.1:lat.1441, names_to = 'position', values_to = 'lat')
  # extract number from position
  lat_tidy$position <- gsub("^.*?\\.", "", lat_tidy$position)
  lat_tidy$position <- as.numeric(lat_tidy$position)

  # do the same for lon
  lon <- data.frame(match_dfs[2])
  lon$site <- c(1:nrow(lat))
  lon_tidy <- pivot_longer(lon, cols = lon.1:lon.1441, names_to = 'position', values_to = 'lon')

  # cbind lat and lon; site and position should match
  lat_lon <- cbind(lat_tidy, lon_tidy[3])

  # create column: replicate, values = filename
  lat_lon$replicate <- str_sub(matches[1], 1, -5)

  # create column: date
    # get date from file name string
  year <- word(matches[1], 3, sep = '_')
  month <- match(word(matches[1], sep = '_'), month.name)
  day <- word(matches[1], 2, sep = '_')
  date <- ymd(paste0(year, "-", month, "-", day))

  lat_lon$date <- date
  lat_lon <- lat_lon %>% mutate(date = date + hours(position - 1))

  # down sample
  # spatial  resolution:
  # e.g. if arg spatial_res = 5, keep every fifth site
  lat_lon_reduced <- lat_lon %>% filter(site %% spatial_res == 0)

  # temporal resolution:
  # e.g. if arg temporal_res = 12, keep two positions per day
  lat_lon_reduced <- lat_lon_reduced %>% filter(position == 1 | (position - 1) %% temporal_res == 0)

  # add to list of replicate dfs
  replicates[[f]] <- lat_lon_reduced

  # update progress bar
  progress <- progress + 1
  setTxtProgressBar(progress_bar, value = progress)

}
# after exiting loop, bind all dfs in replicates list
replicates_df <- bind_rows(replicates)

close(progress_bar)
return(replicates_df)

}

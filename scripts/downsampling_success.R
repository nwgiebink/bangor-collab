# Downsampling Exploration
# Keaton Wilson
# keatonwilson@me.com
# 2021-04-15

# packages
library(tidyverse)

# reading in data
starting_sites = read_csv("./data/distinct_starting_sites.csv")

starting_sites %>%
  ggplot(aes(x = lon, y = lat)) +
  geom_point(size = 0.5)

# from the interwebs (https://davidrroberts.wordpress.com/2015/09/25/spatial-buffering-of-points-in-r-while-retaining-maximum-sample-size/)
buffer.f <- function(foo, buffer, reps){
  # Make list of suitable vectors
  suitable <- list()
  for(k in 1:reps){
    # Make the output vector
    outvec <- as.numeric(c())
    # Make the vector of dropped (buffered out) points
    dropvec <- c()
    for(i in 1:nrow(foo)){
      # Stop running when all points exhausted
      if(length(dropvec)<nrow(foo)){
        # Set the rows to sample from
        if(i>1){
          rowsleft <- (1:nrow(foo))[-c(dropvec)]
        } else {
          rowsleft <- 1:nrow(foo)
        }
        # Randomly select point
        outpoint <- as.numeric(sample(as.character(rowsleft),1))
        outvec[i] <- outpoint
        # Remove points within buffer
        outcoord <- foo[outpoint,c("x","y")]
        dropvec <- c(dropvec, which(sqrt((foo$x-outcoord$x)^2 + (foo$y-outcoord$y)^2)<buffer))
        # Remove unnecessary duplicates in the buffered points
        dropvec <- dropvec[!duplicated(dropvec)]
      } 
    } 
    # Populate the suitable points list
    suitable[[k]] <- outvec
  }
  # Go through the iterations and pick a list with the most data
  best <- unlist(suitable[which.max(lapply(suitable,length))])
  foo[best,]
}

# filtering down to just lat lon
starting_sites_lite = starting_sites %>%
  rename(x = lon, y = lat) %>%
  select(x, y)

# running function
downsampled = buffer.f(starting_sites_lite, 0.16, 5000)


# checking
plot(downsampled)

# filtering based on Peter's suggestion
downsampled_and_filtered = downsampled %>%
  filter(y < 55 & y > 51) %>%
  filter(x > -7.2) %>%
  rename(lat = y, lon = x)

# joining back onto main data
filtered_sites = starting_sites %>%
  semi_join(downsampled_and_filtered) %>%
  pull(site)

# writing to rds
write_rds(filtered_sites, "./data/downsampled_and_filtered_starting_sites.rds")

# make csv of downsampled starting sites for reference
starting_sites_down <- starting_sites %>% filter(site %in% filtered_sites)
write_csv(starting_sites_down, './data/downsampled_and_filtered_starting_sites.csv')


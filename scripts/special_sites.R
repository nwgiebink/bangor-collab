# Special sites
# Noah Giebink
# keatonwilson@me.com
# 2021-06-13

library(tidyverse)
library(RANN)

# special site coordinates
# Holyhead - 53.32339790253614, -4.6179299885036595
# Dublin (Malahide) - 53.4490815359149, -6.12004807253046
# Swansea - 51.60889645432802, -3.9269452313959876
# Rosslare - 52.25868919896821, -6.3218370248155376
# Pwllheli - 52.88533767718526, -4.3925817300787555

special_sites <- data.frame(lat = c(53.32339790253614, 
                                    53.4490815359149,
                                    51.60889645432802,
                                    52.25868919896821,
                                    52.88533767718526), 
                            lon = c(-4.6179299885036595, 
                                    -6.12004807253046,
                                    -3.9269452313959876,
                                    -6.3218370248155376,
                                    -4.3925817300787555))

sites = read_csv('data/distinct_starting_sites.csv')

inner_join(sites, special_sites, by = c("lat", "lon"))


# get index of special sites
  # find nearest neighbor to each special site 
nearest <- nn2(sites[,c('lat','lon')],
               special_sites[,c('lat','lon')], 
               k = 1)
  # return index
special_ind <- nearest$nn.idx[,1]

sites[special_ind,]

sites_labeled <- sites %>% mutate(special = if_else(site %in% special_ind, 'yes', 'no'))

# double check the sites are in the right places
sites_labeled <- sites %>% mutate(special = if_else(site %in% special_ind, 'yes', 'no'))

ggplot(sites_labeled, aes(lon, lat, color=special, alpha = special))+
  geom_point()+
  scale_alpha_discrete(range = c(0.01, 1))

# add special site indices to downsample indices vector
sites_ind <- readRDS('data/downsampled_and_filtered_starting_sites.rds')
sites_ind_updated <- c(sites_ind, special_ind)

# write
write_rds(sites_ind_updated, 'data/downsampled_and_filtered_starting_sites_updated.rds')
write_csv(data.frame(sites_ind_updated), 'data/downsampled_and_filtered_starting_sites_updated.csv')

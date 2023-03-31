# Script description
#
# Bengt Karlson 13 March 2023
# paths are for Mac/UNIX
# Change / to \\ if Windows is used


# load libraries ----------------------------------------------------------

library(tidyverse) # includes ggplot2 tidyr etc
library(lubridate) # useful for working with dates
library(cowplot) # useul for combining multiple plots
library(scales)
library(ggthemes)
library(stringi)
library(readr)
library(ggspatial)
library(ggOceanMapsData)
library(ggOceanMaps)
library(here)



# set paths ----------------------------------------------------------

bpath<-here()# # set base path
setwd(bpath) # set working directory

# define start and end dates ------------------------------------------
start_of_cruise <- ISOdatetime(2023,3,9,0,0,0, tz = "GMT")
end_of_cruise <- ISOdatetime(2023,3,14,23,59,59, tz = "GMT")

start_end <- c(start_of_cruise,end_of_cruise)

# load list of sampling positions (from other script)
mydata <- read_tsv("output/allifcb_data_wide_march_2023.txt")

mydata <- mydata %>%
  rename(latitude = gpsLatitude) %>%
  rename(longitude = gpsLongitude)
  



# make some maps ----

svea_cruise_map = basemap(limits = c(8, 22, 54, 60),
                                  rotate = TRUE,
                                  bathymetry = FALSE) +
annotation_scale(location = "br") 
# annotation_north_arrow(location = "tl", which_north = "true")

svea_cruise_map

ifcb_sampling_locations_map  <- svea_cruise_map +
  geom_spatial_point( data = mydata,
                      aes(x = longitude,
                          y = latitude),
                      color = "red",
                      size = 0.5) +
  xlab("Longitude")  +
  ylab("Latitude") +
  ggtitle("R/V Svea IFCB March 2023",
          subtitle = "Sampling locations (n = ?)") 

ifcb_sampling_locations_map 

ggsave(plot = ifcb_sampling_locations_map,
       path = "plots",
       filename = "ifcb_sampling_locations_map_march_2023.pdf",
       device = "pdf",
       units = "cm",
       width = 14,
       height = 14)

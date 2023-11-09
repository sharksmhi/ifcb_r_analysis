library(sf)
library(tidyverse)

shapefilesDir <- "data/shapefiles/sharkweb_shapefiles/"

basin_shapefile <- "Havsomr_SVAR_2016_3b_CP1252.shp"
basin_names <- "sea_basin_utf8.txt"

source("code/ifcb_read_hdr_meta_data_v1.R")

# Read shapefiles and list of basin names
basins <- st_read(file.path(shapefilesDir, basin_shapefile))
basin_names <- read_delim(file.path(shapefilesDir, basin_names), 
                          delim = ";", 
                          col_names = TRUE, 
                          locale = locale(encoding = "UTF-8"))

# Set CRS of basin layer
basins <- st_set_crs(basins, 3006)

# Aggregate basins by the 17 sea basins
all_basins <- basins %>%
  group_by(BASIN_NR) %>%
  summarise(geometry = sf::st_union(geometry)) %>%
  ungroup()

# Change CRS
all_basins <- st_transform(all_basins, 4326)

# Add geometry information to data
allaifcb_data_wide <- allaifcb_data_wide %>%
  mutate(lon = gpsLongitude,
         lat = gpsLatitude)

# Gather all unique positions
cords = allaifcb_data_wide %>%
  distinct(gpsLongitude, gpsLatitude, lat, lon)

# Convert data points to sf
points_sf <- st_as_sf(cords, coords = c("lon", "lat"), crs = st_crs(all_basins))

# Assign basin number by position
allaifcb_data_wide_st <- st_join(points_sf, all_basins)

# Add sea basin name and create translate list
allaifcb_data_wide_st <- allaifcb_data_wide_st %>%
  as.data.frame() %>%
  left_join(basin_names) %>%
  select(-geometry, -BASIN_NR)

# Add classifier to samples west of Skagerrak
allaifcb_data_wide_st <- allaifcb_data_wide_st %>%
  mutate(classifier = ifelse(is.na(classifier), 
                             ifelse(as.numeric(gpsLongitude) < 10, 
                                    "Skagerrak-Kattegat", 
                                    classifier), 
                             classifier))

# Back-transform to DF and translate basin nr
allaifcb_data_wide_basin <- allaifcb_data_wide %>%
  left_join(allaifcb_data_wide_st) %>%
  select(File, gpsLatitude, gpsLongitude, rdate, classifier)

# Save the data as a txt file
write.table(allaifcb_data_wide_basin, 
            "output/sample_classifier.txt",
            sep = "\t",
            quote = FALSE, 
            na = "NA", 
            row.names=F)

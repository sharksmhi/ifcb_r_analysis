# Load libraries
library(tidyverse)
library(here)

# Define year
year <- 2023

# Define your ifcb data path
ifcb_path <- ""

# Define paths
blobsdir <- paste(ifcb_path, "work/data/blobs", year, sep = "/")
featuredir <- paste(ifcb_path, "work/data/features", year, sep = "/")
datadir <- paste(ifcb_path, "work/data/data", year, sep = "/")
deliverydir <- paste(ifcb_path, "delivery", year, sep = "/")
outputdir <- paste0(here(),"/output/blobs_and_features/")

# List different filenames
blobs <- list.files(blobsdir, pattern="zip$", full.names = FALSE, recursive = TRUE)
features <- list.files(featuredir, pattern="csv$", full.names = FALSE, recursive = FALSE)
roifiles <- list.files(datadir, pattern="roi$", full.names = FALSE, recursive = TRUE)
hdrfiles <- list.files(datadir, pattern="hdr$", full.names = FALSE, recursive = TRUE)
adcfiles <- list.files(datadir, pattern="adc$", full.names = FALSE, recursive = TRUE)
deliveryfiles <- list.files(deliverydir, pattern="roi$", full.names = FALSE, recursive = TRUE)
deliveryfolders <- list.dirs(deliverydir, full.names = FALSE, recursive = FALSE)
datafolders <- list.dirs(datadir, full.names = FALSE, recursive = FALSE)
all_data_files <- list.files(datadir, full.names = FALSE, recursive = TRUE)

# Find missing folders/data from delivery folder
missing_folders <- deliveryfolders[!deliveryfolders %in% datafolders]
missing_data <- deliveryfiles[!deliveryfiles %in% roifiles]

# Create vectors with filenames
blobsnames <- sub("_.*", "", blobs)
blobsfilename <- sub(".*/", "", blobsnames)
featurenames <- sub("_.*", "", features)
roinames <- sub("_.*", "", roifiles)
hdrnames <- sub("_.*", "", hdrfiles)
adcnames <- sub("_.*", "", adcfiles)

# Find missing blobs/features from data/blobs
missing_blobs <- roinames[!roinames %in% blobsnames]
missing_features <- blobsfilename[!blobsfilename %in% featurenames]

# Summarise number of files for each sample (should be roi, adc and hdr, i.e. == 3)
sample_summary <- data_frame(
  dir = dirname(all_data_files)) %>% 
  count(dir) %>%
  mutate(samples = n/3)

# Save data as a txt file
write.table(missing_blobs, 
            paste0(outputdir, "missing_blobs_", year, ".txt"),
            sep = "\t",
            quote = FALSE, 
            na = "NA", 
            row.names=F)

# Save data as a txt file
write.table(missing_data, 
            paste0(outputdir, "missing_data_", year, ".txt"),
            sep = "\t",
            quote = FALSE, 
            na = "NA", 
            row.names=F)
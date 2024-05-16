library(tidyverse)
library(reticulate)

# Setup virtual environment
virtualenv_create("code/python/venv", requirements = "code/python/edit_manual_file/requirements.txt")
use_virtualenv("code/python/venv")

# Now try to import the python function
source_python("code/python/edit_manual_file/edit_manual_file.py")

# Define your ifcb data path
correction_path <- "" # Enter path to folder with correction filenames
manual_path <- "" # Enter path to manual folder
file_path <- file.path(manual_path, classifier)

# Define which classifier you are working on
classifier <- "Baltic"

# Define which correction file to use
correction_file <- "Aphanizomenon_002_selected_images_bundles.txt"

# Read corrections file
corrections <- read.table(file.path(correction_path, correction_file), header = TRUE) %>%
  mutate(sample_filename = sub("^(.*)_[^_]*$", "\\1", image_filename)) %>%
  mutate(roi = gsub(".*IFCB134_(\\d+)\\.png.*", "\\1", image_filename)) %>%
  mutate(roi = as.integer(gsub("^0+", "", roi)))

# Aggregate roi to correct per sample
corrections_aggregated <- aggregate(roi ~ sample_filename, data = corrections, FUN = function(x) list(x))

# Define new class
correct_classid <- as.integer(99)

# Loop for all files
for (i in 1:nrow(corrections_aggregated)) {
  # Extract filename and roi values from the current row
  filename <- as.character(corrections_aggregated$sample_filename[i])
  roi_list <- corrections_aggregated$roi[[i]]  # Extract roi list
  
  # Convert roi list elements to integers
  roi <- lapply(roi_list, as.integer)  # Use lapply to ensure we get a list
  
  # Call the Python function with the extracted values
  edit_manual_file(
    file.path(file_path, paste0(filename, ".mat")),  # Ensure correct file path
    file.path("output/manual", classifier, paste0(filename, ".mat")),  # Ensure correct output file path
    roi,
    correct_classid
  )
}

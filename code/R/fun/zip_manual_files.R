# Load the necessary package
library(zip)

# Define the function to create the zip archive
zip_manual_files <- function(manual_folder, features_folder, class2use_file, zip_filename, data_folder = NULL, readme_file = NULL) {
  # Print message to indicate starting listing files
  message("Listing all files...")
  
  # List all .mat files in the specified folder (excluding subfolders)
  mat_files <- list.files(manual_folder, pattern = "\\.mat$", full.names = TRUE, recursive = FALSE)
  
  # List all feature files in the specified folder (including subfolders)
  feature_files <- list.files(features_folder, pattern = "\\.csv$", full.names = TRUE, recursive = TRUE)
  
  # If data_folder is provided, list all data files in the specified folder (including subfolders)
  if (!is.null(data_folder)) {
    data_files <- list.files(data_folder, pattern = "\\.(roi|adc|hdr)$", full.names = TRUE, recursive = TRUE)
  } else {
    data_files <- NULL
  }
  
  # Function to find matching feature files with a general pattern
  find_matching_features <- function(mat_file, feature_files) {
    base_name <- tools::file_path_sans_ext(basename(mat_file))
    matching_files <- grep(base_name, feature_files, value = TRUE)
    return(matching_files)
  }
  
  # Function to find matching data files with a general pattern
  find_matching_data <- function(mat_file, data_files) {
    base_name <- tools::file_path_sans_ext(basename(mat_file))
    matching_files <- grep(base_name, data_files, value = TRUE)
    return(matching_files)
  }
  
  # Function to print the progress bar
  print_progress <- function(current, total, bar_width = 50) {
    progress <- current / total
    complete <- round(progress * bar_width)
    bar <- paste(rep("=", complete), collapse = "")
    remaining <- paste(rep(" ", bar_width - complete), collapse = "")
    cat(sprintf("\r[%s%s] %d%%", bar, remaining, round(progress * 100)))
    flush.console()
  }
  
  # Temporary directory to store renamed folders
  temp_dir <- tempdir()
  manual_dir <- file.path(temp_dir, "manual")
  features_dir <- file.path(temp_dir, "features")
  data_dir <- file.path(temp_dir, "data")
  config_dir <- file.path(temp_dir, "config")
  
  # Create temporary directories if they don't already exist
  if (!file.exists(manual_dir)) dir.create(manual_dir)
  if (!file.exists(features_dir)) dir.create(features_dir)
  if (!file.exists(config_dir)) dir.create(config_dir)
  if (!is.null(data_files) && !file.exists(data_dir)) dir.create(data_dir)
  
  # Total number of files to copy
  total_files <- length(mat_files)
  current_file <- 0
  
  # Print message to indicate starting copying manual files
  message("Copying manual files...")
  
  # Copy .mat files to the manual directory
  for (mat_file in mat_files) {
    file.copy(mat_file, manual_dir, overwrite = TRUE)
    current_file <- current_file + 1
    print_progress(current_file, total_files)
  }
  
  # Print a new line after the progress bar is complete
  cat("\n")
  
  # Print message to indicate starting copying feature files
  message("Copying feature files...")
  
  # Total number of mat files to process
  total_mat_files <- length(mat_files)
  current_mat_file <- 0
  
  # Find and copy matching feature files for each .mat file
  for (mat_file in mat_files) {
    current_mat_file <- current_mat_file + 1
    print_progress(current_mat_file, total_mat_files)
    
    matching_features <- find_matching_features(mat_file, feature_files)
    for (feature_file in matching_features) {
      # Get relative path of feature file with respect to features_folder
      relative_path <- substr(feature_file, nchar(features_folder) + 2, nchar(feature_file))
      
      # Create the destination directory for the feature file
      dest_dir <- file.path(features_dir, dirname(relative_path))
      if (!file.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
      
      # Copy feature file to the destination directory
      file.copy(feature_file, dest_dir, overwrite = TRUE)
    }
  }
  
  # Print a new line after the progress bar is complete
  cat("\n")
  
  # If data_folder is provided, copy data files
  if (!is.null(data_files)) {
    # Print message to indicate starting copying data files
    message("Copying data files...")
    
    # Total number of mat files to process
    total_mat_files <- length(mat_files)
    current_mat_file <- 0
    
    # Find and copy matching data files for each .mat file
    for (mat_file in mat_files) {
      current_mat_file <- current_mat_file + 1
      print_progress(current_mat_file, total_mat_files)
      
      matching_data <- find_matching_data(mat_file, data_files)
      for (data_file in matching_data) {
        # Get relative path of data file with respect to data_folder
        relative_path <- substr(data_file, nchar(data_folder) + 2, nchar(data_file))
        
        # Create the destination directory for the data file
        dest_dir <- file.path(data_dir, dirname(relative_path))
        if (!file.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE, showWarnings = FALSE)
        
        # Copy data file to the destination directory
        file.copy(data_file, dest_dir, overwrite = TRUE)
      }
    }
    
    # Print a new line after the progress bar is complete
    cat("\n")
  }
  
  # Copy the class2use file to the config directory and rename it to class2use.mat
  message("Copying class2use file...")
  file.copy(class2use_file, file.path(config_dir, "class2use.mat"), overwrite = TRUE)
  
  # If readme_file is provided, copy it
  if (!is.null(readme_file)) {
    file.copy(readme_file, file.path(temp_dir, "README.md"), overwrite = TRUE)
  }
  
  # Print message to indicate starting zip creation
  message("Creating zip archive...")
  
  # Create the zip archive
  files_to_zip <- c(manual_dir, features_dir, config_dir)
  if (!is.null(data_files)) files_to_zip <- c(files_to_zip, data_dir)
  if (!is.null(readme_file)) files_to_zip <- c(files_to_zip, file.path(temp_dir, "README.md"))
  
  zipr(zipfile = zip_filename, files = files_to_zip)
  message("Zip archive created successfully.")
  
  # Clean up temporary directories
  unlink(manual_dir, recursive = TRUE)
  unlink(features_dir, recursive = TRUE)
  unlink(config_dir, recursive = TRUE)
  unlink(data_dir, recursive = TRUE)
}
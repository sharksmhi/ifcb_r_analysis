# Load the necessary package
library(zip)

# Define the function to zip folders containing .png files
zip_png_folders <- function(main_dir, zip_filename) {
  # List all subdirectories in the main directory
  subdirs <- list.dirs(main_dir, recursive = FALSE)
  
  # Initialize a vector to store directories with .png files
  dirs_to_zip <- character()
  
  # Total number of subdirectories
  total_subdirs <- length(subdirs)
  
  # Function to print the progress bar
  print_progress <- function(current, total, bar_width = 50) {
    progress <- current / total
    complete <- round(progress * bar_width)
    bar <- paste(rep("=", complete), collapse = "")
    remaining <- paste(rep(" ", bar_width - complete), collapse = "")
    cat(sprintf("\r[%s%s] %d%%", bar, remaining, round(progress * 100)))
    flush.console()
  }
  
  # Function to truncate the folder name
  truncate_folder_name <- function(folder_name) {
    sub("_\\d{3}$", "", basename(folder_name))
  }
  
  # Temporary directory to store renamed folders
  temp_dir <- tempdir()
  temp_subdirs <- character()
  
  # Iterate over each subdirectory
  for (i in seq_along(subdirs)) {
    # List all .png files in the subdirectory
    png_files <- list.files(subdirs[i], pattern = "\\.png$", full.names = TRUE)
    
    # If there are any .png files, add the subdirectory to the list
    if (length(png_files) > 0) {
      truncated_name <- truncate_folder_name(subdirs[i])
      temp_subdir <- file.path(temp_dir, truncated_name)
      if (!dir.exists(temp_subdir)) {
        dir.create(temp_subdir)
      }
      file.copy(png_files, temp_subdir, overwrite = TRUE)
      temp_subdirs <- c(temp_subdirs, temp_subdir)
    }
    
    # Update the progress bar
    print_progress(i, total_subdirs)
  }
  
  # Print a new line after the progress bar is complete
  cat("\n")
  
  # If there are directories to zip
  if (length(temp_subdirs) > 0) {
    # Create the zip archive
    zipr(zipfile = zip_filename, files = temp_subdirs)
    message("Zip archive created successfully.")
  } else {
    message("No directories with .png files found.")
  }
  
  # Clean up temporary directories
  unlink(temp_subdirs, recursive = TRUE)
}
# Load the necessary package
library(zip)
library(stringr)
library(dplyr)
library(lubridate)

# Define the function to zip folders containing .png files
zip_png_folders <- function(png_directory, zip_filename, readme_file = NULL) {
  # List all subdirectories in the main directory
  subdirs <- list.dirs(png_directory, recursive = FALSE)
  
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
  
  # If readme_file is provided, update it
  if (!is.null(readme_file)) {
    message("Creating README file...")
    
    # Read the template README.md content
    readme_content <- readLines(readme_file, encoding = "UTF-8")
    
    # Get the current date
    current_date <- Sys.Date()
    
    # Get list of filenames with .png extension
    files <- list.files(png_directory, pattern = "png$", full.names = TRUE, recursive = TRUE)
    
    # Summarize the number of images by directory
    files_df <- tibble(dir = dirname(files)) %>% 
      count(dir) %>% 
      mutate(taxa = truncate_folder_name(dir)) %>%  # Use basename to get the folder name
      arrange(desc(n))
    
    # Extract dates from file paths and get the years
    dates <- str_extract(files, "D\\d{8}")
    years <- as.integer(substr(dates, 2, 5))
    
    # Find the minimum and maximum year
    min_year <- min(years, na.rm = TRUE)
    max_year <- max(years, na.rm = TRUE)
    
    # Update the README.md template placeholders
    updated_readme <- readme_content %>%
      gsub("<DATE>", current_date, .) %>%
      gsub("<IMAGE_ZIP>", basename(zip_filename), .) %>%
      gsub("<MATLAB_ZIP>", gsub("annotated_images", "matlab_files", basename(zip_filename)), .) %>%
      gsub("<N_IMAGES>", formatC(sum(files_df$n), format = "d", big.mark = ","), .) %>%
      gsub("<CLASSES>", nrow(files_df), .) %>%
      gsub("<YEAR_START>", min_year, .) %>%
      gsub("<YEAR_END>", max_year, .) %>%
      gsub("<YEAR>", year(current_date), .)
    
    # Create the new section for the number of images
    new_section <- c("### Number of images per class", "")
    new_section <- c(new_section, paste0(files_df$taxa, ": ", formatC(files_df$n, format = "d", big.mark = ",")))
    new_section <- c("", new_section)  # Add an empty line before the new section for separation
    
    # Append the new section to the readme content
    updated_readme <- c(updated_readme, new_section)
    
    # Write the updated content back to the README.md file
    writeLines(updated_readme, file.path(temp_dir, "README.md"), useBytes = TRUE)
  }
  
  # If there are directories to zip
  if (length(temp_subdirs) > 0) {
    # Create the zip archive
    files_to_zip <- temp_subdirs
    if (!is.null(readme_file)) {
      files_to_zip <- c(files_to_zip, file.path(temp_dir, "README.md"))
    }
    zipr(zipfile = zip_filename, files = files_to_zip)
    message("Zip archive created successfully.")
  } else {
    message("No directories with .png files found.")
  }
  
  # Clean up temporary directories
  unlink(temp_subdirs, recursive = TRUE)
}
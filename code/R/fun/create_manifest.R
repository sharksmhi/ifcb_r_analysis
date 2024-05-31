# Load necessary library
library(dplyr)

# Function to create MANIFEST.txt
create_manifest <- function(folder_path, manifest_path = "MANIFEST.txt") {
  # List all files in the folder and subfolders
  files <- list.files(folder_path, recursive = TRUE, full.names = TRUE)
  
  # Get file sizes
  file_sizes <- file.info(files)$size
  
  # Create a data frame with filenames and their sizes
  # Use fixed = TRUE in gsub to avoid interpreting backslashes as escape characters
  manifest_df <- data.frame(
    file = gsub(paste0(normalizePath(folder_path, winslash = "/"), "/"), "", normalizePath(files, winslash = "/"), fixed = TRUE),  # Remove the folder path from the file names
    size = file_sizes,
    stringsAsFactors = FALSE
  )
  
  # Format the file information as "filename [size]"
  manifest_content <- paste0(manifest_df$file, " [", formatC(manifest_df$size, format = "d", big.mark = ","), " bytes]")
  
  # Write the manifest content to MANIFEST.txt
  writeLines(manifest_content, manifest_path)
  
  cat("MANIFEST.txt has been created at", manifest_path, "\n")
}
# Load necessary libraries
library(dplyr)

# Define the function to get all .png files with their respective subfolder names
get_png_files <- function(directory) {
  # List all files recursively and filter out only .png files
  all_files <- list.files(directory, recursive = TRUE, full.names = TRUE)
  png_files <- all_files[grepl("\\.png$", all_files)]
  
  # Extract the immediate subfolder names
  class_folders <- sapply(png_files, function(x) {
    rel_path <- sub(paste0("^", directory, "/"), "", x)
    strsplit(rel_path, "/")[[1]][1]
  })
  
  # Create a data frame with the required columns
  png_df <- data.frame(
    class_folder = class_folders,
    image_filename = basename(png_files),
    stringsAsFactors = FALSE
  )
  
  return(png_df)
}

ifcb_path <- Sys.getenv("ifcb_path")

# Specify the directory containing subfolders with .png images
directory <- file.path(ifcb_path, "png_images/Tångesund/2017-06-27")

# Get the .png files data frame
png_df <- get_png_files(directory)

# Remove duplicated files
png_df <- png_df[!grepl(" \\(1\\)", png_df$image_filename), ]

# Get unique class folders
class_folders <- unique(png_df$class_folder)

# Loop through each class folder and write a separate .txt file
for (i in 1:length(class_folders)) {
  # Filter the data for the current class folder
  class_df <- filter(png_df, class_folder == class_folders[i])
  
  # Define the output file name
  output_file <- paste0(class_folders[i], ".txt")
  
  # Write the data frame to a tab-separated .txt file
  write.table(class_df, file = file.path("output/tångesund_from_png", output_file), sep = "\t", row.names = FALSE, col.names = TRUE, quote = FALSE)
}

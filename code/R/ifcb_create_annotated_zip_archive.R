source("code/R/fun/zip_png_folders.R")

# Define paths
ifcb_path <- Sys.getenv("ifcb_path")
main_directory <- file.path(ifcb_path, "png_images/Baltic/2024-05-21")
zip_file <- "output/Baltic.zip"

# Create zip archive
zip_png_folders(main_directory, zip_file)
source("code/R/fun/zip_png_folders.R")
source("code/R/fun/zip_manual_files.R")

# Get base path for ifcb data
# ifcb_path <- Sys.getenv("ifcb_path")
ifcb_path <- Sys.getenv("tangesund_path")

# Define stable paths
features_folder <- file.path(ifcb_path, "features") # Replace with the path to your features folder
data_folder <- file.path(ifcb_path, "data")

# Define dynamic paths
png_directory <- file.path(ifcb_path, "annotated_images")
manual_folder <- file.path(ifcb_path, "manual/2016") # Replace with the path to your .mat files folder
class2use_file <- file.path(ifcb_path, "config/class2use_Nov2022.mat")

# Define zip filenames
manual_zip_file <- "output/ifcb_tångesund_matlab_files.zip" # Replace with your desired zip file name
png_zip_file <- "output/ifcb_tångesund_images.zip"

# Define README file
readme_file <- "templates/README_tångesund-template.md"

# Create zip archives
zip_png_folders(png_directory, png_zip_file, readme_file)
zip_manual_files(manual_folder, features_folder, class2use_file, manual_zip_file, data_folder, readme_file)

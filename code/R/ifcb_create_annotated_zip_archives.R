library(tidyverse)

source("code/R/fun/zip_png_folders.R")
source("code/R/fun/zip_manual_files.R")

# Get base path for ifcb data
ifcb_path <- Sys.getenv("ifcb_path")
email_address <- Sys.getenv("email_address")
# ifcb_path <- Sys.getenv("tangesund_path")

# Define stable paths
features_folder <- file.path(ifcb_path, "features") # Replace with the path to your features folder
data_folder <- file.path(ifcb_path, "data")

# Define dynamic paths
# # Tångesund
# png_directory <- file.path(ifcb_path, "annotated_images")
# manual_folder <- file.path(ifcb_path, "manual/2016") # Replace with the path to your .mat files folder
# class2use_file <- file.path(ifcb_path, "config/class2use_Nov2022.mat")

# # Baltic
# png_directory <- file.path(ifcb_path, "png_images/Baltic/2024-05-28")
# manual_folder <- file.path(ifcb_path, "manual/Baltic") # Replace with the path to your .mat files folder
# class2use_file <- file.path(ifcb_path, "config/class2use_Baltic_inc_underscore.mat")

# Skagerrak-Kattegat
png_directory <- file.path(ifcb_path, "png_images/Skagerrak_Kattegat/2024-05-20")
manual_folder <- file.path(ifcb_path, "manual/Skagerrak-Kattegat") # Replace with the path to your .mat files folder
class2use_file <- file.path(ifcb_path, "config/class2use_Kattegat-Skagerrak.mat")

# Define zip filenames
# manual_zip_file <- "output/smhi_ifcb_baltic_matlab_files.zip" # Replace with your desired zip file name
# png_zip_file <- "output/smhi_ifcb_baltic_annotated_images.zip"

manual_zip_file <- "output/smhi_ifcb_skagerrak_kattegat_matlab_files.zip" # Replace with your desired zip file name
png_zip_file <- "output/smhi_ifcb_skagerrak_kattegat_annotated_images.zip"

# manual_zip_file <- "output/smhi_ifcb_tångesund_matlab_files.zip" # Replace with your desired zip file name
# png_zip_file <- "output/smhi_ifcb_tångesund_annotated_images.zip"

# Define README file
# readme_file <- "templates/README_baltic-template.md"
readme_file <- "templates/README_skagerrak-kattegat-template.md"
# readme_file <- "templates/README_tångesund-template.md"

# Create zip archives
zip_png_folders(png_directory, png_zip_file, readme_file, email_address)
zip_manual_files(manual_folder, features_folder, class2use_file, manual_zip_file, data_folder, readme_file, png_directory, email_address)

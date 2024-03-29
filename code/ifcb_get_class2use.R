library(tidyverse)

source("code/fun/get_class2use.R")

# Define your data paths
config_path <- ""
class2use_B_file <- "class2use_Baltic.mat"
class2use_SK_file <- "class2use_Kattegat-Skagerrak.mat"

# Create df with Baltic class2use, exluding unclassified
classes_baltic <- data.frame(
  taxa = get_class2use(file.path(config_path, class2use_B_file)),
  classifier = "Baltic") %>%
  filter(!taxa == "unclassified")

# Create df with SK class2use, exluding unclassified
classes_skagerrak_kattegat <- data.frame(
  taxa = get_class2use(file.path(config_path, class2use_SK_file)),
  classifier = "Skagerrak-Kattegat") %>%
    filter(!taxa == "unclassified")

# Bind tables
class2use_df <- rbind(classes_baltic, classes_skagerrak_kattegat)
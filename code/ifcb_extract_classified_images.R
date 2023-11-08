# Source functions
source("code/fun/extract_taxa_images.R")
source("code/fun/extract_taxa_images_from_ROI.R")

# Define your ifcb data path
ifcb_path <- ""

classifier <- "Baltic" #

year <- 2023

classifieddir <- paste(ifcb_path, "work/data/classified", classifier, year, sep = "/")

classifiedfiles <- list.files(classifieddir, pattern="mat$", full.names = FALSE, recursive = TRUE)

samples <- sub("_.*", "", classifiedfiles)

samples <- samples[1:10]

for(i in 1:length(samples)) {
  cat("Extracting sample ", i, "/", length(samples), "\n", sep = "")
  
  extract_taxa_images(samples[i], classifier, ifcb_path) 
}

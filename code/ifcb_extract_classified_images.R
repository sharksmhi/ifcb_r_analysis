# Source functions
source("code/fun/extract_taxa_images.R")
source("code/fun/extract_taxa_images_from_ROI.R")
source("code/fun/get_class2use.R")

# Define your ifcb data path
ifcb_path <- ""
config_path <- paste0(ifcb_path, "/config")
out_path <- "output/"
classifier_path_b <- paste0(ifcb_path, "/classified/Baltic/2023")
classifier_path_sk <- paste0(ifcb_path, "/classified/Skagerrak-Kattegat/2023")

# Define filenames
sample_classifier_file <- "sample_classifier.txt"
class2use_B_file <- "class2use_Baltic.mat"
class2use_SK_file <- "class2use_Kattegat-Skagerrak.mat"
classified_file <- "D20230311T092911_IFCB134_class_v1.mat"

# Choose taxa to extract
taxa_baltic <- data.frame(
  taxa = c("Centrales",
           "Chaetoceros chain",
           "Chaetoceros single cell",
           "Dinophysis acuminata",
           "Dinophysis norvegica",
           "Oocystis",
           "Pennales"),
  classifier = "Baltic")

taxa_west_coast <- data.frame(
  taxa = c("Ciliates",
           "Heterocapsa_rotundata",
           "Pennales_chain",
           "Prorocentrum_micans",
           "Strombidium_like"),
  classifier = "Skagerrak-Kattegat")

# Bind together
taxa_all <- rbind(taxa_baltic, taxa_west_coast)

# Create df with Baltic class2use, exluding unclassified
classes_baltic <- data.frame(
  taxa = get_class2use(file.path(config_path, class2use_B_file)),
  classifier = "Baltic") %>%
  filter(!taxa == "unclassified") %>%
  filter(!taxa %in% taxa_baltic$taxa) %>%
  filter(taxa %in% get_class2use(file.path(classifier_path_b, classified_file)))

# Create df with SK class2use, exluding unclassified
classes_skagerrak_kattegat <- data.frame(
  taxa = get_class2use(file.path(config_path, class2use_SK_file)),
  classifier = "Skagerrak-Kattegat") %>%
  filter(!taxa == "unclassified") %>%
  filter(taxa %in% get_class2use(file.path(classifier_path_sk, classified_file)))

# Bind tables
taxa_all <- rbind(classes_baltic, classes_skagerrak_kattegat)

# Choose which year
year <- 2023

# Read classifier output info from ifcb_assign_sea_basin_to_sample.R
classifier_info <- read_delim(file.path(out_path, sample_classifier_file), 
                          delim = "\t", 
                          col_names = TRUE, 
                          locale = locale(encoding = "UTF-8")) %>%
  mutate(sample = sub("_.*", "", tools::file_path_sans_ext(File))) %>%
  select(-gpsLatitude, -gpsLongitude, -rdate, -File)
  
# Define path to classified files
classifieddir <- paste(ifcb_path, "work/data/classified", sep = "/")

# List classified files
classifiedfiles <- list.files(classifieddir, pattern="mat$", full.names = FALSE, recursive = TRUE)

# Extract sample names
sample = unique(sub("_.*", "", basename(classifiedfiles)))

# #Subset a smaller set of samples (for testing)
# samples <- samples[1:10]

# Air bubbles in samples
bad_samples <- c("D20231016T063715", 
                "D20231016T070351", 
                "D20231016T073026", 
                "D20231016T075700", 
                "D20231016T082336") 

# Create dataframe and add classifier info from geographic information. 
# NA classifier occur when ship is close to land (in harbor)
samples_all <- as.data.frame(sample) %>%
  left_join(classifier_info) %>%
  filter(!is.na(classifier)) %>% 
  filter(!sample %in% bad_samples)

# Remove already extracted taxa
taxa_all <- taxa_all %>%
  filter(!paste(taxa, classifier) == "Nodularia Baltic") %>%
  filter(!paste(taxa, classifier) == "Aphanizomenon Baltic") %>%
  filter(!paste(taxa, classifier) == "Dolichospermum Baltic") %>%
  filter(!paste(taxa, classifier) == "Cryptomonadales Baltic") %>%
  filter(!paste(taxa, classifier) == "Dactyliosolen fragilissimus Baltic") %>%
  filter(!paste(taxa, classifier) == "Peridiniella catenata Baltic") %>%
  filter(!paste(taxa, classifier) == "Prorocentrum cordatum Baltic") %>%
  filter(!paste(taxa, classifier) == "Mesodinium rubrum Baltic") %>%
  filter(!paste(taxa, classifier) == "Skeletonema marinoi Baltic") %>%
  filter(!paste(taxa, classifier) == "Heterocapsa rotundata Baltic")

for(i in 1:length(taxa_all$taxa)) {
  
  taxa = taxa_all$taxa[i]

  samples <- samples_all %>%
    filter(classifier == taxa_all$classifier[i])
  
  for(j in 1:length(samples$sample)) {
    cat("Extracting ", taxa, " images from sample ", j, "/", length(samples$sample), "\n", sep = "")
    
    extract_taxa_images(samples$sample[j], samples$classifier[j], ifcb_path, taxa) 
    gc()
  }
  
}

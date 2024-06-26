# Source functions
source("code/R/fun/extract_taxa_images.R")
source("code/R/fun/extract_taxa_images_from_ROI.R")
source("code/R/fun/get_class2use.R")

# Define your ifcb data path
ifcb_path <- Sys.getenv("ifcb_path")
config_path <- paste0(ifcb_path, "/config")
out_path <- "output"
classifier_path_b <- paste0(ifcb_path, "/classified/Baltic/2023")
classifier_path_sk <- paste0(ifcb_path, "/classified/Skagerrak-Kattegat/2023")

# Define filenames
sample_classifier_file <- "sample_classifier.txt"
class2use_B_file <- "class2use_Baltic_inc_underscore.mat"
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
classifieddir <- paste(ifcb_path, "classified/Skagerrak-Kattegat/2023", sep = "/")
classifieddir2 <- paste(ifcb_path, "classified/Baltic/2023", sep = "/")

# List classified files
classifiedfiles <- c(list.files(classifieddir, pattern="mat$", full.names = FALSE, recursive = FALSE),
                     list.files(classifieddir2, pattern="mat$", full.names = FALSE, recursive = FALSE))

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

# # # Remove already extracted taxa
# taxa_all <- taxa_all %>%
#   filter(!paste(taxa, classifier) == "Nodularia Baltic") %>%
#   filter(!paste(taxa, classifier) == "Aphanizomenon Baltic") %>%
#   filter(!paste(taxa, classifier) == "Dolichospermum Baltic") %>%
  # filter(!paste(taxa, classifier) == "Cryptomonadales Baltic")
# #   filter(!paste(taxa, classifier) == "Dactyliosolen fragilissimus Baltic") %>%
#   filter(!paste(taxa, classifier) == "Peridiniella_catenata Baltic") %>%
# #   filter(!paste(taxa, classifier) == "Prorocentrum cordatum Baltic") %>%
#   filter(!paste(taxa, classifier) == "Mesodinium_rubrum Baltic") %>%
# #   filter(!paste(taxa, classifier) == "Skeletonema marinoi Baltic") %>%
#     filter(!paste(taxa, classifier) == "Dinophysis_norvegica Baltic") %>%
#   filter(!paste(taxa, classifier) == "Dinophysis_acuminata Baltic")%>%
#   filter(!paste(taxa, classifier) == "Dactyliosolen_fragilissimus Baltic")%>%
#   filter(!paste(taxa, classifier) == "Prorocentrum_cordatum Baltic")%>%
#   filter(!paste(taxa, classifier) == "Chaetoceros_chain Baltic")%>%
#   filter(!paste(taxa, classifier) == "Chaetoceros_single_cell Baltic") %>%
#       filter(!paste(taxa, classifier) == "Heterocapsa_rotundata Baltic") %>%
#       filter(!paste(taxa, classifier) == "Skeletonema_marinoi Baltic") %>%
#   filter(!paste(taxa, classifier) == "Cryptomonadales Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Mesodinium_rubrum Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Cerataulina_pelagica Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Chaetoceros_chain Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Chaetoceros_single_cell Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Cylindrotheca_Nitzschia_longissima Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Dactyliosolen_fragilissimus Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Ditylum_brightwellii Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Guinardia_delicatula Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Guinardia_flaccida Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Leptocylindrus_danicus_minimus Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Pennales_chain Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Pseudo-nitzschia_spp Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Strombidium_like Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Pseudosolenia_calcar-avis Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Heterocapsa_rotundata Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Dino_larger_than_30unidentified Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Dino_smaller_than_30unidentified Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Thalassiosira_spp Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Thalassiosira_nordenskioeldii Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Thalassionema_nitzschioides Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Octactis_speculum Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Ditylum_brightwellii Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Skeletonema_marinoi Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Skeletonema_marinoi Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Skeletonema_marinoi Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Skeletonema_marinoi Skagerrak-Kattegat") %>%
#   filter(!paste(taxa, classifier) == "Skeletonema_marinoi Skagerrak-Kattegat") %>%
#   filter(!classifier == "Baltic")

for(i in 1:length(taxa_all$taxa)) {
  
  taxa = taxa_all$taxa[i]

  samples <- samples_all %>%
    filter(classifier == taxa_all$classifier[i])
  
  image_list <- list.files(file.path(ifcb_path, "classified_images", taxa_all$classifier[i], taxa))
  
  for(j in 1:length(samples$sample)) {
    
    if (!any(grepl(samples$sample[j], image_list))) {
      cat("Extracting ", taxa, " images from sample ", j, "/", length(samples$sample), "\n", sep = "")
      
      extract_taxa_images(samples$sample[j], samples$classifier[j], ifcb_path, taxa) 
      # gc()
    } else {
      cat("Skipping ", taxa, " images from already extracted sample ", j, "/", length(samples$sample), "\n", sep = "")
    }
  }
}

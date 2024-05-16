library(R.matlab)

# Define your ifcb data path
ifcb_path <- Sys.getenv("ifcb_base_path")

classifier <- "Baltic" #

taxa <- "Cryptomonadales"

year <- 2023

imagedir <- paste(ifcb_path, "work/data/classified_images", classifier, taxa, sep = "/")
manualdir <- paste(ifcb_path, "work/data/manual", classifier, sep = "/")

imagefiles <- list.files(imagedir, pattern="png$", full.names = FALSE, recursive = TRUE)
manualfiles <- list.files(manualdir, pattern="mat$", full.names = FALSE, recursive = TRUE)

sample <- sub("_.*", "", imagefiles)
roi <- as.numeric(gsub(".*[_]([^.]+)[.].*", "\\1", imagefiles))

annotated.df <- data.frame(roi, taxa, sample)

manual.mat <- readMat(file.path(manualdir, paste0(sample[1], "_IFCB134.mat")))

annotated_matrix <- annotated.df %>% 
  filter(sample == sample[1]) %>%
  mutate(taxa = 19) %>%
  select(-sample) %>%
  as.matrix()

for(i in 1:nrow(manual.mat$classlist)) {
  if(manual.mat$classlist[i,1] %in% annotated_matrix[,1]) {
    if(manual.mat$classlist[i,2] == 1) {
      manual.mat$classlist[i,2] <- unique(annotated_matrix[,2])
    }
  }
}

write.csv(manual.mat$classlist, file.path(manualdir, "additions", paste0(sample[1], "_IFCB134.csv")), row.names = FALSE)
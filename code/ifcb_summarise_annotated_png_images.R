library(tidyverse)

extraction_date <- "2024-03-26"
classifier <- "Skagerrak_Kattegat"

pngdir <- file.path("//winfs-utv/data/utv/ifcb/work/data/png_images", classifier, extraction_date)
plotdir <- paste0(here::here(),"/plots/classifier/")
outputdir <- paste0(here::here(),"/output/classifier/")

files <- list.files(pngdir, pattern="png$", full.names = TRUE, recursive = TRUE)

files_df <- tibble(
  dir = dirname(files)) %>% 
  count(dir) %>% 
  mutate(taxa = basename(dir),
         classifier = sub(".*/png_images/(.*?)/.*", "\\1", dir)) %>%
  arrange(desc(n))

sample_summary <- tibble(file = files,
                   filename = basename(files)) %>%
  mutate(sample_name = gsub("_IFCB.*", "", filename)) %>%
  count(sample_name, name = "n_images") %>%
  arrange(sample_name) %>%
  mutate(date = as.Date(substr(sample_name, 2, 9), format = "%Y%m%d")) %>%
  relocate(date)

for(i in 1:length(unique(files_df$classifier))) {
  files_df_ix <- files_df %>%
    filter(classifier == unique(files_df$classifier)[i])
  
  plot_ix <- files_df_ix %>% 
    ggplot(aes(x = taxa, y = n)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label=n), vjust=0.5, hjust = 0, angle = 90) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    xlab("") +
    scale_y_continuous(limits = c(0, max(files_df_ix$n)+0.1*max(files_df_ix$n))) +
    # geom_hline(yintercept = 50, color = "red") +
    ylab("number of annotated images") +
    ggtitle(unique(files_df_ix$classifier))
  
  ggsave(plot = plot_ix,
         path = plotdir,
         filename = paste0(unique(files_df_ix$classifier), "_n_images.png"),
         device = "png",
         units = "cm",
         width = 14,
         height = 14)
}

# Save data as a txt file
write.table(files_df, 
            paste0(outputdir, "n_images.txt"),
            sep = "\t",
            quote = FALSE, 
            na = "NA", 
            row.names=F)

# Save data as a txt file
write.table(sample_summary, 
            paste0(outputdir, classifier, "_", "n_images_per_sample", "_", extraction_date, ".txt"),
            sep = "\t",
            quote = FALSE, 
            na = "NA", 
            row.names=F)

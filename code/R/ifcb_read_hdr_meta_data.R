# Script description
# Read and save data in hdr files
# Bengt Karlson 13 March 2023
# paths are for Mac/UNIX
# Change / to \\ if Windows is used


# load libraries ----------------------------------------------------------

library(tidyverse) # includes ggplot2 tidyr etc
library(lubridate) # useful for workiing with dates
library(cowplot) # useul for combining multiple plots
library(scales)
library(ggthemes)
library(readbulk)
library(stringi)
library(here)

# set paths ----------------------------------------------------------

bpath<-here() # set base path
setwd(bpath) # set working directory

ifcb_dir <- Sys.getenv("ifcb_path")
datadir <- file.path(ifcb_dir, "data/2023/")

# define start and end dates ------------------------------------------
start_of_cruise <- ISOdatetime(2023,3,9,0,0,0, tz = "GMT")
end_of_cruise <- ISOdatetime(2023,3,14,23,59,59, tz = "GMT")

start_end <- c(start_of_cruise,end_of_cruise)

# load all light ship data, a large number of files ----
allifcb_data <- read_bulk(directory = datadir, 
                          subdirectories = TRUE,
                          extension = ".hdr",
                          data = NULL, 
                          verbose = TRUE,
                          fun = utils::read.table,
                          header = FALSE,
                          sep = " ",
                          skip=0,
                          # comment = " ",
                          nrows = 121)


variables <- variable.names(allifcb_data)

# remove colons (you do not want them in column names)
allifcb_data <- allifcb_data%>%
  mutate_if(is.character, str_replace_all, pattern = ':', replacement = '')



# remove unwanted variables
allifcb_data = allifcb_data  %>%
  filter(!V2 == "UTC") %>%
  filter(!V1 == "gpsTimeFromFix") %>%
  filter(!V1 == "ifcbTimeAtFix")





allaifcb_data_wide <- pivot_wider(data = allifcb_data,
                                  names_from = V1,
                                  values_from = V2)


# create date and time that R can use

# get the string for datetime

# step1
allaifcb_data_wide <- allaifcb_data_wide  %>%
  separate(
    col = "File",
    into = c("DateTime"),
    sep = "_IFCB134.adc",
    remove = FALSE,
    convert = FALSE,
    extra = "drop",
    fill = "right")


# remove D and T
allaifcb_data_wide <- allaifcb_data_wide  %>%
  mutate_at("DateTime", str_replace, "T", "")  %>%
  mutate_at("DateTime", str_replace, "D", "") 



allaifcb_data_wide = allaifcb_data_wide  %>%
  mutate(rdate = as.POSIXct(DateTime, "%Y%m%d%H%M%S", tz = 'GMT')) %>%
  mutate(ryear = year(rdate)) %>%
  mutate(rmonth = month(rdate)) %>%
  mutate(rday = day(rdate)) %>%
  mutate(rhour = hour(rdate)) %>%
  mutate(rmin = minute(rdate)) %>%
  mutate(rsec = second(rdate))

allaifcb_data_wide <- allaifcb_data_wide %>%
  select(!DateTime)


# #save the data as a txt file
write.table(allaifcb_data_wide, 
            "output/allifcb_data_wide_march_2023.txt",
            sep = "\t",
            quote = FALSE, 
            na = "NA", 
            row.names=F)


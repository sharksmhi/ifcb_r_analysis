# Script description
#
# Bengt Karlson 13 March 2022
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

# define start and end dates ------------------------------------------
start_of_cruise <- ISOdatetime(2023,3,0,0,0,0, tz = "GMT")
end_of_cruise <- ISOdatetime(2023,3,14,23,59,59, tz = "GMT")

start_end <- c(start_of_cruise,end_of_cruise)



# load all light ship data, a large number of files ----
allifcb_data <- read_bulk(directory = "data/IFCBdata_march_2023", 
                          subdirectories = FALSE,
                          extension = ".adc",
                          data = NULL, 
                          verbose = TRUE,
                          fun = utils::read.table,
                          header = FALSE,
                          sep = ",",
                          skip=0,
                          # na.strings = c("   -999.0000"),
                          col.names= c("trigger",
                                       "ADC_time",
                                       "PMTA",
                                       "PMTB",
                                       "PMTC",
                                       "PMTD",
                                       "peakA",
                                       "peakB",
                                       "peakC",
                                       "peakD",
                                       "time_of_flight",
                                       "grabtimestart",
                                       "grabtimeend",
                                       "ROIx",
                                       "ROIy",
                                       "ROIwidth",
                                       "ROIheight",
                                       "start_byte",
                                       "comparator_out",
                                       "STartPoint",
                                       "SignalLength",
                                       "status",
                                       "runtime",
                                       "inhibitTime"))


# create date and time that R can use

# get the string for datetime

# step1
allifcb_data <- allifcb_data  %>%
  separate(
    col = "File",
    into = c("DateTime"),
    sep = "_IFCB134.adc",
    remove = FALSE,
    convert = FALSE,
    extra = "drop",
    fill = "right")


# remove D and T
allifcb_data <- allifcb_data  %>%
  mutate_at("DateTime", str_replace, "T", "")  %>%
  mutate_at("DateTime", str_replace, "D", "") 

variables <- variable.names(allifcb_data)

  
allifcb_data = allifcb_data  %>%
  mutate(rdate = as.POSIXct(DateTime, "%Y%m%d%H%M%S", tz = 'GMT')) %>%
  mutate(ryear = year(rdate)) %>%
  mutate(rmonth = month(rdate)) %>%
  mutate(rday = day(rdate)) %>%
  mutate(rhour = hour(rdate)) %>%
  mutate(rmin = minute(rdate)) %>%
  mutate(rsec = second(rdate))

variables <- variable.names(allifcb_data)

# #save the data as a txt file
write.table(allifcb_data, 
            "output/allifcb_data_march_2022.txt",
            sep = "\t",
            quote = FALSE, 
            na = "NA", 
            row.names=F)


# find unique sampling occassions

ifcb_samples <-
  distinct_at(allifcb_data, vars(File,DateTime,rdate))


# calculate time between sampling

ifcb_samples = ifcb_samples  %>%
  mutate(time_between_samples = rdate - lag(rdate-1))

write.table(ifcb_samples, 
            "output/ifcb_samples_july_2022.txt",
            sep = "\t",
            quote = FALSE, 
            na = "NA", 
            row.names=F)


# calculate number of ROIs per Litre

ifcb_trigger_count <- allifcb_data %>%
  select(DateTime,rdate,trigger) %>%
  group_by(DateTime,rdate)%>%
  summarise(number_of_triggers = max(trigger))


ifcb_roi_count <- allifcb_data %>%
  select(DateTime,rdate,ROIwidth) %>%
  filter(ROIwidth > 0) %>%
  group_by(DateTime,rdate)%>%
  summarise(number_of_rois = n())

# ifcb_roi_count <- ifcb_roi_count %>%
#   ungroup() %>%
#   select(number_of_rois)

# ifcb_data_summary <- bind_cols(ifcb_trigger_count,ifcb_roi_count)

# plot sample versus time

time_between_samples_plot <- ifcb_samples %>%
  ggplot() +
  aes(x = rdate,
      y = time_between_samples) +
  
  geom_point(size = 0.5) +
  ggtitle("Time between samples",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  ylim(20,60) +
ylab("Minutes between samples") +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

time_between_samples_plot



# plot sample versus time

trigger_plot <- ifcb_trigger_count %>%
  ggplot() +
  aes(x = rdate,
      y = number_of_triggers) +
  geom_point(size = 0.5) +
  ggtitle("Number of triggers per sample",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
   ylab("Number of triggers") +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

trigger_plot


roi_plot <- ifcb_roi_count %>%
  ggplot() +
  aes(x = rdate,
      y = number_of_rois) +

  geom_point(size = 0.5) +
  ggtitle("Number of ROIs (~cells) per sample",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  ylab("Number of ROIs") +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

roi_plot


# next plot
roi_height_plot <- allifcb_data %>%
  ggplot() +
  aes(x = rdate,
      y = ROIheight) +
  geom_point(size = 0.5) +
  ggtitle("R/V Svea, IFCB samples",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

roi_height_plot

# next plot
roi_width_plot <- allifcb_data %>%
  ggplot() +
  aes(x = rdate,
      y = ROIwidth) +
  geom_point(size = 0.5) +
  ggtitle("R/V Svea, IFCB samples",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

roi_width_plot


# next plot
pmta_plot <- allifcb_data %>%
  ggplot() +
  aes(x = rdate,
      y = PMTA) +
  geom_point(size = 0.5) +
  ggtitle("R/V Svea, IFCB samples",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

pmta_plot

# next plot
pmtb_plot <- allifcb_data %>%
  ggplot() +
  aes(x = rdate,
      y = PMTB) +
  geom_point(size = 0.5,
             colour = "darkgreen") +
  ggtitle("Chl. fluor PMTB, integrated signal intensity",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  ylim(0,0.5) +
  xlab("Date") +
  ylab("Chl. fluor PMTB") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

pmtb_plot


# next plot
pmtc_plot <- allifcb_data %>%
  ggplot() +
  aes(x = rdate,
      y = PMTC) +
  geom_point(size = 0.5) +
  ggtitle("R/V Svea, IFCB samples",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

pmtc_plot

# next plot
pmtd_plot <- allifcb_data %>%
  ggplot() +
  aes(x = rdate,
      y = PMTD) +
  geom_point(size = 0.5) +
  ggtitle("R/V Svea, IFCB samples",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

pmtd_plot

# next plot
pmta_vs_pmtb_plot <- allifcb_data %>%
  ggplot() +
  aes(x = PMTA,
      y = PMTB) +
  geom_point(size = 0.5) +
  ggtitle("chl. fluor . vs side scatter",
          subtitle = "R/V Svea, July 2022") +
  # scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  # xlab("Date") +
  xlab("PMTA side scatter") +
  ylab("PMTB chl. fluor.") +
  ylim(0,0.5) +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

pmta_vs_pmtb_plot


# next plot
peaka_plot <- allifcb_data %>%
  ggplot() +
  aes(x = rdate,
      y = peakA) +
  geom_point(size = 0.5) +
  ggtitle("R/V Svea, IFCB samples",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

peaka_plot


# next plot
peakb_plot <- allifcb_data %>%
  ggplot() +
  aes(x = rdate,
      y = peakB) +
  geom_point(size = 0.5,
             colour = "green") +
  ggtitle("Peak chl. fluorescence, peakB",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

peakb_plot

# next plot
inhibit_time_plot <- allifcb_data %>%
  ggplot() +
  aes(x = rdate,
      y = inhibitTime) +
  geom_point(size = 0.5) +
  ggtitle("Inhibit time, sec.",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())

inhibit_time_plot

# next plot
runtime_plot <- allifcb_data %>%
  ggplot() +
  aes(x = rdate,
      y = runtime) +
  geom_point(size = 0.5) +
  ggtitle("Runtime, sec.",
          subtitle = "R/V Svea, July 2022") +
  scale_x_datetime(date_breaks = "1 day",date_labels = "%d", limits = c(start_of_cruise,end_of_cruise)) +
  xlab("Date") +
  theme_bw() +
  theme(plot.title = element_text(lineheight=.8, face="bold",hjust = 0.5),
        # panel.grid.major = element_line(colour = 'black', linetype = 'dotted'),
        # panel.grid.minor = element_line(colour = 'black', linetype = 'dotted'),
        legend.position="right",
        legend.title = element_blank())
runtime_plot


# combine eight plots
eigth_ifcb_plots <- plot_grid(trigger_plot,
                             roi_plot,
                             peakb_plot,
                             pmtb_plot,
                             pmta_vs_pmtb_plot,
                             runtime_plot,
                             inhibit_time_plot,
                             time_between_samples_plot,
                             nrow = 4, 
                             ncol = 2,
                             align = 'v') 

print(eigth_ifcb_plots)

save_plot("plots/march_2023_eigth_ifcb_plots.png",
          eigth_ifcb_plots, base_height = 12,
          base_width = 8) #inches

# 
# # combine five plots ----
# five_ifcb_plots <- plot_grid(trigger_plot,
#                              roi_plot,
#                            peakb_plot,
#                            pmtb_plot,
#                            time_between_samples_plot,
#                            nrow = 5, 
#                            align = 'v') 
# 
# print(five_ifcb_plots)
# 
# save_plot("plots/five_ifcb_plots.png",
#           five_ifcb_plots, base_height = 12,
#           base_width = 8) #inches
# 

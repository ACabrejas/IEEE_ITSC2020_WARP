## Clear-all
rm(list = ls()) # Clear variables
graphics.off()  # Clear plots
cat("\014")     # Clear console

library(dplR)
library(data.table)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

source("./00_functions/get_link_data.R")
source("./00_functions/wt.plot.R")


## Choose motorway
mX <- "m6"
wavelet_name = "morse"


load(paste('./01_raw_data/',mX,'_data_selected_and_links_list_A.RData', sep = ''))
links_list = links_list_df$link_id
link = links_list[1]
i=which(links_list==link)

link_data = get_link_data(mX, i, wavelet_name, link)

tt_wt = morlet(link_data$travel_time - mean(link_data$travel_time))
ba_wt = morlet(link_data$background - mean(link_data$background))

qscales = quantile(tt_wt$Power, probs = (0:10)/10)

wt.plot(tt_wt,wavelet.levels = qscales,
             add.coi = TRUE, add.sig = FALSE,
             x.lab = gettext("Time [weeks]", domain = "R-dplR"),
             period.lab = gettext("Period [minutes]                                         ", domain = "R-dplR"),
             crn.lab = gettext("De-Trended Travel Time [seconds]", domain = "R-dplR"),
             key.lab = parse(text=paste0("\"",
                                         gettext("Power",
                                                 domain="R-dplR"),
                                         "\"^2")),
             add.spline = FALSE, f = 0.5, nyrs = NULL,
             crn.col = "black", crn.lwd = 1,coi.col='black',
             side.by.side = F,
             useRaster = FALSE, res = 150, reverse.y = FALSE)

wt.plot(ba_wt,wavelet.levels = qscales,
             add.coi = TRUE, add.sig = FALSE,
             x.lab = gettext("Time [weeks]", domain = "R-dplR"),
             period.lab = gettext("Period [minutes]                                         ", domain = "R-dplR"),
             crn.lab = gettext("De-Trended Processed Background [seconds]", domain = "R-dplR"),
             key.lab = parse(text=paste0("\"",
                                         gettext("Power",
                                                 domain="R-dplR"),
                                         "\"^2")),
             add.spline = FALSE, f = 0.5, nyrs = NULL,
             crn.col = "black", crn.lwd = 1,coi.col='black',
             side.by.side = F,
             useRaster = FALSE, res = 150, reverse.y = FALSE)


## Clear-all
rm(list = ls()) # Clear variables
graphics.off()  # Clear plots
cat("\014")     # Clear console

library(data.table)
library(rlist)
library(ggplot2)
library(reshape2)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

## Choose motorway
mX <- "m11"

wavelet_name = "morse"

if (mX == "m25") {
  data_length = 106560
} else {
  data_length = 120960
}

load(paste('./01_raw_data/',mX,'_data_selected_and_links_list_A.RData', sep = ''))
links_list = links_list_df$link_id
link = links_list[1]

## Recalculate?
recalculate = F
testrun = F
save_results = T
## Custom quantile range start (All, top 95% and top 99% are always included)
custom_quantile_start = 50

## SOURCE FILES (user functions)
source("./00_functions/plots_profiles.R")
source("./00_functions/rms_error.R")
source("./00_functions/data_length.R")
source("./00_functions/get_link_data.R")
source("./00_functions/get_method_parameters.R")
source("./00_functions/create_profile_storage.R")
source("./00_functions/calculate_profile.R")
source("./00_functions/relative_errors.R")
source("./00_functions/relative_errors_neg.R")
source("./00_functions/density_errors.R")
source("./00_functions/basic_errors.R")
source("./00_functions/daytime_errors.R")
source("./00_functions/errors_across_links.R")
source("./00_functions/Fourier_Profile.R")
source("./00_functions/Thales_Profile.R")
source("./00_functions/Null_Profile.R")
source("./00_functions/STL_Profile.R")
source("./00_functions/Hybrid_Profile.R")
source("./00_functions/ewmaweights.R")
source("./00_functions/Segmentation_Profile.R")
source("./00_functions/hybrid_profile_new.R")

labels_mx = c("M6", "M11", "M25")
if(mX=="m6"){label_mx = labels_mx[1]}else if(mX=="m11"){label_mx = labels_mx[2]}else if(mX=="m25"){label_mx=labels_mx[3]}

length_weeks = data_length(mX)

## LOOP THROUGH LINKS AND CALCULATE PROFILES
for (link in links_list) {
  
  print(paste("Calculating link number ",which(links_list==link),"/",length(links_list),". ID: ",link, ". Progress for current run = ", round(100*which(links_list==link)/length(links_list),2),"%.", sep = ""))
  
  i = which(link == links_list)
  
  
  link_data = get_link_data(mX, i, wavelet_name, link)
  
  # Forecasts from currently used model
  thales_results = calculate_profile(profile_algorithm = "thales", profile_storage = thales_results)
  # Forecasts always the median travel time for the link
  null_results = calculate_profile(profile_algorithm = "null", profile_storage = null_results)
  # Forecasts using FFT
  fourier_results = calculate_profile(profile_algorithm = "fourier", profile_storage = fourier_results)
  # Forecasts using STL
  stl_results = calculate_profile(profile_algorithm = "stl", profile_storage = stl_results)
  # Hybrid Fourier-STL forecasts
  hybrid_results = calculate_profile(profile_algorithm = "hybrid", profile_storage = hybrid_results)
  # Naive segmentation
  segmentation_results = calculate_profile(profile_algorithm = "segmentation", profile_storage = segmentation_results)
  
  
  #rm(link_data)
}

## CALCULATE ERRORS ACROSS LINKS
fourier_results = errors_across_links(profile_storage = fourier_results)
thales_results = errors_across_links(profile_storage = thales_results)
null_results = errors_across_links(profile_storage = null_results)
stl_results = errors_across_links(profile_storage = stl_results)
hybrid_results = errors_across_links(profile_storage = hybrid_results)
segmentation_results = errors_across_links(profile_storage = segmentation_results)


# RESULTS CHECK ON A GLOBAL BASIS
# Daytime
relative_error_daytime("Relative")
relative_error_daytime("Negative")
relative_error_daytime("Density")

# Results percentile errors
quantile_error(quantile = 1, error_type = "ab")
quantile_error(quantile = 95, error_type ="ab")
quantile_error(quantile = 99, error_type ="ab")
quantile_error(quantile = custom_quantile_start, error_type ="ab")

quantile_error(quantile = 1, error_type ="rms")
quantile_error(quantile = 95, error_type ="rms")
quantile_error(quantile = 99, error_type ="rms")
quantile_error(quantile = custom_quantile_start, error_type ="rms")

# Results relative errors over time
relative_error_timeseries("Relative")
relative_error_timeseries("Negative")
relative_error_timeseries("Density")

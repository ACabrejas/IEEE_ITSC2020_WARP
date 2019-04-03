create_profile_storage = function() {
  
  output = list()
  

  ### FOR ALL SERIES, DEPENDING ON WHETHER THEY ARE CHOSEN AS OUTPUTS:
  #1. Define error vectors:
  ## Vectors for rms (root mean square) of percentage errors of each quantile of each link
  ## Vectors for mean of absolute percentage error of each quantile of each link
  ## Vectors for sum of absolute percentage error of each link in background mode
  ## Vectors for sum of absolute percentage error of each link in spikes mode
  ## Daytime errors
  ## Daytime density weighted errors
  #2. Aggregate them in their corresponding data frames
  
  # Storage for calculated profile
  profile <- matrix(-1,nrow = length(links_list), ncol =  (1440*7*length_weeks$pred_weeks))
  
  # Storage for profile's relative error
  relative_error <- matrix(-1,nrow = length(links_list), ncol =  (1440*7*length_weeks$pred_weeks))
  density_error <- matrix(-1,nrow = length(links_list), ncol =  (1440*7*length_weeks$pred_weeks))
  relative_error_neg <- matrix(-1,nrow = length(links_list), ncol =  (1440*7*length_weeks$pred_weeks))
  
  relative_errors = list(relative_error = relative_error, density_error = density_error, relative_error_neg = relative_error_neg)
  
  
  # Storage for the Quantile Related Errors (calculated on a per-link basis)
  rms_error <- matrix(rep(-1,(length(links_list)*100)),nrow=length(links_list),ncol=100) 
  ab_error <- matrix(rep(-1,(length(links_list)*100)),nrow=length(links_list),ncol=100) 
  rms_error95 <- matrix(rep(-1,(length(links_list)*100)),nrow=length(links_list),ncol=100) 
  ab_error95 <- matrix(rep(-1,(length(links_list)*100)),nrow=length(links_list),ncol=100) 
  rms_error99 <- matrix(rep(-1,(length(links_list)*100)),nrow=length(links_list),ncol=100) 
  ab_error99 <- matrix(rep(-1,(length(links_list)*100)),nrow=length(links_list),ncol=100)
  rms_error_custom <- matrix(rep(-1,(length(links_list)*100)),nrow=length(links_list),ncol=100)
  ab_error_custom <- matrix(rep(-1,(length(links_list)*100)),nrow=length(links_list),ncol=100)
  
  quantile_errors = list(rms_error = rms_error, rms_error95 = rms_error95, rms_error99 = rms_error99, rms_error_custom = rms_error_custom,
                         ab_error = ab_error, ab_error95 = ab_error95, ab_error99 = ab_error99, ab_error_custom = ab_error_custom)
  
  # Storage for Quantile Average Errors (across links for same quantiles)
  rms_error_avg = rep(-1,100)
  ab_error_avg = rep(-1,100)
  rms_error95_avg = rep(-1,100)
  ab_error95_avg = rep(-1,100)
  rms_error99_avg = rep(-1,100)
  ab_error99_avg = rep(-1,100)
  rms_error_custom_avg = rep(-1,100)
  ab_error_custom_avg = rep(-1,100)
  
  quantile_errors_avg = list(rms_error_avg = rms_error_avg, rms_error95_avg = rms_error95_avg, rms_error99_avg = rms_error99_avg, rms_error_custom_avg = rms_error_custom_avg,
                             ab_error_avg = ab_error_avg, ab_error95_avg = ab_error95_avg, ab_error99_avg = ab_error99_avg, ab_error_custom_avg = ab_error_custom_avg)
  
  # Storage for mean errors
  mean_ab_error_background <- rep(-1,(length(links_list)))
  mean_ab_error_background_errorbarplus <- rep(-1,(length(links_list)))
  mean_ab_error_background_errorbarminus <- rep(-1,(length(links_list)))
  
  mean_ab_error_spikes <- rep(-1,(length(links_list)))
  mean_ab_error_spikes_errorbarplus <- rep(-1,(length(links_list)))
  mean_ab_error_spikes_errorbarminus <- rep(-1,(length(links_list)))
  
  
  mean_ab_errors = data.frame(mean_ab_error_background, mean_ab_error_spikes, mean_ab_error_background_errorbarplus, mean_ab_error_background_errorbarminus,
                              mean_ab_error_spikes_errorbarplus, mean_ab_error_background_errorbarminus)
  
  # Storage for daytime errors matrix
  day_time_error_matrix <- matrix(rep(-1,(length(links_list)*1440)),nrow=length(links_list),ncol=1440)
  day_time_error_neg_matrix<- matrix(rep(-1,(length(links_list)*1440)),nrow=length(links_list),ncol=1440)
  day_time_density_error_matrix <- matrix(rep(-1,(length(links_list)*1440)),nrow=length(links_list),ncol=1440)
  
  day_time_error_matrices = list(day_time_error_matrix = day_time_error_matrix, day_time_error_neg_matrix = day_time_error_neg_matrix,
                                 day_time_density_error_matrix = day_time_density_error_matrix)
  
  # Storage for datime errors
  day_time_error <- rep(-1,1440)
  day_time_error_neg <- rep(-1,1440)
  day_time_density_error <- rep(-1,1440)
  
  daytime_errors = data.frame(day_time_error, day_time_error_neg, day_time_density_error)
  
  output_param = list(profile = profile, relative_errors = relative_errors, quantile_errors = quantile_errors,day_time_error_matrices = day_time_error_matrices , 
                      mean_ab_errors = mean_ab_errors, quantile_errors_avg = quantile_errors_avg, daytime_errors = daytime_errors)
  
  
  output = output_param
 


return(output)
}
errors_across_links = function(profile_storage, method, spike_parameter) {
  ## Quantile error calculation across links
  for (k in 1:100) {

    profile_storage$quantile_errors_avg$rms_error_avg[k] =        mean(profile_storage$quantile_errors$rms_error[,k])
    profile_storage$quantile_errors_avg$rms_error95_avg[k] =      mean(profile_storage$quantile_errors$rms_error95[,k])
    profile_storage$quantile_errors_avg$rms_error99_avg[k] =      mean(profile_storage$quantile_errors$rms_error99[,k])
    profile_storage$quantile_errors_avg$rms_error_custom_avg[k] = mean(profile_storage$quantile_errors$rms_error_custom[,k])
    
    profile_storage$quantile_errors_avg$ab_error_avg[k] =         mean(profile_storage$quantile_errors$ab_error[,k])
    profile_storage$quantile_errors_avg$ab_error95_avg[k] =       mean(profile_storage$quantile_errors$ab_error95[,k])
    profile_storage$quantile_errors_avg$ab_error99_avg[k] =       mean(profile_storage$quantile_errors$ab_error99[,k])
    profile_storage$quantile_errors_avg$ab_error_custom_avg[k] =  mean(profile_storage$quantile_errors$ab_error_custom[,k])
  }
  ## Daytime error calculation across links
  day_time_arrow <- seq(1,1440,by=1)/60
  for (k in 1:1440) {
    
    profile_storage$daytime_errors$day_time_error[k] =         mean(profile_storage$day_time_error_matrices$day_time_error_matrix[,k])
    profile_storage$daytime_errors$day_time_error_neg[k] =     mean(profile_storage$day_time_error_matrices$day_time_error_neg_matrix[,k])
    profile_storage$daytime_errors$day_time_density_error[k] = mean(profile_storage$day_time_error_matrices$day_time_density_error_matrix[,k])
  }
  
  return(profile_storage)
}
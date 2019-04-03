daytime_errors = function() {
  # Cycle through minutes of the day
  for (k in 1:1440) {
    # Create a vector that will select the same minute of a day across all prediction days
    seqq <- seq(k,(1440*7*length_weeks$pred_weeks),by=1440)
    # Compute mean of the absolute values of the relative errors
    profile_storage$day_time_error_matrices$day_time_error_matrix[which(links_list==link),k] = mean(abs(profile_storage$relative_errors$relative_error[which(links_list == link), seqq]))
    # Compute mean of the absolute values of the negative relative errors
    profile_storage$day_time_error_matrices$day_time_error_neg_matrix[which(links_list==link),k] = mean(abs(profile_storage$relative_errors$density_error[which(links_list == link), seqq]))
    # Compute mean of the absolute values of the relative erros times the flow
    profile_storage$day_time_error_matrices$day_time_density_error_matrix[which(links_list==link),k] = mean(abs(profile_storage$relative_errors$relative_error_neg[which(links_list == link), seqq]))
  }
}
hybrid_profile = function() {
  hybrid_profile <- rep(-1,(1440*7*length_weeks$pred_weeks))
  spike_flag = link_data$spike_flag[((length_weeks$train_weeks*7*1440)+1) :(1440*7*length_weeks$total_weeks)]

  hybrid_profile[spike_flag==0] <- fourier_results$profile[which(links_list==link), spike_flag == 0]
  hybrid_profile[spike_flag==1] <- stl_results$profile[which(links_list==link), spike_flag == 1] 
  
  return(hybrid_profile)
}
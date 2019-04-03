calculate_profile = function(profile_algorithm, profile_storage){
  
  ################################################ 
  ## --- COMMON SECTION I: STORAGE CREATION --- ##
  ################################################
  
  # Create packed containers for corresponding profile
  if (link == links_list[1]  ) {
    profile_storage = create_profile_storage()
    print(paste("STORAGE CREATED FOR",profile_algorithm, "PROFILE", sep = " "))
    }
    
  link_index = which(links_list == link)
  
  #####################################
  ## --- END OF COMMON SECTION I --- ##
  #####################################
  
  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  #######################################
  ## --- PROFILE SPECIFIC SECTION  --- ##
  #######################################
  
  # Select profile and execute its associated function
  # Rows are links, columns are minutes for the profile
  if (profile_algorithm == "fourier") {
    profile_storage$profile[link_index, ] = fourier_profile()
  } else if (profile_algorithm == "thales") {
    profile_storage$profile[link_index,] = thales_profile()
  } else if (profile_algorithm == "null") {
    profile_storage$profile[link_index,] = null_profile()
  } else if (profile_algorithm == "stl") {
    profile_storage$profile[link_index,] = stl_profile(use_background_and_spikes = T, automatic_settings_day = F, automatic_settings_week = F, automatic_settings_spike = T,
                                                       automatic_nl_nt = T, compute_average_seasonality = T, compute_linear_trend = T)
  } else if (profile_algorithm == "hybrid") {
    # Requires STL and Hybrid to run first
    profile_storage$profile[link_index,] = hybrid_profile()
  } else if (profile_algorithm == "wavelet") {
    
  } else if (profile_algorithm == "segmentation") {
    profile_storage$profile[link_index,] = segmentation_profile(weight_type = "uniform")
  } else if (profile_algorithm == "hybrid_new") {
    profile_storage$profile[link_index,] = hybrid_profile_new(automatic_settings_spike = T, automatic_nl_nt = T)
  }
  ##########################################
  ## --- END PROFILE SPECIFIC SECTION --- ##
  ##########################################  
  
  #////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  ################################################################
  ## --- COMMON SECTION TO ALL PROFILES: ERRORS CALCULATION --- ##
  ################################################################
  
  ## COMPUTE BASIC ERRORS (relative error, relative negative error, relative error scaled by flow)
  # Relative error
  profile_storage$relative_errors$relative_error[link_index,] = relative_errors(calculated_profile = profile_storage$profile[link_index,], test_data = link_data$travel_time[(1+(1440*7*(length_weeks$train_weeks))):(1440*7*(length_weeks$total_weeks))])
  # Relative error * flow
  profile_storage$relative_errors$density_error[link_index,] = density_errors(calculated_profile = profile_storage$profile[link_index,], test_data = link_data$travel_time[(1+(1440*7*(length_weeks$train_weeks))):(1440*7*(length_weeks$total_weeks))])
  # Negative only relative errors (error<0 -> forecast is smaller than measurement for point, we predict less than we find, interesting under the assumption that no one complains from being home early )
  profile_storage$relative_errors$relative_error_neg[link_index,] = relative_errors_neg(input = profile_storage$relative_errors$relative_error[link_index,])
  
  
  ## COMPUTE DAYTIME ERRORS
  # Cycle through minutes of the day
  for (k in 1:1440) {
    # Create a vector that will select the same minute of a day across all prediction days
    seqq <- seq(k,(1440*7*length_weeks$pred_weeks),by=1440)
    # Compute mean of the absolute values of the relative errors
    profile_storage$day_time_error_matrices$day_time_error_matrix[link_index,k] = mean(abs(profile_storage$relative_errors$relative_error[link_index, seqq]))
    # Compute mean of the absolute values of the negative relative errors
    profile_storage$day_time_error_matrices$day_time_error_neg_matrix[link_index,k] = mean(abs(profile_storage$relative_errors$relative_error_neg[link_index, seqq]))
    # Compute mean of the absolute values of the relative erros times the flow
    profile_storage$day_time_error_matrices$day_time_density_error_matrix[link_index,k] = mean(abs(profile_storage$relative_errors$density_error[link_index, seqq]))
  }  
  
  
  ## COMPUTE QUANTILE OF TRAVEL TIME ERRORS
  # Create container for errors ordered according to travel times
  error_df = data.frame(travel_time = link_data$travel_time[(1+(1440*7*(length_weeks$train_weeks))):(1440*7*(length_weeks$total_weeks))], relative_error = profile_storage$relative_errors$relative_error[link_index,])
  error_df_sorted = error_df[order(error_df$travel_time),]
  
  # Set quantile range
  quantiles_requested = c(1, 95, 99, custom_quantile_start)
  for (quant in quantiles_requested) {
  q_range <- (length(link_data$travel_time[(1+(1440*7*(length_weeks$train_weeks))):(1440*7*(length_weeks$total_weeks))])/100)/(100/(100-quant))
  q_start <- length(link_data$travel_time[(1+(1440*7*(length_weeks$train_weeks))):(1440*7*(length_weeks$total_weeks))])*quant/100
  
  # Calculate rms and mean-absolute of percentage errors of profiles against travel time for all quantiles
    for (k in 1:100) {
      # Place the results for each quantile range in the appropriate container
      if (quant == 1) {
        profile_storage$quantile_errors$rms_error[link_index,k] = rms(error_df_sorted$relative_error[floor(q_start+1+q_range*(k-1)):ceiling(q_start+q_range*k)])
        profile_storage$quantile_errors$ab_error[link_index,k] =  mean(abs(error_df_sorted$relative_error[floor(q_start+1+q_range*(k-1)):ceiling(q_start+q_range*k)]))
      } else if (quant == 95) {
        profile_storage$quantile_errors$rms_error95[link_index,k] = rms(error_df_sorted$relative_error[floor(q_start+1+q_range*(k-1)):ceiling(q_start+q_range*k)])
        profile_storage$quantile_errors$ab_error95[link_index,k] =  mean(abs(error_df_sorted$relative_error[floor(q_start+1+q_range*(k-1)):ceiling(q_start+q_range*k)]))
      } else if (quant == 99) {
        profile_storage$quantile_errors$rms_error99[link_index,k] = rms(error_df_sorted$relative_error[floor(q_start+1+q_range*(k-1)):ceiling(q_start+q_range*k)])
        profile_storage$quantile_errors$ab_error99[link_index,k] =  mean(abs(error_df_sorted$relative_error[floor(q_start+1+q_range*(k-1)):ceiling(q_start+q_range*k)]))
      } else if (quant == custom_quantile_start) {
        profile_storage$quantile_errors$rms_error_custom[link_index,k] = rms(error_df_sorted$relative_error[floor(q_start+1+q_range*(k-1)):ceiling(q_start+q_range*k)])
        profile_storage$quantile_errors$ab_error_custom[link_index,k] =  mean(abs(error_df_sorted$relative_error[floor(q_start+1+q_range*(k-1)):ceiling(q_start+q_range*k)]))
      }
    }
  }
  
  ## CALCULATE SUMMARY ERRORS
  # Calculate the mean of absolute errors for background mode and spike mode
  profile_storage$mean_ab_errors$mean_ab_error_background[link_index] = mean(abs(profile_storage$relative_errors$relative_error[link_index, link_data$spike_flag[(1+(1440*7*(length_weeks$train_weeks))):(1440*7*(length_weeks$total_weeks))] == 0]))
  profile_storage$mean_ab_errors$mean_ab_error_spikes[link_index] = mean(abs(profile_storage$relative_errors$relative_error[link_index, link_data$spike_flag[(1+(1440*7*(length_weeks$train_weeks))):(1440*7*(length_weeks$total_weeks))] == 1]))
  # Calculate error bars per link for the background and spikes [PENDING]
  #profile_storage$mean_ab_errors$mean_ab_error_background_errorbarplus[link_index] 
  #profile_storage$mean_ab_errors$mean_ab_error_background_errorbarminus[link_index]
  ######################################
  ## --- END OF COMMON SECTION II --- ##
  ######################################

  return(profile_storage)
}
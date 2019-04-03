hybrid_profile_new = function(automatic_settings_spike, automatic_nl_nt) {
  hybrid_profile <- rep(-1,(1440*7*length_weeks$pred_weeks))
  STL_spikes_profile <- rep(-1,(1440*7*length_weeks$pred_weeks))
  
  ###################
  for (i in 1:length_weeks$pred_weeks) {
    print(paste("Calculating STL SPIKE ONLY Profile. Current week: ", i,"/",length_weeks$pred_weeks,"."))
    
    
    # Get spikes for 8 weeks of training
    spikes_train <- link_data$spikes[(1+(1440*7*(i-1))):(1440*7*(i+length_weeks$span_weeks))]
    # Measurements per seasonal (week) cycle
    freq_spike = 10080
    # Create the time series
    spikes_train.ts <- ts(spikes_train, frequency = freq_spike)
    automatic_settings_spike=T
    ## STL Spikes Settings
    if (automatic_settings_spike == TRUE) {
      # Automatic case
      spikes_train.stl = stl(spikes_train.ts, s.window="periodic")
    } else {
      # Manual Parameters
      robust_s <- TRUE
      inner_s <- 1
      outer_s <- 15
      n_s_s <- 10081
      s_degree_s <- 0
      n_t_s <- 1.99*n_s_s
      t_degree_s <- 1
      l_degree_s <- 1
      automatic_nl_nt=T
      # Automatic Nl and Nt
      if (automatic_nl_nt == TRUE) {
        if(freq_week %% 2 == 0){                                   #Nl
          n_l_s = freq_week + 1
        } else {
          n_l_s = freq_week
        }
        
        if (ceiling((1.5*1440)/(1-(1.5/n_s_s))) %% 2 == 0) {      #Nt
          n_t_s = ceiling((1.5*1440)/(1-(1.5/n_s_s))) + 1
        } else {
          n_t_s = ceiling((1.5*1440)/(1-(1.5/n_s_s)))
        }
      }
      # STL for spikes, manual parameters execution
      spikes_train.stl = stl(background_train_week.ts, s.window = n_s_s, s.degree = s_degree_s, t.window = n_t_s, t.degree = t_degree_s,
                             l.window = n_l_s, l.degree = l_degree_s, s.jump = ceiling(n_s_2/10),
                             t.jump = ceiling(n_t_2/10), l.jump = ceiling(n_l_2/10),
                             robust = robust_s, inner = inner_s, outer = outer_s)
      
    }
    trend_spikes_train <- as.vector(spikes_train.stl$time.series[,"trend"])
    seasonal_spikes_train <- as.vector(spikes_train.stl$time.series[,"seasonal"])
    remainder_spikes_train <- as.vector(spikes_train.stl$time.series[,"remainder"])
    ## Calculate spikes STL seasonal prediction
    seasonal_spikes_pred <- seasonal_spikes_train[1:(1440*7)] 
    seasonal_spikes_pred[seasonal_spikes_pred < 0] <- 0
    ## Get spikes STL profile prediction
    STL_spikes_profile[(1+(1440*7*(i-1))):(1440*7*i)]  <- seasonal_spikes_pred

  }
  
  compute_average_seasonality = T
  
  if (compute_average_seasonality == TRUE) {
    STL_pred = rep(-1,10080)
    for (k in 1:10080) {
      seqq = seq(k,length_weeks$train_weeks*1440*3,10080)
      STL_pred[k] = mean(STL_spikes_profile[seqq])
    }
  } else {
    STL_pred <- STL_spikes_profile[1:(1440*7)]
  }
  
  STL_pred = rep(STL_pred, 4)
  
  ##################
  
  hybrid_profile <- fourier_results[[method]][[as.character(spike_parameter)]]$profile[which(links_list==link),] + STL_pred

  
  return(hybrid_profile)
  
}
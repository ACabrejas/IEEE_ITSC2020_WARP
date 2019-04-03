stl_profile = function(use_background_and_spikes, automatic_settings_day, automatic_settings_week, automatic_settings_spike,
                       automatic_nl_nt, compute_average_seasonality, compute_linear_trend) {
  ## Temporary storage
  STL_background_profile = rep(-1, (1440*7*length_weeks$pred_weeks))
  STL_spikes_profile = rep(-1, (1440*7*length_weeks$pred_weeks))
  STL_profile = rep(-1, (1440*7*length_weeks$pred_weeks))
  
  for (i in 1:length_weeks$pred_weeks) {
    print(paste("Calculating STL Profile. Current week: ", i,"/",length_weeks$pred_weeks,"."))

    ## Get traveltime and background for 8 weeks of training
    travel_time_train <- link_data$travel_time[(1+(1440*7*(i-1))):(1440*7*(i+length_weeks$span_weeks))]
    background_train <- link_data$background[(1+(1440*7*(i-1))):(1440*7*(i+length_weeks$span_weeks))]

    ##############################################    PART 1: BASIC STL - Daily Seasonality   ##################################
    # Measurements per seasonal (day) cycle
    freq_day = 1440
    
    #STL: Daily Manual Settings
    if (automatic_settings_day == FALSE) {
      robust_1 <- TRUE
      inner_1 <- 1
      outer_1 <- 15
      n_s <- 1441
      s_degree <- 1
      n_t <- 1.99*n_s
      t_degree <- 1
      l_degree <- 1
      
      # Automatic Nl and Nt
      if (automatic_nl_nt == TRUE) {
        if(freq_day %% 2 == 0){                               #Nl
          n_l = freq_day + 1
        } else {
          n_l = freq_day
        }
        if (ceiling((1.5*1440)/(1-(1.5/n_s))) %% 2 == 0) {    #Nt
          n_t = ceiling((1.5*1440)/(1-(1.5/n_s))) + 1
        } else {
          n_t = ceiling((1.5*1440)/(1-(1.5/n_s)))
        }
      }
    }
    
    #STL Daily Decomposition
    if (use_background_and_spikes == TRUE) {
      background_train_day.ts <- ts(background_train, frequency = freq_day)
    } else {
      background_train_day.ts <- ts(travel_time_train, frequency = freq_day)
    }
    if (automatic_settings_day == TRUE) {
      background_train_day.stl = stl(background_train_day.ts, s.window = 'periodic')
    } else {
      background_train_day.stl = stl(background_train_day.ts, s.window = n_s, s.degree = s_degree, t.window = n_t, t.degree = t_degree,
                                     l.window = n_l, l.degree = l_degree, s.jump = ceiling(n_s/10),
                                     t.jump = ceiling(n_t/10), l.jump = ceiling(n_l/10),
                                     robust = robust_1, inner = inner_1, outer = outer_1)
    }
    trend_background_train_day <- as.vector(background_train_day.stl$time.series[,"trend"])
    seasonal_background_train_day <- as.vector(background_train_day.stl$time.series[,"seasonal"])
    remainder_background_train_day <- as.vector(background_train_day.stl$time.series[,"remainder"])
    deseasonalised_day = trend_background_train_day + remainder_background_train_day
    
    ###############################################################################################################################
    
    
    
    ##############################################    PART 2: BASIC STL - Weekly Seasonality   ##################################
    # Measurements per seasonal (week) cycle
    freq_week = 10080
    
    #STL: Weekly Manual Settings
    if (automatic_settings_week == FALSE) {
      robust_2 <- TRUE
      inner_2 <- 1
      outer_2 <- 15
      n_s_2 <- 10081
      s_degree_2 <- 1
      n_t_2 <- 1.99*n_s_2
      t_degree_2 <- 1
      l_degree_2 <- 1
      
      # Automatic Nl and Nt
      if (automatic_nl_nt == TRUE) {
        if(freq_week %% 2 == 0){                                   #Nl
          n_l_2 = freq_week + 1
        } else {
          n_l_2 = freq_week
        }
        
        if (ceiling((1.5*1440)/(1-(1.5/n_s_2))) %% 2 == 0) {      #Nt
          n_t_2 = ceiling((1.5*1440)/(1-(1.5/n_s_2))) + 1
        } else {
          n_t_2 = ceiling((1.5*1440)/(1-(1.5/n_s_2)))
        }
      }
    }
    
    #STL Weekly Decomposition
    background_train_week.ts <- ts(deseasonalised_day, frequency = freq_week)
    if (automatic_settings_week == TRUE) {
      background_train_week.stl = stl(background_train_week.ts, s.window = 'periodic')
    } else {
      background_train_week.stl = stl(background_train_week.ts, s.window = n_s_2, s.degree = s_degree_2, t.window = n_t_2, t.degree = t_degree_2,
                                      l.window = n_l_2, l.degree = l_degree_2, s.jump = ceiling(n_s_2/10),
                                      t.jump = ceiling(n_t_2/10), l.jump = ceiling(n_l_2/10),
                                      robust = robust_2, inner = inner_2, outer = outer_2)
    }
    trend_background_train <- as.vector(background_train_week.stl$time.series[,"trend"])
    seasonal_background_train_week <- as.vector(background_train_week.stl$time.series[,"seasonal"])
    remainder_background_train <- as.vector(background_train_week.stl$time.series[,"remainder"])
    seasonal_background_train <- seasonal_background_train_day + seasonal_background_train_week
    
    ##################################################################################################################################################
    
    ##############################################    PART 3: Calculation of Seasonal and Trend components   #########################################
    
    # Seasonal Component to forecast, 2 options: a) Compute seasonal as average of minutes of the day from all training weeks.
    #                                            b) Use seasonal component of the week immediately before
    if (compute_average_seasonality == TRUE) {
      seasonal_background_pred = rep(-1,10080)
      for (k in 1:10080) {
        seqq = seq(k,length_weeks$train_weeks*1440*7,10080)
        seasonal_background_pred[k] = mean(seasonal_background_train[seqq])
      }
    } else {
      seasonal_background_pred <- seasonal_background_train[1:(1440*7)]
    }
    
    
    
    ## Make background STL trend prediction
    t_train <- seq(1,(1440*7*length_weeks$train_weeks),by=1) # Time axis for eight weeks (training)
    linear_model <- lm(trend_background_train ~ t_train)
    b <- as.numeric(linear_model$coefficients[1]) # y-intercept
    m <- as.numeric(linear_model$coefficients[2]) # Slope
    t_pred <- seq((1440*7*length_weeks$train_weeks+1),(1440*7*(length_weeks$train_weeks+1)),by=1) # Time axis for ninth week (testing)
    t_span <- c(t_train,t_pred)
    temp <- rep(0,length(t_span))
    for (k in 1:length(t_span)) {
      temp[k] <- b + k*m
    }
    trend_background_pred <- temp[(1440*7*length_weeks$train_weeks+1):(1440*7*(length_weeks$train_weeks+1))]
    
    ## Make background STL profile prediction
    if(compute_linear_trend == TRUE) {
      STL_background_profile[(1+(1440*7*(i-1))):(1440*7*i)] <- trend_background_pred + seasonal_background_pred
      #STL_background_profile[(1+(1440*7*(i+length_weeks$span_weeks))):(1440*7*(i+length_weeks$train_weeks))] <- trend_background_pred + seasonal_background_pred
    } else {
      STL_background_profile[(1+(1440*7*(i-1))):(1440*7*i)] <- median(trend_background_pred) + seasonal_background_pred
      #STL_background_profile[(1+(1440*7*(i+length_weeks$span_weeks))):(1440*7*(i+length_weeks$train_weeks))] <- median(trend_background_pred) + seasonal_background_pred
    }
    ##################################################################################################################################################
    
    ##############################################    PART 4: Background + Spikes STL, calculation of spikes   #######################################
    
    ## Calculate STL Spikes Component
    if (use_background_and_spikes == TRUE) {
      
      # Get spikes for 8 weeks of training
      spikes_train <- link_data$spikes[(1+(1440*7*(i-1))):(1440*7*(i+length_weeks$span_weeks))]
      # Measurements per seasonal (week) cycle
      freq_spike = 10080
      # Create the time series
      spikes_train.ts <- ts(spikes_train, frequency = freq_spike)
      
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
      #STL_spikes_profile[(1+(1440*7*(i+length_weeks$span_weeks))):(1440*7*(i+length_weeks$train_weeks))] <- seasonal_spikes_pred
      STL_profile[(1+(1440*7*(i-1))):(1440*7*i)] <- STL_background_profile[(1+(1440*7*(i-1))):(1440*7*i)] + STL_spikes_profile[(1+(1440*7*(i-1))):(1440*7*i)]
      #STL_profile[(1+(1440*7*(i+length_weeks$span_weeks))):(1440*7*(i+length_weeks$train_weeks))] <- STL_background_profile[(1+(1440*7*(i+length_weeks$span_weeks))):(1440*7*(i+length_weeks$train_weeks))] + STL_spikes_profile[(1+(1440*7*(i+length_weeks$span_weeks))):(1440*7*(i+length_weeks$train_weeks))]
    } else {
      STL_profile[(1+(1440*7*(i-1))):(1440*7*i)]<- STL_background_profile[(1+(1440*7*(i-1))):(1440*7*i)]
      #STL_profile[(1+(1440*7*(i+length_weeks$span_weeks))):(1440*7*(i+length_weeks$train_weeks))] <- STL_background_profile[(1+(1440*7*(i+length_weeks$span_weeks))):(1440*7*(i+length_weeks$train_weeks))]
    }
    
  }
  return(STL_profile)
}



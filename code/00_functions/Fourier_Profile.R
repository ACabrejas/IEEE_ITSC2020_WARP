fourier_profile = function() {
  ## --- FOURIER PROFILE ---
  # Parameters
  cut_freq = 0.0041 ## Low-pass filter cut-off frequency, frequency for period = 4 hours (0.0041 = 1/(4*60))
  alpha = 0.3
  
  ## Set FFT time and frequency axes
  time_step = 1
  init = 1
  end = 1440*7 ## Minutes in one week
  t_axis = seq(init,end,time_step)
  f_axis = seq(0,length(t_axis)-1,1) / ((length(t_axis)-1) * time_step)
  
  ## Get background for first week
  #background_week_1 = link_data$background[1:(1440*7)]
  background_week_1 = link_data$background[1:(1440*7)]
  
  ## Define the fourier profile time series vector of link selected, initialized just for first weke
  Fourier_profile = rep(-9,(1440*7*length_weeks$total_weeks))
  Fourier_profile[1:(1440*7)] = background_week_1 ## First week Fourier profile initialized with travel time of first week
  
  ## Define our new profile frequency spectrum vector (fourier_spectrum_filtered), initialized just for first week
  fourier_spectrum_filtered = as.complex(rep(0,(1440*7*length_weeks$total_weeks))) # FFT makes spectrum vector size the same as time series vector size
  fourier_spectrum_week_1 = fft(background_week_1)/length(background_week_1)
  fourier_spectrum_week_1_filtered <- as.complex(rep(0,length(fourier_spectrum_week_1)))
  fourier_spectrum_week_1_filtered[f_axis <= cut_freq | f_axis >= (1 + f_axis[2] - cut_freq ) ] = fourier_spectrum_week_1[f_axis <= cut_freq | f_axis >= (1 + f_axis[2] - cut_freq)]
  fourier_spectrum_filtered[1:(1440*7)] = fourier_spectrum_week_1_filtered
  
  ## Run through weeks 2-12
  for (i in 2:length_weeks$total_weeks) {
    ## Calculate profile time series vector of current week as the inverse FFT of the profile spectrum of the previous week
    Fourier_profile[(1+(1440*7*(i-1))):(1440*7*i)] = Re(fft(fourier_spectrum_filtered[(1+(1440*7*(i-2))):(1440*7*(i-1))], inverse = TRUE))
    
    ## Get filtered spectrum of current week
    background_week_i = link_data$background[(1+(1440*7*(i-1))):(1440*7*i)]
    #background_week_i = link_data$background[(1+(1440*7*(i-1))):(1440*7*i)]
    fourier_spectrum_week_i = fft(background_week_i)/length(background_week_i)
    fourier_spectrum_week_i_filtered = as.complex(rep(0,length(fourier_spectrum_week_i)))
    fourier_spectrum_week_i_filtered[f_axis <= cut_freq | f_axis > (1-cut_freq) ] = fourier_spectrum_week_i[f_axis <= cut_freq | f_axis > (1-cut_freq)]
    
    ## Update the filtered spectrum vector 
    fourier_spectrum_filtered[(1+(1440*7*(i-1))):(1440*7*i)] = alpha * fourier_spectrum_week_i_filtered + (1-alpha) * fourier_spectrum_filtered[(1+(1440*7*(i-2))):(1440*7*(i-1))]
  }
  
  ## Save data    
  return(Fourier_profile[(1+(1440*7*(length_weeks$train_weeks))):(1440*7*(length_weeks$total_weeks))])
}
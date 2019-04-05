relative_error_daytime = function(error_type) {
  # Create date and time index
  date_create = seq.POSIXt(as.POSIXct(Sys.Date()), as.POSIXct(Sys.Date()+1), by = "1 min")
  # Remove the last entry
  date = date_create[1:(length(date_create)-1)]
  # Remove the date and leave time of the day
  time = substr(date,12,16)
  #Define the labels
  seqq = seq(1,1440, 120)
  time_label = time[seqq]
  
  # Create dataframe to plot depending on the needed data
  if (error_type == "Relative") {
    plot_data = data.frame(Published = thales_results$daytime_errors$day_time_error,
                           #Null = null_results$daytime_errors$day_time_error,
                           #STL = stl_results$daytime_errors$day_time_error,
                           #Fourier = fourier_results$daytime_errors$day_time_error,
                           Hybrid = hybrid_results$daytime_errors$day_time_error,
                           Segmentation =  segmentation_results$daytime_errors$day_time_error,
                           time)
  } else if (error_type == "Negative") {
    plot_data = data.frame(Published = thales_results$daytime_errors$day_time_error_neg,
                           #Null = null_results$daytime_errors$day_time_error_neg,
                           #STL = stl_results$daytime_errors$day_time_error_neg,
                           #Fourier = fourier_results$daytime_errors$day_time_error_neg,
                           Hybrid = hybrid_results$daytime_errors$day_time_error_neg,
                           Segmentation =  segmentation_results$daytime_errors$day_time_error_neg,
                           time)
  } else if (error_type == "Density") {
    plot_data = data.frame(Published = thales_results$daytime_errors$day_time_density_error,
                           #Null = null_results$daytime_errors$day_time_density_error,
                           #STL = stl_results$daytime_errors$day_time_density_error,
                           #Fourier = fourier_results$daytime_errors$day_time_density_error,
                           Hybrid = hybrid_results$daytime_errors$day_time_density_error,
                           Segmentation =  segmentation_results$daytime_errors$day_time_density_error,
                           time)
  } else {
    stop("Incorrect or missing error type. \n Please choose from: \n -Relative \n -Negative \n -Density")
  }
  # Melt it
  plot_data_long = melt(plot_data, id="time")
  
  # Plot
  ggplot(data = plot_data_long, aes(x=time, y=value, colour=variable, group = variable)) + 
    #ylab(paste(error_type,"Error", sep = " ")) + 
    ylab("MARE") + 
    xlab("Time of the day") +
    #theme(axis.title.x = element_blank()) + 
    geom_line(size=1.5) + theme(text = element_text(size=28),axis.text.x = element_text(angle = 0)) + 
    scale_x_discrete(breaks=time_label, labels=as.character(time_label)) +
    scale_y_continuous(breaks=seq(0.025,0.15,by=0.025)) + 
    scale_colour_discrete(name  =label_mx, labels=c("Published Profile", "Wavelet Hybrid Profile", "Segmentation Profile"))+
                         # breaks=c("Published", "Hybrid", "Segmentation)")+
                        #  labels=c("Published Model", "Wavelet Hybrid Model", "Segmentation Model")  +
    theme(legend.position = c(0.19, 0.88)) + theme(legend.text=element_text(size=24)) 
    #ggtitle(paste("Average", error_type, "error for all links across times of the day"))
  plotname = paste('../paper/images/',label_mx,'_daytime_8_12.pdf', sep = '')
  ggsave(plotname, height = 8, width = 12)
}

###########################################################################################################

relative_error_timeseries = function(error_type, method, spike_parameter) {
  # Create x axis (only for proper indexing in the dataframe)
  Time = 1:(1440*7*length_weeks$pred_weeks)
  # Select type of error and create corresponding dataframe with aggregated results
  if (error_type == "Relative") {
    plot_data = data.frame(Published = colMeans(thales_results$relative_errors$relative_error),
                           #Null = colMeans(null_results$relative_errors$relative_error),
                           #Fourier = colMeans(fourier_results$relative_errors$relative_error),
                           #STL = colMeans(stl_results$relative_errors$relative_error),
                           Hybrid = colMeans(hybrid_results$relative_errors$relative_error),
                           Segmentation = colMeans(segmentation_results$relative_errors$relative_error),
                           Time = Time)
  } else if (error_type == "Negative") {
    plot_data = data.frame(Published = colMeans(thales_results$relative_errors$relative_error_neg),
                           #Null = colMeans(null_results$relative_errors$relative_error_neg),
                           #Fourier = colMeans(fourier_results$relative_errors$relative_error_neg),
                           #STL = colMeans(stl_results$relative_errors$relative_error_neg),
                           Hybrid = colMeans(hybrid_results$relative_errors$relative_error_neg),
                           Segmentation = colMeans(segmentation_results$relative_errors$relative_error_neg),
                           Time = Time)
  } else if (error_type == "Density") {
    plot_data = data.frame(Published = colMeans(thales_results$relative_errors$density_error),
                           #Null = colMeans(null_results$relative_errors$density_error),
                           #Fourier = colMeans(fourier_results$relative_errors$density_error),
                           #STL = colMeans(stl_results$relative_errors$density_error),
                           Hybrid = colMeans(hybrid_results$relative_errors$density_error),
                           Segmentation = colMeans(segmentation_results$relative_errors$density_error),
                           Time = Time)
  } else {
    # Message and break if error input has an unexpected value
    stop("Incorrect or missing error type. \n Please choose from: \n -Relative \n -Negative \n -Density")
  }
  
  # Melt dataframe
  plot_data_long = melt(plot_data, id="Time")
  
  # One axis tick per prediction day
  axis_breaks = c(1,seq(1440, (length_weeks$pred_weeks*7)*1440, length.out = ((length_weeks$pred_weeks*7)-1)))
  custom_ticks = seq(from=1, to=length_weeks$pred_weeks*7, by=1)
  
  # Plot
  ggplot(data = plot_data_long, aes(x=Time, y=value, colour=variable, group = variable)) + 
    ylab(paste(error_type,"Error", sep = " ")) + xlab("Time in Days from date of prediction") +
    geom_line(size=.8, alpha=1) + 
    scale_x_continuous(breaks=axis_breaks, labels=custom_ticks) +
    theme(legend.title=element_blank()) + 
    ggtitle(paste("Average", error_type,"error from prediction date", sep = " "))
  plotname = paste('../paper/images/',label_mx,'_error_timeseries.pdf', sep = '')
  ggsave(plotname, height = 8, width = 12)
}

#######################################################################################################################################

quantile_error = function(quantile, error_type, spike_parameter) {
  
  false_x_axis = 1:100
  # Create dataframe to plot depending on the needed data
  if (quantile == 1) {
    if (error_type == "ab") {
      plot_data = data.frame(Published = thales_results$quantile_errors_avg$ab_error_avg,
                             #Null = null_results$quantile_errors_avg$ab_error_avg,
                             #STL = stl_results$quantile_errors_avg$ab_error_avg,
                             #Fourier = fourier_results$quantile_errors_avg$ab_error_avg,
                             Hybrid = hybrid_results$quantile_errors_avg$ab_error_avg,
                             Segmentation = segmentation_results$quantile_errors_avg$ab_error_avg,
                             false_x_axis)
    } else if (error_type == "rms") {
      plot_data = data.frame(Published = thales_results$quantile_errors_avg$rms_error_avg,
                             #Null = null_results$quantile_errors_avg$rms_error_avg,
                             #STL = stl_results$quantile_errors_avg$rms_error_avg,
                             #Fourier = fourier_results$quantile_errors_avg$rms_error_avg,
                             Hybrid = hybrid_results$quantile_errors_avg$rms_error_avg,
                             Segmentation = segmentation_results$quantile_errors_avg$rms_error_avg,
                             false_x_axis)
    } else {
      # Error message missing method
      stop("Incorrect or missing method input. \n Please choose from: \n - \"ab\" (absolute error) \n 
           - \"rms\" (root mean squared error)")
    }
    
  } else if (quantile == 95) {
    if (error_type == "ab") {
      plot_data = data.frame(Published = thales_results$quantile_errors_avg$ab_error95_avg,
                             #Null = null_results$quantile_errors_avg$ab_error95_avg,
                             #STL = stl_results$quantile_errors_avg$ab_error95_avg,
                             #Fourier = fourier_results$quantile_errors_avg$ab_error95_avg,
                             Hybrid = hybrid_results$quantile_errors_avg$ab_error95_avg,
                             Segmentation = segmentation_results$quantile_errors_avg$ab_error95_avg,
                             false_x_axis)
    } else if (error_type == "rms") {
      plot_data = data.frame(Published = thales_results$quantile_errors_avg$rms_error95_avg,
                             #Null = null_results$quantile_errors_avg$rms_error95_avg,
                             #STL = stl_results$quantile_errors_avg$rms_error95_avg,
                             #Fourier = fourier_results$quantile_errors_avg$rms_error95_avg,
                             Hybrid = hybrid_results$quantile_errors_avg$rms_error95_avg,
                             Segmentation = segmentation_results$quantile_errors_avg$rms_error95_avg,
                             false_x_axis)
    } else {
      # Error message missing method
      stop("Incorrect or missing method input. \n Please choose from: \n - \"ab\" (absolute error) \n 
           - \"rms\" (root mean squared error)")
    }
  } else if (quantile == 99) {
    if (error_type == "ab") {
      plot_data = data.frame(Published = thales_results$quantile_errors_avg$ab_error99_avg,
                             #Null = null_results$quantile_errors_avg$ab_error99_avg,
                             #STL = stl_results$quantile_errors_avg$ab_error99_avg,
                             #Fourier = fourier_results$quantile_errors_avg$ab_error99_avg,
                             Hybrid = hybrid_results$quantile_errors_avg$ab_error99_avg,
                             Segmentation = segmentation_results$quantile_errors_avg$ab_error99_avg,
                             false_x_axis)
    } else if (error_type == "rms") {
      plot_data = data.frame(Published = thales_results$quantile_errors_avg$rms_error99_avg,
                             #Null = null_results$quantile_errors_avg$rms_error99_avg,
                             #STL = stl_results$quantile_errors_avg$rms_error99_avg,
                             #Fourier = fourier_results$quantile_errors_avg$rms_error99_avg,
                             Hybrid = hybrid_results$quantile_errors_avg$rms_error99_avg,
                             Segmentation = segmentation_results$quantile_errors_avg$rms_error99_avg,
                             false_x_axis)
    } else {
      # Error message missing method
      stop("Incorrect or missing method input. \n Please choose from: \n - \"ab\" (absolute error) \n 
           - \"rms\" (root mean squared error)")
    }
  } else if (quantile == custom_quantile_start) {
    if (error_type == "ab") {
      plot_data = data.frame(Published = thales_results$quantile_errors_avg$ab_error_custom_avg,
                             #Null = null_results$quantile_errors_avg$ab_error_custom_avg,
                             #STL = stl_results$quantile_errors_avg$ab_error_custom_avg,
                             #Fourier = fourier_results$quantile_errors_avg$ab_error_custom_avg,
                             Hybrid = hybrid_results$quantile_errors_avg$ab_error_custom_avg,
                             Segmentation = segmentation_results$quantile_errors_avg$ab_error_custom_avg,
                             false_x_axis)
    } else if (error_type == "rms") {
      plot_data = data.frame(Published = thales_results$quantile_errors_avg$rms_error_custom_avg,
                             #Null = null_results$quantile_errors_avg$rms_error_custom_avg,
                             #STL = stl_results$quantile_errors_avg$rms_error_custom_avg,
                             #Fourier = fourier_results$quantile_errors_avg$rms_error_custom_avg,
                             Hybrid = hybrid_results$quantile_errors_avg$rms_error_custom_avg,
                             Segmentation = segmentation_results$quantile_errors_avg$rms_error_custom_avg,
                             false_x_axis)
    } else {
      # Error message missing method
      stop("Incorrect or missing method input. \n Please choose from: \n - \"ab\" (absolute error) \n 
           - \"rms\" (root mean squared error)")
    }
  } else {
    # Error message missing quantile
    stop("Incorrect or missing quantile input. \n Please choose from: \n - quantile = 1 (results for range 1-100) \n 
        - quantile = 95 (results for range 95-100) \n - quantile = 99 (results for range 99-100 \n 
         - quantile = custom_quantile_start (results for custom range)")
  }
  
  # Melt it
  plot_data_long = melt(plot_data, id="false_x_axis")
  # Define custom ticks for x axis
  if (quantile == 1) {
    custom_ticks = c(1,seq(from = 10, to= 100, length.out = 10))
  } else {
    custom_ticks = c(quantile, seq(from = quantile + ((100-quantile)/10), to = 100, length.out = 10))
  }

  # Plot
  ggplot(data = plot_data_long, aes(x=false_x_axis, y=value, colour=variable, group = variable)) + 
    ylab("Relative Error") + 
    #xlab("Percentile of travel times") +
    geom_line(size=1.5) + theme(text = element_text(size=24),axis.text.x = element_text(hjust = 1)) + 
     labs(x="Percentile of Travel Time")+
    scale_x_continuous(breaks=c(1,seq(from = 10, to= 100, length.out = 10)), labels=custom_ticks) +
    coord_cartesian(xlim = c(0, 100), ylim = c(0,0.35)) +
    scale_colour_discrete(name  =label_mx, breaks=c("Published", "Hybrid", "Segmentation"),
                          labels=c("Published Model","Wavelet Hybrid Model", "Segmentation Model")) +
    theme(text = element_text(size=18),legend.position = c(0.14, 0.90)) 
    #ggtitle(paste("Average AB/RMS error for all links across percentiles of travel time", sep = " "))
  
  ggplot(data = plot_data_long, aes(x=false_x_axis, y=value, colour=variable, group = variable)) + 
    ylab("MARE") + 
    labs(x="Percentile of Travel Time")+
    #theme(axis.title.x = element_blank()) + 
    geom_line(size=1.5) + theme(text = element_text(size=24),axis.text.x = element_text(angle = 0)) + 
    scale_x_continuous(breaks=c(1,seq(from = 10, to= 100, length.out = 10)), labels=custom_ticks) +
    scale_colour_discrete(name  =label_mx)+
    scale_colour_discrete(name  =label_mx, breaks=c("Published", "Hybrid", "Segmentation"),
                          labels=c("Published Model","Wavelet Hybrid Model", "Segmentation Model")) +
    theme(legend.position = c(0.15, 0.90)) + theme(legend.text=element_text(size=18)) 
  
  plotname = paste('../paper/images/',label_mx,'_quantile_',quantile,'_', error_type,'_8_12.pdf', sep = '')
  ggsave(plotname, height = 8, width = 12)
  
  
}

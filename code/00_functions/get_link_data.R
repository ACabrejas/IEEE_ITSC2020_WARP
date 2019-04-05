get_link_data = function(mX, i, wavelet_name, link) {
  ##################################################################################################
  ##                                                                                              ##
  ## ------------------------------  DATA RETRIEVAL FUNCTION  ----------------------------------  ##
  ##                                                                                              ##
  ## Input: Link ID, fetch information                                                            ##
  ## Operation: Indicate the type of data that needs to be fetched and the corresponding list.    ##
  ## Output: Named list with the requested information, labelled.                                 ##
  ##                                                                                              ##
  ##################################################################################################
  
  # Fetch all data
  
  background_name = paste('./03_background_spikes_matlab_to_r/',wavelet_name,'/',mX,'_link_',i,'_background.csv', sep = "")
  spikes_name     = paste('./03_background_spikes_matlab_to_r/',wavelet_name,'/',mX,'_link_',i,'_spikes.csv', sep = "")
  
  background = fread(file = background_name, header = F, sep = ',')[[1]]
  spikes = fread(file = spikes_name, header = F, sep = ',')[[1]]

  travel_time <- m_data_selected$travel_time[m_data_selected$link_id == link]
  flow <- m_data_selected$traffic_flow[m_data_selected$link_id == link]
  flow[is.na(flow)] = median(flow, na.rm = T)
  
  spike_flag = spikes>3
  
  #plot(spikes, type='l')
  
  newspikes = spikes
  newspikes[!spike_flag] =0
  
  #plot(newspikes, type='l')
  
  spikeremainder = spikes - newspikes
  
  #plot(spikeremainder, type='l')
  
  background = background + spikeremainder
  
  output = list(travel_time = travel_time, background = background, spikes = spikes, spike_flag = spike_flag, flow = flow)
  
  return(output)
}


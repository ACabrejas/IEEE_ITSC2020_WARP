library(dplR)

load(paste('./01_raw_data/',mX,'_data_selected_and_links_list_A.RData', sep = ''))
links_list = links_list_df$link_id
link = links_list[1]

travel_time = m_data_selected$travel_time[m_data_selected$link_id == link]
background_name = paste('./03_background_spikes_matlab_to_r/',wavelet_name,'/',mX,'_link_',i,'_background.csv', sep = "")
spikes_name     = paste('./03_background_spikes_matlab_to_r/',wavelet_name,'/',mX,'_link_',i,'_spikes.csv', sep = "")

background = fread(file = background_name, header = F, sep = ',')[[1]]
spikes = fread(file = spikes_name, header = F, sep = ',')[[1]]

tt_wt = morlet(travel_time)
tt_wt2 = tt_wt

wavelet.plot(tt_wt, add.coi = T, add.sig = F, add.spline = F)

levels = 68

cplx = tt_wt$wave
mod_wt = Mod(cplx)
pow_wt = mod_wt**2
phase_wt = Arg(cplx)

background_complex = array(0,c(levels,length(travel_time)))
spikes_complex = array(0,c(levels,length(travel_time)))

for (i in 1:levels){
  print(paste('Current Level: ', i))
  
  background_mod = numeric(length(travel_time))
  spikes_mod = numeric(length(travel_time))
  
  scale_data = pow_wt[,i]
  mod_data = mod_wt[,i]
  arg_data = phase_wt[,i]
  
  median_power = median(scale_data)
  iqr_power = IQR(scale_data)
  upper_lim = median_power + iqr_power
  
  over_limit = scale_data>upper_lim
  within_limit = !over_limit
  
  background_mod[within_limit] = mod_data[within_limit]
  background_mod[over_limit] = sqrt(upper_lim)
  spikes_mod[over_limit] = mod_data[over_limit] - sqrt(upper_lim)
  
  a =  background_mod*cos(arg_data)
  b = background_mod*sin(arg_data)
  
  background_complex[i,] =  complex(real = a, imaginary = b)
  spikes_complex[i,] = complex(real = spikes_mod*cos(arg_data), imaginary = spikes_mod*sin(arg_data))
}

tt_wt2$wave = background_complex
wavelet.plot(tt_wt2, add.coi = T, add.sig = F, add.spline = F)

wavelet.plot(morlet(background), add.coi=F, add.sig=F, add.spline=F)

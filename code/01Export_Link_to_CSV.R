## Clear-all
rm(list = ls()) # Clear variables
graphics.off()  # Clear plots
cat("\014")     # Clear console

library(ggplot2)

## Choose motorway
mX <- "m6"

## Load motorway data
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
file_name = paste(mX,"_data_selected_and_links_list_A.RData", sep = "")
load(paste('./01_raw_data/',file_name, sep = ''))
links_list <- links_list_df$link_id


## Extract link data
for (i in 1:length(links_list)) {
  
  
  print(paste("Link #",i,"/",length(links_list)))
  link = links_list[i]
  link_data = m_data_selected$travel_time[m_data_selected$link_id==link]
  
  filename =  paste("02_extracted_link_data/",mX,"_link_",i,".csv", sep = "")
  
  write.table(link_data, file = filename ,row.names=FALSE, na="",col.names=FALSE, sep=",")

}


## Plot examples of travel times (1 week = 10080 minutes)

i=1
link = links_list[i]
link_data = m_data_selected$travel_time[m_data_selected$link_id==link]
plot(link_data, type = 'l')
plot(link_data[1:(4*10080)], type = 'l')
i=i+1


Travel_Time = link_data[1:(4*10080)]
Time = 1:length((Travel_Time))

dataplot = data.frame(Travel_Time, Time)
dataplot$Time = factor(dataplot$Time)
ggplot(data.frame(Time = 1:length(Travel_Time), Travel_Time = Travel_Time),
       aes(x = Time, y = Travel_Time)) + geom_line()

plot(Time, Travel_Time, type = 'l')

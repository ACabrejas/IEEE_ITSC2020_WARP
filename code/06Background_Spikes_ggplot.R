
## Clear-all
rm(list = ls()) # Clear variables
graphics.off()  # Clear plots
cat("\014")     # Clear console

library(reshape2)
library(ggplot2)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

## Choose motorway
mX <- "m6"
wavelet = "morse"

link_number = 1
week_start = 1
length_weeks = 3

## Load motorway data
file_name1 = paste("./03_background_spikes_matlab_to_r/",wavelet,"/",mX,"_link_",link_number,"_background.csv", sep = "")
file_name2 = paste("./03_background_spikes_matlab_to_r/",wavelet,"/",mX,"_link_",link_number,"_spikes.csv", sep = "")

background = fread(file = file_name1, header = F, sep = ',')[[1]]
spikes = fread(file = file_name2, header = F, sep = ',')[[1]]
spikes[spikes<0.5]=0


labels_mx = c("M6", "M11", "M25")
if(mX=="m6"){label_mx = labels_mx[1]}else if(mX=="m11"){label_mx = labels_mx[2]}else if(mX=="m25"){label_mx=labels_mx[3]}

background_sel = background[(1+10080*week_start):(10080*week_start+10080*length_weeks)]
spikes_sel = spikes[(1+10080*week_start):(10080*week_start+10080*length_weeks)]
spikes_plot = rep(0, length(spikes_sel))
spikes_plot = spikes_sel + background_sel
spikes_plot[spikes_sel==0] = NA
background_sel[spikes_sel!=0] = NA

time = seq(1:length(spikes_plot))

plot_data = data.frame(Spikes = spikes_plot, Background = background_sel, Time=time)

plot_data_long = melt(plot_data, id="Time")

dates = c("07/03/2016","08/03/2016","09/03/2016","10/03/2016","11/03/2016",
          "12/03/2016","13/03/2016","14/03/2016","15/03/2016","16/03/2016",
          "17/03/2016","18/03/2016","19/03/2016","20/03/2016","21/03/2016",
          "22/03/2016","23/03/2016","24/03/2016","25/03/2016","26/03/2016",
          "27/03/2016","28/03/2016")

axis_breaks = seq(1,22)


ggplot(data = plot_data_long, aes(x=Time, y=value, colour=variable, group = variable)) + 
  ylab("Travel time [seconds]") + 
  xlab("Date") +
  geom_line(size=1.5) + theme(text = element_text(size=28),axis.text.x = element_text(angle = 0)) +
  scale_x_discrete(breaks=axis_breaks, labels=dates) +
  scale_y_continuous(breaks=seq(0.025,0.15,by=0.025)) + 
  theme(legend.position = c(0.14, 0.9)) + theme(legend.text=element_text(size=24)) 

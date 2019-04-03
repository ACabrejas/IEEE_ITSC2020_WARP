segmentation_profile = function(weight_type) {
  Segmentation_profile = rep(-9,(1440*7*length_weeks$pred_weeks))
  
  for (week in 1:length_weeks$pred_weeks) {
    for (minute in 1:(10080)){
      seqq = seq(minute+(10080*(week-1)),by=10080, length.out = length_weeks$train_weeks)
      if (weight_type == "exponential") {
        weights = ewmaweights(length_weeks$train_weeks)
      } else if (weight_type == "uniform") {
        weights = rep(1/length_weeks$train_weeks,length_weeks$train_weeks)
      }
      Segmentation_profile[minute+(10080*(week-1))] = sum(link_data$travel_time[seqq] * weights)
    }
  }
  
  return(Segmentation_profile)
}


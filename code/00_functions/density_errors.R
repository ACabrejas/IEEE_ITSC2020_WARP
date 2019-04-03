density_errors = function(calculated_profile, test_data) {
  
  density_error <- link_data$flow[(1+(1440*7*(length_weeks$train_weeks))):(1440*7*(length_weeks$total_weeks))] * (calculated_profile - test_data) / test_data
  
  return(density_error)
}
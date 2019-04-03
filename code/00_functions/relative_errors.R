relative_errors = function(calculated_profile, test_data) {
  
  relative_error <- (calculated_profile - test_data) / test_data

  return(relative_error)
}
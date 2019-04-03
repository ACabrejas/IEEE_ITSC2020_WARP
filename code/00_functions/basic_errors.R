basic_errors = function(test_data) {
  # Relative error
  profile_storage$relative_errors$relative_error[which(links_list==link),] = relative_errors(calculated_profile = profile_storage$profile[which(links_list==link),], test_data = travel_time_testdata)
  # Relative error * flow
  profile_storage$relative_errors$density_error[which(links_list==link),] = density_errors(calculated_profile = profile_storage$profile[which(links_list==link),], test_data = travel_time_testdata)
  # Negative only relative errors (error<0 -> forecast is smaller than measurement for point, we predict less than we find, interesting under the assumption that no one complains from being home early )
  profile_storage$relative_errors$relative_error_neg[which(links_list==link),] = relative_errors_neg()
}
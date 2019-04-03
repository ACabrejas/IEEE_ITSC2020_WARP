get_methods_parameters = function() {
  methods_parameters = list()
  for (method in 1:(length(names(data$background_spikes)))) {
    method_name = names(data$background_spikes[method])
    parameters = (names(data$background_spikes[[method]]))
    methods_parameters[[method_name]] = parameters
  }
  return(methods_parameters)
}
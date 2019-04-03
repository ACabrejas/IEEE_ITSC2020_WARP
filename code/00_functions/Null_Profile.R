null_profile = function() {
  Null_model_profile <- rep(-1, (1440*7*length_weeks$pred_weeks))
    for (i in 1:length_weeks$pred_weeks) {
    ## Get background for 8 weeks of training
    background_train <- link_data$background[(1+(1440*7*(i-1))):(1440*7*(i+length_weeks$span_weeks))]
    ## Make Null model prediction
    Null_model_profile[(1+(1440*7*(i-1))):(1440*7*i)] <- median(background_train)
  }
  return(Null_model_profile)
}
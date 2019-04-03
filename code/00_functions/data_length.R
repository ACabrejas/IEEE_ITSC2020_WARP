data_length = function(mX) {
  # Adjust lengths based on dataset
  if (mX == "m25") {
    train_weeks = 6
    pred_weeks = 3
  } else {
    train_weeks = 8
    pred_weeks = 4
  }
  span_weeks = train_weeks - 1
  total_weeks = train_weeks + pred_weeks
  output = list(span_weeks = c(span_weeks), total_weeks = c(total_weeks), train_weeks = c(train_weeks), pred_weeks = pred_weeks)
  return(output)
}
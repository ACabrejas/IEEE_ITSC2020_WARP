## Define Root Mean Square function
rms <- function(vector){
  sq_sum <- vector %*% vector
  return(sqrt(sq_sum[1,1]/length(vector)))
}
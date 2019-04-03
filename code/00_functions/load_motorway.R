load_motorway = function(mX) {
  ## Load motorway data
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
  file_name <- paste(mX,'_data_selected_and_links_list_AdvBackgroundSpikes_th_0.8.RData',sep="")
  load(paste('../00_Data/04_Processed_data/',file_name, sep = ''))
  links_list <- links_list_df$link_id
}
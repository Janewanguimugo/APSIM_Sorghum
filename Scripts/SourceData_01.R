######################Source data only once###############################
#' Title by Jane Wangui Mugo
#'
#' @param cell 
#' @param b 
#' @param date 
#'
#' @return
#' @export
#'
#' @examples
apsim.data <- function(cell, b, date) {
  my_packages <- c("spdep", "rgdal", "maptools", "raster", "plyr", "ggplot2", "rgdal",
                   "dplyr", "cowplot","readxl", "apsimx", "gtools", "foreach","doParallel",
                   "ranger")
  list.of.packages <- my_packages
  new.packages <- list.of.packages[!(my_packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(my_packages, require, character.only = TRUE)
  
  cores<- detectCores()
  myCluster <- makeCluster(cores -2, # number of cores to use
                           type = "PSOCK") # type of cluster
  registerDoParallel(myCluster)
  #GET COUNTRY SHAPEFILE
  country<-raster::getData("GADM", country= b, level=0)
  
  country <- st_as_sf(country)
  
  # Make a grid of points
  points <- country %>% 
    st_make_grid(cellsize = cell, what = "centers") %>% # grid of points
    st_intersection(country) 
  
  #View the number of points sampled and convert them to a dataframe
  print(ggplot() + 
          geom_sf(data = country) + 
          geom_sf(data = points))
  
  df<-as.data.frame(st_coordinates(st_centroid(points)))
  colnames(df) <- c('Longitude','Latitude')
  stn<-df
  #text(stn$Longitude, y = stn$Latitude, pos = 3)
  
  #Get Meteorological data from nasapower
  
  require(nasapower)
  ## This will not write a file to disk
  my_list_clm <- foreach (i = 1:nrow(stn)) %dopar% {
    apsimx::get_power_apsim_met(lonlat = c(stn$Longitude[[i]], stn$Latitude[[i]]), 
                                dates = date)
  }
  #Get soil data from iscric
  my_list_sol <- foreach (i = 1:nrow(stn)) %dopar% {
    tryCatch(apsimx::get_isric_soil_profile(lonlat = c(stn$Longitude[i], stn$Latitude[[i]]),add.args = list(crops = c("Maize", "Sorghum")))
             , error=function(err) NA)
  }
  # Return both lists in a named list
  data <- list(my_list_clm = my_list_clm, my_list_sol = my_list_sol, stn = stn)
  saveRDS(list(my_list_clm = my_list_clm, my_list_sol = my_list_sol, stn = stn), "my_data.rds")
  return(data)
}
#' Title by Jane Wangui Mugo
#'
#' @param results 
#' @param b 
#' @param wkdir 
#'
#' @return
#' @export
#'
#' @examples
apsim.plots<- function(results, b, wkdir){
  my_packages <- c("spdep", "rgdal", "maptools", "raster", "plyr", "ggplot2", "rgdal",
                   "dplyr", "cowplot","readxl", "apsimx", "gtools", "foreach","doParallel",
                   "ranger", "viridis")
  list.of.packages <- my_packages
  new.packages <- list.of.packages[!(my_packages %in% installed.packages()[,"Package"])]
  if(length(new.packages)) install.packages(new.packages)
  lapply(my_packages, require, character.only = TRUE)
  
  cores<- detectCores()
  myCluster <- makeCluster(cores -2, # number of cores to use
                           type = "PSOCK") # type of cluster
  registerDoParallel(myCluster)
  
  setwd(wkdir)
  stn<- read.csv("station.csv")
  
  foreach (i = 1:length(results))%do%{
    results[[i]]$Longitude<-stn$Longitude[[i]]
    results[[i]]$Latitude<-stn$Latitude[[i]]
  }
  
  for (i in 1:10){
    foreach (i = 1:length(results))%do%{ 
      if(lengths(results[i])< 5){
        results[[i]] <- NULL
      }
    }
  }
  ##############################Graphs######################################
  foreach (i = 1:length(results))%do%{
    # Define the custom order for SowDate
    custom_order <- c("01-Nov", "15-Nov", "01-Dec", "15-Dec", "01-Jan", "15-jan", "01-Feb", "15-Feb")
    # Convert SowDate to a factor with the custom order
    results[[i]]$SowDate <- factor(results[[i]]$SowDate, levels = custom_order) 
    # Order the data frame by SowDate
    results[[i]] <- results[[i]] %>%
      arrange(SowDate)
    print(results[[i]]  %>%
            ggplot(aes(x=SowDate, y=FinalYield_kg_Ha, color= Ideotype)) +
            geom_point(na.rm=TRUE)+
            ggtitle(paste0("Yield ",i)))
  }
  ###########################################################################
  final<- do.call("smartbind", results)
  glimpse(final)
  
  final<-final%>%
    group_by(Longitude, Latitude, Ideotype)%>%
    slice(which.max(FinalYield_kg_Ha))%>%
    as.data.frame()
  
  country<-getData("GADM", country=b, level=0)
  
  print(ggplot() +
          geom_polygon(data = country, aes(x = long, y = lat), fill = "white") +
          geom_point(data = final, aes(x = Longitude, y = Latitude, color = factor(SowDate)), size = 4, shape = 15) +
          facet_wrap(~ Ideotype) +
          scale_color_viridis_d())
  print(ggplot() +
    geom_polygon(data = country, aes(x = long, y = lat), fill = "white") +
    geom_point(data = final, aes(x = Longitude, y = Latitude, color = FinalYield_kg_Ha), size = 4, shape = 15) +
    facet_wrap(~ Ideotype) +
    scale_color_viridis(option = "D"))
  
  # print(ggplot() +  geom_point(data=final, aes(x=Longitude, y=Latitude, color= SowDate), size = 4)+
  #         facet_wrap(~ Ideotype))
  # print(ggplot() +  geom_point(data=final, aes(x=Longitude, y=Latitude, color= FinalYield_kg_Ha), size = 4)+
  #         facet_wrap(~ Ideotype))
}

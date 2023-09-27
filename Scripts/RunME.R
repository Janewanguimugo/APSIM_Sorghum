#01 Start by Sourcing the soil and Climate Data run only once
#b = the country shapefile e.g "ZM" for Zimbabwe
source("D:/Zimbabwe/Scripts/SourceData_01.R")
apsim.data(cell = 3,
                        b= "Zimbabwe", 
                        date = c("2001-01-01","2022-01-01")
                        )
##NEXT RUN START FROM HERE NO NEED TO REDOWNLOAD THE DATA
data <- readRDS("D:/Zimbabwe/project/my_data.rds")
# Access the lists
my_list_clm <- data$my_list_clm
my_list_sol <- data$my_list_sol
stn<- data$stn
write.csv(stn, "station.csv", row.names=FALSE )

#02 use the second function to edit your APSIMx files with unique weather and soil 
#It Will take time to run
source("D:/Zimbabwe/Scripts/RunSimulation_02.R")
results<- apsim.spatial(wkdir ="D:/Zimbabwe/project", 
                        exdir = "D:/Zimbabwe/", 
                        crop = "Sorghum_2090.apsimx", 
                        clck = c("2001-01-01T00:00:00", "2021-12-01T00:00:00"),
                        my_list_clm = my_list_clm,
                        my_list_sol = my_list_sol
                        )
saveRDS(results, "D:/Zimbabwe/project/my_results.rds")
results <- readRDS("D:/Zimbabwe/project/my_results.rds")
#03 Plot the Outputs for the highest mean yield variety
##THIRD FUNCTION ON PLOTTING USING THE RESULTS OBTAINED FROM apsim.spatial COMMAND##
#results = the results list obtained from apsim.spatial command
#wkdir = the directory where station data is saved
source("D:/Zimbabwe/Scripts/PlotOutputs_03.R")
apsim.plots(results,"Zimbabwe", "D:/Zimbabwe/project")

 


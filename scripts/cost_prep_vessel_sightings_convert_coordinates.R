# correct coordinates

library(sf)
library(sp)
library(tidyverse)
#library(stringr)

# aim convert and concatenate coordinates to decimal degrees: from Deciomal degrees + decimal minutes to decimal degrees
# method: split minutes decimal seconds into two columns, then multiply the decimal seconds with 60 and concatenate three coliumns to get DMS Then use sp char2DMS to get an offical data type. then convert to numeric to get decimal degrees

# isolate characters
# Decimal_degrees
d_y <-  as.character(boat_sightings$Lattitude)
d_x <- as.character(boat_sightings$Longitude)

# Minutes 
m_y <- stringr::str_split_fixed(string = as.character(boat_sightings$Lat_min),
                                                         pattern =  "[[:punct:]]",
                                                         n = 2)[,1]
m_x <- stringr::str_split_fixed(string = as.character(boat_sightings$Long_min),
                                                         pattern =  "[[:punct:]]",
                                                         n = 2)[,1]
# Seconds
s_y_chr <- stringr::str_split_fixed(string = as.character(boat_sightings$Lat_min),
                                pattern =  "[[:punct:]]",
                                n = 2)[,2] 

# replace double zeros with 0 othewise this will cause an error becuase it considers the cell empty
s_y <- sub("", "0", x=  s_y_chr) %>% 
   as.numeric() * 0.60 # (normally *60, but we have effectively ,multiplied by 10 already by removing the decimal part in front of the point".")
   
s_x_chr <- stringr::str_split_fixed(string = as.character(boat_sightings$Long_min),
                                pattern =  "[[:punct:]]",
                                n = 2)[,2]
# repalce double zeros with 0 othewise this will cause an error becuase it considers the cell empty
s_x <- sub("", "0", x=  s_x_chr) %>% 
  as.numeric() * 0.60 
  

# concatenate into a single character
# dms_y <- paste0(d_y, "°",m_y,"′",as.character(s_y), "″N")
# dms_y_2 <- sp::char2dms(dms_y, chd = "°", chm = "′", chs = "″")
# dms_x <- paste0(d_x, "°",m_x,"′",as.character(s_x), "″E")
# dms_x_2 <- sp::char2dms(dms_x, chd = "°", chm = "′", chs = "″")
# 
# 
# #convert to decimal coordinates
# dd_y <- as.numeric(dms_y_2)
# dd_x <- as.numeric(dms_x_2)
# 
# # add data to dataframe
# boat_sightings$dd_lat <- dd_y
# boat_sightings$dd_lon <- dd_x
# 
# # remove NA from data set
# boat_sightings_na_removed <- boat_sightings %>% filter(!is.na(dd_lat) & !is.na(dd_lon))
# 
# # convert to sf object
# sightings_sf <- st_as_sf(
#   x = boat_sightings_na_removed,
#   coords = c("dd_lon", "dd_lat"),
#   crs = 4326
#   )
# 
# print("A lot of objects were created, but only boat_sightings and sightings_sf are required for further processing. At this stage, this script has to be run from within the script itself, and will not run properly from the source function.")
# rm(d_x, d_y, dd_x, dd_y, dms_x, dms_y, m_x, m_y, s_x, s_x_chr, s_y, s_y_chr, dms_x_2, dms_y_2)
# 
# 

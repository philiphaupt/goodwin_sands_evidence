# apply coordinate converterversion 2.
library(tidyverse)
# make a single column for boat sightings so that we can use an existing function to convert the coodinates
dat_for_conversion <- boat_sightings %>% unite(lat, Lattitude, Lat_min) %>% unite(lon, Longitude, Long_min)

# convert names to lower caps
names(dat_for_conversion) <- tolower(names(dat_for_conversion))

# run for column lat and lon
source("C:/Users/Phillip Haupt/Documents/my_functions/ddm_to_dd_converter.R", echo = T)#lo0ads function
# Get the names for the columns so that we can add the correct x or y label to the output columns.
conversion_fn_output <- apply( dat_for_conversion[,grep("lat", colnames(dat_for_conversion))| grep("lon", colnames(dat_for_conversion))] , 2 , conversion_fn )

# Create outputs
# R object: create  a new object as a tibble (not nested list)
output_data <- tibble(x = unlist(conversion_fn_output[grep("lon", names(conversion_fn_output))]),
                      y = unlist(conversion_fn_output[grep("lat", names(conversion_fn_output))]))

# join to the original data set
vessel_sightings_dd <- bind_cols(boat_sightings, output_data)

# make the data spatial
vessel_sightings_dd_pts_sf <- st_as_sf(vessel_sightings_dd, coords = c("x", "y"), crs = 4326) # Creates r spatial object (sf). Note, can change crs to 32631 to get utm31 output


# Aim: Prepare COST layer from KEIFCA vessel sightings data
# Read in sightings, convert to sf
#library(tmap)
library(sf)
library(tidyverse)
library(readxl)
# cost based on sightings


# Read in the sightings data
boat_sightings <- readxl::read_xlsx("C:/Users/Phillip Haupt/Documents/vessel_sightings/Vessel-sightings/data/VesselSightings_Data.xlsx", sheet = "Qry_Boat") %>% #C:/Users/Phillip Haupt/OneDrive - Kent & Essex Inshore Fisheries and Conservation Authority/
  filter(!is.na(Lattitude)) %>% 
  filter(Lattitude != 0) %>% 
  filter(!is.na(Longitude)) %>% 
  filter(!is.na(Lat_min)) %>% 
  filter(!is.na(Long_min))

print("The object created and used is: boat_sightings")

#read in the gear table to be able to decode the gears used
gear <- readxl::read_xlsx("C:/Users/Phillip Haupt/Documents/vessel_sightings/Vessel-sightings/data/gear_types_sightings.xlsx") %>% 
  dplyr::select(gear_code = `SFC Specific Code`,
                gear_description = `SFC Specific Description`,
                main_gear = `Main Gear Class`)






#Read in and access vessel sightings data

library(readxl)
library(tidyverse)



boat_sightings <- readxl::read_xlsx("C:/Users/Phillip Haupt/Documents/vessel_sightings/Vessel-sightings/data/Boat_sightings_20150101_to_20200601.xlsx") %>% #C:/Users/Phillip Haupt/OneDrive - Kent & Essex Inshore Fisheries and Conservation Authority/
  filter(!is.na(Lattitude)) %>% 
  filter(Lattitude != 0) %>% 
  filter(!is.na(Longitude)) %>% 
  filter(!is.na(Lat_min)) %>% 
  filter(!is.na(Long_min))

print("The object created and used is: boat_sightings")

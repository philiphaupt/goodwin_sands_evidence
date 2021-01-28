# Aim: Prepare COST layer from KEIFCA vessel sightings data
# Read in sighitngs, convert to sf
library(tmap)
library(sf)
library(tidyverse)
library(readxl)
# cost based on sightings


# Read in the sightings data
boat_sightings <- readxl::read_xlsx("C:/Users/Phillip Haupt/Documents/vessel_sightings/Vessel-sightings/data/Boat_sightings_20150101_to_20200601.xlsx", sheet = "Sheet1") %>% #C:/Users/Phillip Haupt/OneDrive - Kent & Essex Inshore Fisheries and Conservation Authority/
  filter(!is.na(Lattitude)) %>% 
  filter(Lattitude != 0) %>% 
  filter(!is.na(Longitude)) %>% 
  filter(!is.na(Lat_min)) %>% 
  filter(!is.na(Long_min))

print("The object created and used is: boat_sightings")

#read in teh gear table to be able to decode the gears used
gear <- readxl::read_xlsx("C:/Users/Phillip Haupt/Documents/vessel_sightings/Vessel-sightings/data/gear_types_sightings.xlsx") %>% 
  dplyr::select(gear_code = `SFC Specific Code`,
                gear_description = `SFC Specific Description`,
                main_gear = `Main Gear Class`)

# Convert the coordinates DMds to dd and add to object boat_sightings
source("./scripts/cost_prep_vessel_sightings_prep_convert_coordinates.R", echo=T) # currently has to be read in manually - does not run from calling source?
# rm(d_x, d_y, dd_x, dd_y, dms_x, dms_y, m_x, m_y, s_x, s_x_chr, s_y, s_y_chr, dms_x_2, dms_y_2)
st_crs(sightings_sf)
sightings_utm31_sf <- sf::st_transform(sightings_sf, st_crs(goodwin_utm31_sf))

# clean data
plot(sightings_utm31_sf["geometry"])#col = as.factor(sightings_utm31_sf$`Activity/Gear type `)

# only sightings inside goodwin
sightings_goodwin <- st_intersection(sightings_utm31_sf, goodwin_utm31_sf)

# exploratory map:
aoi <- st_buffer(goodwin_utm31_sf, 7500)

sightings_goodwin <- sightings_goodwin %>% rename(gear = `Activity...Gear.type`)
sightings_goodwin$gear <- as.factor(sightings_goodwin$gear)

# join gear code names to gear codes
sightings_goodwin <- left_join(sightings_goodwin, gear, by  = c('gear' = 'gear_code'))
# convert main gear to factor for plotting purposes
sightings_goodwin$main_gear  <- as.factor(sightings_goodwin$main_gear)

# plot map
tmap::tm_shape(aoi)+
  tmap::tm_fill("white", alpha = 0.01)+
  tmap::tm_shape(KEIFCA)+
  tmap::tm_polygons() +
  tmap::tm_shape(goodwin_utm31_sf)+
  tmap::tm_fill(col = "blue", alpha = 0.3) +
  tmap::tm_shape(sightings_goodwin)+
  tmap::tm_dots(col = "main_gear", palette=c(Potting='cyan', Trawling = 'yellow', Angling = 'blue'),stretch.palette = FALSE, size = 0.1, jitter = 0.1) # +
  # tmap::tm_shape(fishing_dat_pts_goodwin_utm31_sf) +
  # tmap::tm_dots(col = "black", size = 0.5)
#palette=c(A='cyan', B='yellow', H='blue',L='red',N='green'), 

pu_sp <- as(pu_sf, 'Spatial')
spplot(pu_sp, "cost", main = "Planning unit cost",
       xlim = c(-0.1, 1.1), ylim = c(-0.1, 1.1))

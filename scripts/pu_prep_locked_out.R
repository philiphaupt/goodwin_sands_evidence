# Locked out area from aggeregate area

library(sf)
library(tidyverse)


# lock out areas inside and outside 6 nm
pu$locked_out[pu$inside_outside_6 == "outside"] <- TRUE # exclude planning units in MMO area
#pu$locked_out[pu$inside_outside_6 == "inside"] <- FALSE - not needed as all were defined as FALSE when reading in the planning units.


# add the aggeregate extraction area as LOCKED OUT - 
#  Read in aggeregate areas:
agg_area <- read_sf("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/Goodwin_aggregate_area.shp")
#plot(agg_area["geometry"])
#st_crs(agg_area)
#st_crs(pu_geom_for_puvsp)
agg_area <- st_transform(agg_area, st_crs(pu_geom_for_puvsp)) # make projections the same UTM31 N

# intersect with planning units - keeping ony id numbers for the planning units which intersect with the aggeregate extraction area - which will be joined back to the fulllist of pus in the following step
puv_locked_out <- st_intersection(pu_geom_for_puvsp, agg_area) %>% # spatial join which assigns the polygon data (without geometry) to the point data (keeping point geometry data)
  st_drop_geometry() %>% 
  dplyr::select(puid) %>% 
  mutate(lock = TRUE)

# join to pu_no_geom (adding areas to exclude - aggeregate dredging approved areas)
pu_no_geom_lo_added <- pu_no_geom %>% left_join(puv_locked_out, by = c("id" = "puid")) %>% 
  mutate(lo = case_when(
    (locked_out == TRUE & lock == TRUE) ~ FALSE,# change this to FALSE and last one below to change the MMO (outside 6nm) to be available for solutions, but not aggeregate areas
    (locked_out == FALSE & lock == TRUE) ~ TRUE, # keeps aggeregate areas locked out
    (locked_out == FALSE & is.na(lock)) ~ FALSE, # keeps aggeregate areas locked out
    (locked_out == TRUE & is.na(lock)) ~ FALSE, #change this to FALSE and first one at the top to change the MMO (outside 6nm) to be available for solutions, but not aggeregate areas
    )) %>% 
  mutate(locked_out = lo) %>% 
  dplyr::select(-c(lock, lo))


# Locked out area from aggeregate area

library(sf)
library(tidyverse)

# 1 Read in
agg_area <- read_sf("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/Goodwin_aggregate_area.shp")
plot(agg_area["geometry"])
st_crs(agg_area)
st_crs(pu_geom_for_puvsp)
agg_area <- st_transform(agg_area, st_crs(pu_geom_for_puvsp))

# intersect with planning units
puv_locked_out <- st_intersection(pu_geom_for_puvsp, agg_area) %>% # spatial join which assigns the polygon data (without geometry) to the point data (keeping point geometry data)
  st_drop_geometry() %>% 
  dplyr::select(puid) %>% 
  mutate(lock = TRUE)

# join to pu_no_geom (adding areas to exclude - aggeregate dredging approved areas)
pu_no_geom_lo_added <- pu_no_geom %>% left_join(puv_locked_out, by = c("id" = "puid")) %>% 
  mutate(lo = case_when(
    (locked_out == TRUE & lock == TRUE) ~ FALSE,#change this to FALSE and last one below to change the MMO (outside 6nm) to be available for solutions
    (locked_out == FALSE & lock == TRUE) ~ TRUE,
    (locked_out == FALSE & is.na(lock)) ~ FALSE,
    (locked_out == TRUE & is.na(lock)) ~ FALSE,
    )) %>% 
  mutate(locked_out = lo) %>% 
  dplyr::select(-c(lock, lo))


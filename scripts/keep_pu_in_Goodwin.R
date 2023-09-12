# Restrict planning units to only those overlapping/intersecting Goodwin Sands MCZ (Not the full extent of the boundaing box around the MCZ.)

pu <- st_intersection(pu_hex, goodwin_utm31_sf %>% dplyr::select(geom))


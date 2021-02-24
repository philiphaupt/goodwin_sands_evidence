# Read in and add additional shipwrecks to the shipwreck data

# Jo - additional data
wrecks_add <- read.csv("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/additional_wreck_data_Jo_Thomson_2020Feb.csv")

# convert to sf object
wrecks_add_sf <- st_as_sf(
  x = wrecks_add,
  coords = c("LONGTITUDE", "LATITUDE"),
  crs = 4326
)


rm(wrecks_add)

shipwrecks_with_add_dat_sf <- bind_rows(shipwrecks_sf, wrecks_add_sf)

shipwrecks_with_add_dat_sf <- shipwrecks_with_add_dat_sf %>% mutate(source = if_else(is.na(SOURCE), "UKHO obstructions data", SOURCE))
shipwrecks_with_add_dat_sf$source <- as.factor(shipwrecks_with_add_dat_sf$source)
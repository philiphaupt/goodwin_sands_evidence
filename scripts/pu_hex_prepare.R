library(sf)
library(tidyverse)
library(tmap)


# DATA PREP ----------------------------------------

# PLANNING UNITS 
# read in planning units (hexagons ccreated earlier in QGIS - can be done like this: https://r-spatial.github.io/sf/reference/st_make_grid.html)
pu <- sf::st_read("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/goodwin_pu_utm31n.gpkg")


pu$locked_in <- as.logical(FALSE) # can be used to predefine planning units that we want to FORCE into the selection.
pu$locked_out <- as.logical(FALSE)

# pu cost parameter
pu$cost <- 8 # arbitrary value assigned at this opint. Replace this with Fishing cost using sightings data. It should be above zero otherwise solutons will include ALL planning units with no prioritization.
# Note plannin gunits wer created in QGIS before hand. See project on server.

# a first copy of the planning unit file but slightly different column names to allow preprocessing of puvspr wihtout duplicating the names clash requirement.
pu_geom_for_puvsp <- pu %>% 
  dplyr::select(puid, geom)

# A second copy for official input use with unneccesary columns (fields) removed
pu <- pu %>% 
  dplyr::select(id = puid,
         cost,
         locked_in,
         locked_out,
         -status, 
         - inside_outside_6)


pu_sf <-  pu %>%  st_cast("POLYGON")

# A third copy wihtout any geometry info - for fast processing, but cannot be used in scenarios with Spatial penalties, such as BLM. . drop geometry and other fields. Keep geometry if you want touse spatial constraints, like penalties for Boundary length.
pu_no_geom <-  pu %>% sf::st_drop_geometry()

#View planning units
tmap::tmap_mode("view")
tmap::tm_shape(pu_sf)+
  tmap::tm_polygons(col = "white", alpha = 0.1)












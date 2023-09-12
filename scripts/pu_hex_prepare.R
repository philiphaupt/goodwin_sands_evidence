library(sf)
library(tidyverse)

# DATA PREP ----------------------------------------
# Note planning units were created in QGIS before hand. See project on server.

# PLANNING UNITS 
  # read in planning units (hexagons created earlier in QGIS - can be done like this: https://r-spatial.github.io/sf/reference/st_make_grid.html)
#pu <- sf::st_read("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/goodwin_pu_utm31n.gpkg")
source("./scripts/make_planning_units.R")

# keep only planning units that  intersect with Goodwin Sands MCZ
source("./scripts/keep_pu_in_Goodwin.R")

# define inside and outside planning units - this allows creating planning units inside the area of KEIFCA Goodwin plus a bit extra into the MMO territory, to allow
source("./scripts/define_inside_outside_pus.R", echo = TRUE)

# intersecting planning units with inside KEIFCA boudnary, and those to be inclued outside KEIFCA boundary. 
file.edit("./scripts/earmark_pus.R")

# pu cost parameter
pu$cost <- 8 # arbitrary value assigned at this point. Replace this with Fishing cost using sightings data. It should be above zero otherwise solutons will include ALL planning units with no prioritization.


# lock out areas inside and outside 6 nm
pu$locked_out[pu$inside_outside_6 == "outside"] <- TRUE # exclude planning units in MMO area
#pu$locked_out[pu$inside_outside_6 == "inside"] <- FALSE - not needed as all were defined as FALSE when reading in the planning units.


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
# tmap::tmap_mode("view")
# tmap::tm_shape(pu_sf)+
#   tmap::tm_polygons(col = "white", alpha = 0.1)












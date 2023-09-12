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

# intersecting planning units with inside KEIFCA boundary, and those to be inclued outside KEIFCA boundary. 
source("./scripts/earmark_pus.R")












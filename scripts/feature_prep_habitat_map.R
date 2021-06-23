# Read in conservation features: Habitat map and Sabellaria and mussels, and process these ready for combining into the planning units (pu)
library(sf)
library(tidyverse)
library(mapview)


# FEATURES (Read in)
# HABITAT - all habitata read in, target 0 for non designated habitat: Note that this habitat file was prepared in QGIS. Multiple steps were taken to prepare it: see prject files on server.
habitat <- sf::st_read("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/goodwin_habitat_utm31n.gpkg", layer = "goodwin_habitat_utm31n_intersect_hex_pus")
hab <- habitat %>% dplyr::select(fid, puid, eunis_l3, sf_code, sf_name, orig_hab,hab_type, area, geom)
# plot(st_geometry(hab), col = as.factor(hab$eunis_l3))
mapview::mapview(hab,zcol = "orig_hab")


# plot map of habitat, Sabellaia and mussels
mapview::mapview(list(hab, sab_and_mussels),
                 zcol = list("orig_hab", "name"),
                 cex = list(NULL, "count"),
                 burst = TRUE)

# prepare a habitat data set without a geomoetry for fast processing whre geometry is not required.
hab_no_geom <- hab %>% st_drop_geometry()

# house keeping - remove large objects to free up memory
rm(habitat) 


# ASSIGN FEATURE IDs: Habitat types (EUNIS L3)
# Assess distinct habitat types so taht we can assign them ID numbers for the problem setting (further down the code)
hab_no_geom %>% distinct(eunis_l3, orig_hab)
# Assign a column with the habitat numbers as follows (I have used shorthand to denote these:
# here are the id codes for the habitat types: 3 = "subt_sand"(A5.2), 4 = "subt_mix_sed" (A5.4), 5 = "subt_coarse_sed" (A5.1), 6 = "mod_en_circ_rock" (A4.2)
hab_no_geom$id <- as.numeric("") # add column "id" in which the habitat type id will be stored.
hab_no_geom$id[hab_no_geom$eunis_l3 == "A5.2"] <- 3
hab_no_geom$id[hab_no_geom$eunis_l3 == "A5.4"] <- 4
hab_no_geom$id[hab_no_geom$eunis_l3 == "A5.1"] <- 5
hab_no_geom$id[hab_no_geom$eunis_l3 == "A4.2"] <- 6





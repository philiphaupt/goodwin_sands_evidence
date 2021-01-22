# AIM: # Read in conservation features: Species: Sabellaria and mussels, and process these ready for combining into the planning units (pu)


library(sf)
library(tidyverse)

# SPECIES - only designated species were used
# read in spatial point data for sabellaria and mussels
sab_and_mussels <- sf::st_read("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/sab_and_mussels_mcz_features_utm31n.gpkg")
sab_and_mussels <- sab_and_mussels %>% mutate(name = tolower(str_sub(sab_and_mussels$taxonname,1,3))) # add simplified species name


# ASSIGN FEATURE IDs: Species
sab_and_mussels$fid <- sab_and_mussels$id # rename column "id" to "fid",becuase column name "ID" is reserved for problem setting in PriotizeR.
sab_and_mussels$id[sab_and_mussels$name == "sab"] <- 1 # assign id numbers based on species names that match the SPEC file
sab_and_mussels$id[sab_and_mussels$name == "myt"] <- 2 # assign id numbers based on species names that match the SPEC file



# drop these lines - dont need to separate them.
# separate the ross worma nd mussels
# sab <- sab_and_mussels %>% filter(grepl("Sabellaria", taxonname))
# mus <- sab_and_mussels %>% filter(grepl("Mytilus", taxonname))
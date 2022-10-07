 # AIM: prepare the planning unit by conservation feature matrix: PUVSP (equivalent from Marxan)

library(tidyverse)
library(sf)
library(data.table)
# library(nngeo) = if you  need nearest neighbour calculations - e.g. points for sabellaria outside of mcz, but you want to include the data.

# FEATURES BY PLANNING UNITS MATRIX (rij - matrix or data.frame required in problem setting)
# species (note that the habitat file was preprocessed i a similar way in QGIS)
puvsp_prep_mussels <- st_join(mussels, pu_geom_for_puvsp, join = st_intersects) %>% # spatial join which assigns the polygon data (without geometry) to the point data (keeping point geometry data)
  st_drop_geometry() #then drop the point geometry data, as we do not need it for further processing



# spec puvspr prep: Calculate the total abundance for each species in each planning unit. 
puvsp_prep_2 <- puvsp_prep_mussels %>%
  dplyr::select( # drop unnecessary fields
    id, 
    name,
    puid,
    count
  ) %>% 
  group_by( # group by species id (which will be mirrored in name AND planning unit)
    id, 
    name,
    puid
  ) %>% 
  dplyr::summarise(amount = sum(as.numeric(count)))
# dplyr::summarise(amount = log10(sum(as.numeric(count)))+0.1 )# I have log-transformed totals to reduce the effect of super abudnant sites. Transformation can be weakened by sqrt transformation, and strengthened to presence absence transformation.
# this will reduce the number of records, a there may be multiple points in eahch planning unit.

# complete information for all pus - i.e. fill in zero values. We can't fill it in yet - BUT we first need to add ALL the planning unit ID numbers - which is what we will do here.
puvsp_prep_3 <- left_join(pu_geom_for_puvsp, puvsp_prep_2, by = "puid")%>% #adds the planning units and
  mutate_if(is.numeric,coalesce,0) %>% # keeping existing data where the species is present, and assigning NA or 0 to the amount column.
  st_drop_geometry() # don't need the geometry for the puvspr, as it references the planning unit ID, whch the software will pick up when reading the planning unit file.
# Explanation of the resulting table: Results in 288 records: 278 planing units, and additional 10 records as cells where both sabellaria and mytilus are present will be represented twice in teh data.

# Complete information step 2: Create a long table with all planning unit id numbers for every species: Done in two steps pivoting data wider while filling in zero values for absences and then longer
puvsp_prep_4 <- puvsp_prep_3 %>%
  dplyr::select(pu = puid, # keep only essential fields
                species = id,
                amount) %>% 
  pivot_wider(id_cols = pu,
              names_from = species,
              values_from = amount,
              values_fill = 0) %>% 
  dplyr::select(-`0`) %>% 
  #pivot_longer(cols = c(`1`, `2`), names_to = "species") %>% 
  pivot_longer(cols = unique(puvsp_prep_3$id),names_to = "species") %>% 
  dplyr::select(pu,
                species,
                amount = value) %>% 
  arrange(pu, species)

# make species numeric
puvsp_prep_4$species <- as.numeric(puvsp_prep_4$species)

# Explanation of resulting table (and test) This should result in a table where the number of rows are equal to the number of planning units multiplied by the number of species read in. Here 278 * 2 = 556

rm(puvsp_prep_mussels, puvsp_prep_2, puvsp_prep_3) # housekeeping

# Add Sabellaria polygons in the same way.
puvsab <- sab_no_geom %>% 
  dplyr::select(pu = puid,
                species = id,
                amount = area_km) %>%
  pivot_wider(id_cols = pu,
              names_from = species,
              values_from = amount,
              values_fill = 0) %>% #at this point there are 278 rows and the column s are the id numbers that we used for the habitat, so 3,4,5,6, and pu.
  pivot_longer(cols = `1`, names_to = "species") %>% 
  dplyr::select(pu,
                species,
                amount = value) %>% # now there are 5 * 278 rows of data - see comment above
  arrange(pu, species)

# make species numeric
puvsab$species <- as.numeric(puvsab$species)
# Add habitat in the same way.
puvhab <- hab_no_geom %>% 
  dplyr::select(pu = puid,
                species = id,
                amount = area_km) %>% 
  pivot_wider(id_cols = pu,
              names_from = species,
              values_from = amount,
              values_fill = 0) %>% #at this point there are 278 rows and the column s are the id numbers that we used for the habitat, so 3,4,5,6, and pu.
  pivot_longer(cols = c(`3`, `4`, `5`, `6`), names_to = "species") %>% 
  dplyr::select(pu,
                species,
                amount = value) %>% # now there are 5 * 278 rows of data - see comment above
  arrange(pu, species)

# make species numeric
puvhab$species <- as.numeric(puvhab$species)






# COMBINE DATA SETS
#combine pu v sp and pu v hab.
puvf <- bind_rows(puvsab, puvsp_prep_4,puvhab) ## planning unit versus feature

print("Output to use: puvf, contains planning unit number and amount of species and habitat per pu.")


rm(puvhab, puvsp_prep_4)

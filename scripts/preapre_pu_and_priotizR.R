library(sf)
library(tidyverse)
library(data.table)
# library(nngeo) = if you  need nearest neighbour calculations - e.g. points for sabellaria outside of mcz, but you want to include the data.
library(mapview)
library(prioritizr)
library("gurobi")
library("slam")

# DATA PREP ----------------------------------------

# PLANNING UNITS
# read in planning units (hexagons ccreated earleir in QGIS - can be done like this: https://r-spatial.github.io/sf/reference/st_make_grid.html)
pu <- sf::st_read("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/goodwin_pu_utm31n.gpkg")
#create a blank canvas planning units
pu$locked_in <- as.logical(FALSE) # can be used to predfine planning units that we want to FORCE into the selection.
pu$locked_out <- as.logical(FALSE)
pu$locked_out[pu$inside_outside_6 == "outside"] <- TRUE # exclude planning units in MMO area
#pu$locked_out[pu$inside_outside_6 == "inside"] <- FALSE
pu$cost <- 8 # arbitrary - could replace this with Fishing cost using sightings data.
# Note plannin gunits wer created in QGIS before hand. See project on server.

# a first copy of hte planning unit file but slightly different column names to allow preprocessing of puvspr wihtout duplciating the names clash requirement.
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



# FEATURES (Read in)

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

# HABITAT - all habitata read in, target 0 for non designated habitat: Note that this habitat file was prepared in QGIS. Multiple steps were taken to prepare it: see prject files on server.
habitat <- sf::st_read("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/goodwin_habitat_utm31n.gpkg", layer = "goodwin_habitat_utm31n_intersect_hex_pus")
hab <- habitat %>% dplyr::select(fid, puid, eunis_l3, sf_code, sf_name, orig_hab,hab_type, area, geom)
# plot(st_geometry(hab), col = as.factor(hab$eunis_l3))
mapview::mapview(hab,zcol = "orig_hab")
# plot map of habitat, Sabellaia and mussels
mapview::mapview(list(hab, sab_and_mussels),
                 zcol = list("orig_hab", NULL),
                 cex = list(NULL, "count"),
                 burst = TRUE)

hab_no_geom <- hab %>% st_drop_geometry()

rm(habitat) # house keeping remove large objects to free up memory
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

# SPEC (Make it from the Features)
# create spec.dat (features) for prioritizer
# "id" # integer unique identifier for each feature These identifiers are used
# in the argument to rij.
# "name" # character name for each feature.
# "prop" # numeric relative target for each feature (optional).
# "amount" # numeric absolute target for each feature (optional)
id <- c(1,2, 3,4,5,6)
name <- c("sab", "myt", "subt_sand", "subt_mix_sed", "subt_coarse_sed", "mod_en_circ_rock")
prop <- c(0.025,0.02, 0.2, 0, 0.2, 0.035) # target is zero for non-designated mixed subtidal sediment
spec <- as.data.frame(cbind(id, name, prop))
spec$id <- as.numeric(spec$id)
spec$prop <- as.numeric(spec$prop)



# FEATURES BY PLANNING UNITS MATRIX (rij - matrix or data.frame reqiored in problem setting)
# species (note that the habitat file was preprocessed i a similar way in QGIS)
puvsp_prep <- st_join(sab_and_mussels, pu_geom_for_puvsp, join = st_intersects) %>% # spatial join which assigns the polygon data (without geometry) to the point data (keeping point geometry data)
  st_drop_geometry() #then drop the point geometry data, as we do not need it for further processing
  

# spec puvspr prep: Calculate hte total abundance for each species in each planning unit. 
puvsp_prep_2 <- puvsp_prep %>%
  dplyr::select( # drop unneccssary fields
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

# complete information for all pus - i.e. fill in sero values. We can't fill it in yet - BUT we first need to add ALL the planning unit ID numbers - which is what we will do here.
puvsp_prep_3 <- left_join(pu_geom_for_puvsp, puvsp_prep_2, by = "puid")%>% #adds the planning units and
  mutate_if(is.numeric,coalesce,0) %>% # keeping existinng data where teh species is present, and assigning NA or 0 to the amount column.
  st_drop_geometry() # don't need the geometry for the puvspr, as it references the planning unit ID, whch the software will pick up when reading the planning unit file.
# Explanation of the resulting table: Results in 288 reocrds: 278 planing units, and additional 10 records as cells where both sabellaria and mytilus are present will be represented twice in teh data.

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
  pivot_longer(cols = c(`1`, `2`), names_to = "species") %>% 
  dplyr::select(pu,
         species,
         amount = value) %>% 
  arrange(pu, species)

# make species numeric
puvsp_prep_4$species <- as.numeric(puvsp_prep_4$species)
  
# Explabnation of resulting table (and test) This should result in a table where the number of rows are equal to the number of planning units multiplied by the naumber of species read in. Here 278 * 2 = 556
rm(puvsp_prep, puvsp_prep_2, puvsp_prep_3)

# Add habitat in the same way.
puvhab <- hab_no_geom %>% 
  dplyr::select(pu = puid,
         species = id,
         amount = area) %>% 
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
puvf <- bind_rows(puvsp_prep_4,puvhab) ## planning unit versus feature


# PROBLEM DEFINTION -------------------------------------------------------


#https://cran.r-project.org/web/packages/prioritizr/prioritizr.pdf


# PROBLEM DEFINTION: # define the objective, e.g. minimum set while achieving all targets, maximum coverage - see https://cran.r-project.org/web/packages/prioritizr/vignettes/prioritizr.html - about a 1/4 the way down the page for may more options.  All conservation planning problems involve minimizing or maximizing some kind of objective. Most relevant ones are:  ----------------------------------------------

# DEFINE BUDGET:
# overall 2780 planning units costed at 10 units per unit , for example - this could be done using fishing effort toweight it. Total is thus 2780. If we set a maximum budget at 50% of that we can force the software not to select all units for objectives that will maximise achievement while not exceeding budget.

# STEPS:
# Define the problem (1st step of every example below - should be consistent)
# Add an objective
# Add targets
# Add constraints
# Add penalties

source("./scripts/prepare_aggeregate_area_as_locked_out.R")
# EXPLORE combinations the above to develop conservation plnning options:

# MIN SET
# Minimum set objective: Minimize the cost of the solution whilst ensuring that all targets are met (Rodrigues et al. 2000). This objective is similar to that used in Marxan (Ball et al. 2009).

p_min_set <- problem(x = pu_no_geom_lo_added, cost_column = "cost", features = spec, rij = puvf) %>% # define the base in put data: x is the planning units, features are the species or habitats, and we define the cost column which we may relate to fishing activity or aggeregate dredging; not that locked in and out can also be used
  add_min_set_objective() %>% 
  add_relative_targets(spec$prop) %>% # or a single arbrirary target or c() numbers
  #add_locked_in_constraints(which(pu_no_geom$locked_in)) %>%  # Locked in constraints: Add constraints to ensure that certain planning units are prioritized in the solution. For example, it may be desirable to lock in planning units that are inside existing protected areas so that the solution fills in the gaps in the existing reserve network.
  add_locked_out_constraints(which(pu_no_geom_lo_added$locked_out)) %>% # Locked out constraints: Add constraints to ensure that certain planning units are not prioritized in the solution. For example, it may be useful to lock out planning units that have been degraded and are not suitable for conserving species.
  add_gurobi_solver(time_limit = 120)
  #add_neighbor_constraints(2)  # Neighbor constraints: Add constraints to a conservation problem to ensure that all selected planning units have at least a certain number of neighbors.
  #add_boundary_penalties(0.01)# Boundary penalties: Add penalties to penalize solutions that are excessively fragmented. These penalties are similar to those used in Marxan (Ball et al. 2009; Beyer et al. 2016).

# MAX COVER
# Maximum cover objective: Represent at least one instance of as many features as possible within a given budget (Church et al. 1996).

p_max_cover <- problem(x = pu_no_geom, features = spec, rij = puvf , cost_column = "cost") %>% # define the base in put data: x is the planning units, features are the species or habitats, and we define the cost column which we may relate to fishing activity or aggeregate dredging; not that locked in and out can also be used
  add_max_cover_objective(1390) %>% # define the objective, e.g. minimum set while achieving all targets, maximum coverage - see https://cran.r-project.org/web/packages/prioritizr/vignettes/prioritizr.html - about a 1/4 the way down the page for may more options.  All conservation planning problems involve minimizing or maximizing some kind of objective. Most relevant ones are: 
  add_relative_targets(spec$prop)

# MAX FEATURES OBJECTIVES
# Maximum features objective: Fulfill as many targets as possible while ensuring that the cost of the solution does not exceed a budget (inspired by Cabeza & Moilanen 2001). This object is similar to the maximum cover objective except that we have the option of later specifying targets for each feature. In practice, this objective is more useful than the maximum cover objective because features often require a certain amount of area for them to persist and simply capturing a single instance of habitat for each feature is generally unlikely to enhance their long-term persistence.
p_max_feat <- problem(x = pu_no_geom, features = spec, rij = puvf , cost_column = "cost") %>% # define the base in put data: x is the planning units, features are the species or habitats, and we define the cost column which we may relate to fishing activity or aggeregate dredging; not that locked in and out can also be used
  add_max_features_objective(1390) %>% 
  add_relative_targets(spec$prop)

# MIN SHORTFALL
# Minimum shortfall objective: Minimize the shortfall for as many targets as possible while ensuring that the cost of the solution does not exceed a budget. In practice, this objective useful when there is a large amount of left-over budget when using the maximum feature representation objective and the remaining funds need to be allocated to places that will enhance the representation of features with unmet targets.
p_min_shortfall <- problem(x = pu_no_geom, features = spec, rij = puvf , cost_column = "cost") %>% # define the base in put data: x is the planning units, features are the species or habitats, and we define the cost column which we may relate to fishing activity or aggeregate dredging; not that locked in and out can also be used
  add_min_shortfall_objective(budget = 1390) %>% 
  add_relative_targets(spec$prop)





# SOLUTIONS ---------------------------------------------------------------
# SOLUTIONS: MIN SET
s_min_set <- prioritizr::solve(p_min_set)
s_min_set_sf <- left_join(pu_geom_for_puvsp, s_min_set, by = c("puid" = "id"))
# MAX COVER
s_max_cover <- prioritizr::solve(p_max_cover)
s_max_cover_sf <- left_join(pu_geom_for_puvsp, s_max_cover, by = c("puid" = "id"))
# MAX FEATURES OBJECTIVES
s_max_feat <- prioritizr::solve(p_max_feat)
s_max_feat_sf <- left_join(pu_geom_for_puvsp, s_max_feat, by = c("puid" = "id"))
# MIN SHORTFALL
s_min_shortfall <- prioritizr::solve(p_min_shortfall)
s_max_feat_sf <- left_join(pu_geom_for_puvsp, s_min_shortfall, by = c("puid" = "id"))

# PLOTS -------------------------------------------------------------------


# MINSET SOLUTIONS --------------------------------------------------------


plot(s_min_set_sf["solution_1"], 
     main = "Solution",
     axes = TRUE, 
     key.width = lcm(1.3), 
     key.length = 1.0, 
     key.pos = 4,
     pal = sf.colors(2),
     graticule = TRUE
     #ylim = c(390000, 411390), xlim = c(566500, 569000))
)


mapview(s_min_set_sf["solution_1"], 
        legend = TRUE)


# only solution
sol <- s_min_set_sf %>% dplyr::filter(solution_1 == 1)
# read in for plotting
KEIFCA_boundary_line <- st_read("C:/Users/Phillip Haupt/Documents/GIS/6M_12M_from_territorial_sea_baseline_5_Jun_20_and_1983/KEIFCA_6NM.GPKG", layer = "KEIFCA_bounbdary_line")

# plot solution over the features
mapview::mapview(list(hab, KEIFCA_boundary_line, sol, sab_and_mussels, agg_area),#KEIFCA read in on vessel_sightings_in_goodwin.R script
                 zcol = list("orig_hab","IFCA", "solution_1", "taxonname", "FID"),
                 alpha.regions = list(0.7,0, 0, 1, 0),
                 alpha = list(0.1, 0.7, 1, 0.1, 1),
                 cex = list(NULL, NULL, NULL, "count", NULL),
                 color = list("grey", "black", "darkgreen", "black", "black"),
                 lwd = list(1, 2, 3, 1, 2),
                 burst = TRUE,
                 legend = TRUE,
                 label = hab$orig_hab)

#batch run with SPF, BLM, NREPS, NITNS changing
# spf <- c(30,25)
# blm <- c(0, 0.1, 0.2, 0.5, 1)
# nreps <- c(10, 20, 50, 100)
# nitns <- c(10000, 100000, 1000000, 10000000)
# mm <- marxan(pu="pu_non_st.csv", 
#              puvsp="puvsp_non_st.csv", 
#              spec="spec_non_st.csv", 
#              bound="bound_non_st.csv",
#              spf=spf, blm=blm, nreps=nreps, nitns=nitns, scenname="Full")


# INTERPRETATION OF SOLUTION
#-----------calculations
# 
# ~ Pre calcuulations
# Hwo much of the features are inside and how much is outside?



# Cost
s_min_set %>% 
  group_by(solution_1) %>% 
  summarise(sum(cost))

results <- left_join(puvf, s_min_set, by = c("pu" = "id"))
results2 <- left_join(results, spec, by = c("species" = "id"))                       

# What proportionof each feature occurs inside and occurs outside 6NM?
#habitat - inside 6nm
results2 %>% group_by(name, locked_out, solution_1) %>% 
  summarise(amount = sum(amount)) %>% 
  filter(name != "sab" & name != "myt" & locked_out == FALSE) %>% 
ggplot2::ggplot(aes(x = solution_1, y = amount))+
  geom_col(aes(fill = as.factor(solution_1))) +
  facet_wrap(name~locked_out)

#habitat - inside and outside 6nm
results2 %>% group_by(name, locked_out, solution_1) %>% 
  summarise(amount = sum(amount)) %>% 
  filter(name != "sab" & name != "myt") %>% 
  ggplot2::ggplot(aes(x = solution_1, y = amount))+
  geom_col(aes(fill = as.factor(solution_1))) +
  facet_wrap(name~locked_out)

#species - inside 6nm
results2 %>% group_by(name, locked_out, solution_1) %>% 
  summarise(amount = sum(amount)) %>% 
  filter(name == "sab" & locked_out == FALSE | name == "myt" & locked_out == FALSE) %>% 
  ggplot2::ggplot(aes(x = solution_1, y = amount))+
  geom_col(aes(fill = as.factor(solution_1))) +
  facet_wrap(name~locked_out)

#species  - in and out 6nm
results2 %>% group_by(name, locked_out, solution_1) %>% 
  summarise(amount = sum(amount)) %>% 
  filter(name == "sab" | name == "myt" ) %>% 
  ggplot2::ggplot(aes(x = solution_1, y = amount))+
  geom_col(aes(fill = as.factor(solution_1))) +
  facet_wrap(name~locked_out)

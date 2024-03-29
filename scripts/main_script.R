# spatial planning scenario 1 MAIN script - calling the helper scripts in the correct sequence
rm(list = ls())
# USER INPUT PARAMETERS
# Planning Units
sqaures = FALSE # shape of planning units
pu_cell_size = 666.859 #  If hexagons 666.859 is roughly 1 km^2 surface area. 

# Planning units adjacency to MMO district
# Distance to buffer around KEIFCA district
keifca_buffer_distance = 800 # this ensures that adjacent MMO planning units can be selected in or out.

# # List all the files in the scripts directory
# dir("./scripts") # all the files in 
# file.rename("./scripts/solution_map_prep_goodwin_mcz.R", "./scripts/map_utelities_prep_goodwin_mcz.R")

# PREP
# Read in mapping utility files
source("./scripts/map_utelities_prep_KEIFCA_district_boundaries.R", echo=T) #KEIFCA boundaries
source("./scripts/map_utelities_prep_goodwin_mcz.R", echo=T) # MCZ

# PLANNING UNITS
# 1. Prepare the planning units 1 - read in , assign baseline cost, provide fields/columns for inserting locked in locked out info & repeat this so that there are options with and without geometry, and one with only geometry and puid
source("./scripts/pu_hex_prepare.R", echo=T)

# 2. Set COST for planning units
source("./scripts/cost_pu.R")

# 2. {NOT RUN this would have been to exclude aggeregate dredging areas - but this is now open for selecion again becuase the license application has been halted.}Prepare planning units 2 - assign locked out areas
# file.edit("./scripts/pu_prep_locked_out.R", echo=T)

# 3. Planning Unit finishing before creating PUvSP matrix
source("./scripts/pu_final_prep.R")


# CONSERVATION FEATURES
# 3. Feature prep - 1 Sabellaria and Mussels (CEFAS 2014 survey)
source("./scripts/feature_prep_sabellaria_and_mussels.R", echo=T) # included
source("./scripts/feature_prep_mapped_sabellaria_alternative.R")#")
# 4. Feature prep -2 Habitat map (Natural England)
source("./scripts/feature_prep_habitat_map.R", echo=T) # included


#--------
# NOT INCLUDED IN THE PLAN YET - see the list of features that still needs including
# 5. Feature prep - 3 shipwrecks (OS maps - hydrographic office)
# source("./scripts/feature_prep_shipwrecks.R", echo=T) # not included
# source("./scripts/feature_prep_shipwrecks_add_GSCT_additional_data.R", echo=T) # not included
# 6. Feature prep - Fish data NS IBTS (ICES DATRAS 2015 - 2020 included)
# source("./scripts/feature_prep_fish_NS_IBTS_survey.R", echo=T) # Warning: slow, large data set, long processing time # not included
#----------

# 7. PUVSP (create planing units using one of two approaches - 1 with Sabellaria ,mapped out polygons, 2, Sabellaria points)
if("sab_polys" %in% ls()){
  source("./scripts/puvsp_prep_with_sab_polys.R", echo=T)
} else {
source("./scripts/puvsp_prep.R", echo=T)
}


# TARGETS
# 8. Set conservation target for habitats and species & other features
source("./scripts/targets_set.R", echo=T)
source("./scripts/feature_full_names_for_plots.R", echo = T) #  more info about features - needs to be run after spec is read in


# COST
# 9. Vessel sightings
source("./scripts/cost_prep_vessel_sightings_in_goodwin.R", echo=T) # NB! Warning: needs to be run inside script!
# make sure conversion scripts reads from here: C:/Users/Phillip Haupt/Documents/GIS/COORDINATE_CONVERTER/coordinate_converter/scripts/ddm_to_dd_converter.R

# Convert the coordinates DMds to dd and add to object boat_sightings
source("C:/Users/Phillip Haupt/Documents/my_functions/ddm_to_dd_converter.R", echo = T)#lo0ads function
source("./scripts/cost_prep_vessel_sightings_convert_coordinates_v2.R", echo=T) # currently has to be read in manually - does not run from calling source?

# Remove non-working sightings
source("./scripts/keep_only_working_sightings.R")

# plot vessel sightings
source("./scripts/cost_prep_vessel_sightings_plot.R", echo = TRUE)

# PROBLEM DEFINTION
# 10. Define the conservation planning problem
source("./scripts/problem_definition.R", echo=T)

# SOLUTIONS
# 11. RUN solutions by running a spatial optimisation algorithm
source("./scripts/solutions_run.R", echo=T)

# 12. map solutions
source("./scripts/solution_map.R", echo=T) 

# 13. solution analysis
source("./scripts/solution_analyse_cost_target_achievement.R", echo=T)


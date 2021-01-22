 # spatial planning scnearion 1 MAIN script - calling the helper scripts in the correct sequence

# # List all the files inthe scripts directory
# dir("./scripts") # all the files in 
# file.rename("./scripts/solution_map_prep_goodwin_mcz.R", "./scripts/map_utelities_prep_goodwin_mcz.R")

# PREP
# Read in mapping utelity files
source("./scripts/map_utelities_prep_KEIFCA_district_boundaries.R", echo=T) #KEIFCA boundaries
source("./scripts/map_utelities_prep_goodwin_mcz.R", echo=T) # MCZ

# PLANNING UNITS
# 1. Prepare the planning units 1 - read in , assign baseline cost, provide fields/columns for inserting locked in locked out info & repeat this so that there are options with and without geometry, and one with only geometry and puid
source("./scripts/pu_hex_prepare.R", echo=T)

# 2. Prepare planning units 2 - assign locked out areas
source("./scripts/pu_prep_locked_out.R", echo=T)


# CONSERVATION FEATURES
# 3. Feature prep - 1 Sabellaria and Mussels (CEFAS 2014 survey)
source("scripts/feature_prep_sabellaria_and_mussels.R", echo=T) # included
 
# 4. Feature prep -2 Habitat map (Natural England)
source("./scripts/feature_prep_habitat_map.R", echo=T) # included
 
# 5. Feature prep - 3 shipwrecks (OS maps - hydrographic office)
source("./scripts/feature_prep_shipwrecks.R", echo=T) # not included

# 6. Feature prep - Fish data NS IBTS (ICES DATRAS 2015 - 2020 included)
source("./scripts/feature_prep_fish_NS_IBTS_survey.R", echo=T) # Warning: slow, large data set, long processing time # not included

# TARGETS
# 7. Set conservation target for habitats and species & other features
source("./scripts/targets_set.R", echo=T)

# PUVSP
# prepare PU vs Feature matrix
source("./scripts/puvsp_prep.R", echo=T)

# COST
# 9. Vessel sightings
source("./scripts/cost_prep_vessel_sightings_in_goodwin.R", echo=T) # NB! Warning: needs to be run inside script!

# PROBLEM DEFINTION
# 10. Define the conservation planning problem
source("./scripts/problem_definition.R", echo=T)

# SOLUTIONS
# 11. RUN solutions by running a spatial optimisation algorithm
source("./scripts/solutions_run.R", echo=T)

# 12. map solutions
source("./scripts/solution_map.R", echo=T) #Wrnging: run iside files to see outputs

# 13. solution analysis
source("./scripts/solution_analyse_cost_target_achievement.R", echo=T)

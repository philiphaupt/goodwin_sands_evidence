# PROBLEM DEFINTION -------------------------------------------------------
library(tidyverse)
library(prioritizr)
library("gurobi")
library("slam")

#  Background information:
#https://cran.r-project.org/web/packages/prioritizr/prioritizr.pdf


# see e.g. minimum set while achieving all targets, maximum coverage - see https://cran.r-project.org/web/packages/prioritizr/vignettes/prioritizr.html - about a 1/4 the way down the page for may more options.  All conservation planning problems involve minimizing or maximizing some kind of objective. Most relevant ones are:  ----------------------------------------------

# DEFINE BUDGET: or the cost of planning units
# overall 278 planning units (pus) costed at 10 units per unit if each pu costs the same, i.e. has the same penalty for earmrking it to achieve conservation targets. Alternatively this could be done using fishing effort to weight the cost of each planning unit, therefore making it more costly to achieve a cosnervation target in an area where fishign already takes place.
# Total is thus 2780. If we set a maximum budget at 50% of that we can force the software not to select all units for objectives that will maximise achievement while not exceeding budget.

# STEPS in the problem defintion
# Define the problem (1st step of every example below - should be consistent)
# Add an objective
# Add targets
# Add constraints
# Add penalties


# EXPLORE combinations the above to develop conservation planning options:
# source("./scripts/prepare_aggeregate_area_as_locked_out.R") # in this script we can lock pus out of the possible set of solutions.


# MIN SET
# Minimum set objective: Minimize the cost of the solution whilst ensuring that all targets are met (Rodrigues et al. 2000). This objective is similar to that used in Marxan (Ball et al. 2009).
pu_sf$geometry <- pu_sf$geom
#p_min_set <- pu_sf %>% dplyr::select(-id, geom) %>% problem(cost_column = "cost", features = spec, rij = puvf) %>% # define the base in put data: x is the planning units, features are the species or habitats, and we define the cost column which we may relate to fishing activity or aggeregate dredging; not that locked in and out can also be used
p_min_set <- problem(pu_no_geom_lo_added,cost_column = "cost", features = spec, rij = puvf) %>% # define the base in put data: x is the planning units, features are the species or habitats, and we define the cost column which we may relate to fishing activity or aggeregate dredging; not that locked in and out can also be used
  add_min_set_objective() %>% 
  add_relative_targets(spec$prop) %>% # or a single arbrirary target or c() numbers
  #add_locked_in_constraints(which(pu_no_geom$locked_in)) %>%  # Locked in constraints: Add constraints to ensure that certain planning units are prioritized in the solution. For example, it may be desirable to lock in planning units that are inside existing protected areas so that the solution fills in the gaps in the existing reserve network.
  add_locked_out_constraints(which(pu_no_geom_lo_added$locked_out)) %>% # Locked out constraints: Add constraints to ensure that certain planning units are not prioritized in the solution. For example, it may be useful to lock out planning units that have been degraded and are not suitable for conserving species.
  #add_neighbor_constraints(k = 9) %>% 
  #add_rsymphony_solve_LP(gap = 0, time_limit = 120, verbose = TRUE) # free, may need sympphony to be installed
  add_gurobi_solver(gap = 0, time_limit = 120, verbose = TRUE) # propriatary
#add_neighbor_constraints(2)  # Neighbor constraints: Add constraints to a conservation problem to ensure that all selected planning units have at least a certain number of neighbors.
#add_boundary_penalties(0.01)# Boundary penalties: Add penalties to penalize solutions that are excessively fragmented. These penalties are similar to those used in Marxan (Ball et al. 2009; Beyer et al. 2016).

# MAX COVER
# Maximum cover objective: Represent at least one instance of as many features as possible within a given budget (Church et al. 1996).

p_max_cover <- problem(x = pu_no_geom, features = spec, rij = puvf , cost_column = "cost") %>% # define the base in put data: x is the planning units, features are the species or habitats, and we define the cost column which we may relate to fishing activity or aggeregate dredging; not that locked in and out can also be used
  add_max_cover_objective(1390) %>% # define the objective, e.g. minimum set while achieving all targets, maximum coverage - see https://cran.r-project.org/web/packages/prioritizr/vignettes/prioritizr.html - about a 1/4 the way down the page for may more options.  All conservation planning problems involve minimizing or maximizing some kind of objective. Most relevant ones are: 
  add_relative_targets(spec$prop) %>% 
  add_gurobi_solver(gap = 0, time_limit = 120, verbose = TRUE)
# MAX FEATURES OBJECTIVES
# Maximum features objective: Fulfill as many targets as possible while ensuring that the cost of the solution does not exceed a budget (inspired by Cabeza & Moilanen 2001). This object is similar to the maximum cover objective except that we have the option of later specifying targets for each feature. In practice, this objective is more useful than the maximum cover objective because features often require a certain amount of area for them to persist and simply capturing a single instance of habitat for each feature is generally unlikely to enhance their long-term persistence.
p_max_feat <- problem(x = pu_no_geom, features = spec, rij = puvf , cost_column = "cost") %>% # define the base in put data: x is the planning units, features are the species or habitats, and we define the cost column which we may relate to fishing activity or aggeregate dredging; not that locked in and out can also be used
  add_max_features_objective(1390) %>% 
  add_relative_targets(spec$prop)  %>% 
  add_gurobi_solver(gap = 0, time_limit = 120, verbose = TRUE)

# MIN SHORTFALL
# Minimum shortfall objective: Minimize the shortfall for as many targets as possible while ensuring that the cost of the solution does not exceed a budget. In practice, this objective useful when there is a large amount of left-over budget when using the maximum feature representation objective and the remaining funds need to be allocated to places that will enhance the representation of features with unmet targets.
p_min_shortfall <- problem(x = pu_no_geom, features = spec, rij = puvf , cost_column = "cost") %>% # define the base in put data: x is the planning units, features are the species or habitats, and we define the cost column which we may relate to fishing activity or aggeregate dredging; not that locked in and out can also be used
  add_min_shortfall_objective(budget = 1390) %>% 
  add_relative_targets(spec$prop) %>% 
  add_gurobi_solver(gap = 0, time_limit = 120, verbose = TRUE)



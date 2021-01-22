# Solution
library(tidyverse)
library(prioritizr)
library("gurobi")
library("slam")



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



# AIM: Plot the solution on a map to visualise the result.
library(sf)
#library(mapview)
 
# plot solution
# read in for plotting
KEIFCA_boundary_line <- st_read("C:/Users/Phillip Haupt/Documents/GIS/gis_data/6M_12M_from_territorial_sea_baseline_5_Jun_20_and_1983/KEIFCA_6NM.GPKG", layer = "KEIFCA_bounbdary_line")

sol_sf <- s_min_set_sf#s_max_feat_sf
# SOLUTIONS --------------------------------------------------------

sol_sf %<>% 
        dplyr::group_by(solution_1) %>%
        dplyr::mutate(solution_label = factor(ifelse(solution_1 == 1, "Included", "Excluded")))
# define colour scheme for included and excluded from solution:
colour_solution <- c("Included" = "#66a61e", "Excluded" = "#C0C0C0")#ffff99

# plot a map
ggplot2::ggplot(sol_sf, aes(fill = solution_label))+
        geom_sf()+
        labs(fill = "Solution status")+
        scale_color_manual(values = colour_solution, aesthetics =  "fill")+
        ggdark::dark_theme_light()
        

# plot(sol_sf["solution_1"], 
#      main = "Solution",
#      axes = TRUE, 
#      key.width = lcm(1.3), 
#      key.length = 1.0, 
#      key.pos = 4,
#      pal = sf.colors(2),
#      graticule = TRUE,
#      col = colour_solution#ffff99
#      
#      #ylim = c(390000, 411390), xlim = c(566500, 569000))
# )


# mapview(sol_sf["solution_1"], 
#         legend = TRUE)


# only solution
sol_only <- sol_sf %>% dplyr::filter(solution_1 == 1)

# plot solution over the features
# mapview::mapview(list(hab, KEIFCA_boundary_line, sol_only, sab_polys, mussels, agg_area),#KEIFCA read in on vessel_sightings_in_goodwin.R script
#                  zcol = list("orig_hab","IFCA", "solution_1","Sabellaria_reef", "taxonname", "Company"),
#                  alpha.regions = list(0.7,0, 0, 0.5, 1, 0),
#                  alpha = list(0.1, 0.7, 1,0.5, 0.1, 1),
#                  cex = list(NULL, NULL, NULL, NULL,"count", NULL),
#                  color = list("grey", "black", "darkgreen","black" ,"black", "black"),
#                  lwd = list(1, 2, 3,1, 1, 2),
#                  burst = TRUE,
#                  legend = TRUE,
#                  label = hab$orig_hab)

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



# a first copy of the planning unit file but slightly different column names to allow preprocessing of puvspr wihtout duplicating the names clash requirement.
pu_geom_for_puvsp <- pus_zones %>% 
  dplyr::select(puid, 
                geometry)





# A second copy for official input use with unnecessary columns (fields) removed
pu <- pus_zones %>% 
  dplyr::select(id = puid,
                cost,
                locked_in,
                locked_out)
                #-status, 
                #- inside_outside_6)


pu_sf <-  pu %>%  st_cast("POLYGON")

# A third copy without any geometry info - for fast processing, but cannot be used in scenarios with Spatial penalties, such as BLM. . drop geometry and other fields. Keep geometry if you want touse spatial constraints, like penalties for Boundary length.
pu_no_geom <-  pu %>% sf::st_drop_geometry()


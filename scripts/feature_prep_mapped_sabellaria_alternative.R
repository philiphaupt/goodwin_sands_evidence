library(sf)

sidescan_2021 <- sf::st_read("C:/Users/Phillip Haupt/Documents/GIS/gis_data/Sabellaria_survey/Sabbelaria_reef_results.gpkg", layer = "Side_scan_visual_assessment_2021")


# filter - keep only Sabellaria likely and verified
sab_polys <- sidescan_2021 %>% filter(Sabellaria_reef %in% c(
"likely sabellaria", 
"likely sabellaria, ARIS verified"#, 
# "potential sabellaria", 
# "reef with potential sabellaria", 
# "potential sabellaria, low density"
)
)

# change projection for sabellaria polys to 32631
sab_polys <- st_transform(sab_polys, crs = 32631) 


ggplot()+
  geom_sf(data = pu)+
  geom_sf(data = sab_polys, aes(fill = Sabellaria_reef))

# dissolve per planning unit
sab_polys_presence <- st_intersection(sab_polys, pu_geom_for_puvsp) %>% 
  dplyr::select(puid, geometry) %>% 
  dplyr::group_by(puid) %>% 
  dplyr::summarise() 

# calculate are and make km per pu
sab_polys_presence <- sab_polys_presence %>% mutate(area_km = st_area(sab_polys_presence) %>% as.numeric()/1000000)


sab_polys_presence <- sab_polys_presence %>% 
  sf::st_drop_geometry()

# intersect with pu
sab_polys_pu <- left_join(pu_geom_for_puvsp, sab_polys_presence, by = "puid") #sf::st_join(pu_geom_for_puvsp, sab_polys_presence, join = st_intersects)
sab_polys_pu <- sab_polys_pu %>% mutate(area_km = if_else(is.na(area_km),0, area_km)  )

#sab_polys_pu$area_km <- st_area(sab_polys_pu) %>% as.numeric()/1000000
# Drop geometer and assign feature id for putting through optimisation
sab_no_geom <- sab_polys_pu %>% st_drop_geometry()
sab_no_geom <- sab_no_geom %>% mutate(id = 1) # needs developing if you want different target for different confidences

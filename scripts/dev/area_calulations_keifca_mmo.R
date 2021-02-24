# intersect Goodwin Sands with KEIFCA district

#goodwin site level
goodwin_inside_6 <- st_intersection(goodwin_utm31_sf, KEIFCA)
st_area(goodwin_inside_6)/1000000
st_area(goodwin_inside_6)/st_area(goodwin_utm31_sf)
st_area(goodwin_utm31_sf)-st_area(goodwin_inside_6)


# habitat features
hab_totals <- hab %>% mutate(area_m_sq = st_area(.)) %>% 
  st_drop_geometry() %>% 
  group_by(orig_hab) %>% 
  summarise(sum_area_m_sq = sum(area_m_sq))

hab_inshore_totals <- st_intersection(hab, KEIFCA)%>% 
  mutate(area_m_sq = st_area(.)) %>% 
  st_drop_geometry() %>% 
  group_by(orig_hab) %>% 
  summarise(sum_area_m_sq = sum(area_m_sq))

# circalittoral rock
1-as.numeric(hab_inshore_totals[1,2]/hab_totals[1,2])# Prop in MMO area
#subital sand: in KEIFCA area
hab_inshore_totals[4,2]/hab_totals[4,2]


# Sabellaria
sab_and_mussels$name <- as.factor(sab_and_mussels$name)

total_sab <- sab_and_mussels %>% 
  st_drop_geometry() %>% 
  dplyr::select(name, count) %>% 
  dplyr::filter(name == "sab") %>% 
  dplyr::group_by(.) %>% 
  dplyr::summarise(total = sum(as.numeric(count)))

inshore_sab <- st_intersection(sab_and_mussels, KEIFCA) %>% 
  st_drop_geometry() %>% 
  dplyr::select(name, count) %>% 
  dplyr::filter(name == "sab") %>% 
  dplyr::group_by(.) %>% 
  dplyr::summarise(total = sum(as.numeric(count)))

1-inshore_sab/total_sab  


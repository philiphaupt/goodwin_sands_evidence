# REAd in obstructions data from admiralty charts:


obstructions <- sf::st_read("C:/Users/Phillip Haupt/Documents/GIS/admirality_charts/Vector_Data/MTF_OBSTRUCTIONS.tab")
names(obstructions)
glimpse(obstructions)
obstructions %>% group_by(THEME, FEATURE_CODE, DESCRIPTION) %>% summarise(count = n())


# filter - keep only shipwrecks
shipwrecks <- obstructions %>% dplyr::filter(str_detect(str_to_lower(DESCRIPTION) , "\\wreck"))
# intersect with Goodwin Sands MCZ - needs to be WGS84 - to match projections:
goodwin_shipwrecks_wgs84_sf <- sf::st_intersection(shipwrecks, goodwin_wgs84_sf)


# summarise
shipwreck_summary <- goodwin_shipwrecks_wgs84_sf %>% 
  group_by(DESCRIPTION) %>% 
  summarise(total = n())



# segment plot
shipwreck_summary %>%
  arrange(total) %>%    # First sort by val. This sort the dataframe but NOT the factor levels
  mutate(name=factor(DESCRIPTION, levels=DESCRIPTION)) %>%   # This trick update the factor levels
  ggplot( aes(x=name, y=total)) +
  geom_segment( aes(xend=name, yend=0)) +
  geom_point( size=6, color="black",shape =  21, fill = c("grey", "black", "darkgreen", "red")) +
  coord_flip() +
  theme_bw() +
  xlab("")+
  ylab("Number of shipwrecks per category")+
  theme(axis.text.y = element_text(color="black", size=14))+
  theme(axis.text.x = element_text(color = "black", size = 14))+
  theme(axis.title.x = element_text(color = "black", size = 16))

# plot to check
# needs KEIFCA boundaries, MCZ and aggeregate to have been read in already: see scripts in folder.
# exploratory map:
aoi <- st_buffer(goodwin_utm31_sf, 7500)
# plot map
tmap::tm_shape(aoi)+
  tmap::tm_fill("white")+
  tmap::tm_shape(KEIFCA)+
  tmap::tm_polygons() +
  tmap::tm_shape(goodwin_utm31_sf)+
  tmap::tm_fill(col = "blue", alpha = 0.5) +
  tmap::tm_shape(goodwin_shipwrecks_wgs84_sf)+
  tmap::tm_dots(shape = 21, size = 0.5) +
  tmap::tm_shape(agg_area) +
  tm_polygons(col = "salmon",
              alpha = 0.5) #+
  #tmap::tm_shape(sightings_goodwin)+
  #tmap::tm_dots(col = "gear", palette=c(I='cyan', L1='yellow', L2='blue',O3='red',T='green'),stretch.palette = FALSE, size = 0.5, jitter = 0.1) #+
  # tmap::tm_shape(fishing_dat_pts_goodwin_utm31_sf) +
  # tmap::tm_dots(col = "black", size = 0.5)
  
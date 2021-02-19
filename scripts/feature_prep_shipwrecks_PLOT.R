# restrcit shipwrecks to Goodwin Sands, plot and summarise


# intersect with Goodwin Sands MCZ - needs to be WGS84 - to match projections:
goodwin_shipwrecks_wgs84_sf <- sf::st_intersection(shipwrecks_with_add_dat_sf, goodwin_wgs84_sf)
#goodwin_obstructions_wgs84_sf <- sf::st_intersection(obstructions_sf, goodwin_wgs84_sf)

# summarise
(shipwreck_summary <- goodwin_shipwrecks_wgs84_sf %>% 
  group_by(DESCRIPTION) %>% 
  summarise(total = n()))



# segment plot - danger
shipwreck_summary %>%
  arrange(total) %>%    # First sort by val. This sort the dataframe but NOT the factor levels
  mutate(name=factor(DESCRIPTION, levels=DESCRIPTION)) %>%   # This trick update the factor levels
  ggplot( aes(x=name, y=total)) +
  geom_segment( aes(xend=name, yend=0)) +
  geom_point( size=6, color="black",shape =  21, fill = c("cornflowerblue", "grey30", "white", "darkgreen", "red")) +
  coord_flip() +
  theme_bw() +
  xlab("")+
  ylab("Number of shipwrecks per category")+
  theme(axis.text.y = element_text(color="black", size=14))+
  theme(axis.text.x = element_text(color = "black", size = 14))+
  theme(axis.title.x = element_text(color = "black", size = 16))#+
  #ggdark::dark_theme_bw()

# plot to check
# needs KEIFCA boundaries, MCZ and aggeregate to have been read in already: see scripts in folder.
# exploratory map:
tmap::tmap_mode("plot")
aoi <- st_buffer(goodwin_utm31_sf, 7500)
# plot map
gs_wrecks_map <- tmap::tm_shape(aoi)+
  tmap::tm_fill("white", alpha = 0.01)+
  tmap::tm_shape(KEIFCA)+
  tmap::tm_polygons() +
  tmap::tm_shape(goodwin_utm31_sf)+
  tmap::tm_borders(col = "cornflowerblue", 
                alpha = 1,
                lwd = 2) +
  #tmap::tm_fill(col = "")+
  tmap::tm_shape(goodwin_shipwrecks_wgs84_sf)+
  tmap::tm_symbols(#shape = "source", 
                size = 0.3,
                alpha = 0.9, 
                col = "source") +
  tmap::tm_shape(agg_area) +
  tm_polygons(col = "salmon",
              alpha = 0.5) #+



# prep map for html output
gs_wrecks_map <- tmap::tm_shape(aoi)+
  tmap::tm_fill("white", alpha = 0.01)+
  tmap::tm_shape(KEIFCA)+
  tmap::tm_polygons() +
  tmap::tm_shape( goodwin_utm31_sf)+
  tmap::tm_borders(col = "cornflowerblue", 
                   alpha = 1,
                   lwd = 2) +
  #tmap::tm_fill(col = "")+
  goodwin_shipwrecks_wgs84_sf %>% 
  dplyr::select(NAME, DESCRIPTION, INFORMATION, source) %>% 
  tmap::tm_shape()+
  tmap::tm_symbols(col = "source", 
    size = 0.3,
    alpha = 0.9, 
    ) +
  tmap::tm_shape(agg_area) +
  tm_polygons(col = "salmon",
              alpha = 0.5) #+


tmap_save(gs_wrecks_map, "Goodwin_Sands_shipwrecks.html")

#tmap::tm_shape(sightings_goodwin)+
#tmap::tm_dots(col = "gear", palette=c(I='cyan', L1='yellow', L2='blue',O3='red',T='green'),stretch.palette = FALSE, size = 0.5, jitter = 0.1) #+
# tmap::tm_shape(fishing_dat_pts_goodwin_utm31_sf) +
# tmap::tm_dots(col = "black", size = 0.5)


# plot depth of shipwrecks in Goodwin Sands
goodwin_shipwrecks_wgs84_sf %>% sf::st_drop_geometry() %>% distinct(INFORMATION)
ggplot2::ggplot(data = goodwin_shipwrecks_wgs84_sf, aes(x = DEPTH)) +
  geom_histogram(aes(y=..density..),binwidth = 5, alpha = 0.5, position = "identity", fill = "cornflowerblue", col ="white") +
  geom_density(alpha = .4, col = "navy", lwd = 1)#


# EXPORT FOR gstc FIRST X NUMBER OF COLUMNS
goodwin_shipwrecks_wgs84_sf %>% sf::st_coordinates() %>% tibble::as_tibble() %>%  bind_cols(dplyr::select(goodwin_shipwrecks_wgs84_sf, 1:20)) %>% 
  dplyr::select(-c(fid, GEOTYPE, GID, THEME, FEATURE_CODE)) %>% 
  write.csv(file = "./output/export/wrecks_list_GoodwinSands_MCZ.csv")

####-------------------

# segment plot

goodwin_shipwrecks_wgs84_sf %>% 
  st_drop_geometry() %>% 
  group_by(source) %>% 
  summarise(total = n()) %>% 
  ggplot( aes(x=source, y=total)) +
  geom_segment( aes(xend=source, yend=0)) +
  geom_point( size=6, color="black",shape =  21, fill = c("brown", "grey30", "cornflowerblue", "white", "darkgreen", "orange")) +
  coord_flip() +
  theme_bw() +
  xlab("")+
  ylab("Number of shipwrecks per category")+
  theme(axis.text.y = element_text(color="black", size=14))+
  theme(axis.text.x = element_text(color = "black", size = 14))+
  theme(axis.title.x = element_text(color = "black", size = 16)) +
  ggdark::dark_theme_bw()

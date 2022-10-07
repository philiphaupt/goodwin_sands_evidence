# restrcit shipwrecks to Goodwin Sands, plot and summarise

# intersect with Goodwin Sands MCZ - needs to be WGS84 - to match projections:
goodwin_shipwrecks_wgs84_sf <- sf::st_intersection(shipwrecks_with_add_dat_sf, goodwin_wgs84_sf)

#------------------------------------

# write goodwins shipwrecks to file
goodwin_shipwrecks_wgs84_sf <- goodwin_shipwrecks_wgs84_sf %>% 
  #select(-fid) %>% 
  # mutate(fid = gsub(x = goodwin_shipwrecks_wgs84_sf$fid, "MTF_OBSTRUCTIONS.", "")) %>% #as.character(rownames(goodwin_shipwrecks_wgs84_sf))) %>% 
  # mutate(fid = if(is.na(fid)){
  #   max(as.numeric(goodwin_shipwrecks_wgs84_sf$fid), na.rm = TRUE)+row_number()
  # })
  mutate(fid = as.integer(row_number())) %>% 
  #relocate(fid) %>% 
  select(name = NAME) %>% st_sf()

goodwin_shipwrecks_wgs84_sf <- st_set_crs(goodwin_shipwrecks_wgs84_sf,  st_crs(goodwin_wgs84_sf)) %>% st_sf()
ggplot()+
  geom_sf(data = goodwin_shipwrecks_wgs84_sf)

sf::st_write(goodwin_shipwrecks_wgs84_sf, 
         dsn = "goodwin_shipwrecks_wgs84.gpkg", 
         layer = "shipwrecks_goodwin_sands",
         fid_column_name = "fid",
         delete_dsn = TRUE,
         delete_layer = TRUE
         )

#---------------------------------------------

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
tmap::tmap_mode("view")
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
                col = "source")# +
  #tmap::tm_shape(agg_area) +
  #tm_polygons(col = "salmon",
  #            alpha = 0.5) #+

gs_wrecks_map

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
  tmap::tm_symbols(col = "NAME", 
    size = 0.3,
    alpha = 0.9, 
    ) #+
  #tmap::tm_shape(agg_area) +
  #tm_polygons(col = "salmon",
  #            alpha = 0.5) #+
gs_wrecks_map

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
#--------------------------------
# option2

buffer_around_goodwin <- st_buffer(goodwin_utm31_sf, 5000)
buffer_around_goodwin_wgs <- st_transform(buffer_around_goodwin, 4326)
# intersect with Goodwin Sands MCZ - needs to be WGS84 - to match projections:
goodwin_shipwrecks_wgs84_sf <- sf::st_intersection(shipwrecks_with_add_dat_sf, buffer_around_goodwin_wgs)


# admiralty data
adm_dir <- "C:/Users/Phillip Haupt/Documents/GIS/admirality_charts/Raster_Charts/20191002/Raster_Charts/RCx/No_Transformation/1828-0.tif"#"1892-0"
library(raster)
adm <- raster(adm_dir)

# reteive info for projectoin:
st_crs(goodwin_utm31_sf)
res(adm)
proj4string(adm)
proj4string(as_Spatial(goodwin_utm31_sf))
# reproject to allow crop
adm_utm31 <- projectRaster(adm, crs = "+proj=utm +zone=31 +datum=WGS84 +units=m +no_defs")
#crop to goodwin buffer
adm_crop <- crop(adm_utm31, buffer_around_goodwin)
plot(adm_crop)
adm_goodwin <- mask(adm_crop, buffer_around_goodwin)
plot(adm_goodwin)



`Goodwin Sands MCZ` <- goodwin_wgs84_sf
Shipwrecks <- goodwin_shipwrecks_wgs84_sf %>% relocate(NAME)
`Aggregate extraction area` <- agg_area

tmap_mode("view")
(
  gs_wrecks_map <-
    tmap::tm_shape(Shipwrecks) +
    tmap::tm_symbols(col = "#03c03c",
                     size = 0.3,
                     alpha = 0.8,) +
    # aoi %>%
    # transmute(Name = "") %>%
    # tmap::tm_shape() +
    # tmap::tm_fill("white", alpha = 0.01) +
    # tmap::tm_shape(KEIFCA)+
    # tmap::tm_polygons() +
    tmap::tm_shape(`Goodwin Sands MCZ`) +
    tmap::tm_borders(col = "cornflowerblue",
                     alpha = 1,
                     lwd = 2) +
    #tmap::tm_fill(col = "")+
    
    #dplyr::select(NAME, DESCRIPTION, INFORMATION, source) %>% +
    tmap::tm_shape(`Aggregate extraction area`) +
    tm_polygons(col = "salmon",
                alpha = 0.5)
  # tm_shape(adm)+
  # tm_raster()
  # tm_rgb(r = 2,
  #        g = 1,
  #        b = 3)
)
  


tmap_save(gs_wrecks_map, paste0("Goodwin_Sands_shipwrecks_",Sys.Date(),".html"))



# EXPORT FOR GSCT----------
coords <- Shipwrecks %>% 
  st_cast("POINT") %>% 
  sf::st_coordinates()
prep_export_data <- Shipwrecks %>% 
  st_drop_geometry() %>% 
  cbind(coords)

write_excel_csv(prep_export_data, "goodwin_buffered_shipwrecks_with_additional_data.csv")



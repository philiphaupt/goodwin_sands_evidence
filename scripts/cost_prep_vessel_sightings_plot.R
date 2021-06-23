# plot vessel sightings - visual

st_crs(vessel_sightings_dd_pts_sf)
sightings_utm31_sf <- sf::st_transform(vessel_sightings_dd_pts_sf, st_crs(goodwin_utm31_sf))

# clean data
plot(sightings_utm31_sf["geometry"])#col = as.factor(sightings_utm31_sf$`Activity/Gear type `)

# only sightings inside goodwin
sightings_goodwin <- st_intersection(sightings_utm31_sf, goodwin_utm31_sf)

# exploratory map:
aoi <- st_buffer(goodwin_utm31_sf, 7500)

sightings_goodwin <- sightings_goodwin %>% rename(gear = `Activity...Gear.type`)
sightings_goodwin$gear <- as.factor(sightings_goodwin$gear)

# join gear code names to gear codes
sightings_goodwin <- left_join(sightings_goodwin, gear, by  = c('gear' = 'gear_code'))
# convert main gear to factor for plotting purposes
sightings_goodwin$main_gear  <- as.factor(sightings_goodwin$main_gear)

tmap_mode("plot")
# plot map
tmap::tm_shape(aoi)+
  tmap::tm_fill("white", alpha = 0.01)+
  tmap::tm_shape(KEIFCA)+
  tmap::tm_polygons() +
  tmap::tm_shape(goodwin_utm31_sf)+
  tmap::tm_fill(col = "blue", alpha = 0.3) +
  tmap::tm_shape(sightings_goodwin)+
  tmap::tm_dots(col = "main_gear", title = "Gear type", palette=c(Potting='cyan', Trawling = 'yellow', Angling = 'blue'),stretch.palette = FALSE, size = 0.1, jitter = 0.1)  
  # tm_layout(
  #   "Gear type",
  #   legend.title.size=1,
  #   legend.text.size = 0.6,
  #   legend.position = c("right","bottom"),
  #   legend.bg.color = "white",
  #   )
# tmap::tm_shape(fishing_dat_pts_goodwin_utm31_sf) +
# tmap::tm_dots(col = "black", size = 0.5)
#palette=c(A='cyan', B='yellow', H='blue',L='red',N='green'), 

# pu_sp <- as(pu_sf, 'Spatial')
# spplot(pu_sp, "cost", main = "Planning unit cost",
#        xlim = c(-0.1, 1.1), ylim = c(-0.1, 1.1))

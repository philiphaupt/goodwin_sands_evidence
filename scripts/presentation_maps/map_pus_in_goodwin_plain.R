## plot goodwin sands planning domain and units inside KEIFCA
library(ggmap)


ph_basemap <- get_map(location=c(lon = 1.56, lat = 51.2), zoom=11, maptype = 'terrain-background', source = 'stamen')



st_bbox(goodwin_wgs84_sf)
ggplot()+
  geom_sf(
    data = pu_geom_for_puvsp,
    fill = NA, colour = "grey",
    size = 0.5, 
    inherit.aes = FALSE
  )+
  #geom_sf(data = goodwin_wgs84_sf, aes(MCZ_NAME, aes(color = "black", fill = NULL)))#
geom_sf(
  data = goodwin_utm31_sf,
  fill=NA, colour="black",
  size=1,
  inherit.aes=FALSE
)   


ggmap(ph_basemap) +
  geom_sf(data = philly_crimes_sf, aes(fill=homic_rate_cat), inherit.aes = FALSE) +
  scale_fill_brewer(palette = "OrRd")
  
  
  
  
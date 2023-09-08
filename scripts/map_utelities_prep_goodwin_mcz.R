# Read in MCZs and isolate Goodwin Sands MCZ
library(sf)
library(tidyverse)
#library(tmap)

# Read in MPAs - MCZs
dir("C:/Users/Phillip Haupt/Documents/GIS/gis_data/MPAs") # lists all the files in teh directory
st_layers("C:/Users/Phillip Haupt/Documents/GIS/gis_data/MPAs/MPAs_England.gpkg") # Lists all the layers in the geopackage
mcz_etrs89_sf <- st_read("C:/Users/Phillip Haupt/Documents/GIS/gis_data/MPAs/MPAs_England.gpkg", layer = "MCZs_England_ETRS89_3035") # reads in the specified layer from geopackage
st_crs(mcz_etrs89_sf)# reveals that the projections is ETRS89-extended - as indicated by the file name

# Keep only Goodwin Sands MCZ
goodwin_etrs89_sf <- mcz_etrs89_sf %>%  filter(MCZ_NAME == "Goodwin Sands") # KEEP ONLY Goodwin Sands MCZ - study area
goodwin_utm31_sf <- st_transform(goodwin_etrs89_sf, 32631) # transform the projection to UTM31N which is the standard used at KEIFCA.
goodwin_wgs84_sf <- st_transform(goodwin_utm31_sf, 4326) # only needed to intersect cefas survey data - which is a lot of points already in WGS84; therefore easier to transform Goodwin and then transform the intersected result to utm31N than transform ALL the points before intersecting.


# remove other MCZs
rm(mcz_etrs89_sf, goodwin_etrs89_sf) # no longer required

# plot Goodwin Sands MCZ
ggplot(data = KEIFCA)+
  geom_sf(col = "blue", fill ="cornflowerblue")+
  labs(title = "KEIFCA District")+
geom_sf(data = goodwin_wgs84_sf, col = "Forestgreen", fill = "Olivedrab", alpha = 0.5)

  

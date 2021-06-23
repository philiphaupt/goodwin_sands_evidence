# prepare Goodwin Sands MCZ Sabellaria frmo JNCC mode output
library(tidyverse)
library(raster)
library(sf)

sab_model <- raster::raster("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/C20210303_Sabellaria_DataPackage_full/C20200306_Sabellaria_SuitabilityModel_50.tif")
raster::crs(sab_model)
# reteive info for projectoin:
st_crs(goodwin_utm31_sf)
res(sab_model)
proj4string(sab_model)
proj4string(as_Spatial(goodwin_utm31_sf))
# reproject to allow crop
sab_model_utm31 <- projectRaster(sab_model, crs = "+proj=utm +zone=31 +datum=WGS84 +units=m +no_defs")
#crop to goodwin
sab_mod_crop <- crop(sab_model_utm31, goodwin_utm31_sf)
plot(sab_mod_crop)
sab_mod_goodwin <- mask(sab_mod_crop, goodwin_utm31_sf)
plot(sab_mod_goodwin)

# overlay sabellaria points
sab <- sab_and_mussels %>% filter(name == "sab")
st_coordinates(sab)
points(st_coordinates(sab), cex = 0.5*log(as.numeric(sab$count)))
summary(as.numeric(sab$count))
median(as.numeric(sab$count))
ggplot(data = sab, aes(x = as.numeric(count), col = "red"))+
  geom_density()

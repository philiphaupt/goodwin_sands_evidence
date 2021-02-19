library(geojsonR)
library(httr)
apiKey <- "XXXXXXXXXXX"
result <- GET("https://opendatadev.arcgis.com/datasets/a46e1c0d912d459fbaf723c347ee9b78.geojson",
              add_headers(Authorization = paste("Key", apiKey)))

point_dat <- FROM_GeoJson(result$url)
#https://opendatadev.arcgis.com/datasets/a46e1c0d912d459fbaf723c347ee9b78.geojson
class(result)
https://datahub.admiralty.co.uk/server/rest/services/Hosted/INSPIRE_Wrecks_Points/FeatureServer/0/query?outFields=*&where=1%3D1
https://opendatadev.arcgis.com/datasets/a46e1c0d912d459fbaf723c347ee9b78.geojson

httr::content(result, as = "raw")

wrecks_inspire <- sf::st_read("C:/Users/Phillip Haupt/Documents/GIS/wrecks/INSPIRE_Wrecks_Points_UK_EEZ/INSPIRE_Wrecks_and_Obstructions_UK_EEZ_Points.shp")
st_crs(wrecks_inspire)
st_crs(goodwin_wgs84_sf)
sf::st_crs(goodwin_utm31_sf)
wrecks_inspire_utm31 <- sf::st_transform(wrecks_inspire, 32631)

goodwin_inspire_shipwrecks_utm31_sf <- sf::st_intersection(wrecks_inspire_utm31, goodwin_utm31_sf)


library(tmap)
tmap::tm_shape(goodwin_inspire_shipwrecks_utm31_sf)+
  tm_dots()


dplyr::sample_n()
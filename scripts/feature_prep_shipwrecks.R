# ReAd in obstructions data from admiralty charts:
library(tidyverse)
library(sf)
library(geojsonsf)

# Read in data
# UKHO data set:
url <- "https://datahub.admiralty.co.uk/server/rest/services/Hosted/INSPIRE_Wrecks_Points/FeatureServer/0"
obstructions <- esri2sf(url)
# obstructions_sf <- sf::st_read("C:/Users/Phillip Haupt/Documents/GIS/admirality_charts/Vector_Data/MTF_OBSTRUCTIONS.tab")
# names(obstructions)
# obstructions %>% group_by(THEME, FEATURE_CODE, DESCRIPTION) %>% summarise(count = n())

# Read in the shipwrecks areas from webserver: (see further below how to read in teh file from hard disc if this fails)
# Get the most up to date version from the UKHO ArcGIS webserver
#---RESULT: DID NOT WORK ACCESS FORBIDDEN - THIS SAME ROUTINE WORKS ON CROWN ESTATE SITE!
# url_json <- "https://opendatadev.arcgis.com/datasets/a46e1c0d912d459fbaf723c347ee9b78.geojson"
# df <- geojsonsf::geojson_sf(url_json)





# obstructions %>% sf::st_drop_geometry() %>% select(UPDATED) %>% distinct() %>% arrange()
# obstructions %>% sf::st_drop_geometry() %>% select(ACCURACY) %>% distinct() %>% arrange()

# filter - keep only shipwrecks
# shipwrecks_sf <- obstructions_sf %>% dplyr::filter(str_detect(str_to_lower(DESCRIPTION) , "\\wreck"))
shipwrecks_sf <-obstructions %>% dplyr::filter(str_detect(str_to_lower(catwrk) , "\\wreck"))
st_crs(shipwrecks_sf)

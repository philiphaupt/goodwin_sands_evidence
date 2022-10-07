# Add the aggeregate extraction area as LOCKED OUT - 

library(tidyverse)
library(sf)
library(geojsonsf)

# Read in the aggeregate areas from webserver: (see further below how to read in teh file from hard disc if this fails)
# Get the most up to date version from the Crown EState ArcGIS webserver
# url_json <- "https://opendata.arcgis.com/datasets/d734d753d04649e2a7e1c64b820a5df9_0.geojson"
# df <- geojsonsf::geojson_sf(url_json)


                        
#-----------------
# From Arcgis server:
# library(devtools)
# #devtools::install_github("yonghah/esri2sf")
# library("esri2sf")
#url <- "https://services2.arcgis.com/PZklK9Q45mfMFuZs/arcgis/rest/services/OffshoreMineralsAggregatesSiteAgreements_EnglandWalesNI_TheCrownEstate/FeatureServer/0/query?outFields=*&where=1%3D1"
#where <- "Area_Numbe = 521"
#df <- esri2sf(url, where = where)
#-----------------------

#st_crs(pu_geom_for_puvsp)
# agg_area <- df %>% dplyr::filter(Area_Number == 521) %>% 
#   st_transform(st_crs(pu_geom_for_puvsp)) # make projections the same UTM31 N
# 
# #st_write(agg_area, "aggeregate_extraction_areas.gpkg", layer = "aggeregate_extraction_area_goodwin_sands_mcz")


#  Read in aggregate areas:

# FROM FILE ON HARD DISC:
agg_area <- read_sf("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/Offshore_Minerals_Aggregates_Site_Agreements/Offshore_Minerals_Aggregates_Site_Agreements.shp") %>%
  dplyr::filter(Area_Numbe == 521)
plot(agg_area["geometry"])

# reproject
agg_area <- agg_area %>% 
     st_transform(st_crs(pu_geom_for_puvsp))
# intersect with planning units - keeping ony id numbers for the planning units which intersect with the aggeregate extraction area - which will be joined back to the fulllist of pus in the following step
puv_locked_out <- st_intersection(pu_geom_for_puvsp, agg_area) %>% # spatial join which assigns the polygon data (without geometry) to the point data (keeping point geometry data)
  st_drop_geometry() %>% 
  dplyr::select(puid) %>% 
  mutate(lock = TRUE)

# join to pu_no_geom (adding areas to exclude - aggeregate dredging approved areas)
pu_no_geom_lo_added <- pu_no_geom %>% left_join(puv_locked_out, by = c("id" = "puid")) %>% 
  mutate(lo = case_when(
    (locked_out == TRUE & lock == TRUE) ~ FALSE,# FALSE = AVAILABLE, TRUE = LOCKED_OUT: change this to FALSE and last one below to change the MMO (outside 6nm) to be available for solutions, but not aggeregate areas
    (locked_out == FALSE & lock == TRUE) ~ TRUE, # keeps aggeregate areas locked out
    (locked_out == FALSE & is.na(lock)) ~ FALSE, # keeps aggeregate areas locked out
    (locked_out == TRUE & is.na(lock)) ~ FALSE, # FALSE = AVAILABLE, TRUE = LOCKED_OUT: change this to FALSE and first one at the top to change the MMO (outside 6nm) to be available for solutions, but not aggeregate areas
    )) %>% 
  mutate(locked_out = lo) %>% 
  dplyr::select(-c(lock, lo))


# on a map
pu %>% dplyr::select(id) %>% 
  left_join(pu_no_geom_lo_added, by = c("id" = "id")) %>% 
  tmap::tm_shape() +
  tm_polygons(col = "locked_out",palette=c("TRUE"='red', "FALSE"='blue'))

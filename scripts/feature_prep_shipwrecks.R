# ReAd in obstructions data from admiralty charts:
library(tidyverse)
library(sf)

# Read in data
# UKHO data set:
obstructions_sf <- sf::st_read("C:/Users/Phillip Haupt/Documents/GIS/admirality_charts/Vector_Data/MTF_OBSTRUCTIONS.tab")
# names(obstructions)
# glimpse(obstructions)
# obstructions %>% group_by(THEME, FEATURE_CODE, DESCRIPTION) %>% summarise(count = n())


# obstructions %>% sf::st_drop_geometry() %>% select(UPDATED) %>% distinct() %>% arrange()
# obstructions %>% sf::st_drop_geometry() %>% select(ACCURACY) %>% distinct() %>% arrange()

# filter - keep only shipwrecks
shipwrecks_sf <- obstructions_sf %>% dplyr::filter(str_detect(str_to_lower(DESCRIPTION) , "\\wreck"))

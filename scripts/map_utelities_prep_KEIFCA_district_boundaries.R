library(tidyverse)
library(sf)

#  Prepare KEFICA 6 NM district boundaries
# Read in KEIFCA district
KEIFCA_layers <- st_layers("C:/Users/Phillip Haupt/Documents/GIS/gis_data/6M_12M_from_territorial_sea_baseline_5_Jun_20_and_1983/KEIFCA_6NM.GPKG")
KEIFCA_boundary_line <- st_read("C:/Users/Phillip Haupt/Documents/GIS/gis_data/6M_12M_from_territorial_sea_baseline_5_Jun_20_and_1983/KEIFCA_6NM.GPKG", layer = "KEIFCA_bounbdary_line")
plot(KEIFCA_boundary_line["geom"])

KEIFCA <- st_read("C:/Users/Phillip Haupt/Documents/GIS/gis_data/6M_12M_from_territorial_sea_baseline_5_Jun_20_and_1983/KEIFCA_6NM.GPKG",  layer = "KEIFCA_6NM_district_upto_2020") %>% st_as_sf()
#st_layers("C:/Users/Phillip Haupt/Documents/GIS/gis_data/6M_12M_from_territorial_sea_baseline_5_Jun_20_and_1983/KEIFCA_6NM.GPKG")
st_crs(KEIFCA)
plot(KEIFCA["geom"])


# Plot Goodwin Sands MCZ inside KEIFCA district
ggplot(data = KEIFCA)+
  geom_sf(col = "blue", fill ="cornflowerblue")+
  labs(title = "KEIFCA District")




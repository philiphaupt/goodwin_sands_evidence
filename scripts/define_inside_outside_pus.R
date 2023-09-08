# AIM develop a strip on the MMO side that captures pus on border
library(sf)
library(tidyverse)

# Goodwin Sands inside KEIFCA district
keifca_goodwin <- st_intersection(goodwin_utm31_sf,KEIFCA) %>% select(MCZ_NAME)

# KEIFCA's Goodwin buffered by X amount
keifca_buffer <- st_buffer(KEIFCA, 800)
goodwin_keifca_plus_buffer <- st_intersection(goodwin_utm31_sf,keifca_buffer)%>% select(MCZ_NAME)

# MMO Goodwin Half
mmo_goodwin <- st_difference(goodwin_utm31_sf,KEIFCA) %>% select(MCZ_NAME)

# isolate the buffer on the MMO side which can now be intersected with the planning units to lock them in
buffer_mmo_strip <- st_intersection(st_difference(goodwin_keifca_plus_buffer,keifca_goodwin), mmo_goodwin)

# MMO half without buffer
mmo_without_buffer <- st_difference(mmo_goodwin, buffer_mmo_strip)

# compilation
recombined_zoned_goodwin <-  sf::st_combine(buffer_mmo_strip, keifca_goodwin)# st_combine(x =, y = mmo_without_buffer)

# test plot
ggplot()+
  geom_sf(data = goodwin_utm31_sf)+
  geom_sf(data = mmo_goodwin, fill = "red", alpha = 0.1)+
  geom_sf(data = keifca_goodwin, fill = "blue", alpha = 0.2)+
  geom_sf(data = buffer_mmo_strip,  fill = "purple", alpha = 0.4)+
  labs(title = "KEIFCA side of Goodwin Sands MCZ \n and the buffer around the MMO boundary")+
  geom_sf(data = KEIFCA, lty = "dashed", alpha = 0) #+
  # geom_sf(data = pu_hex, alpha = 0)

ggplot()+
  geom_sf(data = recombined_zoned_goodwin)

## ggplot - tilt stacked maps

# load libraries
# library(rgeos)
# library("UScensus2000tract")
# library(ggplot2)
# library(dplyr)
# library(RColorBrewer)
library(tidyverse)
library(sf)
library(patchwork)
sm <- matrix(c(1.5,1.2,-0.5,1), 2, 2) # shear matrix 2,1.2,0,1 - specifies how much to modify the geometry by to create tilted layers

# prep data tilted
pu_tilt <- pu
pu_tilt$geom <- pu_tilt$geom * sm
plot(pu_tilt[c('cost', 'locked_in')])
goodwin_wgs84_sf_tilt <- goodwin_wgs84_sf
goodwin_wgs84_sf_tilt$geom <- goodwin_wgs84_sf_tilt$geom * sm
hab_tilt <- hab
hab_tilt$geom <- hab_tilt$geom * sm
s_min_set_sf_tilted <- s_min_set_sf
s_min_set_sf_tilted$geom <- s_min_set_sf_tilted$geom * sm

#test
plot(hab_tilt[c('hab_type')])
plot(goodwin_wgs84_sf_tilt[c('MCZ_NAME')])


# or,
# library(dplyr)
# nc_tilt <- mutate(nc, geometry = geometry * sm) %>% 
#   st_set_crs(st_crs(nc))

pu_with_all_dat <- s_min_set_sf
pu_with_all_dat$hab <- hab$hab_type

# plot using ggplot

plots <- lapply(c('cost', 'locked_in', 'solution_1'), function(i) {
  p <- ggplot(s_min_set_sf_tilted) +
    geom_sf(aes_string(fill = i), show.legend = FALSE) +
    theme_void()+
    theme(plot.background = element_rect(fill = "grey93"), 
          #panel.border = element_rect(color = NA) 
          )
  
  if(is.numeric(s_min_set_sf_tilted[[i]])) {
    p <- p + scale_fill_viridis_c()
  }
  p
})

Reduce(`/`, plots)
# or, purrr::reduce(plots, `/`)
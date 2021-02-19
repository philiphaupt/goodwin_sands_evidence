library(sf)
library(fasterize)

r <- raster(pu_sf, res = 500)
pu_r <- fasterize(pu_sf, r, field = "id", fun="sum")
plot(pu_r)


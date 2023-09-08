# Create hexagon planning units "pu" file
library("sf")

# hexagons
pu_hex = (st_make_grid(
  x = goodwin_utm31_sf,
  cellsize = 666.859,
  #offset = st_bbox(x)[c("xmin", "ymin")],
  #n = c(10, 10),
  crs = 32631,
  what = "polygons",
  square = FALSE,
  flat_topped = TRUE
))




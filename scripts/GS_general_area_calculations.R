round((sf::st_area(agg_area)/1000000)/(sf::st_area(goodwin_utm31_sf)/1000000)*100,2)


tmap::tm_shape(agg_area)+
  tm_polygons()+
  tm_shape(hab)+
  tm_polygons()

sf::st_area(pu)
 
 
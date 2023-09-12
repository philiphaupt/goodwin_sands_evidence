# aim: Select which planning units get included apriori.
library(sf)
# Create lock in lock out variables - and set to FALSE. I.e. no assumptions.
pu$locked_in <- as.logical(FALSE) # can be used to predefine planning units that we want to FORCE into the selection.
pu$locked_out <- as.logical(FALSE)



inner <- st_intersection(pu, keifca_goodwin)
inter <- st_intersection(pu, buffer_mmo_strip) %>% mutate(locked_in = TRUE)
outer <- st_intersection(pu, mmo_without_buffer) %>% mutate(locked_out = TRUE)

pus_in_buffered_keifca <- rbind(inner, inter)
pus_zones <- rbind(pus_in_buffered_keifca, outer)

plot(pus_zones)

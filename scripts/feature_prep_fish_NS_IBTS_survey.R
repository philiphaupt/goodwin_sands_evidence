# aim: Prepare additional data sets: FISHING DATA
# RATIONALE: To establ;ish a link between the species that depend/use the Goodwin Sands benthic habitats.
# this data set is the North Sea Bottom Trawl

# REad fisheries data:NS - IBTS North SEa International Bottom Trawl Survey 2015 - 2020 data

library(tidyverse)
library(sf)
library(plotrix)

fishing_dat <-
  read_csv(
       "C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/survey_data/datras/CPUE per length per Hour and Swept Area_2021-01-18 13_17_34_NS_IBTS/CPUE per length per Hour and Swept Area_2021-01-18 13_17_34.csv"
 #"C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/survey_data/datras/Exchange Data_2021-01-18 13_16_46/Exchange Data_2021-01-18 13_16_46.csv"
     )


names(fishing_dat)
#add id number
fishing_dat$rec_id <- rownames(fishing_dat)

# needs to be converted to SF point object, then interescted with goodwin sands - for POINTS based on shooting lat and long
fishing_dat_pts_sf <-
  st_as_sf(
    fishing_dat,
    coords = c("ShootLong", "ShootLat"),
    crs = 4326,
    agr = "constant"
  )
names(fishing_dat_pts_sf)


# Keep only points that are within the Goodwin Sands MCZ boundary
fishing_dat_pts_goodwin_wgs_sf <-
  sf::st_intersection(fishing_dat_pts_sf, goodwin_wgs84_sf)
#transform to utm
fishing_dat_pts_goodwin_utm31_sf <-
  sf::st_transform(fishing_dat_pts_goodwin_wgs_sf, 32631)
# analyse: 
# What species are there?
species_cpue_km2 <- fishing_dat_pts_goodwin_utm31_sf %>% 
  #st_drop_geometry() %>%  
  group_by(Species) %>% 
  summarise(mean_cpue_per_km2 = mean(CPUE_number_per_km2),
            se_cpue_per_km2 = plotrix::std.error(CPUE_number_per_km2)) %>% 
  arrange(desc(mean_cpue_per_km2)) %>% 
  filter(mean_cpue_per_km2 != 0) 
  

# # Compute the position of labels - only needed for a pie chart - can remove.
# species_cpue_km2 <- species_cpue_km2 %>% 
#   arrange(desc(Species)) %>%
#   mutate(prop = mean_cpue_per_km2 / sum(species_cpue_km2$mean_cpue_per_km2) *100) %>%
#   mutate(ypos = cumsum(prop)- 0.5*prop )

# segment plot
species_cpue_km2 %>%
    arrange(mean_cpue_per_km2) %>%    # First sort by val. This sort the dataframe but NOT the factor levels
    mutate(name=factor(Species, levels=Species)) %>%   # This trick update the factor levels
    ggplot( aes(x=name, y=mean_cpue_per_km2)) +
    geom_segment( aes(xend=name, yend=0)) +
    geom_point( size=4, color="orange") +
    coord_flip() +
    theme_bw() +
    xlab("")+
  ylab("Mean catch per unit effort km^2 swept area")+
  theme(axis.text.y = element_text(color="black", size=14, face="italic"))+
  theme(axis.text.x = element_text(color = "black", size = 14))+
  theme(axis.title.x = element_text(color = "black", size = 16))
# Most common species is the bullhead, poor cod, velvet crab, sole, whiting, lemon sole, cuttlefish - so really characterises the offshore fishery. 

# What is the inshore fishery comprised of?
# There is a second data set which ca be checked: BTS (this one was the NS_IBTS)

  


# plot solution over the features - needs to run after PrioritizR sequence
mapview::mapview(list(hab, KEIFCA_boundary_line, species_cpue_km2),#KEIFCA read in on vessel_sightings_in_goodwin.R script
                 zcol = list("orig_hab","IFCA", "Species"),
                 alpha.regions = list(0.7,0, 1),
                 alpha = list(0.1, 0.7,0.1),
                 cex = list(NULL, NULL, "mean_cpue_per_km2"),
                 color = list("grey", "black", "black"),
                 lwd = list(1, 2, 1),
                 burst = TRUE,
                 legend = TRUE,
                 label = hab$orig_hab)
#shows that ALl surveys wre carried out outside of 6NM and only include Subtidal coarse sediment.





# Convert the shoot-haul points to lines
# make data long then regroup
fishing_dat_lns_goodwin_utm31_sf <- fishing_dat %>%
  dplyr::select(rec_id,
                #Quarter,
                #Gear,
                # Year,
                # Month,
                # Day,
                #Stratum,
                #DayNight,
                ShootLat,
                ShootLong,
                HaulLat,
                HaulLong,
                #Depth,
                Species) %>% 
                #NoPerHaul,
                #LngtClass) %>%
                pivot_longer(
                  cols = c(ShootLat, HaulLat),
                  names_to = "shoot_haul_lat",
                  values_to = "Lat"
                ) %>%
                  pivot_longer(
                    cols = c(ShootLong, HaulLong),
                    names_to = "shoot_haul_long",
                    values_to = "Long"
                  ) %>%
                  dplyr::filter((shoot_haul_lat == "ShootLat" &
                                   shoot_haul_long == "ShootLong") |
                                  (shoot_haul_lat == "HaulLat" &
                                     shoot_haul_long == "HaulLong")
                  ) %>%
  st_as_sf(
    coords = c("Long", "Lat"),
    crs = 4326,
    agr = "constant"
  ) %>% 
                  group_by(rec_id) %>%
                  summarize(m = mean(rec_id)) %>%
                  st_cast("LINESTRING") %>% 
  st_transform(32631)
                
                #                              
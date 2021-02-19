# Read and report on Manually derived options

library(sf)
library(tidyverse)
library(tmap)

data_dir <- "C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/handdrawn_options"

files <- list.files(data_dir) %>% as_tibble() %>% dplyr::filter(str_detect(value, pattern = "shp"))
# 
# options_hd <- list()
# file_path <- vector()
# for (i in seq_along(files$value)) {
#   file_path[i] <- paste0(data_dir,"/",files$value[i])
#   options_tmp <- sf::st_read(file_path[i])
#   options_hd[[i]] <- options_tmp
# }



option1 <- sf::st_read(paste0(data_dir,"/",files$value[1])) %>% 
  mutate(option_number = 1)
option2 <- sf::st_read(paste0(data_dir,"/",files$value[2])) %>% 
  mutate(option_number = 2)
option3 <- sf::st_read(paste0(data_dir,"/",files$value[3])) %>% 
  mutate(option_number = 3)
option4 <- sf::st_read(paste0(data_dir,"/",files$value[4])) %>% 
  mutate(option_number = 4)

# combine
options <- bind_rows(option1, option2, option3, option4) %>% 
  mutate(FID = seq(1:4)) %>% 
  st_transform(32631) %>% 
  filter(option_number != 1) #exclude option 1 - no longer considered.

rm(option1, option2, option3, option4)
# plot
tm_shape(options)+tm_polygons(col = "FID")

# st_crs(hab)

# assess target achievement
hab_target_assess_hd_options <- st_intersection(hab, options)


tm_shape(hab_target_assess_hd_options)+
  tm_polygons(col = "orig_hab")


hab_target_assess_hd_options %<>% 
mutate(area_m = st_area(hab_target_assess_hd_options)) %>% 
  st_drop_geometry() %>%
  group_by(option_number, orig_hab) %>% 
  dplyr::summarise(area_protected = sum(area_m)) 

 

#total habitat amounts
total_hab_area <- hab %>% 
  group_by(orig_hab) %>% 
  dplyr::summarise(total_hab_area =  sum(area))
#on a map
tmap::tm_shape(total_hab_area)+
  tm_polygons(col = "orig_hab")



#prep in and excluded areas
excluded_area <- st_difference(total_hab_area, st_union(options)) %>% 
  dplyr::mutate(solution1 = "excluded")
included_area <- st_intersection(total_hab_area, options)%>% 
  dplyr::mutate(solution1 = "included")

options_hab_full_area <- st_union(excluded_area, included_area)

glimpse(excluded_area)
glimpse(included_area)
glimpse(options_hab_full_area)
#-----------------------




# define colour scheme for options:
colour_options <- c("2" = "#66a61e", 
                    "3" = "#C0C0C0", 
                    "4" = "#ffff99"
                    #"4" = "#eeeeee"
)



# ggplot2::ggplot(included_area, aes())+
#   geom_sf()+
#   geom_sf(data = excluded_area) +
#   ggdark::dark_theme_light()

# ggplot(options_hab_full_area)+
#   geom_sf(aes(fill = solution1))

# plot a map
ggplot2::ggplot(included_area, aes(fill = as.factor(option_number)))+
  geom_sf()+
  labs(fill = "Handdrawn option")+
   scale_color_manual(values = colour_options, aesthetics =  "fill")+
  ggdark::dark_theme_light()



#join the totals to the handdrawn areas to calculate the proporiton achived.
target_achievement_hand_drawn <- total_hab_area %>% sf::st_drop_geometry() %>% 
  right_join(hab_target_assess_hd_options, by  = "orig_hab") %>% 
  mutate(prop_achieved = area_protected/total_hab_area) %>% 
  units::drop_units() %>% 
  left_join(dplyr::select(feature_full_names, feature_name, prop), by = c("orig_hab" = "feature_name")) %>% 
  mutate(prop = ifelse(is.na(prop) == TRUE, 0, prop)) %>% 
  dplyr::mutate(shortfall = prop_achieved-prop)
  


# PROPORTION OF AREA IN SOL - HABITAT &SPECIES
target_achievement_hand_drawn %>% 
  dplyr::filter(option_number != 1) %>% 
  # filter(feature_name != "Sabellaria" & feature_name != "Mytilus") %>% # activate for habitat only , and change title
  ggplot2::ggplot(aes(x = orig_hab, y = prop_achieved)) +
  geom_col(aes(fill = as.factor(option_number))) +
  geom_hline(aes(yintercept = prop),
             lwd = 1,
             col = "red",
             lty = "dashed") +
  scale_color_manual(values = colour_options, aesthetics =  "fill")+
  facet_wrap(~orig_hab) +
  ggdark::dark_theme_gray() +
  ggtitle("Proportion of habitat-features in solution & target set (red dashed line)")+
  labs(x = "Status in solution", y = "Proportion of area or amount for each habitat or species in planning area")#+
  #theme(legend.position = "none")

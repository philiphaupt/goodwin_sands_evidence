# AIM: Set conservation targets for conservation features
library(ggdark)
library(tidyverse)
# The output object is called: "spec" 

# and it is made for the conservation features (so those needs to be read in already) and then defining a proportion of the abundance or area that you want to conserve.

# Note to self: It is the equivalent spec.dat (features) of Marxan but for prioritizer

# Definitions:

# "id" # integer unique identifier for each feature These identifiers are used in the argument to rij.
id <- c(1,2, 3,4,5,6)

# "name" # character name for each feature.
name <- c("sab", "myt", "subt_sand", "subt_mix_sed", "subt_coarse_sed", "mod_en_circ_rock") # these are shorthand names which have been added to the conservation featuers to allow JOINING them in a table

# SET TARGETS - the sequence corresponds with the sequence of the conservation features being read in - so it is important.
# "prop" # numeric relative target for each feature (optional).
# "amount" # numeric absolute target for each feature (optional)
prop <- c(0.025,0.02, 0.2, 0, 0.2, 0.035) # target is zero for non-designated mixed subtidal sediment

# Convert the objects into a single dataframe with id numbers of conservation features next to their respective targets (proportions)
spec <- as.data.frame(cbind(id, name, prop))
spec$id <- as.numeric(spec$id) # make sure that id is numeric (as required by PrioritizeR)
spec$prop <- as.numeric(spec$prop) # as above


source("./scripts/feature_full_names_for_plots.R", echo = T)

print(feature_full_names)

# plot targets and total available per habitat in study area



puvf %>% dplyr::select(-pu) %>% 
  group_by(species) %>% 
  summarise(total_amount = sum(amount)) %>% 
  right_join(feature_full_names, by = c("species" = "id")) %>% 
  ggplot(aes(x = prop, y = feature_name, fill = feature_name, label = round(total_amount),0))+
  geom_col()+
  xlim(0, 1) +
  dark_theme_gray() +
  ggtitle("Conservation targets: Proportion of features required to meet targets set and total available amount per species.")+
  labs(x = "Porpotion", y = "Feature")+
  theme(legend.position = "none")+
  geom_vline(aes(xintercept = 1))+
  geom_text(x = 0.92)


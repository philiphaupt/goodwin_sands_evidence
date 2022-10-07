# full feature names for plots
library(tidyverse)


feature_full_names <- c("Sabellaria", "Mytilus", "Subtidal sand", "Subtidal mixed sediment", "Subtidal coarse sediment", "Moderate energy circalittoral rock") %>% 
  as_tibble() %>% rename(feature_name = value)
feature_full_names$name <- spec$name
feature_full_names <- left_join(feature_full_names, spec, by = "name")

print(feature_full_names)

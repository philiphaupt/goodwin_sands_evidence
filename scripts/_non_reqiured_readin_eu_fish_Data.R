library(tidyverse)
eu_fish_ld <- read_csv("C:/Users/Phillip Haupt/Downloads/fish_ld_main.tsv")
ek_fish_ld_uk <- read_csv("C:/Users/Phillip Haupt/Downloads/fish_ld_uk.tsv") %>% 
  dplyr::filter(natvessr == "EU")

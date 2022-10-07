# Aim: analyse the results

library(tidyverse)
library(ggdark)

# INTERPRETATION OF SOLUTION
#-----------calculations
#
# ~ Pre calcuulations
# Hwo much of the features are inside and how much is outside?
sol <- s_min_set# s_max_feat
# Cost
sol %>%
   group_by(solution_1) %>%
   summarise(sum(cost))

results <- left_join(puvf, sol, by = c("pu" = "id"))
results2 <-
   left_join(results, spec, by = c("species" = "id"))
results3 <- left_join(results2, feature_full_names, by = "name")

# Total amount available per feature
total_amounts <- results3 %>%
   dplyr::select(feature_name, locked_out, solution_1, amount) %>% 
   dplyr::group_by(feature_name) %>% 
   dplyr::summarise(total_amount = sum(amount))

# define colour scheme for included and excluded from solution:
colour_solution <- c("Included" = "#66a61e", "Excluded" = "#C0C0C0")#ffff99

#prepare plot data for reporting on PORPOTION OF AREA IN SOLUTION
sol_plot_dat <- results3 %>%
   dplyr::select(feature_name, solution_1, amount) %>% 
   dplyr::group_by(feature_name) %>% 
   dplyr::mutate(total_amount = sum(amount)) %>% 
   dplyr::ungroup() %>% 
   dplyr::group_by(feature_name, solution_1) %>%
   dplyr::mutate(solution_amount = ifelse(solution_1 == 1, sum(amount),1-sum(amount)*-1)) %>% 
   dplyr::group_by(feature_name, solution_1) %>% 
   summarise(proportion = sum(solution_amount)/sum(total_amount)) %>%
   dplyr::mutate(solution_label = factor(ifelse(solution_1 == 1, "Included", "Excluded"))) %>% 
   left_join(dplyr::select(feature_full_names, feature_name, target = prop), by = "feature_name")

# PROPORTION OF AREA IN SOL - HABITAT &SPECIES
sol_plot_dat %>% 
  # filter(feature_name != "Sabellaria" & feature_name != "Mytilus") %>% # activate for habitat only , and change title
   ggplot2::ggplot(aes(x = solution_label, y = proportion)) +
   geom_col(aes(fill = solution_label)) +
   geom_hline(aes(yintercept = target),
              lwd = 1,
              col = "red",
              lty = "dashed") +
   scale_color_manual(values = colour_solution, aesthetics =  "fill")+
   facet_wrap(~feature_name) +
   ggdark::dark_theme_gray() +
   ggtitle("Proportion of habitat-features in solution & target set (red dashed line)")+
   labs(x = "Status in solution", y = "Target achievement for each habitat or species")+
   theme(legend.position = "none")





   
#------------------------------------------------------------------------------

# PROPORTION OF AREA IN SOL - SPECIES
# sol_plot_dat %>% 
#    filter(feature_name == "Sabellaria" | feature_name == "Mytilus") %>%
#    ggplot2::ggplot(aes(x = solution_label, y = proportion)) +
#    geom_col(aes(fill = solution_label)) +
#    scale_color_manual(values = colour_solution, aesthetics =  "fill")+
#    facet_wrap(~feature_name) +
#    ggdark::dark_theme_gray() +
#    ggtitle("Proportion of species-features in solution")+
#    labs(x = "Earmarked in solution", y = "Proportion of respective amount per species")+
#    theme(legend.position = "none")
# 
# #habitat - inside and outside 6nm
# results3 %>% group_by(name, locked_out, solution_1) %>%
#    summarise(amount = sum(amount)) %>%
#    filter(name != "sab" & name != "myt") %>%
#    ggplot2::ggplot(aes(x = solution_1, y = amount)) +
#    geom_col(aes(fill = as.factor(solution_1))) +
#    facet_wrap(name ~ locked_out)
# 
# #species - inside 6nm
# results3 %>% group_by(name, locked_out, solution_1) %>%
#    summarise(amount = sum(amount)) %>%
#    filter(name == "sab" &
#              locked_out == FALSE | name == "myt" & locked_out == FALSE) %>%
#    ggplot2::ggplot(aes(x = solution_1, y = amount)) +
#    geom_col(aes(fill = as.factor(solution_1))) +
#    facet_wrap(name ~ locked_out)
# 
# #species  - in and out 6nm
# results3 %>% group_by(name, locked_out, solution_1) %>%
#    summarise(amount = sum(amount)) %>%
#    filter(name == "sab" | name == "myt") %>%
#    ggplot2::ggplot(aes(x = solution_1, y = amount)) +
#    geom_col(aes(fill = as.factor(solution_1))) +
#    facet_wrap(name ~ locked_out)

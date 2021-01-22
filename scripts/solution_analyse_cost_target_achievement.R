 # Aim: analyse the results
 
 library(tidyverse)
 
 # INTERPRETATION OF SOLUTION
 #-----------calculations
 # 
 # ~ Pre calcuulations
 # Hwo much of the features are inside and how much is outside?
 
 # Cost
 s_min_set %>% 
   group_by(solution_1) %>% 
   summarise(sum(cost))
 
 results <- left_join(puvf, s_min_set, by = c("pu" = "id"))
 results2 <- left_join(results, spec, by = c("species" = "id"))                       
 
 # What proportionof each feature occurs inside and occurs outside 6NM?
 #habitat - inside 6nm
 results2 %>% group_by(name, locked_out, solution_1) %>% 
   summarise(amount = sum(amount)) %>% 
   filter(name != "sab" & name != "myt" & locked_out == FALSE) %>% 
   ggplot2::ggplot(aes(x = solution_1, y = amount))+
   geom_col(aes(fill = as.factor(solution_1))) +
   facet_wrap(name~locked_out)
 
 #habitat - inside and outside 6nm
 results2 %>% group_by(name, locked_out, solution_1) %>% 
   summarise(amount = sum(amount)) %>% 
   filter(name != "sab" & name != "myt") %>% 
   ggplot2::ggplot(aes(x = solution_1, y = amount))+
   geom_col(aes(fill = as.factor(solution_1))) +
   facet_wrap(name~locked_out)
 
 #species - inside 6nm
 results2 %>% group_by(name, locked_out, solution_1) %>% 
   summarise(amount = sum(amount)) %>% 
   filter(name == "sab" & locked_out == FALSE | name == "myt" & locked_out == FALSE) %>% 
   ggplot2::ggplot(aes(x = solution_1, y = amount))+
   geom_col(aes(fill = as.factor(solution_1))) +
   facet_wrap(name~locked_out)
 
 #species  - in and out 6nm
 results2 %>% group_by(name, locked_out, solution_1) %>% 
   summarise(amount = sum(amount)) %>% 
   filter(name == "sab" | name == "myt" ) %>% 
   ggplot2::ggplot(aes(x = solution_1, y = amount))+
   geom_col(aes(fill = as.factor(solution_1))) +
   facet_wrap(name~locked_out)
 
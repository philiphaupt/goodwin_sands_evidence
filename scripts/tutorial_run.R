# install.packages("prioritizr", repos = "https://cran.rstudio.com/")
# install.packages("c:/gurobi911/win64/R/gurobi_9.1-1.zip", repos = NULL)
# install.packages("slam", repos = "https://cloud.r-project.org")
# load package
library(prioritizr)
library("gurobi")
library("slam")




# load planning unit data
data(sim_pu_polygons)

# show the first 6 rows in the attribute table
head(sim_pu_polygons@data)

# plot the planning units and color them according to acquisition cost
spplot(sim_pu_polygons, "cost", main = "Planning unit cost",
       xlim = c(-0.1, 1.1), ylim = c(-0.1, 1.1))

# load feature data
data(sim_features)

# plot the distribution of suitable habitat for each feature
plot(sim_features, main = paste("Feature", seq_len(nlayers(sim_features))),
     nr = 2)

# create problem
p1 <- problem(sim_pu_polygons, features = sim_features,
              cost_column = "cost") %>%
  add_min_set_objective() %>%
  add_relative_targets(0.15) %>%
  add_binary_decisions() %>%
  add_default_solver(gap = 0)


# solve the problem
s1 <- solve(p1)

# plot solution
plot(s1, col = c("grey90", "darkgreen"), main = "Solution",
     xlim = c(-0.1, 1.1), ylim = c(-0.1, 1.1))

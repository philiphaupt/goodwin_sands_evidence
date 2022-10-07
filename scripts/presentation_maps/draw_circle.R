library("circlize")

plot(c(-1, 1), c(-1, 1), type = "n", axes = FALSE, ann = FALSE, asp = 1)

draw.sector(
  start.degree = 0,
  end.degree = 360,
  rou1 = 1,
  rou2 = NULL,
  center = c(0, 0),
  clock.wise = TRUE,
  col = "blue",
  border = "black",
  lwd = par("lwd"),
  lty = par("lty"))
draw.sector(-49, 90, rou1 = 1, rou2 = 0, clock.wise = FALSE, col = "yellow",lty = 1)
draw.sector(-49, 90, rou1 = 0.3, rou2 = 0, clock.wise = FALSE, col = "red", lty = 2)



# draw yellow bits 15 degrees at a time
start_angles = seq(from = -49, to = 86, by = 15)
end_angles = seq(from = -34, to = 90, by = 15)
end_angles[9] = end_angle[9] + 4
fov_angles <- cbind(start_angles, end_angles)

for (i in 1:10) {
  plot(c(-1, 1), c(-1, 1), type = "n", axes = FALSE, ann = FALSE, asp = 1)
  draw.sector(
    start.degree = 0,
    end.degree = 360,
    rou1 = 1,
    rou2 = NULL,
    center = c(0, 0),
    clock.wise = TRUE,
    col = "blue",
    border = "black",
    lwd = par("lwd"),
    lty = par("lty"))
  draw.sector(start_angles[i], end_angles[i], rou1 = 1, rou2 = 0, clock.wise = FALSE, col = "yellow",lty = 1)
  draw.sector(start_angles[i], end_angles[i], rou1 = 0.3, rou2 = 0, clock.wise = FALSE, col = "red", lty = 2)
  png(paste0("circleplot", i, ".png"), )#needs to refer to the graphics in plot
  dev.off()
}

# sectors = letters[1:3]
# circos.initialize(sectors, xlim = c(0, 1))
# for(i in 1:2) {
#   circos.trackPlotRegion(ylim = c(0, 3))
# }
# circos.info(plot = TRUE)
# 
# draw.sector(get.cell.meta.data("cell.start.degree", sector.index = "a"),
#             get.cell.meta.data("cell.end.degree", sector.index = "a"),
#             rou1 = 1, col = "#FF000040")
# 
# draw.sector(0, 360,
#             rou1 = get.cell.meta.data("cell.top.radius", track.index = 1),
#             rou2 = get.cell.meta.data("cell.bottom.radius", track.index = 1),
#             col = "#00FF0040")
# 
# draw.sector(get.cell.meta.data("cell.start.degree", sector.index = "e"),
#             get.cell.meta.data("cell.end.degree", sector.index = "f"),
#             get.cell.meta.data("cell.top.radius", track.index = 2),
#             get.cell.meta.data("cell.bottom.radius", track.index = 3),
#             col = "#0000FF40")
# 
# pos = circlize(c(0.2, 0.8), c(0.2, 0.8), sector.index = "h", track.index = 2)
# draw.sector(pos[1, "theta"], pos[2, "theta"], pos[1, "rou"], pos[2, "rou"],
#             clock.wise = TRUE, col = "#00FFFF40")
# circos.clear()
# 
# 
# 

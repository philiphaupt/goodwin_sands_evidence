library(tidyverse)

timeline_data <- data.frame(
  #id = 1:nrow(timeline_data_simple),
  event = c(
    "Pre-planning engagement",
    "Prelim assessment",
    "Data collation",
    "Scoping meeting",
    "Identifying options",
    "Review options" ,
    "Funding bid",
    "Sabellaria survey"
  ),
  start = c(
    "2020-06-22",
    "2020-11-10",
    "2020-12-01",
    "2021-03-08",
    "2021-04-01",
    "2021-04-15" ,
    "2020-12-20",
    "2021-10-08"
  ),
  end = c(
    "2021-03-10",
    "2020-12-01",
    "2021-02-28",
    "2021-03-15",
    "2021-03-15",
    "2021-04-16",
    "2021-01-15",
    "2021-10-30"
  ),
  my_grps = c(
    "Engagement",
    "Research",
    "Research",
    "Engagement",
    "Research",
    "Engagement",
    "New research",
    "New research"
  ),
  group = "my_grps",
  color = c(
    '#cbb69d', '#603913','#603913' , '#cbb69d','#603913','#cbb69d','#c69c6e','#c69c6e'
  ),
  fontcolor = c(
    "black", "white","white","black","white", "black", "black", "black"
  )
)

# sort data
earliest_date_by_event <-
  timeline_data[timeline_data$start == ave(timeline_data$start, timeline_data$event, FUN =
                                                  min), ]

# re-order
earliest_date_by_event <-
  earliest_date_by_event[order(
    earliest_date_by_event$start,
    earliest_date_by_event$event), ]

# modify level of factor
timeline_data$event <-
  factor(timeline_data$event, levels = rev(as.character(unique(earliest_date_by_event$event))))
timeline_data$my_grps <- as.factor(timeline_data$my_grps)

# beatification data
label_column <- "event"
category_column <- "my_grps"
event_colours <- list("Engagement" = "#DC241f", "Research" = "#0087DC", "New research" = "#FDBB30")

ggplot_timeline <- ggplot(
  data = timeline_data,
  aes(
    x = start,
    xend = end,
    y = eval(as.name(label_column)),
    yend = eval(as.name(label_column)),
    colour = eval(as.name(category_column))
  )
)

# plot the result
ggplot_timeline + 
  geom_segment(size=3) + 
  xlab("Date") + 
  scale_colour_manual(name = "Event type",values = event_colours) + 
  ylab("Events")

#https://ox-it.github.io/OxfordIDN_htmlwidgets/timeseries/timelines/
library(plotly)

# ---- analyze tree coverage and wealth data ----

## upload libraries
library(tidyverse)

## upload data
stl_places <- readRDS("final_data/stl_places_geographical_data_combined.rds")
stl_income <- read.csv("final_data/stl_places_median_household_income.csv")

## combine data
stl_places <- merge(x = stl_places, y = stl_income, by = "NAME")

## remove used data frame
rm(stl_income)

## visualize scatter plot
ggplot(stl_places) +
  geom_point(aes(x = PERC_EIE, y = INCOME, size = ALAND), color = "#496b3c") +
  geom_smooth(aes(x = PERC_EIE, y = INCOME), method = "lm", se = FALSE, color = "#8ccf74", size = 1.5)
  labs(
    title = "Median Household Income of St. Louis Cities by Tree Coverage",
    x = "Tree Coverage (%)",
    y = "Median Household Income ($)"
  ) +
  theme(legend.position = "none") +
  theme_bw()

## create linear model
lm <- lm(stl_places$INCOME ~ stl_places$PERC_EIE)
summary(lm)

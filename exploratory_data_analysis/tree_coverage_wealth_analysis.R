# ---- analyze tree coverage and wealth data ----

## upload libraries
library(tidyverse)
library(scales)

## upload data
stl_places <- readRDS("final_data/stl_places_geographical_data_combined.rds")
stl_income <- read.csv("final_data/stl_places_median_household_income.csv")

## combine data
stl_places <- merge(x = stl_places, y = stl_income, by = "NAME")

## remove used data frame
rm(stl_income)

## setup export device
png("exploratory_data_analysis/visualizations/tree_coverage_income_scatterplot_eie.png")

## visualize scatter plot
ggplot(stl_places) +
  geom_point(aes(x = PERC_EIE, y = INCOME, size = ALAND), color = "#496b3c") +
  geom_smooth(aes(x = PERC_EIE, y = INCOME), method = "lm", se = FALSE, color = "#8ccf74", size = 1.5) +
  labs(
    title = "Median Household Income of St. Louis Cities by Tree Coverage (EIE Data)",
    x = "Tree Coverage (%)",
    y = "Median Household Income ($)"
  ) +
  theme(legend.position = "none") +
  guides(size = guide_legend(title = "Area of City")) +
  theme_bw()

## turn off export device
dev.off()

## create linear model
lm <- lm(stl_places$INCOME ~ stl_places$PERC_EIE)
summary(lm)

## setup export device
png("exploratory_data_analysis/visualizations/tree_coverage_income_scatterplot_model.png")

## visualize scatter plot
ggplot(stl_places) +
  geom_point(aes(x = PERC, y = INCOME, size = ALAND), color = "#496b3c") +
  geom_smooth(aes(x = PERC, y = INCOME), method = "lm", se = FALSE, color = "#8ccf74", size = 1.5) +
  labs(
    title = "Median Household Income of St. Louis Cities by Tree Coverage (Model Data)",
    x = "Tree Coverage (%)",
    y = "Median Household Income ($)"
  ) +
  theme(legend.position = "none") +
  guides(size = guide_legend(title = "Area of City")) +
  theme_bw()

## turn off export device
dev.off()

## create linear model
lm <- lm(stl_places$INCOME ~ stl_places$PERC)
summary(lm)

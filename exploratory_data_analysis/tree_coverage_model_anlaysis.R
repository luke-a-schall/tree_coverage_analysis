# ---- analyze model output ----

## upload libraries
library(tidyverse)

## import data from model
tree_coverage <- read.csv("final_data/stl_places_tree_coverage_original.csv")
stl_places <- readRDS("final_data/stl_places_geographical_data.rds")

## merge data frames
stl_places <- merge(stl_places, tree_coverage[,c(1,3)], by = "NAME")

## remove used data frame
rm(tree_coverage)

## setup export device
png("exploratory_data_analysis/visualizations/st_louis_tree_coverage_map.png", bg = "transparent")

## visualize tree coverage
ggplot(data = stl_places) +
  geom_sf(aes(fill = PERC), color = "black", size = 0.2) +
  scale_fill_gradient(
    low = "#90EE90",
    high = "#013220"
  ) +
  theme_minimal() +
  labs(
    title = "Tree Coverage Percentage by City in St. Louis County",
    x = "Longitude (Degrees)",
    y = "Latitude (Degrees)",
    fill = "Tree Coverage (%)"
  ) +
  theme(
    legend.position = "bottom",
    legend.direction = "horizontal"
  )

## turn off export device
dev.off()

## view data distribution
hist(stl_places$PERC, main = "Distribution of Tree Coverage in St. Louis", xlab = "Tree Coverage (%)", ylab = "Proportion of Cities in St. Louis", freq =  FALSE, breaks = 20, col = "#8ccf74")


# ---- compare results to google ----

## upload google tree coverage data
google_coverage <- read.csv("final_data/stl_places_tree_coverage_google.csv")

## merge tree coverage data
stl_places <- merge(stl_places, google_coverage, by = "NAME")

## remove used data frame
rm(google_coverage)

## remove rows with missing tree coverage values
stl_places <- stl_places %>%
  drop_na(PERC_EIE)

## create data frame for plots
perc_plot_data <- data.frame(source = c(rep("model", length(stl_places[,1])), rep("google", length(stl_places[,1]))), value = c(stl_places$PERC, stl_places$PERC_EIE))

## plot dual density plot
ggplot(perc_plot_data, aes(x = value, fill = source)) +
  scale_fill_manual(values = c("#8ccf74", "#496b3c")) +
  geom_density(alpha = 0.6, position = "identity", adjust = 2) +
  theme_bw() +
  labs(title = "Tree Coverage Calculations from Model and Google",
       x = "Tree Coverage (%)",
       y = "Proportion of Cities in St. Louis")

## run statistical t test to compare means
t.test(stl_places$PERC, stl_places$PERC_EIE, alternative = "greater", mu = 0, var.equal = TRUE, paired = TRUE)

## view statistics for the tree coverage percentages
summary(stl_places$PERC)
summary(stl_places$PERC_EIE)

sd(stl_places$PERC)
sd(stl_places$PERC_EIE)

## calculate differences between the two values
stl_places <- stl_places %>%
  mutate(PERC_DIFF = PERC - PERC_EIE)

## distribution of the differences
hist(stl_places$PERC_DIFF, main = "Differences between Model and Google Tree Coverage Percentages", 
     xlab = "Difference in Percentages",
     ylab = "Proportion of Occurances",
     col = "#8ccf74")

## statistics for the differences of percentages
summary(stl_places$PERC_DIFF)
sd(stl_places$PERC_DIFF)
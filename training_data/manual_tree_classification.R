# ---- collect city outlines ----

## upload packages
library(df.formatter)
library(tigris)
library(dplyr)
library(sf)

## collect city names
us_places <- us.cities
stl_places <- us_places %>%
  filter(state_id == "MO") %>%
  filter(county_name == "St. Louis")

## collect city geometries
mo_places <- places(state = "MO", year = 2023)
stl_places <- mo_places %>%
  filter(NAME %in% stl_places$city)

## remove used variables
rm(us_places)
rm(mo_places)

## visualize city outline
plot(st_geometry(stl_places))


# ---- collect city imagery ----

## upload packages
library(reticulate)
library(rgee)

## setup python environment
Sys.setenv(RETICULATE_PYTHON = "C:/Users/lukes/miniconda3/envs/ds_env")
Sys.setenv(EARTHENGINE_PYTHON = "C:/Users/lukes/miniconda3/envs/ds_env")

## setup earth engine
ee$Authenticate()
ee$Initialize(project = "tree-coverage-analysis")

## reformat city outlines
stl_places <- st_set_crs(stl_places, 4326)
stl_places_ee <- sf_as_ee(stl_places)

## collect city imagery
stl_imagery <- ee$ImageCollection("USDA/NAIP/DOQQ")$
  filterBounds(stl_places_ee)$
  filterDate("2022-01-01", "2022-12-31")$
  sort("system:time_start", FALSE)$
  mosaic()

## visualize city imagery
Map$centerObject(stl_places_ee)
Map$addLayer(stl_imagery, list(bands = c("N","R","G"), min = 0, max = 225), "NAIP")


# ---- collect training data ----

## upload packages
library(tidyverse)
library(mapedit)
library(leaflet.extras)
library(shiny)

## specify training data (TUNABLE)
training_trees <- editMap()
training_no_trees <- editMap()
training_trees$class <- "1"
training_no_trees$class <- "0"
training_data <- rbind(training_trees, training_no_trees)
saveRDS(training_data, "training_data/tree_classification_training_data_revised.rds")

## remove used variables
rm(training_trees)
rm(training_no_trees)
rm(training_data)
rm(stl_places_ee)
rm(stl_places)
rm(stl_imagery)
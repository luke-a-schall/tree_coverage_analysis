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
library(geojsonio)
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

## load training data
training_data <- readRDS("training_data/tree_classification_training_data_original.rds")
training_data_ee <- sf_as_ee(training_data)
training_data_ee <- stl_imagery$sampleRegions(
  collection = training_data_ee,
  properties = list("class"),
  scale = 1,
  geometries = FALSE
)


# ---- build classification models ----

## set imagery bands
bands <- c("N","R","G")

## build random forest classification model
classifier <- ee$Classifier$smileRandomForest(50)$train(
  features = training_data_ee,
  classProperty = "class",
  inputProperties = bands
)

## classify imagery data
classified_data <- stl_imagery$classify(classifier)$rename("tree")


# ---- collect model output ----

## create output data frame
tree_coverage <- data.frame(NAME = stl_places$NAME, SIZE = stl_places$ALAND, PERC = as.numeric(NA))
tree_coverage <- tree_coverage %>%
  arrange(desc(SIZE))

## loop percentage collection
for(city in tree_coverage$NAME) {
  ## specify city
  temp_place <- stl_places[stl_places$NAME == city,]
  temp_place_ee <- sf_as_ee(temp_place)
  
  ## sample classified imagery data
  sampled_data <- classified_data$sample(
    region = temp_place_ee,
    scale = 1,
    numPixels = 10000,
    seed = 37,
    geometries = FALSE
  )
  
  ## calculate tree coverage
  tree_percentage <- sampled_data$aggregate_mean("tree")$multiply(100)$getInfo()
  
  ## update tree coverage
  tree_coverage$PERC[tree_coverage$NAME == city] <- tree_percentage
}

write.csv(tree_coverage, "final_data/stl_places_tree_coverage_original.csv", row.names = FALSE)
write.csv(stl_places, "final_data/stl_places_geographical_data.csv", row.names = FALSE)
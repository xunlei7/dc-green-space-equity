library(sf)
library(dplyr)
library(ggplot2)
library(viridis)

tracts <- st_read("data/tract_parks.geojson")
parks <- st_read("data/Parks_and_Recreation_Areas.geojson")
parks_centroid <- st_read("data/parks_centroid.geojson")


tracts <- st_transform(tracts, 3857)
parks <- st_transform(parks, 3857)
parks_centroid <- st_transform(parks_centroid, 3857)


ggplot() +
  geom_sf(data = tracts, fill = NA, color = "grey70") +
  geom_sf(data = parks, fill = "darkgreen", alpha = 0.5, color = NA) +
  theme_minimal() +
  ggtitle("Washington, DC – Parks and Census Tracts")


ggplot() +
  geom_sf(data = tracts, fill = NA, color = "grey70") +
  geom_sf(data = parks_centroid, color = "forestgreen", size = 1, alpha = 0.6) +
  theme_minimal() +
  ggtitle("Park Centroid Distribution")


tracts <- tracts %>%
  mutate(
    median_income = as.numeric(median_income)
  )

ggplot(tracts) +
  geom_sf(aes(fill = median_income), color = "white", size = 0.1) +
  scale_fill_viridis(option = "plasma", na.value = "grey90") +
  theme_minimal() +
  ggtitle("Median Household Income by Census Tract")


tracts <- tracts %>%
  mutate(
    population = as.numeric(population),
    total_park_area_sqm = as.numeric(total_park_area_sqm),
    park_density = total_park_area_sqm / population
  )

ggplot(tracts) +
  geom_sf(aes(fill = park_density), color = "white", size = 0.1) +
  scale_fill_viridis(option = "C", na.value = "grey90") +
  theme_minimal() +
  ggtitle("Park Area Per Person (sqm per capita)")


ggplot(tracts, aes(x = median_income, y = park_density)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "loess", color = "blue") +
  theme_minimal() +
  labs(
    x = "Median Household Income",
    y = "Park Area per Person",
    title = "Income vs Park Density"
  )

library(sf)
library(dplyr)


tracts <- st_read("dc_tracts_income.geojson")
parks  <- st_read("Parks_and_Recreation_Areas.geojson")

print(paste("Loaded tracts:", nrow(tracts)))
print(paste("Loaded parks:", nrow(parks)))

tracts <- st_transform(tracts, 3857)
parks  <- st_transform(parks, 3857)

parks_centroid <- parks %>%
  mutate(geometry = st_centroid(geometry))

st_write(parks_centroid, "parks_centroid.geojson", delete_dsn = TRUE)
print("Saved: parks_centroid.geojson")

parks <- parks %>%
  mutate(park_area_sqm = as.numeric(st_area(geometry)))

parks_joined <- st_join(parks, tracts, join = st_intersects)

park_summary <- parks_joined %>%
  st_drop_geometry() %>%
  group_by(GEOID) %>%
  summarise(
    park_count = n(),
    total_park_area_sqm = sum(park_area_sqm, na.rm = TRUE)
  )

tract_parks <- tracts %>%
  left_join(park_summary, by = "GEOID") %>%
  mutate(
    park_count = ifelse(is.na(park_count), 0, park_count),
    total_park_area_sqm = ifelse(is.na(total_park_area_sqm), 0, total_park_area_sqm)
  )

st_write(tract_parks, "tract_parks.geojson", delete_dsn = TRUE)

print("Saved: tract_parks.geojson")

library(tidyverse)

source("R/lib_dwd_cdc.R")

url_base <- "https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/annual/climate_indices/precip/historical/"

dwd_files <- dwd_cdc_listzips(url_base)

## Process stations within year range ----
dwd_precip <- dwd_files |>
  filter(from <= lubridate::as_date("1905-01-01")) |>
  filter(to >= lubridate::as_date("1888-01-01")) |>
  mutate(data = map(file, process_station, url_base = url_base))


precip_rel <- flatten_dwd_cdc(dwd_precip)

saveRDS(precip_rel, file = "data/dwd-precip.rds")

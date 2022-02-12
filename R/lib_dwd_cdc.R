## Identify all zip files ----
dwd_cdc_listzips <- function(url_base) {
  dwd_files <- httr::GET(url_base) |>
    xml2::read_html() |>
    xml2::xml_find_all(xpath = "//a") |>
    xml2::xml_attr(attr = "href") |>
    as.character()

  dwd_files <- dwd_files[tools::file_ext(dwd_files) %in% c("zip")]

  tibble(file = dwd_files) |>
    separate(file,
             into = c("A", "var", "station_id", "from", "to", "B"),
             sep = "_",
             remove = FALSE) |>
    select(-A, -B) |>
    mutate(from = lubridate::ymd(from),
           to = lubridate::ymd(to))
}


flatten_dwd_cdc <- function(dwd) {
  list(
    stationsname = map_df(dwd$data, ~ bind_rows(.$stationsname)),
    geographie = map_df(dwd$data, ~ bind_rows(.$geographie)),
    parameter = map_df(dwd$data, ~ bind_rows(.$parameter)),
    fehldaten = map_df(dwd$data, ~ bind_rows(.$fehldaten)),
    fehlwerte = map_df(dwd$data, ~ bind_rows(.$fehlwerte)),
    daten = map_df(dwd$data, ~ bind_rows(.$daten))
  )
}

## Extract zip ----
zip_extract <- function(file, url_base) {
  zip_local <- file.path("data-raw", file)
  message(zip_local)
  if (!file.exists(zip_local)) {
    download.file(paste0(url_base, file),
                  destfile = zip_local)
  }
  unzip(zip_local, exdir = tools::file_path_sans_ext(zip_local))
}

extract_station_data <- function(file) {
  exdir <- file.path("data-raw", tools::file_path_sans_ext(file))
  txt_files <- dir(exdir, pattern = "*.txt", full.names = TRUE)

  read_station_txt <- function(txt_files, pattern) {
    f <- txt_files[grepl(pattern, basename(txt_files))]
    if (length(f) == 0) return(tibble::tibble())

    readr::read_delim(f,
                      delim = ";",
                      trim_ws = TRUE,
                      locale = readr::locale(encoding = "latin1",
                                             decimal_mark = ".")) |>
      # suppress all the annoying messages
      suppressMessages() |>
      suppressWarnings() |>
      # Column names are not consistent! (e.g. Stations_ID and Stations_id)
      janitor::clean_names(case = "snake") |>
      # Some Stations_ID are character, so force for all tables
      mutate(stations_id = as.character(stations_id)) |>
      # Similarly with dates, so convert to date format
      mutate(across(contains("datum"), \(x) lubridate::ymd(as.character(x))))
  }

  list(
    stationsname = read_station_txt(txt_files, "^Metadaten_Stationsname"),
    geographie = read_station_txt(txt_files, "^Metadaten_Geographie"),
    parameter = read_station_txt(txt_files, "^Metadaten_Parameter"),
    fehldaten = read_station_txt(txt_files, "^Metadaten_Fehldaten"),
    fehlwerte = read_station_txt(txt_files, "^Metadaten_Fehlwerte"),
    daten = read_station_txt(txt_files, "^produkt")
  )
}

process_station <- function(file, url_base) {
  if (!dir.exists(paste0("data-raw/", basename(file)))) {
    zip_extract(file, url_base)
  }
  extract_station_data(file)
}

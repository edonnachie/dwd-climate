# Deutsche Wetterdienst - Climate Data Center

Germany's national meteorological service, the [Deutscher Wetterdienst](https://www.dwd.de), provides both current weather and historic climate data on its [open data server](https://opendata.dwd.de).

The purpose of this project is to process the provided [historic precipitation data](https://opendata.dwd.de/climate_environment/CDC/observations_germany/climate/annual/climate_indices/precip/historical) from 5579 individual weather stations. The data for each station is provided as a separate zip file, containing a number of csv files that represent a relational data structure. These data cam be combined to form a single relational database, allowing the full precipitation data to be analysed.

## Usage

The script [R/dwd-precip-R](R/dwd-precip-R) shows how a selection of files can be processed to form a combined, relational dataset.

# shapefile downloaded from http://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
#stateLines5m <- readOGR(dsn = '/Users/ewnovak/Documents/projects/shiny_airplanes/cb_2015_us_state_5m',
#                      layer = 'cb_2015_us_state_5m')
#stateLines5m <- stateLines[-c(3,23,33,34,41,42,43),]  # remove OCONUS locations
#stateLines5m <- as.data.table(fortify(stateLines, region = 'GEOID'))

stateLines500k <- readOGR(dsn = '/Users/ewnovak/Documents/projects/shiny_airplanes/cb_2015_us_state_5m',
                          layer = 'cb_2015_us_state_5m')
stateLines500k <- stateLines[-c(3,23,33,34,41,42,43),]  # remove OCONUS locations
stateLines500k <- as.data.table(fortify(stateLines, region = 'GEOID'))


# TODO: select data


# loading and preprocessing data for the flights
setwd('~/Documents/projects/shiny_airplanes')
air_data <- as.data.table(read.csv('data.txt', sep = '|'))
air_data[, datetime := as.POSIXct(paste(date, time))]
setkey(air_data, mph)
air_data[, grad := colorRampPalette(c('red', 'yellow', 'green'))(nrow(air_data))]
air_data[, colors := grad]
setkey(air_data, datetime)
air_data[, seconds := as.integer(datetime)]
air_data[, qsec := as.numeric(cut(seconds, quantile(seconds, 0:10/10), 
                              labels = 1:10, include.lowest = TRUE))]
air_data[, qsec_local := as.numeric(cut(seconds, quantile(seconds, 0:10/10), 
                                    labels = 1:10, include.lowest = TRUE)),
         by = .(aircraft, origin, destination)]


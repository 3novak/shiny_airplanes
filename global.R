# shapefile downloaded from http://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
stateLines <- readOGR(dsn = '/Users/ewnovak/Documents/projects/shiny_airplanes/cb_2015_us_state_5m',
                      layer = 'cb_2015_us_state_5m')
stateLines <- stateLines[-c(3,23,33,34,41,42,43),]  # remove OCONUS locations
stateLines <- as.data.table(fortify(stateLines, region = 'GEOID'))

# TODO: select data


# loading and preprocessing data for the flights
setwd('~/Documents/projects/shiny_airplanes')
data <- as.data.table(read.csv('data.txt', sep = '|'))
data[, datetime := as.POSIXct(paste(date, time))]
setkey(data, mph)
data[, grad := colorRampPalette(c('red', 'yellow', 'green'))(nrow(data))]
data[, colors := grad]
setkey(data, datetime)
data[, seconds := as.integer(datetime)]
data[, qsec := as.numeric(cut(seconds, quantile(seconds, 0:10/10), 
                   labels = 1:10, include.lowest = TRUE))]
data[, qsec_local := as.numeric(cut(seconds, quantile(seconds, 0:10/10), 
                              labels = 1:10, include.lowest = TRUE)), by = .(aircraft, origin, destination)]


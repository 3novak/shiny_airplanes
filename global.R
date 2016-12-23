# data for plotting is loaded here to be visible to UI.R and server.R

# TODO list
# TODO: select data: county level, etc.
# TODO: path indicators: add triangles, pictures, sizes, etc.
# TODO: add a longer flight
# TODO: add a pan cursor
# TODO: scroll zoom
# TODO: select on an origin airport
# TODO: select on a destination airport
# TODO: select on flight duration
# TODO: select on maximum altitude attained
# TODO: select on distance (as the crow flies) traveled
# TODO: show desc stats
# TODO: add a color-coded legend for the speed
# TODO: tighten up the left panel

# shapefile downloaded from http://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
#stateLines5m <- readOGR(dsn = '/Users/ewnovak/Documents/projects/shiny_airplanes/cb_2015_us_state_5m',
#                      layer = 'cb_2015_us_state_5m')
#stateLines5m <- stateLines[-c(3,23,33,34,41,42,43),]  # remove OCONUS locations
#stateLines5m <- as.data.table(fortify(stateLines, region = 'GEOID'))

stateLines500k <- readOGR(dsn = '/Users/ewnovak/Documents/projects/shiny_airplanes/cb_2015_us_state_5m',
                          layer = 'cb_2015_us_state_5m')
stateLines500k <- stateLines500k[-c(3,23,33,34,41,42,43),]  # remove OCONUS locations
#stateLines500k <- as.data.table(fortify(stateLines500k, region = 'GEOID'))

# loading and preprocessing data for the flights
setwd('~/Documents/projects/shiny_airplanes')
air_data <- as.data.table(read.csv('~/Documents/projects/shiny_airplanes/data.txt', sep = '|'))
air_data <- air_data[lat != 0 & long != 0,]
air_data[, datetime := as.POSIXct(paste(date, time))]

# sort on speed in order to apply the palette
setkey(air_data, mph)
air_data[, grad := colorRampPalette(c('blue', 'orange', 'red'))(nrow(air_data))]
air_data[, colors := grad]

# sort on time in order to assign time quantiles
setkey(air_data, datetime)
air_data[, seconds := as.integer(datetime)]
air_data[, qsec := as.numeric(cut(seconds, quantile(seconds, 0:10/10), 
                              labels = 1:10, include.lowest = TRUE))]
air_data[, qsec_local := as.numeric(cut(seconds, quantile(seconds, 0:10/10), 
                                    labels = 1:10, include.lowest = TRUE)),
         by = .(aircraft, origin, destination)]

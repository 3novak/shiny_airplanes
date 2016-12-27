library(shiny)
library(data.table)
library(rgdal)
library(rgeos)
library(leaflet)
library(ggplot2)
library(scales)

# data for plotting is loaded here to be visible to UI.R and server.R

# TODO: select data: county level, etc.
# TODO: path indicators: add triangles, pictures, sizes, etc.
# TODO: add a longer flight
# TODO: select on flight duration
# TODO: select on distance (as the crow flies) traveled
# TODO: add airport markers
# TODO: perform stats by dest/origin airport


# shapefile downloaded from http://www.census.gov/geo/maps-data/data/cbf/cbf_state.html
#stateLines5m <- readOGR(dsn = '/Users/ewnovak/Documents/projects/shiny_airplanes/cb_2015_us_state_5m',
#                      layer = 'cb_2015_us_state_5m')
#stateLines5m <- stateLines[-c(3,23,33,34,41,42,43),]  # remove OCONUS locations
#stateLines5m <- as.data.table(fortify(stateLines, region = 'GEOID'))
stateLines500k <- readOGR(dsn = 'cb_2015_us_state_5m',
                          layer = 'cb_2015_us_state_5m')
stateLines500k <- stateLines500k[-c(3,23,33,34,41,42,43),]  # remove OCONUS locations

# loading and preprocessing data for the flights
air_data <- as.data.table(read.csv('data.txt', sep = '|'))
air_data <- air_data[!is.null(mph),]
air_data <- air_data[lat != 0 & long != 0,]
air_data[, datetime := as.POSIXct(paste(date, time))]

# sort on speed in order to apply the palette
setkey(air_data, mph)
colorPal <- colorRampPalette(c('blue', 'orange', 'red'))
air_data[, grad := colorPal(nrow(air_data))]
air_data[, colors := grad]

num_bins <- 10
speed_cuts <- levels(cut(air_data[, mph], breaks = num_bins))
qpal <- colorQuantile(colorPal, air_data[, mph], n=5)


# sort on time in order to assign time quantiles
setkey(air_data, datetime)
air_data[, seconds := as.integer(datetime)]
air_data[, qsec := as.numeric(cut(seconds, quantile(seconds, 0:10/10), 
                              labels = 1:10, include.lowest = TRUE))]
air_data[, qsec_local := as.numeric(cut(seconds, quantile(seconds, 0:10/10), 
                                    labels = 1:10, include.lowest = TRUE)),
         by = .(aircraft, origin, destination)]
air_data[, qsec_factor := as.factor(qsec_local)]

air_data[, flight_id := factor(rleidv(air_data, cols = c('aircraft', 'origin', 'destination')))]
air_data[, bin_mph := as.numeric(cut(mph, breaks = c(-1, 100, 200, 300, 400, 10000)))]

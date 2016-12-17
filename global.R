setwd('~/Documents/projects/airplanes')
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

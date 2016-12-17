library(shiny)
library(data.table)
library(ggplot2)
library(ggmap)
library(rgdal)
library(scales)
library(rgeos)

shinyServer(function(input, output){
  output$mapPlot <- renderPlot({

    # modifications to the data from the inputs through UI.R
    data <- data[(altitude > input$alt_cut[1]) & (altitude < input$alt_cut[2]),]
    data <- data[qsec > input$time_cut_min,]
    data <- data[qsec_local > input$time_min_local,]
    if (input$choose_color == 'grad'){
      data[, colors := grad]
    } else {
      data[, colors := input$choose_color] 
    }
    
    # define the plot
    # use geom_path() for shapes with no fill
    ggplot() + geom_polygon(data = stateLines, aes(x = long, y = lat),
                            color = 'black',
                            size = 0.25, 
                            group = stateLines[, group],
                            fill = 'white') +
               coord_map() +
               geom_point(data = data, colour = data[, colors],
                          aes(x = data[, long], y = data[, lat]))
  })
})


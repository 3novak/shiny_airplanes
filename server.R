library(shiny)
library(data.table)
library(ggplot2)
library(ggmap)
library(rgdal)
library(scales)
library(rgeos)

shinyServer(function(input, output){
  
  ranges <- reactiveValues(x = NULL, y = NULL)
  
  output$mapPlot <- renderPlot({

    # zoom controls
    observeEvent(input$zoom_dblclick, {
      brush <- input$zoom_brush
      if (!is.null(brush)) {
        ranges$x <- c(brush$xmin, brush$xmax)
        ranges$y <- c(brush$ymin, brush$ymax)
        
      } else {
        ranges$x <- NULL
        ranges$y <- NULL
      }
    })
    
    # modifications to the data from the inputs through UI.R
    air_data <- air_data[(altitude > input$alt_cut[1]) & (altitude < input$alt_cut[2]),]
    air_data <- air_data[qsec > input$time_cut_min,]
    air_data <- air_data[qsec_local > input$time_min_local,]
    if (input$choose_color == 'grad'){
      air_data[, colors := grad]
    } else {
      air_data[, colors := input$choose_color]
    }
    
    stateData <- stateLines500k

    # define the plot
    # use geom_path() for shapes with no fill
    ggplot() + geom_polygon(data = stateData, 
                            aes(x = long, y = lat),
                            color = 'black',
                            group = stateData[, group],
                            size = 0.2, 
                            fill = 'white') +
               labs(x = 'Latitude', y = 'Longitude') +
               coord_map(xlim = ranges$x, ylim = ranges$y) +
               geom_point(data = air_data, colour = air_data[, colors],
                          aes(x = long, y = lat))
  })
})

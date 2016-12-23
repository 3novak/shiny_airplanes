library(shiny)
library(data.table)
library(ggplot2)
library(ggmap)
library(rgdal)
library(scales)
library(rgeos)
library(leaflet)

shinyServer(function(input, output){
  
  stateData <- stateLines500k
  
  subsetData <- reactive({
      new_data <- air_data[altitude > input$alt_cut[1] &
                           altitude < input$alt_cut[2] &
                           qsec >= input$time_cut_min & 
                           qsec_local >= input$time_min_local, ]
      
      if (input$choose_color == 'red'){
        new_data[, colors := 'red']
      } else if (input$choose_color == 'navy'){
        new_data[, colors := 'navy']
      } else if (input$choose_color == 'grad'){
        new_data[, colors := grad]
      }
      return(new_data)
  })
  
  output$mapPlot <- renderLeaflet({
    leaflet() %>%
      addPolygons(data = stateData,
                  color = '#9babbc',
                  weight = 2,
                  fillColor = '#abbbcc',
                  fillOpacity = 0.8,
                  smoothFactor = .2)
  })
  
  observe({
    leafletProxy('mapPlot') %>%
      clearGroup('A') %>%
      addCircles(data = subsetData(),
                 group = 'A',
                 lng = ~long,
                 lat = ~lat,
                 radius = 2,
                 weight = 2,
                 color = ~colors)
  })
})
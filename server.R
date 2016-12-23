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
      return(new_data)
  })
  
  colorPal <- reactive({
    if (input$choose_color == 'red'){
      pal2 <- colorNumeric('red', air_data[, mph])
    } else if (input$choose_color == 'navy'){
      pal2 <- colorNumeric('navy', air_data[, mph])
    } else if (input$choose_color == 'grad'){
      pal2 <- colorNumeric(colorRamp(c('blue', 'dark green')), air_data[, mph])
    }
    return(pal2)
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
    pal <- colorPal()
    leafletProxy('mapPlot') %>%
      clearGroup('A') %>%
      addCircles(data = subsetData(),
                 group = 'A',
                 lng = ~long,
                 lat = ~lat,
                 radius = 2,
                 weight = 2,
                 color = ~pal(mph))
    })
  
  observe({
    proxy <- leafletProxy('mapPlot', data = air_data)
    
    proxy %>% clearControls()
    pal <- colorPal()
    proxy %>% addLegend(position = 'bottomright', pal = pal, values = ~mph)
  })
})
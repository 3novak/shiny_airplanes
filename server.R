library(shiny)
library(data.table)
library(rgdal)
library(rgeos)
library(leaflet)

shinyServer(function(input, output){
  
  stateData <- stateLines500k
  
  subsetData <- reactive({
      new_data <- air_data[altitude >= input$alt_cut[1] &
                           altitude <= input$alt_cut[2] &
                           qsec >= input$time_cut_min & 
                           qsec_local >= input$time_min_local &
                           origin %in% input$origin &
                           destination %in% input$dest, ]
      return(new_data)
  })
  
  colorPal <- reactive({
    if (input$choose_color == 'red'){
      pal2 <- colorNumeric('red', air_data[, mph])
    } else if (input$choose_color == 'navy'){
      pal2 <- colorNumeric('navy', air_data[, mph])
    } else if (input$choose_color == 'grad'){
      pal2 <- colorNumeric(colorRamp(c('blue', 'red')), air_data[, mph])
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
    if (nrow(subsetData()) == 0){
      leafletProxy('mapPlot') %>%
        clearGroup('mk')
    } else{
      pal <- colorPal()
      leafletProxy('mapPlot') %>%
        clearGroup('mk') %>%
        addCircles(data = subsetData(),
                   group = 'mk',
                   lng = ~long,
                   lat = ~lat,
                   radius = 2,
                   weight = 2,
                   color = ~pal(mph))
      }
    })
  
  observe({
    proxy <- leafletProxy('mapPlot', data = subsetData())
    proxy %>% clearControls()
    if (input$legend){
      pal <- colorPal()
      proxy %>% addLegend(position = 'bottomright', pal = pal, values = ~mph) 
    }
  })
})
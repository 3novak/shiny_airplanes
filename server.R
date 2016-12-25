library(shiny)
library(data.table)
library(rgdal)
library(rgeos)
library(leaflet)
library(ggplot2)
library(scales)

shinyServer(function(input, output){
  
  stateData <- stateLines500k
  
  subsetData <- reactive({
      new_data <- air_data[altitude >= input$alt_cut[1] &
                           altitude <= input$alt_cut[2] &
                           datetime >= input$time_range[1] &
                           datetime <= input$time_range[2] &
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
  
  # desc stats section
  output$statsPlot <- renderPlot({
  ggplot(data = subsetData(), aes(x = subsetData()$qsec_factor, y = subsetData()$altitude)) + 
    geom_point(aes(size = subsetData()$bin_mph, color = subsetData()$flight_id), alpha = .4) +
    labs(title = '\nAircraft altitude over the course of a flight', 
         x = 'Flight time decile', 
         y = 'Altitude (ft.)', 
         color = 'Flight', 
         size = 'Speed quintile') +
    scale_color_manual(values = c('red', 'blue')) +
    # TODO: add labels to the legend so it looks better
    # c('[0, 100)', '[100, 200)', '[200, 300)', '[300, 400)', '[400, inf)') +
    scale_y_continuous(labels = comma)
  })

})
library(shiny)
library(data.table)
library(rgdal)
library(rgeos)
library(leaflet)
library(ggplot2)
library(scales)

shinyServer(function(input, output){
  
  stateData <- stateLines500k
  
  air_data1 <- air_data
  
  # subset data based on the widgets from the ui.R file.
  subsetData <- reactive({
      new_data <- air_data[altitude >= input$alt_cut[1] &
                           altitude <= input$alt_cut[2] &
                           datetime >= input$time_range[1] &
                           datetime <= input$time_range[2] &
                           qsec_local >= input$time_min_local &
                           origin %in% input$origin &
                           destination %in% input$dest &
                           flight_id %in% input$flight, ]
      return(new_data)
  })
  
  # daisychained subsetting for the purpose of aggregation in charts
  flightSelection <- reactive({
    new_data1 <- subsetData()
    if (input$agg_level == 'bydecbyflight'){
      new_data1 <- new_data1[, .(altitude = mean(altitude, na.rm = TRUE),
                                 mph = mean(mph, na.rm = TRUE)),
                             by = .(flight_id, qsec_factor)]
    } else {
      if (input$agg_level == 'bydec'){
        new_data1 <- new_data1[, .(altitude = mean(altitude, na.rm = TRUE),
                                   mph = mean(mph, na.rm = TRUE)),
                               by = qsec_factor]
        new_data1[, flight_id := 'aggregated']
      }
    }
    new_data1[, bin_mph := as.numeric(cut(mph, breaks = c(-1, 100, 200, 300, 400, 10000)))]
    return(new_data1)
  })
  
  # select colors for plotting airplain locations on the map
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
  
  # plot the main graphic with boundary lines. no other markers included.
  # further objects are plotted reactively.
  # if we were cool, we would plot markers for airports at this stage, and
  # clicking a marker would toggle between displaying flights from the airport,
  # to the airport, and hiding all flights to and from the airport.
  output$mapPlot <- renderLeaflet({
    leaflet() %>%
      addPolygons(data = stateData,
                  color = '#9babbc',
                  weight = 2,
                  fillColor = '#abbbcc',
                  fillOpacity = 0.8,
                  smoothFactor = .2)
  })
  
  # conditional required to circumnavigate the issue documented with leaflet
  # https://github.com/rstudio/leaflet/issues/345
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
  
  # color-coded legend for speed. only useful when the gradient
  # option for path color is selected.
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
    ggplot(data = flightSelection(), aes(x = qsec_factor, y = altitude)) + 
      geom_point(aes(size = bin_mph, color = flight_id), alpha = .4) + 
      labs(title = '\nAircraft altitude over the course of a flight', 
           x = 'Flight time decile', 
           y = 'Altitude (ft.)', 
           color = 'Flight', 
           size = 'Speed quintile') + 
      scale_color_manual(values = c('red', 'blue')) + 
      # TODO: add labels to the legend so it looks better
      # c('[0, 100)', '[100, 200)', '[200, 300)', '[300, 400)', '[400, inf)') +
      scale_y_continuous(labels = comma) + 
      theme(axis.text = element_text(size = 12),
            axis.title = element_text(size = 14, face = 'bold'),
            plot.title = element_text(size = 20, face = 'bold'))
  })
})
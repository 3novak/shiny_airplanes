
shinyUI(fluidPage(
  titlePanel('Aircraft Flights'),
    sidebarPanel(
      tabsetPanel(
        tabPanel('Flight',
          sliderInput('alt_cut',
                      'Altitude range:',
                      min = 0,
                      max = 40000,
                      value = c(0, 40000),
                      step = 1000),
          tags$hr(),
          selectInput('origin',
                      'Filter on origin:',
                      choices = air_data[, unique(origin)],
                      selected = air_data[, unique(origin)],
                      multiple = TRUE,
                      selectize = FALSE),
          selectInput('dest',
                      'Filter on destination:',
                      choices = air_data[, unique(destination)],
                      selected = air_data[, unique(destination)],
                      multiple = TRUE,
                      selectize = FALSE),
          tags$hr(),
          selectInput('flight',
                      'Choose a flight:',
                      choices = air_data[, unique(flight_id)],
                      selected = air_data[, unique(flight_id)],
                      multiple = TRUE,
                      selectize = FALSE)
        ),
        tabPanel('Time',
          sliderInput('time_range',
                      'Time range:',
                      min = min(air_data$datetime),
                      max = max(air_data$datetime),
                      value = c(min(air_data$datetime), max(air_data$datetime)),
                      ticks = FALSE,
                      step = 60*10),
          sliderInput('time_min_local',
                      'Min flight time decile:',
                      min = 1,
                      max = max(air_data$qsec_local),
                      value = 1,
                      step = 1)
        ),
        tabPanel('Display',
           selectInput('choose_color',
                       'Select path color:',
                       choices = list('red' = 'red', 'navy' = 'navy', 'gradient' = 'grad'),
                       selected = 'grad'),
           checkboxInput('legend', label = 'Display Legend', value = TRUE),  # have the default depend on the selection of 'choose_color'
           tags$hr(),
           selectInput('agg_level',
                       'Choose aggregation level:',
                       choices = list('deciles across flights' = 'bydec',
                                      'decile within flights' = 'bydecbyflight'),
                       selected = 'bydecbyflight',
                       multiple = FALSE)
        )
    ),
    width = 3),
    mainPanel(
      tabsetPanel(
        tabPanel('Main display',
          leafletOutput('mapPlot')
        ),
        tabPanel('Altitude graph',
          plotOutput('statsPlot'),
          p(class = 'text-muted', '\n\nplot only includes data subject to the conditions in the Flight, Time, and Display tabs')
        )
      )
    )
))
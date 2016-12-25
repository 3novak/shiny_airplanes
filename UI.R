
shinyUI(fluidPage(
  titlePanel('Aircraft Flights'),
    sidebarPanel(
      tabsetPanel(
        tabPanel('Plot',
          sliderInput('alt_cut',
                      'Altitude range:',
                      min = 0,
                      max = 40000,
                      value = c(0, 40000),
                      step = 1000),
          tags$hr(),
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
                      step = 1),
          tags$hr(),
          selectInput('choose_color',
                      'Select path color:',
                      choices = list('red' = 'red', 'navy' = 'navy', 'gradient' = 'grad'),
                      selected = 'grad'),
          checkboxInput('legend', label = 'Display Legend', value = TRUE),
          tags$hr(),
          selectInput('origin',
                      'Filter on origin',
                      choices = air_data[, unique(origin)],
                      selected = air_data[, unique(origin)],
                      multiple = TRUE,
                      selectize = FALSE),
          selectInput('dest',
                      'Filter on destination',
                      choices = air_data[, unique(destination)],
                      selected = air_data[, unique(destination)],
                      multiple = TRUE,
                      selectize = FALSE)
          ),  # end of first panel
        tabPanel('Stats',
          selectInput('desc1',
                      'do some stats',
                      choices = c('choice 1', 'beef', 'broccoli'),
                      selected = 'beef',
                      multiple = FALSE,
                      selectize = TRUE)
        )
    ),
    width = 3),
    mainPanel(
      tabsetPanel(
        tabPanel('Main display',
          leafletOutput('mapPlot')
        ),
        tabPanel('Descriptive stats',
          plotOutput('statsPlot')
        )
      )
    )
))

shinyUI(fluidPage(
  titlePanel('Aircraft Flights'),
  sidebarLayout(
    sidebarPanel(
      sliderInput('alt_cut',
                  'Altitude range:',
                  min = 0,
                  max = 40000,
                  value = c(0, 40000),
                  step = 1000),
      tags$hr(),
      sliderInput('time_cut_min',
                  'Minimum overall time decile:',
                  min = 1,
                  max = max(air_data$qsec),
                  value = 1,
                  step = 1),
      sliderInput('time_min_local',
                  'Minimum local time decile:',
                  min = 1,
                  max = max(air_data$qsec_local),
                  value = 1,
                  step = 1),
      tags$hr(),
      selectInput('choose_color',
                  'Select path color:',
                  choices = list('red' = 'red', 'navy' = 'navy', 'gradient' = 'grad'),
                  selected = 'grad')
    ),
    mainPanel(
      leafletOutput('mapPlot'),
      p(class = 'text-muted', 'doubleclick the map to reset the zoom')
    )
  )
))
library(shiny)
library(data.table)
library(maps)



# map('state')
shinyServer(function(input, output){
  output$mapPlot <- renderPlot({
    
    map('state', regions=c('minnesota', 'wisconsin', 'michigan', 
                           'iowa', 'illinois', 'indiana'))
    data <- data[(altitude > input$alt_cut[1]) & (altitude < input$alt_cut[2]),]
    data <- data[qsec > input$time_cut_min,]
    data <- data[qsec_local > input$time_min_local,]
    if (input$choose_color == 'grad'){
      data[, colors := grad]
    } else {
      data[, colors := input$choose_color] 
    }
    points(data[, long], data[, lat], cex = .2, col = data[, colors])
    
  })
})



#Arrowhead(data[, long], data[, lat], arr.length = .1)



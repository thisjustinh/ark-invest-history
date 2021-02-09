library(shiny)
library(ggplot2)

dataset <- diamonds

fluidPage(
  
  titlePanel("ARK ETF Value v. Fund Holdings"),
  
  mainPanel(
    plotOutput('plot')
  )
)
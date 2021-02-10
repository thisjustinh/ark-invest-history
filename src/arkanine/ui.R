library(shiny)
library(ggplot2)

fluidPage(
  
  titlePanel("Ark Invest History"),
  sidebarLayout(
    sidebarPanel(
      h2("Display"),
      helpText("View different plots related to Ark Invest and their five 
               actively-managed ETFs."),
      selectInput("plotChoice",
                  label="Choose which data to observe.",
                  choices=list("Market Cap v. Total Assets",
                               "Difference in Market Cap v. Total Assets"),
                  selected="Market Cap v. Total Assets")
    ),
    mainPanel(
      plotOutput('plot')
    )
  )
)
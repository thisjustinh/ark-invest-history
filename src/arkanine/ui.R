library(shiny)
library(ggplot2)

fluidPage(
  
  titlePanel("Ark Invest History"),
  sidebarLayout(
    sidebarPanel(
      h2("Display"),
      helpText("View different plots related to Ark Invest and their five 
               actively-managed ETFs."),
      selectInput("dataChoice",
                  label="Data",
                  choices=list("Market Cap v. Total Assets",
                               "Difference in Market Cap v. Total Assets"),
                  selected="Market Cap v. Total Assets"),
      radioButtons("vizChoice",
                   label="Visualization",
                   choices=list("Plot"=1,
                                "Table"=2),
                   selected=1)
    ),
    mainPanel(
      plotOutput('plot')
    )
  )
)
library(shiny)

fluidPage(
  
  titlePanel("Ark Invest History"),
  sidebarLayout(
    sidebarPanel(
      h2("What do you want to see?"),
      helpText("View different plots related to Ark Invest and their five 
               actively-managed ETFs."),
      selectInput("displayChoice",
                  label="Display",
                  choices=list("Market Cap v. Total Assets",
                               "PCA Biplot"),
                  selected="Market Cap v. Total Assets"),
      conditionalPanel(
        condition="input.displayChoice == 'PCA Biplot'",
        selectInput("dataChoice",
                    label="Data",
                    choices=list("ARKK",
                                 "ARKQ",
                                 "ARKW",
                                 "ARKG",
                                 "ARKF"),
                    selected="ARKK"), 
        uiOutput("benchmarkSelectInput")
      ),
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
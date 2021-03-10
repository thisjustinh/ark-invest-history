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
                               "PCA Biplot (alr)",
                               "PCA Biplot (clr)"),
                  selected="Market Cap v. Total Assets"),
      conditionalPanel(
        condition="input.displayChoice != 'Market Cap v. Total Assets'",
        selectInput("dataChoice",
                    label="Data",
                    choices=list("ARKK",
                                 "ARKQ",
                                 "ARKW",
                                 "ARKG",
                                 "ARKF"),
                    selected="ARKK"),
        conditionalPanel(
          condition="input.displayChoice == 'PCA Biplot (alr)'",
          uiOutput("benchmarkSelectInput")),
        radioButtons("vizChoice",
                     label="Visualization",
                     choices=list("Loadings Biplot"=1,
                                  "Full Biplot"=2,
                                  "Scree Plot"=3),
                     selected=1)
      )
    ),
    mainPanel(
      plotOutput('plot')
    )
  )
)
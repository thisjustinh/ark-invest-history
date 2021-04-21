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
                               "PCA",
                               "PCA (alr)",
                               "PCA (clr)",
                               "PCA (ilr)",
                               "Robust PCA (ilr)",
                               "SPCA (ilr)"),
                  selected="Market Cap v. Total Assets"),
      conditionalPanel(
        condition="input.displayChoice != 'Market Cap v. Total Assets'",
        selectInput("dataChoice",
                    label="Data",
                    choices=list("ARKK",
                                 "ARKQ",
                                 "ARKW",
                                 "ARKG",
                                 "ARKF",
                                 "ARKX"),
                    selected="ARKK"),
        conditionalPanel(
          condition="input.displayChoice == 'PCA (alr)'",
          uiOutput("benchmarkSelectInput")),
        radioButtons("vizChoice",
                     label="Visualization",
                     choices=list("Loadings Plot"=1,
                                  "Loadings Biplot"=2,
                                  "Full Biplot"=3,
                                  "Scree Plot"=4),
                     selected=1)
      )
      
    ),
    mainPanel(
      plotOutput('plot')
    )
  )
)
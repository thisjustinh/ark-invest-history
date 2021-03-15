source("setup.R")
source("ggbiplot.R")

function(input, output) {
  
  dataset <- reactive({
    switch(input$dataChoice,
           "ARKK" = arkk.comp,
           "ARKQ" = arkq.comp,
           "ARKW" = arkw.comp,
           "ARKG" = arkg.comp,
           "ARKF" = arkf.comp,
           "IZRL" = izrl.comp,
           "PRNT" = prnt.comp)
  })
  
  output$benchmarkSelectInput <- renderUI({
    # don't use tickers w/ 0s as benchmark: below is only used if 0-cols exist in alr
    # df.cols <- df %>%
    #   mutate( # get rid of NA ticker
    #     ticker=ifelse(is.na(ticker), str_sub(company, end=4), ticker)
    #   ) %>%
    #   select(c(date, ticker, `weight(%)`)) %>%
    #   dplyr::group_by(date, ticker) %>%
    #   dplyr::summarise(weight = sum(`weight(%)`)) %>%  # sum different tickers
    #   spread(ticker, weight) %>%
    #   replace(is.na(.), 0) %>%
    #   ungroup() %>%
    #   select(-date) %>%
    #   select_if(~ !any(. == 0)) %>%
    #   colnames()
    selectInput("benchmarkChoice",
                label="Benchmark Asset",
                choices=colnames(dataset()),
                selected=colnames(dataset())[1])
  })
  
  output$plot <- renderPlot({
    if (input$displayChoice == "Market Cap v. Total Assets") {
      p <- ggplot(cap_to_assets, aes(x=date, y=market_cap_to_assets, color=fund)) + 
        geom_point() +
        geom_hline(aes(yintercept=1), linetype='dotted', col = 'red') + 
        # facet_wrap(~ fund) +
        xlab("Date") + 
        ylab("Market Cap to Total Assets") +
        theme(axis.text.x=element_text(vjust=0.5))
    } else if (input$displayChoice == "PCA Biplot (alr)") {
        p <- alr.pca.biplot(dataset(), input$benchmarkChoice, input$vizChoice)
    } else if (input$displayChoice == "PCA Biplot (clr)") {
        p <- clr.pca.biplot(dataset(), input$vizChoice)
    }
    print(p)
  }, height=700)
  
}

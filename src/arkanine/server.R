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
           "ARKX" = arkx.comp)
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
        geom_line() +
        geom_hline(aes(yintercept=1), linetype='dotted', col = 'red') + 
        # facet_wrap(~ fund) +
        xlab("Date") + 
        ylab("Market Cap to Total Assets") +
        theme(axis.text.x=element_text(vjust=0.5))
    } else if (input$displayChoice == "PCA") {
      p <- pca.viz(prcomp(dataset(), center=TRUE, scale.=TRUE), input$vizChoice)
    } else if (input$displayChoice == "PCA (alr)") {
      p <- alr.pca.biplot(dataset(), input$benchmarkChoice, input$vizChoice)
    } else if (input$displayChoice == "PCA (clr)") {
      p <- clr.pca.biplot(dataset(), input$vizChoice)
    } else if (input$displayChoice == "PCA (ilr)") {
      p <- ilr.pca.biplot(dataset(), input$vizChoice)
    } else if (input$displayChoice == "Robust PCA (ilr)") {
      p <- robust.ilr.biplot(dataset(), input$vizChoice)
    } else if (input$displayChoice == "SPCA (ilr)") {
      p <- spca.viz(dataset(), input$vizChoice)
    }
    print(p)
  }, height=700)
  
}
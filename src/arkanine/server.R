source("setup.R")

function(input, output) {
  
  output$benchmarkSelectInput <- renderUI({
    df <- switch(input$dataChoice,
                 "ARKK" = arkk,
                 "ARKQ" = arkq,
                 "ARKW" = arkw,
                 "ARKG" = arkg,
                 "ARKF" = arkf)
    # don't use tickers w/ 0s as benchmark
    # TODO: Improve this logic/runtime/redundancy
    df.cols <- df %>%
      mutate( # get rid of NA ticker
        ticker=ifelse(is.na(ticker), str_sub(company, end=4), ticker)
      ) %>%
      select(c(date, ticker, `weight(%)`)) %>%
      dplyr::group_by(date, ticker) %>%
      dplyr::summarise(weight = sum(`weight(%)`)) %>%  # sum different tickers
      spread(ticker, weight) %>%
      replace(is.na(.), 0) %>%
      ungroup() %>%
      select(-date) %>%
      select_if(~ !0 %in% .) %>%
      colnames()
    tickers <- c(sort(unique(df.cols)), "UNREPORTED")
    selectInput("benchmarkChoice",
                label="Benchmark Asset",
                choices=tickers,
                selected=tickers[1])
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
    } else if (input$displayChoice == "PCA Biplot") {
      df <- switch(input$dataChoice,
                   "ARKK" = arkk,
                   "ARKQ" = arkq,
                   "ARKW" = arkw,
                   "ARKG" = arkg,
                   "ARKF" = arkf)
      p <- comp.pca.biplot(df, input$benchmarkChoice)
    }
    
    print(p)
    
  }, height=700)
  
}
library(shiny)
library(tidyverse)

function(input, output) {
  
  master <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/master.csv") %>%
    mutate(date = as.Date(strptime(date, "%m/%d/%Y"))) %>%
    group_by(date, fund) %>%
    summarize(reported_assets=sum(`market value($)`), weight=sum(`weight(%)`) / 100) %>%
    mutate(total_assets=reported_assets / weight) %>%
    inner_join(read_csv('https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/price-history/master.csv'), by=c('date', 'fund')) %>%
    mutate(market_cap=NA)
  
  # Numbers hardcoded from Marketwatch
  arkk_outstanding <- 171.15e06
  arkq_outstanding <- 35.7e06
  arkw_outstanding <- 44.2e06
  arkg_outstanding <- 110.01e06
  arkf_outstanding <- 56.05e06
  
  for (i in c(1:nrow(master))) {
    if (master$fund[i] == "ARKK") {
      master$market_cap[i] <- master$close[i] * arkk_outstanding
    } else if (master$fund[i] == "ARKQ") {
      master$market_cap[i] <- master$close[i] * arkq_outstanding
    } else if (master$fund[i] == "ARKW") {
      master$market_cap[i] <- master$close[i] * arkw_outstanding
    } else if (master$fund[i] == "ARKG") {
      master$market_cap[i] <- master$close[i] * arkg_outstanding
    } else {
      master$market_cap[i] <- master$close[i] * arkf_outstanding
    }
  }
  
  master <- master %>%
    mutate(market_cap_to_assets = market_cap / total_assets)
  
  output$plot <- renderPlot({
        
    p <- ggplot(master, aes(x=date, y=market_cap_to_assets, color=fund)) + 
      geom_line() +
      geom_hline(aes(yintercept=1), linetype='dotted', col = 'red') + 
      # facet_wrap(~ fund) +
      ylab("Market Cap to Total Assets")
    
    print(p)
    
  }, height=700)
  
}
library(shiny)
library(tidyverse)

function(input, output) {
  
  arkk <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKK.csv")
    
  arkq <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKQ.csv")
  arkw <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKW.csv")
  arkg <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKG.csv")
  arkf <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKF.csv")
  etf <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/price-history/master.csv")
  
  arkk$date <- as.Date(strptime(arkk$date, "%m/%d/%Y"))
  arkq$date <- as.Date(strptime(arkk$date, "%m/%d/%Y"))
  arkw$date <- as.Date(strptime(arkk$date, "%m/%d/%Y"))
  arkg$date <- as.Date(strptime(arkk$date, "%m/%d/%Y"))
  arkf$date <- as.Date(strptime(arkk$date, "%m/%d/%Y"))
  etf$date <- as.Date(strptime(arkk$date, "%m/%d/%Y"))
  
  
  
  output$plot <- renderPlot({
        
    p <- ggplot(dataset(), aes_string(x=input$x, y=input$y)) + geom_point()
    
    print(p)
    
  }, height=700)
  
}
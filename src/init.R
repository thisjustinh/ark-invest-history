library(jsonlite)
library(tidyverse)

transactions <- fromJSON('https://raw.githubusercontent.com/KarlZhu-SE/ark-funds-monitor/master/src/rawData/mergedData.json')
transactions <- transactions[1:1824, 1:8]  # hardcoded numbers

transactions$Date <- as.Date(transactions$Date)
transactions$Shares <- as.numeric(transactions$Shares)
transactions$`% of ETF` <- as.numeric(transactions$`% of ETF`)

transactions <- transactions[order(transactions$Date),]

write_csv(transactions, '../master.csv')

test <- read_csv('test.csv')

for(etf in c('ARKK', 'ARKQ', 'ARKW', 'ARKG', 'ARKF')) {
  path <- paste('../fund-holdings/delta', etf, '.csv', sep='')
  test %>%
    filter(date == as.Date("2021-01-08")) %>%
    filter(fund == etf) %>%
    write_csv(path)
}

ark.track <- read_csv('../fund-holdings/master.csv')
for(etf in c('ARKK', 'ARKQ', 'ARKW', 'ARKG', 'ARKF')) {
  print(
    ark.track %>%
      filter(date == as.Date("2021-01-08")) %>%
      filter(fund == etf) %>%
      dim()
  )
}

today <- 
  ark.track %>%
  filter(date == as.Date("2021-01-08"))

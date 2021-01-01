library(jsonlite)
library(tidyverse)

transactions <- fromJSON('https://raw.githubusercontent.com/KarlZhu-SE/ark-funds-monitor/master/src/rawData/mergedData.json')
transactions <- transactions[1:1710, 1:8]  # hardcoded numbers

transactions$Date <- as.Date(transactions$Date)
transactions$Shares <- as.numeric(transactions$Shares)
transactions$`% of ETF` <- as.numeric(transactions$`% of ETF`)

transactions <- transactions[order(transactions$Date),]

write_csv2(transactions, '../master.csv')

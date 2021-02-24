library(readxl)
library(tidyverse)

etf <- "master"
for (etf in c("ARKK", "ARKQ", "ARKW", "ARKG", "ARKF", "master")) {
  # df <- read_excel("~/Documents/fund_holdings.xlsx", sheet = etf)
  # df <- df %>%
  #   mutate(stockPrice = as.numeric(gsub("[^0-9.]", "", stockPrice))) %>%
  #   mutate(`weight(%)` = as.numeric(gsub("[^0-9.]", "", `weight(%)`))) %>%
  #   mutate(`market value($)` = stockPrice * shares) %>%
  #   mutate(date = as.Date(date))
  # write_csv(df, str_glue("{etf}.csv"))
  
  df <- read_csv(str_glue("{etf}.csv")) %>%
    select(-stockPrice)
  newer <- read_csv(str_glue("../fund-holdings/{etf}.csv")) %>%
    filter(date > as.Date("2021-01-25"))
  full <- rbind(df, newer)
  write_csv(full, str_glue("../fund-holdings/{etf}.csv"))
}

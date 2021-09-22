# ARK Transactions

[![Fetch ETF prices](https://github.com/xinging-birds/ark-invest-history/actions/workflows/price.yml/badge.svg)](https://github.com/xinging-birds/ark-invest-history/actions/workflows/price.yml)

ARK Invest has five active ETFs (ARKK, ARKG, ARKQ, ARKW, ARKF) and we aim to track data scraped from their investor resources. Data is scraped using git workflows, and then processed to be added to the master historical transactions CSV file.

The folders each hold different data: `fund-holdings` contains the actual published data from Ark each day, `transactions` contain the one-day differences in fund holdings that indicate whether something was bought or sold, and `price-history` contains the ETF equity price history per day (OHLC values from Yahoo Finance).

Note that starting from 2021-03-15, ARK changed its reporting habits from end-of-day holdings to beginning-of-day holdings, and these changes are also reflected in the fund holdings here.

This repository is not affiliated with ARK Invest and accepts no responsibility for financial decisions made.

[R Shiny App Link](https://superbia-vice.shinyapps.io/arkanine/)

## Acknowledgments
Thanks to [ArkTrack](https://arktrack.com) whose data I used to initialize the repository.

Thanks to [tigger0jk](https://github.com/tigger0jk/ark-invest-scraper) for the scraping workflow for the holdings.

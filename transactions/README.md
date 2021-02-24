# Fund Holdings

ARKK, ARKQ, ARKW, ARKG, ARKF CSV files denote the last disclosed fund holdings respectively, while the delta files track differences between the last fund holdings and the ones from the day before that. Latest compiles the delta files into one.

The master CSV fiile contains all differences starting from 2020-10-20. The columns are as follows:

| Column            | Description                                           |
|-------------------|-------------------------------------------------------|
| date              | Date recorded                                         |
| fund              | Fund that holding belongs to                          |
| company           | Holding company                                       |
| ticker            | Holding ticker                                        |
| shares            | Total shares of holding                               |
| value             | Value of shares (millions)                            |
| stockPrice        | Price of holding equity                               |
| weight            | % of respective ETF                                   |
| deltaShares       | Change in shares since previous day                   |
| flowValue         | Value of shares bought/sold (millions)                |
| deltaValue        | Change in holding value since previous day (millions) |
| deltaPrice        | Change in equity price since previous day             |
| deltaPricePercent | Change in equity price as a percentage                |
| deltaWeight       | Change in holding weight since previous day           |
| action            | Action taken for holding (Buy/Sell/Enter/Exit)        |
import sys
import yfinance as yf
import pandas as pd
from datetime import datetime
from pytz import timezone

DEBUG = False

history = []
for fund in ['ARKK', 'ARKQ', 'ARKW', 'ARKG', 'ARKF', 'ARKX', 'IZRL', 'PRNT']:
    today = str(datetime.now(timezone('EST')).date())
    fund_price_action = yf.Ticker(fund).history(start=today)
    # If any are empty, quit execution of code
    if fund_price_action.empty:
        sys.exit()

    history.append([
        today,
        fund,
        round(fund_price_action["Open"][0], 2),
        round(fund_price_action["High"][0], 2),
        round(fund_price_action["Low"][0], 2),
        round(fund_price_action["Close"][0], 2),
        fund_price_action["Volume"][0],
        fund_price_action["Dividends"][0],
        fund_price_action["Stock Splits"][0]
    ])

price_history = pd.DataFrame(history,
                             columns=['date',
                                      'fund',
                                      'open',
                                      'high',
                                      'low',
                                      'close',
                                      'volume',
                                      'dividends',
                                      'stock_splits'])
old = pd.read_csv("../price-history/master.csv")

new = pd.concat([old, price_history])

if DEBUG:
    print(new.to_string())
    assert(new.shape[0] == old.shape[0] + price_history.shape[0])
else:
    new.to_csv('../price-history/master.csv', index=False)

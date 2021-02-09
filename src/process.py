import sys
import pandas as pd
from io import StringIO

DEBUG = False

holdings = StringIO(sys.stdin.read())

new = pd.read_csv(holdings, error_bad_lines=False)
new = new.iloc[:-3]
new = new.drop(columns=["cusip"])

fund = new['fund'][0]
date = new['date'][0]
old = pd.read_csv(f'../fund-holdings/latest{fund}.csv')

# combine multiple occurrences
new = new.groupby(['date', 'fund', 'company', 'ticker'],
                  as_index=False, dropna=False).agg('sum')

# Doesn't do anything if the date of the fund holdings is the same as last time
if old['date'][0] != new['date'][0]:
    if not DEBUG:
        master_fund = pd.read_csv(f'../fund-holdings/{fund}.csv')
        pd.concat([master_fund, new]).to_csv(f'../fund-holdings/{fund}.csv', index=False)

        new.to_csv(f'../fund-holdings/latest{fund}.csv', index=False)

    transactions = []
    for index, row in new.iterrows():
        shares = round(float(row['shares']), 2)
        value = round(float(row['market value($)']), 2)
        value_millions = round(value / 1e06, 2)
        stockPrice = round(value / shares, 2)
        weight = round(float(row['weight(%)']) / 100, 4)

        old_row = old.loc[old['company'] == row['company']]

        if old_row.empty:
            # completely new holding
            transactions.append([
                date,
                fund,
                row['company'],
                row['ticker'],
                shares,
                value_millions,
                stockPrice,
                weight,
                shares,
                value_millions,
                value_millions,
                '',
                '',
                '',
                'Enter'
            ])
        else:
            oldShares = round(float(old_row['shares'].iloc[0]), 2)
            if oldShares < shares:
                action = 'Buy'
            elif oldShares > shares:
                action = 'Sell'
            else:
                continue

            oldValue = round(float(old_row['market value($)'].iloc[0]), 2)
            oldStockPrice = round(oldValue / oldShares, 2)
            oldWeight = round(float(old_row['weight(%)'].iloc[0]) / 100, 4)

            transactions.append([
                date,
                fund,
                row['company'],
                row['ticker'],
                shares,
                value_millions,
                stockPrice,
                weight,
                round(shares - oldShares, 2),  # deltaShares
                round((shares - oldShares) * stockPrice / 1e06, 2),
                round((value - oldValue) / 1e06, 2),  # deltaValue
                round(stockPrice - oldStockPrice, 2),  # deltaPrice
                round((stockPrice - oldStockPrice) / oldStockPrice, 4),
                round((weight - oldWeight) / oldWeight, 4),  # deltaWeight
                action
            ])

    # Second pass for checking if anything has been completely sold
    for index, row in old.iterrows():
        if not (new['company'] == row['company']).any():
            oldShares = round(float(row['shares']), 2)
            oldValue = round(float(row['market value($)']), 2)
            oldStockPrice = round(oldValue / oldShares, 2)

            # completely sold holding
            transactions.append([
                date,
                fund,
                row['company'],
                row['ticker'],
                0,
                0,
                '',
                0,
                oldShares,
                '',
                -1 * round(oldValue / 1e06, 2),
                '',
                '',
                '',
                'Exit'
            ])

    # Check nonempty
    if len(transactions):
        transactions_csv = pd.DataFrame(transactions,
                                        columns=[
                                            'date',
                                            'fund',
                                            'company',
                                            'ticker',
                                            'shares',
                                            'value',
                                            'stockPrice',
                                            'weight',
                                            'deltaShares',
                                            'flowValue',
                                            'deltaValue',
                                            'deltaPrice',
                                            'deltaPricePercent',
                                            'deltaWeight',
                                            'action'])

    if DEBUG:
        # transactions_csv.apply(str, axis=1)
        check = transactions_csv.sort_values('deltaShares')
        print(check.to_string())
        print(check.shape)
        check.to_csv('temp.csv', index=False)
    else:
        transactions_csv.to_csv(f'../transactions/delta{fund}.csv',
                                index=False) 


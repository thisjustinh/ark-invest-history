import sys
import pandas as pd
from io import StringIO

holdings = StringIO(sys.stdin.read())

new = pd.read_csv(holdings, error_bad_lines=False)
new = new.iloc[:-3]

print(new)

fund = new['fund'][0]
date = new['date'][0]
old = pd.read_csv(f'../fund-holdings/{fund}.csv')

if old['date'][0] != new['date'][0]:
    new.to_csv(f'../fund-holdings/{fund}.csv')

    transactions = []
    for index, row in new.iterrows():
        try:
            old_row = old.loc[old['company'] == row['company']]
            print(old_row)
        except KeyError:
            # completely new holding
            transactions.append([
                date, 
                fund, 
                'Buy',
                row['company'], 
                row['ticker'], 
                row['cusip'],
                round(float(row['shares']), 2),
                round(float(row['weight(%)']), 2)
            ])
            continue
        print('nani')
        if float(old_row['shares'].iloc[0]) < float(row['shares']):
            direction = 'Buy'
        elif float(old_row['shares'].iloc[0]) > float(row['shares']):
            direction = 'Sell'
        else:
            continue
        print('what?')            
        transactions.append([
            date, 
            fund, 
            direction,
            row['company'], 
            row['ticker'], 
            row['cusip'],
            round(abs(float(row['shares']) - float(old_row['shares'].iloc[0])), 2),
            round(abs(float(row['weight(%)']) - float(old_row['weight(%)'].iloc[0])), 2)
        ])
        print(transactions[-1])
    
    # Second pass for checking if anything has been completely sold
    print('SPOTIFY TECHNOLOGY SA' in new['company'])
    for index, row in old.iterrows():
        if not new['company'].str.contains(row['company']).any():
            # completely sold holding
            print(index)
            transactions.append([
                date, 
                fund, 
                'Sell',
                row['company'], 
                row['ticker'], 
                row['cusip'],
                round(float(row['shares']), 2),
                round(float(row['weight(%)']), 2)
            ])

    if len(transactions):
        transactions_csv = pd.DataFrame(transactions, columns=['date', 'fund', 'direction', 'company', 'ticker', 'cusip', 'shares', 'weight(%)'])
    
        transactions_csv.to_csv(f'../transactions/{fund}.csv')

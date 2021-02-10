import pandas as pd

for ticker in ['ARKK', 'ARKQ', 'ARKW', 'ARKG', 'ARKF', '']:
    df = pd.read_csv(f'../fund-holdings/latest{ticker}.csv')
    df['date'] = pd.to_datetime(df['date'])
    df.to_csv(f'../fund-holdings/latest{ticker}.csv', index=False)

for ticker in ['ARKK', 'ARKQ', 'ARKW', 'ARKG', 'ARKF']:
    df = pd.read_csv(f'../transactions/delta{ticker}.csv')
    df['date'] = pd.to_datetime(df['date'])
    df.to_csv(f'../transactions/delta{ticker}.csv', index=False)

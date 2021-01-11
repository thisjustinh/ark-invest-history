import pandas as pd

arkf = pd.read_csv('../fund-holdings/deltaARKF.csv')
arkk = pd.read_csv('../fund-holdings/deltaARKK.csv')
arkg = pd.read_csv('../fund-holdings/deltaARKG.csv')
arkq = pd.read_csv('../fund-holdings/deltaARKQ.csv')
arkw = pd.read_csv('../fund-holdings/deltaARKW.csv')

latest = pd.concat([arkf, arkk, arkg, arkq, arkw])
latest.to_csv('../fund-holdings/latest.csv', index=False)

# print(latest)
# print(arkf.shape, arkk.shape, arkg.shape, arkq.shape, arkw.shape)

master = pd.read_csv('../fund-holdings/master.csv')

if master['date'].iloc[-1] != latest['date'].iloc[0]:
    master = pd.concat([master, latest])
    master.to_csv('../transactions/master.csv', index=False)

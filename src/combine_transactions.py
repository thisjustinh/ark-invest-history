import pandas as pd

DEBUG = False

arkf = pd.read_csv('../fund-holdings/deltaARKF.csv')
arkk = pd.read_csv('../fund-holdings/deltaARKK.csv')
arkg = pd.read_csv('../fund-holdings/deltaARKG.csv')
arkq = pd.read_csv('../fund-holdings/deltaARKQ.csv')
arkw = pd.read_csv('../fund-holdings/deltaARKW.csv')

latest = pd.concat([arkk, arkq, arkw, arkg, arkf])

if DEBUG:
    assert(latest.shape[0] == arkk.shape[0] + arkq.shape[0] +
           arkw.shape[0] + arkg.shape[0] + arkf.shape[0])
else:
    latest.to_csv('../fund-holdings/latest.csv', index=False)

# print(latest)
# print(arkf.shape, arkk.shape, arkg.shape, arkq.shape, arkw.shape)

master = pd.read_csv('../fund-holdings/master.csv')

if DEBUG:
    assert(pd.concat([master, latest]).shape[0]
           == master.shape[0] + latest.shape[0])
elif master['date'].iloc[-1] != latest['date'].iloc[0]:
    master = pd.concat([master, latest])
    master.to_csv('../transactions/master.csv', index=False)

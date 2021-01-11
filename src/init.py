import pandas as pd

ark_track = pd.read_csv('ark_track.csv')
ark_track = ark_track.drop(columns=['T212', 'T212.ISA'])

ark_track.to_csv('../fund-holdings/master.csv', index=False)

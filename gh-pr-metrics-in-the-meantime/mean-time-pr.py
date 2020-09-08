#!/bin/env python3

import pandas as pd
colum_names = ['creation_time', 'creation_time_epoch', 'merge_time', 'merge_time_epoch', 'id', 'title', 'url']
df = pd.read_csv('~/tmp/gh-data.csv', skiprows=0, header=None, sep='|', parse_dates=[0,1,2,3], names=colum_names, skipinitialspace=True)
colum_names.append('time_delta')
df["time_delta"] = df["merge_time"] - df["creation_time"]

client = DataFrameClient(host=dbhost, username='admin', password='pleasechangeme', database='GitHub_pr_stats')
client.write_points(df_values.drop(columns=['merge_time','creation_time','title']),'wtw')

print(" Median %d\t Mean %d\t Std %d\t Min %d\t Max %d\t" % (df["time_delta"].median().days, df["time_delta"].mean().days, df["time_delta"].std().days, df["time_delta"].min().days, df["time_delta"].max().days))

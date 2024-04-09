import sqlite3
import pandas as pd
from glob import glob
from datetime import datetime

from old.utils import *

'''
Reddit content policy change in Mon Jun 29 2020 17:00:06 GMT+0000
-> https://www.reddit.com/r/announcements/comments/hi3oht/update_to_our_content_policy/

reddit = praw.Reddit(client_id='iehVR0OO_8XeQgOzcu2usA', client_secret='3KyZnNcjS4pK2OldRbTWB4jqDrN2wA', user_agent="testscript by u/fakebot3")
conn = sqlite3.connect("data/filt_data.db", check_same_thread=False)
url = conn.cursor().execute(f"SELECT full_link FROM data WHERE rowid=2500000").fetchone()[0]
submission = reddit.submission(url=url)
datetime.utcfromtimestamp(submission.created_utc).strftime('%Y-%m-%d %H:%M:%S')
'''

filt_data = pd.read_sql_query("SELECT * FROM data WHERE timestamp is NOT NULL and timestamp != 0 and timestamp != 'None';", 
                              sqlite3.connect("data/filt_data.db"))
filt_data["timestamp"] = pd.to_datetime(filt_data['timestamp'],unit='s')
filt_data["year"], filt_data["month"], filt_data["day"], filt_data["hour"] = filt_data["timestamp"].dt.year, filt_data["timestamp"].dt.month, filt_data["timestamp"].dt.day, filt_data["timestamp"].dt.hour
filt_data_grouped = filt_data.groupby("year")
print(filt_data["year"].value_counts())

filt_data_2012 = filt_data_grouped.get_group(2012)
filt_data_2013 = filt_data_grouped.get_group(2013)
filt_data_2019 = filt_data_grouped.get_group(2019)
filt_data_2020 = filt_data_grouped.get_group(2020)

filt_data_2012.to_csv("data/processed/2012/filt_data_2012.csv", index=False)
filt_data_2013.to_csv("data/processed/2013/filt_data_2013.csv", index=False)
filt_data_2019.to_csv("data/processed/2019/filt_data_2019.csv", index=False)
filt_data_2020.to_csv("data/processed/2020/filt_data_2020.csv", index=False)
import os
import time
import praw
import random
import pandas as pd
import polars as pl
import requests
from tqdm import tqdm
from fake_useragent import UserAgent
from concurrent.futures import ThreadPoolExecutor, as_completed

import sqlite3

from reddit_config import *
    
def download(url, reddit):
	try:
		#time.sleep(random.uniform(0, 2))
		submission = reddit.submission(url=url)
		return submission.created_utc
	except Exception as e:
		return None

def fetch_data_sql(i, reddit):
    url = conn.cursor().execute(f"SELECT full_link FROM data WHERE rowid = {i}").fetchone()[0]
    timestamp = conn.cursor().execute(f"SELECT timestamp FROM data WHERE rowid = {i}").fetchone()[0]
    if timestamp != None:
        return None
    else:
        oldest = download(url, reddit)
        conn.cursor().execute(f"UPDATE data SET timestamp = '{oldest}' WHERE rowid = {i}")
        conn.commit()
        return None

if __name__ == "__main__":

    conn = sqlite3.connect("data/filt_data.db", check_same_thread=False)
    length = conn.cursor().execute(f"SELECT COUNT(*) FROM data").fetchone()[0]
    with ThreadPoolExecutor(max_workers=16) as executor:
        futures = [executor.submit(fetch_data_sql, i, random.choice(reddit)) for i in tqdm(range(0, length))]
        for i, future in enumerate(tqdm(as_completed(futures), total=len(futures), desc="Downloading")):
            oldest = future.result()
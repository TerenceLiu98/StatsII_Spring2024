import os
import time
import random
import pandas as pd
import polars as pl
from tqdm import tqdm
from fake_useragent import UserAgent
from waybackpy import WaybackMachineCDXServerAPI
from wayback import *

DATA_FILE = "data/new_yt_score_all_subrs.csv"

data = pl.read_csv(DATA_FILE)
filt_data = data.filter((pl.col("num_comments") > 1) & (pl.col("score") > 1))


datetime_list = []
for i in tqdm(range(0, len(filt_data))):
	header = get_headers()
	proxy = get_proxies(proxies, random.randint(0, len(proxies)))
	url = filt_data["url"][i]
	oldest = download(url, header, proxy)
	datetime_list.append(oldest)
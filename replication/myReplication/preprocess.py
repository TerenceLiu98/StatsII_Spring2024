import os
import time
import random
import pandas as pd
import polars as pl
from tqdm import tqdm
from fake_useragent import UserAgent
from waybackpy import WaybackMachineCDXServerAPI
from wayback import *

#DATA_FILE = "data/new_yt_score_all_subrs.csv"
#data = pl.read_csv(DATA_FILE)
#filt_data = data.filter((pl.col("num_comments") > 1) & (pl.col("score") > 1))
#filt_data.write_csv("data/filt_data.csv")

ua = UserAgent(browsers=["edge", "chrome"])

def get_headers():
    return {
		'User-Agent': ua.random
	}

def download(url, header, proxy):
	try: 
		session = requests.Session()
		session.headers.update(header)
		session.proxies.update(proxy)
		cdx_url = f"http://web.archive.org/cdx/search/cdx?url={url}&output=json&limit=1&fl=timestamp,original"
		session.mount('http://', requests.adapters.HTTPAdapter(max_retries=10))
		response = session.get(cdx_url)
		data = response.json()
		if len(data) > 1:
			return data[1][0]
		else:
			return 0
	except:
		return 0
	
filt_data = pd.read_csv("data/filt_data.csv", low_memory=False)
proxy = {"http": "socks5://aaa:bbb@127.0.0.1:8888", "https": "socks5://aaa:bbb@127.0.0.1:8888"}

datetime_file = open("data/datetime_list.txt", "w")
datetime_list = []
for i in tqdm(range(0, 200)):
	header = get_headers()
	url = filt_data["url"][i]
	oldest = download(url, header, proxy)
	datetime_list.append(oldest)
	datetime_file.write(str(oldest) + "\n")
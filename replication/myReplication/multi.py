import os
import time
import random
import pandas as pd
import polars as pl
import requests
from tqdm import tqdm
from fake_useragent import UserAgent
from concurrent.futures import ThreadPoolExecutor, as_completed

ua = UserAgent(browsers=["edge", "chrome"])

def get_headers():
    return {'User-Agent': ua.random}

def download(url, header, proxy):
    try:
        session = requests.Session()
        session.headers.update(header)
        session.proxies.update(proxy)
        cdx_url = f"http://web.archive.org/cdx/search/cdx?url={url}&output=json&limit=1&fl=timestamp,original"
        session.mount('http://', requests.adapters.HTTPAdapter(max_retries=20))
        response = session.get(cdx_url)
        data = response.json()
        if len(data) > 1:
            return data[1][0]
        else:
            return 0
    except Exception as e:
        return 0

def fetch_data(i, proxy):
    header = get_headers()
    url = filt_data["url"][i]
    oldest = download(url, header, proxy)
    return str(oldest)

if __name__ == "__main__":
    filt_data = pd.read_csv("data/filt_data.csv", low_memory=False)
    proxy = {
        "http": "socks5://aaa:bbb@127.0.0.1:8888",
        "https": "socks5://aaa:bbb@127.0.0.1:8888"
    }

with open("data/datetime_list.txt", "w") as datetime_file:
    with ThreadPoolExecutor(max_workers=10) as executor:
        # Prepare for submission of tasks
        futures = [executor.submit(fetch_data, i, proxy) for i in tqdm(range(len(filt_data)))]
        for future in tqdm(as_completed(futures), total=len(futures), desc="Downloading"):
            oldest = future.result()
            datetime_file.write(oldest + "\n")
import requests
from bs4 import BeautifulSoup
from fake_useragent import UserAgent

ua = UserAgent(browsers=["edge", "chrome"])

def get_headers():
    return {
		'User-Agent': ua.random
	}

def get_proxies(proxies, i):
	tmp = str(proxies.protocols[i]) + "://" + str(proxies.ip[i]) + ":" + str(proxies.port[i])
	return {'http': tmp, 'https': tmp}
            

def download(url, header, proxy):
	session = requests.Session()
	session.headers.update(header)
	session.proxies.update(proxy)
	cdx_url = f"http://web.archive.org/cdx/search/cdx?url={url}&output=json&limit=1&fl=timestamp,original"
	response = session.get(cdx_url)
	data = response.json()
	if len(data) > 1:
		return data[1][0]
	else:
		return 0
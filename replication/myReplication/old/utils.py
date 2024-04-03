import os 
import pandas as pd
import networkx as nx
import igraph as ig
import leidenalg as la
from networkx.algorithms import bipartite
import numpy as np

from urllib.parse import urlparse, parse_qs
from urllib.parse import urlparse, parse_qs

import matplotlib
import matplotlib.pyplot as plt
import prince
import scipy
import seaborn as sns
import tldextract
from tqdm import tqdm

from glob import glob

def strip_video_id_from_url(url):
    '''
    Strips the video_id from YouTube URL.
    :input url: a url to a youtube video
    :returns video_id: the video ID parsed from the URL
    '''
    invalid_value = "INVALID"
    # attempts to parse the url
    try:
        parsed = urlparse(url)
    except:
        return invalid_value
    netloc = parsed.netloc

    if 'youtube' in netloc:
        qs = parsed.query
        parsed_qs = parse_qs(qs)

        if parsed_qs.get('v'):
            video_id = parsed_qs['v'][0][:11]
        else:
            video_id = invalid_value
    # if the url is the youtube shortener (like youtu.be/{video id}, return the path)
    elif netloc == 'youtu.be':
        path = parsed.path
        video_id = path[1:12]
        
    # if the youtube video is an embedded video, return the path after /embed/
    elif 'embed' in parsed.path:
        path = parsed.path
        video_id = path.replace('/embed/', '')[1:12]
        
    # finally, if the video id is of the normal type, return the v={video id} arg
    else:
        video_id = invalid_value
        
    if ' ' in video_id:
        video_id = invalid_value
            
    return video_id
    
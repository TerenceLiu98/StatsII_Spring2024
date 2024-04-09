
import sqlite3
import pandas as pd
from glob import glob
from datetime import datetime

from old.utils import *

'''
2013 data

filt_data_2013_IN = DATA_DIR+'new_filt_gt1_yt.csv.bz2'
filt_data_2013_OUT = DATA_DIR+'valid_id_gt1_yt.csv.bz2'
EDGEL_OUT = DATA_DIR+'subr_yt_edgelist.txt'
'''
filt_data_2013 = pd.read_csv("data/processed/2013/filt_data_2013.csv")

subreddit_ideo_dir = 'data/subreddits_by_ideo/'
ideos = {}

# Map each subreddit to the assigned label
for fp in glob(subreddit_ideo_dir+'*'):
    with open(fp, 'r') as f:
        ideo = fp.split('/')[-1][:-4]
        subrs = f.read().splitlines()
        ideos.update(dict.fromkeys(subrs, ideo))

# Retrieve video ids
filt_data_2013['video_id'] = filt_data_2013.url.apply(strip_video_id_from_url)
filt_data_2013 = filt_data_2013[(filt_data_2013.video_id != 'INVALID') & (filt_data_2013.video_id.apply(len) == 11)].copy()

# Create a subreddit-video network
G = nx.Graph()
for i, r in filt_data_2013.iterrows():
    subr = r['subreddit']
    video_id = r['video_id']
    if G.has_edge(subr, video_id):
        G.edges[subr, video_id]['weight'] += 1
    else: 
        G.add_edge(subr, video_id, weight=1)

with open("data/processed/2013/subr_yt_edgelist.txt", 'wb') as f:
    nx.write_weighted_edgelist(G, f)

# Project the subreddit-video network to just the subreddits and output it
subr_proj = bipartite.projection.weighted_projected_graph(G, nodes=filt_data_2013.subreddit.unique())
nx.write_weighted_edgelist(subr_proj, "data/processed/2013/subr_only_el.txt")
subr_ideo_attrs = {k: {'ideo':ideos[k]} for k in subr_proj.nodes if k in ideos}
nx.set_node_attributes(subr_proj, subr_ideo_attrs)
# we also output it in gexf form to make it easier to visualize using Gephi if desired
nx.write_gexf(subr_proj, "data/processed/2013/subrs_only.gexf")


# community detection on a subreddit network to find political subreddits
subreddit_ideo_dir = 'data/subreddits_by_ideo/'
flagged_subreddits = set()

for fp in glob(os.path.join(subreddit_ideo_dir,'*')):
    with open(fp, 'r') as f:
        subrs = f.read().splitlines()
        flagged_subreddits.update(subrs)
        
len(flagged_subreddits)

# Show that the graph created by this notebook and the one I included are isomorphic
ORIGINAL_G = ig.Graph.Read_Ncol("data/processed/2013/subr_only_el.txt", directed=False, weights=True)
JUST_CREATED = ig.Graph.Read_Ncol("data/processed/2013/subr_only_el.txt", directed=False, weights=True)
ORIGINAL_G.isomorphic(JUST_CREATED)
del ORIGINAL_G
del JUST_CREATED

# Read in the subreddit edgelist
g = ig.Graph.Read_Ncol("data/processed/2013/subr_only_el.txt", directed=False, weights=True)
# Partition using Leiden community detection
# In order to exactly replicate my results, we need to run it twice, hence the replicated cell
max_comm_size = 10
partition = la.find_partition(g, la.CPMVertexPartition, resolution_parameter=0.2, weights='weight',seed=8,max_comm_size=max_comm_size) #la.ModularityVertexPartition, max_comm_size=max_comm_size   la.RBConfigurationVertexPartition)
print(len(partition),partition.total_weight_in_all_comms())
# Further optimize 
optimiser = la.Optimiser()
optimiser.set_rng_seed(0)
optimiser.max_comm_size = max_comm_size
diff = optimiser.optimise_partition(partition, n_iterations=-1)
len(partition)

# Format the communities to aid in the checking step
lens = np.zeros(len(partition))
comm_subrs = []

for i, p in enumerate(partition):
    part_subrs = g.vs[p]['name']
    lens[i] = len(part_subrs)
    comm_subrs.append(part_subrs) 

# Go through the resulting communities and keep the ones where at least one subreddit was in our seed set
check_subrs = flagged_subreddits.copy()
pol_subrs = []
subr_total = 0

for comm in comm_subrs:
    for s in comm:
        if s in check_subrs:
            intxn = check_subrs.intersection(comm) 
            check_subrs.difference_update(intxn)
            pol_subrs.append(comm)
            subr_total += len(comm)

# Flatten it to make checking for intersection and file writing easier
flattened = [s for comm in pol_subrs for s in comm ]

# Write out the subreddits 
with open("data/processed/2013/comm_subrs_10_cpm.txt", 'w') as f:
    for s in flattened:
        f.write("%s\n" % s)


# Read in the subreddits obtained via community detection
with open("data/processed/2013/comm_subrs_10_cpm.txt", 'r') as f:
    comm_subrs = set(f.read().splitlines())

filt_df = filt_data_2013[filt_data_2013.subreddit.isin(comm_subrs)].copy()
subreddit_counts = filt_df.subreddit.value_counts()
filt_df['video_id'] = filt_df.url.apply(strip_video_id_from_url)
filt_df = filt_df[(filt_df['video_id'] != 'INVALID') & (filt_df['video_id'].apply(len) == 11)].copy()

prev_len = 0
df_score = filt_df[['subreddit','video_id', 'score']].dropna()
while prev_len != len(df_score):
    prev_len = len(df_score)
    df_score = df_score.groupby('subreddit').filter(lambda x: x['video_id'].nunique() >= 3)
    df_score = df_score.groupby('video_id').filter(lambda x: x['subreddit'].nunique() >= 2)
    print(prev_len, len(df_score))

# Create a cross tab where the entries are the summed, then logged scores. Like so: log(summed_scores + 1)
xtab = pd.crosstab(df_score['video_id'], df_score['subreddit'], values=df_score['score'], aggfunc=np.sum)
xtab.fillna(0, inplace=True)
X = np.log(xtab+1)
X.shape

# Read in our seed subreddits with ideology labels for visualization purposes
subreddit_ideo_dir = 'data/subreddits_by_ideo/'
ideos = {}
for fp in glob(subreddit_ideo_dir+'*'):
    with open(fp, 'r') as f:
        ideo = fp.split('/')[-1][:-4]
        subrs = f.read().splitlines()
        ideos[ideo] = subrs

ca = prince.CA(n_components=4, n_iter=20, random_state=0)
ca.fit(X)
fitted = ca.column_coordinates(X)
fitted['subreddit'] = xtab.columns
# create frame for plotting subreddits (output it for plotting)
right = fitted[fitted['subreddit'].isin(ideos['right'])].copy()
mod = fitted[fitted['subreddit'].isin(ideos['mod'])].copy()
left = fitted[fitted['subreddit'].isin(ideos['left'])].copy()

right['ideo'] = 'Conservative'
mod['ideo'] = 'Moderate'
left['ideo'] = 'Liberal'

out = pd.concat([right, mod, left])[['subreddit',0,1,2,3,'ideo']].copy()
exclude = pd.concat([fitted[fitted[0] >= 4].subreddit,fitted[fitted[2] >= 5].subreddit,fitted[fitted[3]>=5].subreddit])
exclude.drop_duplicates(inplace=True)

filt_df = filt_df[~filt_df.subreddit.isin(exclude)].copy()
subreddit_counts = filt_df.subreddit.value_counts()

# Threshold subreddits and videos based on how often they show up
prev_len = 0
df_score = filt_df[['subreddit','video_id', 'score']].dropna()
while prev_len != len(df_score):
    prev_len = len(df_score)
    df_score = df_score.groupby('subreddit').filter(lambda x: x['video_id'].nunique() >= 3)
    df_score = df_score.groupby('video_id').filter(lambda x: x['subreddit'].nunique() >= 2)
    print(prev_len, len(df_score))

counts_xtab = pd.crosstab(df_score['video_id'], df_score['subreddit'])
counts_xtab.to_csv("data/processed/2013/counts_subr_vid_crosst.csv")

xtab = pd.crosstab(df_score['video_id'], df_score['subreddit'], values=df_score['score'], aggfunc=np.sum)
xtab.fillna(0, inplace=True)
logged_xtab = np.log(xtab+1)
logged_xtab.shape
logged_xtab.to_csv("data/processed/2013/score_subr_vid_crosst.csv")


vid_data = pd.read_csv("data/anonymized_video_pid.csv")
vid_data = pd.merge(vid_data, filt_data_2013).drop_duplicates("video_id")
vid_data = vid_data[['video_id', 'bert_score', 'collapsed_pid7']]
vid_data.to_csv("data/processed/2013/video.csv", index=False)
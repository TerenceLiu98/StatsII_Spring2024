from utils import * 

'''
data path: /home/jovyan/data/
'''

DATA_DIR = "/home/jovyan/data/youtube/"
IN_FILE = 'included/new_yt_score_all_subrs.csv.bz2'
df = pd.read_csv(os.path.join(DATA_DIR,IN_FILE), low_memory=False)

# Filter data for posts with > 1 comment and a score > 1
df[(df.num_comments > 1) & (df.score > 1)][['domain','url','subreddit','score','num_comments','over_18']].to_csv(os.path.join(DATA_DIR,'new_filt_gt1_yt.csv.bz2'), index=False)
# df = pd.read_csv(os.path.join(DATA_DIR, 'new_filt_gt1_yt.csv.bz2'), low_memory=False)

DF_IN = DATA_DIR+'new_filt_gt1_yt.csv.bz2'
DF_OUT = DATA_DIR+'valid_id_gt1_yt.csv.bz2'
EDGEL_OUT = DATA_DIR+'subr_yt_edgelist.txt'

# Optional: read in our coded subreddits so we can add that label as an attribute in the graph, giving us the option to color subreddits if we visualize them
subreddit_ideo_dir = DATA_DIR + '/included/subreddits_by_ideo/'
ideos = {}

# Map each subreddit to the assigned label
for fp in glob(subreddit_ideo_dir+'*'):
    with open(fp, 'r') as f:
        ideo = fp.split('/')[-1][:-4]
        subrs = f.read().splitlines()
        ideos.update(dict.fromkeys(subrs, ideo))

df = pd.read_csv(DF_IN) 
# Retrieve video ids
df['video_id'] = df.url.apply(strip_video_id_from_url)
# Filter the dataframe to exclude posts with invalid video ids
df = df[(df.video_id != 'INVALID') & (df.video_id.apply(len) == 11)].copy()

# Create a subreddit-video network
graph_exists = False

if not graph_exists:
    G = nx.Graph()
    for i, r in df.iterrows():
        subr = r['subreddit']
        video_id = r['video_id']
        if G.has_edge(subr, video_id):
            G.edges[subr, video_id]['weight'] += 1
        else: 
            G.add_edge(subr, video_id, weight=1)  
    with open(EDGEL_OUT, 'wb') as f:
        nx.write_weighted_edgelist(G, f)
else:
    G = nx.read_weighted_edgelist(EDGEL_OUT)

# Project the subreddit-video network to just the subreddits and output it
subr_proj = bipartite.projection.weighted_projected_graph(G, nodes=df.subreddit.unique())
nx.write_weighted_edgelist(subr_proj, DATA_DIR+'subr_only_el.txt')
subr_ideo_attrs = {k: {'ideo':ideos[k]} for k in subr_proj.nodes if k in ideos}
nx.set_node_attributes(subr_proj, subr_ideo_attrs)
# we also output it in gexf form to make it easier to visualize using Gephi if desired
nx.write_gexf(subr_proj, DATA_DIR+"subrs_only.gexf")
print('SUBREDDIT NETWORK EXECUTION TIME:')
end = time.time()
print(end - start)

# community detection 
# Read in our seed subreddits to aid in choosing communities of political subreddits
subreddit_ideo_dir = DATA_DIR + '/included/subreddits_by_ideo/'
flagged_subreddits = set()

for fp in glob(os.path.join(subreddit_ideo_dir,'*')):
    with open(fp, 'r') as f:
        subrs = f.read().splitlines()
        flagged_subreddits.update(subrs)


# Show that the graph created by this notebook and the one I included are isomorphic
ORIGINAL_G = ig.Graph.Read_Ncol('/home/jovyan/data/youtube/included/subr_only_el.txt', directed=False, weights=True)
JUST_CREATED = ig.Graph.Read_Ncol(f'{DATA_DIR}subr_only_el.txt', directed=False, weights=True)
ORIGINAL_G.isomorphic(JUST_CREATED)
del ORIGINAL_G
del JUST_CREATED
# Read in the subreddit edgelist
g = ig.Graph.Read_Ncol(f'/home/jovyan/data/youtube/included/subr_only_el.txt', directed=False, weights=True)

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

# Flatten it to make checking for intersection and file writing easier
flattened = [s for comm in pol_subrs for s in comm ]

# Write out the subreddits 
with open(f'{DATA_DIR}comm_subrs_10_cpm.txt', 'w') as f:
    for s in flattened:
        f.write("%s\n" % s)

print('COMMUNITY DETECTION EXECUTION TIME:')
end = time.time()
print(end - start)


# Find subreddits we want to exclude from the subreddit-video matrix based on their correspondence analysis scores.

# Read in the subreddits obtained via community detection
with open(f'{DATA_DIR}comm_subrs_10_cpm.txt', 'r') as f:
    comm_subrs = set(f.read().splitlines())

# Read in the YouTube-Reddit post data and filter for posts with a score >= 1
reddit_fp = f'{DATA_DIR}/included/new_yt_score_all_subrs.csv.bz2'
df = pd.read_csv(reddit_fp)
filt_df = df[(df.score >=1) & df.subreddit.isin(comm_subrs)].copy()

del df
# Get the number of posts per subreddit 
subreddit_counts = filt_df.subreddit.value_counts()
# Filter for posts with valid ids
filt_df['video_id'] = filt_df.url.apply(strip_video_id_from_url)
filt_df = filt_df[(filt_df['video_id'] != 'INVALID') & (filt_df['video_id'].apply(len) == 11)].copy()
prev_len = 0
df_score = filt_df[['subreddit','video_id', 'score']].dropna()

while prev_len != len(df_score):
    
    prev_len = len(df_score)
    df_score = df_score.groupby('subreddit').filter(lambda x: x['video_id'].nunique() >= 5)
    df_score = df_score.groupby('video_id').filter(lambda x: x['subreddit'].nunique() >= 3)
    
    print(prev_len, len(df_score))

# Create a cross tab where the entries are the summed, then logged scores. Like so: log(summed_scores + 1)
xtab = pd.crosstab(df_score['video_id'], df_score['subreddit'], values=df_score['score'], aggfunc=np.sum)
xtab.fillna(0, inplace=True)
X = np.log(xtab+1)
X.shape
# Read in our seed subreddits with ideology labels for visualization purposes
subreddit_ideo_dir = '/home/jovyan/data/youtube/included/subreddits_by_ideo/'
ideos = {}

for fp in glob(subreddit_ideo_dir+'*'):
    with open(fp, 'r') as f:
        ideo = fp.split('/')[-1][:-4]
        subrs = f.read().splitlines()
        ideos[ideo] = subrs
# fit the correspondence matrix and then get the column inertias for the subreddits
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
out = pd.merge(out, subreddit_counts.to_frame().reset_index().rename({'index':'subreddit', 'subreddit':'count'}, axis=1), on='subreddit')

# plot the correspondence analysis dimensions against each other and exclude subreddits based on visual inspection
x = 0
y = 1
plt.scatter(fitted[x], fitted[y], c='grey', alpha=0.33)
plt.scatter(right[x], right[y], c='r', alpha=0.33)
plt.scatter(mod[x], mod[y], c='purple', alpha=0.33)
plt.scatter(left[x], left[y], c='blue', alpha=0.33)
plt.savefig("figs/correspondence-analysis-subreddit.png", dpi=500)

x = 1
y = 2
plt.scatter(fitted[x], fitted[y], c='grey', alpha=0.33)
plt.scatter(right[x], right[y], c='r', alpha=0.33)
plt.scatter(mod[x], mod[y], c='purple', alpha=0.33)
plt.scatter(left[x], left[y], c='blue', alpha=0.33)
plt.savefig("figs/corrs-poli-nonpoli.png", dpi=500)

# Here, we filter based on what we observe in the above plots and output a list of subreddits to exclude
exclude = pd.concat([fitted[fitted[0] >= 4].subreddit,fitted[fitted[2] >= 5].subreddit,fitted[fitted[3]>=5].subreddit])
exclude.drop_duplicates(inplace=True)
exclude.to_csv(f'{DATA_DIR}exclude.txt',index=False)
filt_df = filt_df[~filt_df.subreddit.isin(exclude)].copy()

# We create a filtered dataframe where the video ids are valid, the posts have a score >= 1, and the subreddit is on our community-detected set
filt_df.to_csv(f'{DATA_DIR}valid_id_subr_gt1.csv.bz2',index=False)

# Create subreddit-video matrix after threshoding for number of times a subreddit/vedeo shows up
df = pd.read_csv(f'{DATA_DIR}valid_id_subr_gt1.csv.bz2')
subreddit_counts = df.subreddit.value_counts()

# Threshold subreddits and videos based on how often they show up
prev_len = 0
df_score = df[['subreddit','video_id', 'score']].dropna()

while prev_len != len(df_score):
    
    prev_len = len(df_score)
    df_score = df_score.groupby('subreddit').filter(lambda x: x['video_id'].nunique() >= 5)
    df_score = df_score.groupby('video_id').filter(lambda x: x['subreddit'].nunique() >= 3)
    
    print(prev_len, len(df_score))

# Optional: output a counts crosstab. We can use this if we want to compare results from the counts crosstab vs the score crosstab
counts_xtab = pd.crosstab(df_score['video_id'], df_score['subreddit'])
counts_xtab.to_csv(os.path.join(DATA_DIR,'counts_subr_vid_crosst.csv'))

# Create the score-based crosstab. Each cell entry is log(summed_scores+1)
xtab = pd.crosstab(df_score['video_id'], df_score['subreddit'], values=df_score['score'], aggfunc=np.sum)
xtab.fillna(0, inplace=True)
logged_xtab = np.log(xtab+1)

# Output the crosstab
logged_xtab.to_csv(os.path.join(DATA_DIR,'score_subr_vid_crosst.csv'))
print('CREATING SUBREDDIT MATRIX EXECUTION TIME:')
end = time.time()
print(end - start)

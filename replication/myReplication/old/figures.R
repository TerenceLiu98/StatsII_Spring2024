library("FactoMineR")
library("ggplot2")
library("gridExtra")
library("tidyverse")
library("ggridges")
library("ggrepel")
library("dplyr")

### FIGURE 2
dat <- read_csv('data/processed/2012/subreddit_ca.csv')

keeps <- c('news', 'anythinggoesnews', 'worldnews', 'politics', 'worldpolitics',
            'libertarian', 'democrats', 'republican', 'conservative', 
            'progressive', 'anarchism', 'socialism', 'communism', 'conspiracy')

cairo_pdf('figs/f2_subreddits_2012.pdf',width = 7,height = 8)
dat %>%
  mutate(vc2 = vid_count) %>%
  ggplot(aes(x = ca_score,y = reorder(subreddit,ca_score),color = ca_score,label = subreddit,size = vid_count)) + 
  geom_point(aes(size = vc2)) + 
  scale_color_gradient2(low = 'darkblue',mid = 'grey70',high = 'darkred') + 
  geom_text_repel(data = dat %>% filter(subreddit %in% keeps,ca_score < 0),hjust = 0,nudge_x = .25,size = 4) + 
  geom_text_repel(data = dat %>% filter(subreddit %in% keeps,ca_score > 0),hjust = 1.2,nudge_x = -.25,size = 4) + 
  theme_bw(base_size=16) + 
  scale_y_discrete(expand = c(.05,.05)) + 
  scale_size_continuous(range = c(.1,10)) + 
  theme(axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major.y = element_blank(),
        legend.position = 'none') + xlab('Ideology Score \n Liberal \u2192 Conservative') + ylab('Subreddits') +
  xlim(-2,2)
dev.off()

dat <- read_csv('data/processed/2020/subreddit_ca.csv')

keeps <- c('news', 'anythinggoesnews', 'worldnews', 'politics', 'worldpolitics',
            'libertarian', 'democrats', 'republican', 'conservative', 
            'progressive', 'anarchism', 'socialism', 'communism', 'conspiracy')

cairo_pdf('figs/f2_subreddits_2020.pdf',width = 7,height = 8)
dat %>%
  mutate(vc2 = vid_count) %>%
  ggplot(aes(x = ca_score,y = reorder(subreddit,ca_score),color = ca_score,label = subreddit,size = vid_count)) + 
  geom_point(aes(size = vc2)) + 
  scale_color_gradient2(low = 'darkblue',mid = 'grey70',high = 'darkred') + 
  geom_text_repel(data = dat %>% filter(subreddit %in% keeps,ca_score < 0),hjust = 0,nudge_x = .25,size = 4) + 
  geom_text_repel(data = dat %>% filter(subreddit %in% keeps,ca_score > 0),hjust = 1.2,nudge_x = -.25,size = 4) + 
  theme_bw(base_size=16) + 
  scale_y_discrete(expand = c(.05,.05)) + 
  scale_size_continuous(range = c(.1,10)) + 
  theme(axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        panel.grid.major.y = element_blank(),
        legend.position = 'none') + xlab('Ideology Score \n Liberal \u2192 Conservative') + ylab('Subreddits') +
  xlim(-2,2)
dev.off()


### FIGURE 3
# 3A
# Purpose: Create ridge plots showing the distribution of channel ideology estimates (the mean of their video ideologies), grouped by the channel ideology label they were assigned by Hosseinmardi.
# Input:
# /home/jovyan/data/youtube/ideo_channel_means.csv, ideology means for all channels with a label from Hosseinmardi
# Output:
# ../figures/f3a_mean_channel_hosseinmardi.pdf, figure with ridge plots for each label category

library(RColorBrewer)

data <- read.table("/home/jovyan/data/youtube/included/ideo_channel_means.csv", fill=TRUE, header=TRUE, row.names=NULL, sep=",", quote="")  # Read in data
data$channel_ideo <- factor(data$channel_ideo, c('far_left','left','center','right','far_right'))  # Make the labels factors
levels(data$channel_ideo) <- c('Far Left', 'Left', 'Center', 'Right', 'Far Right')  # Order the labels
mycolors <- colorRampPalette(c('darkblue','grey70','darkred'))(length(unique(data$channel_ideo)))  # Set color palette

# Make ridge plot and save to PDF
cairo_pdf('../figures/f3a_mean_channel_hosseinmardi.pdf')
data %>%
  ggplot( aes(x=scoresCA, y=channel_ideo, fill=channel_ideo, color=channel_ideo)) +
  geom_density_ridges(alpha=0.5) +
  theme_bw(base_size=16) +
  scale_fill_manual(values = mycolors) +
  scale_colour_manual(values = mycolors) +
  theme(
    legend.position="none"
  ) +
  xlab("Mean of Channel's Reddit Video Ideology Scores \n Liberal \u2192 Conservative") +
  ylab("Channel Label")
dev.off()

# 3B
# Purpose: Create box plots showing the distribution of video ideology estimates for each of the fifteen channels represented in channels_plot_data. 
# For each channel label category, we plot a box plot for the top three channels by mean video view with >= 50 videos for a total of fifteen box plots.
# Input: 
# /home/jovyan/data/youtube/channels_plot_data.csv, individual video ideology estimates for videos from the top three channels per Hosseinmardi channel label category (15 channels)
# Output:
# ../figures/f3b_channel_box.pdf, figure with a box plot for the videos from each channel
data <- read.table("/home/jovyan/data/youtube/included/channels_plot_data.csv", fill=TRUE, header=TRUE, row.names=NULL, sep=",", quote="")  # read in data

mycolors <- colorRampPalette(c('darkblue','grey70','darkred'))(length(unique(data$channel_title)))  # set color palette

# Make box plots and save as PDF
cairo_pdf('../figures/f3b_channel_box.pdf')
data %>%
  mutate(channel_title = fct_reorder(channel_title, scoresCA)) %>% # Reorder data
  ggplot( aes(x=channel_title, y=scoresCA, fill=channel_title, color=channel_title, alpha=0.33)) +
  geom_boxplot(outlier.shape = NA) +
  scale_fill_manual(values = mycolors) +
  scale_colour_manual(values = mycolors) +
  theme_bw(base_size=16) +
  theme(
    legend.position="none",
  ) +
  coord_flip() + # This switches X and Y axis and allows us to get the horizontal version
  xlab("") +
  ylab("Video Ideology Score \n Liberal \u2192 Conservative")
dev.off()



### FIGURE 4B
# Purpose: Plot distance between ideology estimates for two videos vs. binary agreement with human coders
# Input:
# /scratch/olympus/projects/ytr-clean/text_scored.csv, data on BERT model ideology estimates and their agreement with human labels
# Output:
# ../figures/f4b_text_probit_regr.pdf

set.seed(123)

df <- read.table('/home/jovyan/data/youtube/text_scored.csv', header=TRUE,sep=',',quote="\"")

# For the CA and text-based ideology estimates, plot each video pair where the score distance is on the x-axis and agreement with the human labels (a binary indicator, 0 or 1) is on the y-axis 
pdf('../figures/f4b_text_probit_regr.pdf')
ggplot(df, aes(x=score_diff, y=correct)) +
  geom_jitter(alpha=0.25, color="#69b3a2", width = 0.015, height = 0.015) +
  stat_smooth(method="glm",method.args=list(family=binomial(link="probit")),formula=y~x,se=T) +
  labs(x='Distance between text-based scores of two videos', y='Agreement with human coders') +
  theme_bw(base_size = 16)
dev.off()


### FIGURE 5
# Purpose: Calculate and plot the correlation between our scores and the averaged video bin labels from human coders.
# Input: 
# Scores and bin labels for videos where coders do not have sufficient cross-aisle disagreement: /scratch/olympus/projects/ytr-clean/surge_data/high_agreed_vids.csv
# Output:
# ../figures/f5_bert_vs_bin.pdf and, in print output, the relevant correlation

vids <- read.csv("/home/jovyan/data/youtube/high_agreed_vids.csv")

# Plot average bin label against BERT ideology score
pdf('../figures/f5_bert_vs_bin.pdf')
vids %>% 
  ggplot(aes(x=avg_bin,y=label)) +
  geom_point(alpha=0.33) +
  geom_smooth() +
  scale_x_continuous(n.breaks=7) +
  labs(x="Average bin placement", y="Text-based ideology score") +
  theme_bw(base_size=16)
dev.off()

# Get correlation
print("CORRELATION BETWEEN AVERAGED HUMAN BIN LABELS AND TEXT-BASED IDEOLOGY ESTIMATES")
print(cor(vids$avg_bin, vids$label, method="pearson"))



### FIGURE 6a
# Purpose: Plot the distribution of video ideology at the party level. This aggregates all videos viewed by respondents at the party level and does not remove duplicates.
# Input: 
# anonymized_video_pid.csv, respondent-video data 
# Output:
# ../figures/f6a_ng_pid_vids.pdf
by_party <- read.csv("/home/jovyan/data/youtube/included/anonymized_video_pid.csv")
by_party$collapsed_pid7 <- factor(by_party$collapsed_pid7, c('Democrat','Independent','Republican'))  # Order parties and set as factors

# Get the median video ideology and video SD for each party
print("MEDIAN VIDEO IDEOLOGY AND SD FOR EACH PARTY")
print(by_party %>% 
  group_by(collapsed_pid7) %>%
  summarize(median=median(bert_score), sd=sd(bert_score),n=length(bert_score)))

# Create violin plots with overlaid box plots for each political party and save to PDF
mycolors <- c('darkblue','plum4','darkred')  
cairo_pdf('figs/f6a_ng_pid_vids.pdf',width=7,height=4)
ggplot(by_party, aes(x = collapsed_pid7, y = bert_score, fill = collapsed_pid7)) +
  geom_violin(alpha=0.66) +
  geom_boxplot(width=0.1, fill='white', outlier.shape=NA) +
  scale_fill_manual(values = mycolors) +
  scale_colour_manual(values = mycolors) +
  coord_flip() + 
  theme_bw(base_size=16) +
  theme(
    legend.position="none",
    panel.spacing = unit(0.1, "lines"),
    strip.text.x = element_text(size = 8)
  ) +
  ylim(-1.5,1.5) +
  ylab("Video Ideology Score \n Liberal \u2192 Conservative") +
  xlab("Political party of video's viewer(s)")
dev.off()

### FIGURE 6b
# Purpose: Plot the distribution of video ideology at the individual level, grouped by party.
# Input: 
# anonymized_video_pid.csv, respondent-video data 
# Output:
# ../figures/f6b_ng_indiv.pdf
hist <- read.csv("/home/jovyan/data/youtube/included/anonymized_video_pid.csv")

indiv_means <- hist %>% 
    group_by(caseid) %>%
    filter(n_distinct(video_id) >= 5) %>%
    summarize(sd=sd(bert_score), q25=quantile(bert_score,c(0.25)), median=median(bert_score), q75=quantile(bert_score,c(0.75)), mean=mean(bert_score),collapsed_pid7=first(collapsed_pid7))

indiv_means$collapsed_pid7 <- factor(indiv_means$collapsed_pid7, c('Democrat','Independent','Republican'))  # Make the labels factors
mycolors <- colorRampPalette(c('darkblue','grey70','darkred'))(length(unique(indiv_means$collapsed_pid7)))  # Set color palette

cairo_pdf('../figures/f6b_ng_indiv.pdf')
set.seed(26)
indiv_means %>% 
  ggplot(aes(x=median, y=collapsed_pid7, color=collapsed_pid7)) +
  #geom_point(size=2, alpha=0.6) + #, position=position_jitter(w=0, h=0.1)) +  # Option for plotting without jitter
  geom_pointrange(aes(xmin=q25,xmax=q75),alpha=0.5,size=0.5,position = position_jitterdodge(jitter.width=1.5),show.legend = FALSE) +
  scale_fill_manual(values = mycolors) +
  scale_colour_manual(values = mycolors) +
  xlab("Median ideology of respondent's viewed videos with IQR \n Liberal \u2192 Conservative") +
  ylab("Respondent's Party ID") +
  theme_bw(base_size=16)
dev.off()

# Get the median of the IQR, median of the medians, mean of the medians per party
indiv_means %>% 
  group_by(collapsed_pid7) %>%
  summarize(median_iqr=median(q75-q25), med=median(median), mean=mean(median), sd_mu=mean(sd), n=n())


### FIGURE 7
# Purpose: Plot video ideologies against engagement stats.
# Input:
# /home/jovyan/data/youtube/video_engagement.csv, engagement stats for political videos from Newsguard watch history
# Output:
# ../figures/f7_engagement_vs_ideo.pdf

library(ggpubr)

vids <- read.csv("/home/jovyan/data/youtube/video_engagement.csv")
vids <- vids %>% filter(com_per_view < 0.4)  # Remove outlier
# Plot likes to dislikes ratio
p1 <- vids %>% 
  ggplot(aes(x=bert_score,y=like_dislike_ratio)) +
  geom_point(alpha=0.2) +
  geom_smooth() +
  labs(x="Ideology score", y="(No. likes)/(No. likes + no. dislikes)",title="Proportion of likes") +
  theme_bw()

# Plot number of likes per view
p2<- vids %>% 
  ggplot(aes(x=bert_score,y=like_per_view)) +
  geom_point(alpha=0.2) +
  geom_smooth() +
  labs(x="Ideology score", y="(No. likes + no. dislikes)/No. views",title="Likes/dislikes per view") +
  theme_bw()

# Plot number of comments per view
p3 <- vids %>% 
  ggplot(aes(x=bert_score,y=com_per_view)) +
  geom_point(alpha=0.2) +
  geom_smooth() +
  labs(x="Ideology score", y="No. comments/No. views",title="Comments per view") +
  theme_bw()

# Views vs. ideology score
p4 <- vids %>% 
  ggplot(aes(x=bert_score,y=log(video_view_count))) +
  geom_point(alpha=0.2) +
  geom_smooth() +
  labs(x="Ideology score", y="Logged number of views",title="Number of views vs. ideology") +
  theme_bw()

cairo_pdf('../figures/f7_engagement_vs_ideo.pdf')
ggarrange(p1,p2,p3,p4)
dev.off()

end = Sys.time()
print("Execution time:")
print(end-start)

library("FactoMineR")
library("ggplot2")
library("gridExtra")
library("tidyverse")
library("ggridges")
library("ggrepel")
library("dplyr")

keeps <- c('news', 'anythinggoesnews', 'worldnews', 'politics', 'worldpolitics', 'mensrights', 'worldpolitics', 'politics',
            'libertarian', 'democrats', 'republican', 'conservative', 'liberal', 'riots', 'byebyejob', 'anarcho_capitalism',
            'progressive', 'anarchism', 'socialism', 'conspiracy', 'trump', 'news', 'worldnews', 'bad_cop_no_donut', 'brexit',
            'occupywallstreet', 'firearms', 'gunpolitics', 'liberalgunowners')

# Read in the data
score <- read.table("data/processed/2012/score_subr_vid_crosst.csv", header=TRUE, row.names=1, sep=",")
counts <- read.table("data/processed/2012/counts_subr_vid_crosst.csv", header=TRUE, row.names=1, sep=",")
bin_counts <- counts
bin_counts[bin_counts > 1] <- 1

# Obtain CA components for binary, count, and score data
score_ca <- CA(score,graph=F)
counts_ca <- CA(counts,graph=F)
bin_ca <- CA(bin_counts, graph=F)

scoresCA <- score_ca$row$coord[,"Dim 1"]
countsCA <- counts_ca$row$coord[, "Dim 1"]
binCA <- bin_ca$row$coord[,"Dim 1"]

# Plot the different CAs against each other for reference
p1 <- qplot(countsCA, binCA, alpha=0.2, show.legend=FALSE)
p2 <- qplot(countsCA, scoresCA, alpha=0.2, show.legend=FALSE)
p3 <- qplot(binCA, scoresCA, alpha=0.2, show.legend=FALSE)
grid.arrange(p1, p2, p3)

cor(data.frame(countsCA, binCA, scoresCA))

# Output these scores for videos
df <- data.frame(binCA=binCA,countsCA=countsCA,scoresCA=scoresCA)
write.csv(df,"data/processed/2012/vid_ca.csv", row.names = TRUE)

# Output these scores for subreddits
subr_scores <- score_ca$col$coord[,"Dim 1"]
vid_counts <- colSums(bin_counts)
subr_df <- data.frame(ca_score=subr_scores,vid_count=vid_counts)
subr_df$subreddit <- rownames(subr_df)
write.csv(subr_df,"data/processed/2012/subreddit_ca.csv", row.names = FALSE)

### FIGURE 2
dat <- read_csv('data/processed/2012/subreddit_ca.csv')

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
  xlim(-4, 4)
dev.off()

############## 2013 ##############

# Read in the data
score <- read.table("data/processed/2013/score_subr_vid_crosst.csv", header=TRUE, row.names=1, sep=",")
counts <- read.table("data/processed/2013/counts_subr_vid_crosst.csv", header=TRUE, row.names=1, sep=",")
bin_counts <- counts
bin_counts[bin_counts > 1] <- 1

# Obtain CA components for binary, count, and score data
score_ca <- CA(score,graph=F)
counts_ca <- CA(counts,graph=F)
bin_ca <- CA(bin_counts, graph=F)

scoresCA <- score_ca$row$coord[,"Dim 1"]
countsCA <- counts_ca$row$coord[, "Dim 1"]
binCA <- bin_ca$row$coord[,"Dim 1"]

# Plot the different CAs against each other for reference
p1 <- qplot(countsCA, binCA, alpha=0.2, show.legend=FALSE)
p2 <- qplot(countsCA, scoresCA, alpha=0.2, show.legend=FALSE)
p3 <- qplot(binCA, scoresCA, alpha=0.2, show.legend=FALSE)
grid.arrange(p1, p2, p3)

cor(data.frame(countsCA, binCA, scoresCA))

# Output these scores for videos
df <- data.frame(binCA=binCA,countsCA=countsCA,scoresCA=scoresCA)
write.csv(df,"data/processed/2013/vid_ca.csv", row.names = TRUE)

# Output these scores for subreddits
subr_scores <- score_ca$col$coord[,"Dim 1"]
vid_counts <- colSums(bin_counts)
subr_df <- data.frame(ca_score=subr_scores,vid_count=vid_counts)
subr_df$subreddit <- rownames(subr_df)
write.csv(subr_df,"data/processed/2013/subreddit_ca.csv", row.names = FALSE)

### FIGURE 2
dat <- read_csv('data/processed/2013/subreddit_ca.csv')

cairo_pdf('figs/f2_subreddits_2013.pdf',width = 7,height = 8)
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
  xlim(-4, 4)
dev.off()

by_party <- read.csv("data/processed/2013/video.csv")
by_party$collapsed_pid7 <- factor(by_party$collapsed_pid7, c('Democrat','Independent','Republican'))  # Order parties and set as factors

# Get the median video ideology and video SD for each party
print("MEDIAN VIDEO IDEOLOGY AND SD FOR EACH PARTY")
print(by_party %>% 
  group_by(collapsed_pid7) %>%
  summarize(median=median(bert_score), sd=sd(bert_score),n=length(bert_score)))

# Create violin plots with overlaid box plots for each political party and save to PDF
mycolors <- c('darkblue','plum4','darkred')  
cairo_pdf('figs/pid_vids_2013.pdf',width=7,height=4)
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

############## 2019 ##############
# Read in the data
score <- read.table("data/processed/2019/score_subr_vid_crosst.csv", header=TRUE, row.names=1, sep=",")
counts <- read.table("data/processed/2019/counts_subr_vid_crosst.csv", header=TRUE, row.names=1, sep=",")
bin_counts <- counts
bin_counts[bin_counts > 1] <- 1

# Obtain CA components for binary, count, and score data
score_ca <- CA(score,graph=F)
counts_ca <- CA(counts,graph=F)
bin_ca <- CA(bin_counts, graph=F)

scoresCA <- score_ca$row$coord[,"Dim 1"]
countsCA <- counts_ca$row$coord[, "Dim 1"]
binCA <- bin_ca$row$coord[,"Dim 1"]

# Plot the different CAs against each other for reference
p1 <- qplot(countsCA, binCA, alpha=0.2, show.legend=FALSE)
p2 <- qplot(countsCA, scoresCA, alpha=0.2, show.legend=FALSE)
p3 <- qplot(binCA, scoresCA, alpha=0.2, show.legend=FALSE)
grid.arrange(p1, p2, p3)

cor(data.frame(countsCA, binCA, scoresCA))

# Output these scores for videos
df <- data.frame(binCA=binCA,countsCA=countsCA,scoresCA=scoresCA)
write.csv(df,"data/processed/2019/vid_ca.csv", row.names = TRUE)

# Output these scores for subreddits
subr_scores <- score_ca$col$coord[,"Dim 1"]
vid_counts <- colSums(bin_counts)
subr_df <- data.frame(ca_score=subr_scores,vid_count=vid_counts)
subr_df$subreddit <- rownames(subr_df)
write.csv(subr_df,"data/processed/2019/subreddit_ca.csv", row.names = FALSE)

dat <- read_csv('data/processed/2019/subreddit_ca.csv')

cairo_pdf('figs/f2_subreddits_2019.pdf',width = 7,height = 8)
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
  xlim(-4, 4)
dev.off()

by_party <- read.csv("data/processed/2019/video.csv")
by_party$collapsed_pid7 <- factor(by_party$collapsed_pid7, c('Democrat','Independent','Republican'))  # Order parties and set as factors

# Get the median video ideology and video SD for each party
print("MEDIAN VIDEO IDEOLOGY AND SD FOR EACH PARTY")
print(by_party %>% 
  group_by(collapsed_pid7) %>%
  summarize(median=median(bert_score), sd=sd(bert_score),n=length(bert_score)))

# Create violin plots with overlaid box plots for each political party and save to PDF
mycolors <- c('darkblue','plum4','darkred')  
cairo_pdf('figs/pid_vids_2019.pdf',width=7,height=4)
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

############## 2020 ##############
# Read in the data
score <- read.table("data/processed/2020/score_subr_vid_crosst.csv", header=TRUE, row.names=1, sep=",")
counts <- read.table("data/processed/2020/counts_subr_vid_crosst.csv", header=TRUE, row.names=1, sep=",")
bin_counts <- counts
bin_counts[bin_counts > 1] <- 1

# Obtain CA components for binary, count, and score data
score_ca <- CA(score,graph=F)
counts_ca <- CA(counts,graph=F)
bin_ca <- CA(bin_counts, graph=F)

scoresCA <- score_ca$row$coord[,"Dim 1"]
countsCA <- counts_ca$row$coord[, "Dim 1"]
binCA <- bin_ca$row$coord[,"Dim 1"]

# Plot the different CAs against each other for reference
p1 <- qplot(countsCA, binCA, alpha=0.2, show.legend=FALSE)
p2 <- qplot(countsCA, scoresCA, alpha=0.2, show.legend=FALSE)
p3 <- qplot(binCA, scoresCA, alpha=0.2, show.legend=FALSE)
grid.arrange(p1, p2, p3)

cor(data.frame(countsCA, binCA, scoresCA))

# Output these scores for videos
df <- data.frame(binCA=binCA,countsCA=countsCA,scoresCA=scoresCA)
write.csv(df,"data/processed/2020/vid_ca.csv", row.names = TRUE)

# Output these scores for subreddits
subr_scores <- score_ca$col$coord[,"Dim 1"]
vid_counts <- colSums(bin_counts)
subr_df <- data.frame(ca_score=subr_scores,vid_count=vid_counts)
subr_df$subreddit <- rownames(subr_df)
write.csv(subr_df,"data/processed/2020/subreddit_ca.csv", row.names = FALSE)

dat <- read_csv('data/processed/2020/subreddit_ca.csv')

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
  xlim(-4, 4)
dev.off()

by_party <- read.csv("data/processed/2020/video.csv")
by_party$collapsed_pid7 <- factor(by_party$collapsed_pid7, c('Democrat','Independent','Republican'))  # Order parties and set as factors

# Get the median video ideology and video SD for each party
print("MEDIAN VIDEO IDEOLOGY AND SD FOR EACH PARTY")
print(by_party %>% 
  group_by(collapsed_pid7) %>%
  summarize(median=median(bert_score), sd=sd(bert_score),n=length(bert_score)))

# Create violin plots with overlaid box plots for each political party and save to PDF
mycolors <- c('darkblue','plum4','darkred')  
cairo_pdf('figs/pid_vids_2020.pdf',width=7,height=4)
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
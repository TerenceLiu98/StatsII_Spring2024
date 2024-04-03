library("FactoMineR")
library("ggplot2")
library("gridExtra")

# Read in the data
score <- read.table("/home/jovyan/data/youtube/score_subr_vid_crosst.csv", header=TRUE, row.names=1, sep=",")
counts <- read.table("/home/jovyan/data/youtube/counts_subr_vid_crosst.csv", header=TRUE, row.names=1, sep=",")
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
write.csv(df,"/home/jovyan/data/youtube/vid_ca.csv", row.names = TRUE)

# Output these scores for subreddits
subr_scores <- score_ca$col$coord[,"Dim 1"]
vid_counts <- colSums(bin_counts)
subr_df <- data.frame(ca_score=subr_scores,vid_count=vid_counts)
subr_df$subreddit <- rownames(subr_df)
write.csv(subr_df,"/home/jovyan/data/youtube/subreddit_ca.csv", row.names = FALSE)
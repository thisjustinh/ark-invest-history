library(tidyverse)

data <- read_csv("../fund-holdings/ARKK.csv")

benchmark <- "TSM"

comp_data <- data %>%
  mutate( # get rid of NA ticker
    ticker=ifelse(is.na(ticker), str_sub(company, end=4), ticker)
  ) %>%
  select(c(date, ticker, `weight(%)`)) %>%
  dplyr::group_by(date, ticker) %>%
  dplyr::summarise(weight = sum(`weight(%)`)) %>%  # sum different tickers
  spread(ticker, weight) %>%
  replace(is.na(.), 0) %>%
  ungroup() %>%
  select(-date) %>%
  select_if(~ !any(. == 0)) %>%  # drop any tickers with 0s 
  mutate(UNREPORTED = 0)

for(i in 1:nrow(comp_data)) {
  comp_data$UNREPORTED[i] = max(100 - rowSums(comp_data[i, ]), 0.01)  
}  #  scuffed; just trying to avoid dividebyzero

logratios <-
  comp_data %>%
  mutate_all(~ . / get(benchmark)) %>%  # ratio
  mutate_all(~ log(.)) %>% # log
  select(-benchmark)

logratios[logratios == -Inf] <- 0   # handle nonexistent holding

pr.out <- prcomp(logratios, center=TRUE, scale.=TRUE)
summary(pr.out)
ggbiplot(pr.out, scale=0)

pr.var <- pr.out$sdev^2
pve <- pr.var/sum(pr.var)

# Scree Plot
par(mfrow=c(1,2))

plot(pve, xlab="Principal Component", ylab="Proportion of Variance Explained", ylim=c(0,1),type="b")
plot(cumsum(pve), xlab="Principal Component", ylab="Cumulative Proportion of Variance Explained", ylim=c(0,1),type="b")

# Loadings plot
loadings <- pr.out$rotation
# when choosing "selected, ignore PC3 max because it's water again
selected <- loadings[c(which.max(loadings[,"PC1"]), which.min(loadings[,"PC1"]), which.max(loadings[,"PC2"]), which.min(loadings[,"PC2"])),c("PC1","PC2")]
selected <- as.data.frame(selected)

selected %>% ggplot(aes(x=PC1, y=PC2)) +
  geom_segment(aes(xend=PC1, yend=PC2), x=0, y=0) +
  geom_label(aes(x=PC1, y=PC2, label=row.names(selected)), size=3, vjust="outward")

# Biplot with emphasis on "selected" - https://nbisweden.github.io/Workshop_geneco_2020_05/docs/lab_pca_hmap.html
pca_full <- pr.out$x %>% 
  as.data.frame()

scale <- 10
pca_full %>%  ggplot(aes(x=PC1, y=PC2)) +
  geom_point() +
  geom_vline(xintercept=0, linetype=2) +
  geom_hline(yintercept=0, linetype=2) +
  geom_segment(data=selected, aes(xend=scale*PC1, yend=scale*PC2), x=0, y=0, color="cyan") +
  geom_label(data=selected, aes(x=scale*PC1, y=scale*PC2, label=row.names(selected)), size=3, vjust="outward")

# rownames(comp_data) <- comp_data$date
# comp_data <-
#   comp_data %>%
#   ungroup() %>%
#   select(-date) %>%
#   mutate(UNREPORTED = 0)

library(tidyverse)

data <- read_csv("../fund-holdings/ARKK.csv")

comp_data <-
  data %>%
  mutate( # get rid of NA ticker
    ticker=ifelse(is.na(ticker), str_sub(company, end=4), ticker)
  ) %>%
  select(c('date', 'ticker', 'weight(%)')) %>%
  group_by(date, ticker) %>%
  summarise(weight = sum(`weight(%)`)) %>%  # sum different tickers
  spread(ticker, weight) %>%
  replace(is.na(.), 0) %>%
  ungroup() %>%
  select(-date) %>%
  mutate(UNREPORTED = 0)

for(i in 1:nrow(comp_data)) {
  comp_data$UNREPORTED[i] = max(100 - rowSums(comp_data[i, ]), 0.01)  
}  #  scuffed; just trying to avoid dividebyzero

logratios <-
  comp_data %>%
  mutate(across(everything()), log(. / UNREPORTED)) %>%  # logratio
  select(-UNREPORTED)

logratios[logratios == -Inf] <- 0   # handle nonexistent holding

pr.out <- prcomp(logratios, center=TRUE, scale.=TRUE)
summary(pr.out)
ggbiplot(pr.out)

pr.var <- pr.out$sdev^2
pve <- pr.var/sum(pr.var)

par(mfrow=c(1,2))

plot(pve, xlab="Principal Component", ylab="Proportion of Variance Explained", ylim=c(0,1),type="b")
plot(cumsum(pve), xlab="Principal Component", ylab="Cumulative Proportion of Variance Explained", ylim=c(0,1),type="b")
  
# rownames(comp_data) <- comp_data$date
# comp_data <-
#   comp_data %>%
#   ungroup() %>%
#   select(-date) %>%
#   mutate(UNREPORTED = 0)
library(shiny)
library(tidyverse)

# Numbers hardcoded from Marketwatch
arkk_outstanding <- 171.15e06
arkq_outstanding <- 35.7e06
arkw_outstanding <- 44.2e06
arkg_outstanding <- 110.01e06
arkf_outstanding <- 56.05e06

# Relevant CSVs
arkk <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKK.csv")
arkq <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKQ.csv")
arkw <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKW.csv")
arkg <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKG.csv")
arkf <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKF.csv")
master <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/master.csv")

# Market Cap to Assets Data Frame
cap_to_assets <- master %>%
  mutate(date = as.Date(strptime(date, "%Y-%m-%d"))) %>%
  group_by(date, fund) %>%
  dplyr::summarize(reported_assets=sum(`market value($)`), weight=sum(`weight(%)`) / 100) %>%
  mutate(total_assets=reported_assets / weight) %>%
  inner_join(read_csv('https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/price-history/master.csv'), by=c('date', 'fund')) %>%
  mutate(market_cap=ifelse(fund == "ARKK", close * arkk_outstanding, NA)) %>%
  mutate(market_cap=ifelse(fund == "ARKQ", close * arkq_outstanding, market_cap)) %>%
  mutate(market_cap=ifelse(fund == "ARKW", close * arkw_outstanding, market_cap)) %>%
  mutate(market_cap=ifelse(fund == "ARKG", close * arkg_outstanding, market_cap)) %>%
  mutate(market_cap=ifelse(fund == "ARKF", close * arkf_outstanding, market_cap)) %>%
  mutate(market_cap_to_assets = market_cap / total_assets)

# Generate PCA for Compositional Data Biplot
comp.pca.biplot = function(data, benchmark) {
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
    mutate(UNREPORTED = 0)
  
  for(i in 1:nrow(comp_data)) {
    comp_data$UNREPORTED[i] = max(100 - rowSums(comp_data[i, ]), 0.01)  
  }  #  scuffed; just trying to avoid dividebyzero
  
  # logratios <- comp_data
  # for(col in colnames(logratios)) {
  #   logratios <- logratios %>%
  #     mutate(col = log(col / benchmark))
  # }
  # logratios %>% select(-benchmark)
  logratios <-
    comp_data %>%
    mutate_all(~ . / get(benchmark)) %>%
    mutate_all(~ log(.)) %>%
    select(-benchmark)
  
  logratios[logratios == -Inf] <- 0   # handle nonexistent holding
  
  pr.out <- prcomp(logratios, center=TRUE, scale.=TRUE)
  
  # Loadings plot
  loadings <- pr.out$rotation
  # when choosing "selected, ignore PC3 max because it's water again
  selected <- loadings[c(which.max(loadings[,"PC1"]), which.min(loadings[,"PC1"]), which.max(loadings[,"PC2"]), which.min(loadings[,"PC2"])),c("PC1","PC2")]
  selected <- as.data.frame(selected)
  
  # Biplot with emphasis on "selected" - https://nbisweden.github.io/Workshop_geneco_2020_05/docs/lab_pca_hmap.html
  pca_full <- pr.out$x %>% 
    as.data.frame()
  
  scale <- 10
  p <- pca_full %>%  
    ggplot(aes(x=PC1, y=PC2)) +
    geom_point() +
    geom_vline(xintercept=0, linetype=2) +
    geom_hline(yintercept=0, linetype=2) +
    geom_segment(data=selected, aes(xend=scale*PC1, yend=scale*PC2), x=0, y=0, color="cyan") +
    geom_label(data=selected, aes(x=scale*PC1, y=scale*PC2, label=row.names(selected)), size=3, vjust="outward")
  
  return(p)
}
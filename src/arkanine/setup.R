library(shiny)
library(tidyverse)

### PCA Functions ###

# Generate alr PCA
alr.pca.biplot <- function(comp.data, benchmark, viz) {
  logratios <-
    comp.data %>%
    mutate_all(~ . / get(benchmark)) %>%
    mutate_all(~ log(.)) %>%
    select(-benchmark)
  
  logratios[logratios == -Inf] <- 0   # handle nonexistent holding
  
  pr.out <- prcomp(logratios, center=TRUE, scale.=TRUE)
  
  return(pca.viz(pr.out, viz))
}

clr.pca.biplot <- function(comp.data, viz) {
  comp.mat <- as.matrix(comp.data)
  
  # y = (I_D - (1/D)J_D) log(X)
  D <- ncol(comp.mat)
  # clr.mat <- t((diag(D) - (1/D) * matrix(1, D, D)) %*% t(log(comp.mat))) %>%
  clr.mat <- log(comp.mat) %*% t((diag(D) - (1/D) * matrix(1, D, D)))%>%
    as.data.frame() %>%
    setNames(., colnames(comp.data))  # restore column names, though maybe no meaning
  
  pr.out <- prcomp(clr.mat, center=TRUE, scale.=TRUE)
  
  return(pca.viz(pr.out, viz))
}

# Egozcue et al. (2003)
ilr.pca.biplot <- function(comp.data, viz) {
  y <- log(as.matrix(comp.data))
  y <- y - rowMeans(y)
  k <- dim(y)[2]
  H <- contr.helmert(k)
  H <- t(H) / sqrt((2:k)*(2:k-1))
  z <- (y %*% t(H))
  colnames(z) <- colnames(comp.data)[-1]
  # z <- loop.ilr(comp.data)
  
  pr.out <- prcomp(z, center=TRUE, scale.=TRUE)
  
  return(pca.viz(pr.out, viz))
  
}

loop.ilr <- function(comp.data) {
  z <- matrix(NA, nrow(comp.data), ncol(comp.data) - 1)
  comp.data <- as.data.frame(comp.data)
  for (n in 1:nrow(comp.data)) {
    for (i in 1:ncol(comp.data) - 1) {
      z[n, i] <- 
        sqrt(i / (i + 1)) * log(prod(comp.data[n, 1:i])^(1 / i) / comp.data[n,i + 1])
    }
  }
  colnames(z) <- colnames(comp.data)[-1]  # again, not sure about the meaning
  
  return(z)
}

helmert.ilr <- function(comp.data) {
  y <- log(comp.data)
  y <- y - rowMeans(y)
  k <- dim(y)[2]
  H <- contr.helmert(k)
  H <- t(H) / sqrt((2:k)*(2:k-1))
  return(y %*% t(H))
}

### Helper PCA Functions ###

process.comp <- function(df) {
  comp_data <- df %>%
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
  
  return(comp_data)
}

pca.viz <- function(pca.out, viz) {
  if (viz == 1) {
    # Loadings plot
    loadings <- pca.out$rotation
    # when choosing "selected, ignore PC3 max because it's water again
    selected <- loadings[c(which.max(loadings[,"PC1"]), which.min(loadings[,"PC1"]), which.max(loadings[,"PC2"]), which.min(loadings[,"PC2"])),c("PC1","PC2")]
    selected <- as.data.frame(selected)
    
    # Biplot with emphasis on "selected" - https://nbisweden.github.io/Workshop_geneco_2020_05/docs/lab_pca_hmap.html
    pca_full <- pca.out$x %>% 
      as.data.frame()
    
    scale <- 10
    p <- pca_full %>%  
      ggplot(aes(x=PC1, y=PC2)) +
      geom_point() +
      geom_vline(xintercept=0, linetype=2) +
      geom_hline(yintercept=0, linetype=2) +
      geom_segment(data=selected, aes(xend=scale*PC1, yend=scale*PC2), x=0, y=0, color="cyan") +
      geom_label(data=selected, aes(x=scale*PC1, y=scale*PC2, label=row.names(selected)), size=3, vjust="outward")
  } else if (viz == 2) {
    p <- ggbiplot(pca.out, scale=0)
    # p <- ggbiplot(pca.out)
  } else if (viz == 3) {
    pr.var <- pca.out$sdev^2
    pve <- pr.var/sum(pr.var)
    scree <- data.frame(PC=1:ncol(pca.out$x), Variance=pve, Type="Variance") %>%
      rbind(data.frame(PC=1:ncol(pca.out$x), Variance=cumsum(pve), Type="Cumulative"))
    
    p <- ggplot(scree, aes(x=PC, y=Variance, group=1)) +
      geom_point() +
      geom_line() +
      facet_wrap(~ Type) +
      theme(axis.text.x=element_blank())
  }
  return(p)
}


### Datasets and Constants ###

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

# Comp data dfs
arkk.comp <- process.comp(arkk)
arkq.comp <- process.comp(arkq)
arkw.comp <- process.comp(arkw)
arkg.comp <- process.comp(arkg)
arkf.comp <- process.comp(arkf)

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

library(shiny)
library(tidyverse)
library(elasticnet)
library(robCompositions)

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
  z <- helmert.ilr(comp.data)
  
  pr.out <- prcomp(z, center=TRUE, scale.=TRUE)
  
  return(pca.viz(pr.out, viz))
}

# TODO: Add support for other PCA transformations
spca.comp <- function(comp.data, comp="ILR") {
  z <- helmert.ilr(comp.data)
  z <- scale(z)
  l.norm <- rep(1e-03, 5)
  spr.out <- spca(z, K=5, type="predictor", sparse="penalty", para=l.norm)
  return(spr.out)
}

robust.ilr.biplot <- function(comp.data, viz) {
  res.rob <- pcaCoDa(as.matrix(comp.data))
  
  if (viz == 1) {
    loadings <- res.rob$loadings
    p <- ggplot(as.data.frame(loadings), aes(x=Comp.1, y=Comp.2)) +
      geom_point() +
      geom_segment(aes(xend=Comp.1, yend=Comp.2), x=0, y=0, color="Maroon") +
      geom_label(aes(x=Comp.1, y=Comp.2, label=row.names(loadings)), size=2, vjust="outward")
  } else if (viz == 2) {
    loadings <- res.rob$loadings
    # when choosing "selected, ignore PC3 max because it's water again
    selected <- loadings[c(which.max(loadings[,"Comp.1"]), which.min(loadings[,"Comp.1"]), which.max(loadings[,"Comp.2"]), which.min(loadings[,"Comp.2"])),c("Comp.1","Comp.2")]
    selected <- as.data.frame(selected)
    
    # Biplot with emphasis on "selected" - https://nbisweden.github.io/Workshop_geneco_2020_05/docs/lab_pca_hmap.html
    pca_full <- res.rob$scores %>% 
      as.data.frame()
    
    scale <- 10
    p <- pca_full %>%  
      ggplot(aes(x=Comp.1, y=Comp.2)) +
      geom_point() +
      geom_vline(xintercept=0, linetype=2) +
      geom_hline(yintercept=0, linetype=2) +
      geom_segment(data=selected, aes(xend=scale*Comp.1, yend=scale*Comp.2), x=0, y=0, color="cyan") +
      geom_label(data=selected, aes(x=scale*Comp.1, y=scale*Comp.2, label=row.names(selected)), size=3, vjust="outward")
  } else if (viz == 3) {
    p <- biplot(res.rob, scale=0)
  } else if (viz == 4) {
    p <- "Oops, not supported yet!"
    # pr.var <- res.rob$sdev^2
    # pve <- pr.var/sum(pr.var)
    # scree <- data.frame(PC=1:ncol(pca.out$x), Variance=pve, Type="Variance") %>%
    #   rbind(data.frame(PC=1:ncol(pca.out$x), Variance=cumsum(pve), Type="Cumulative"))
    # 
    # p <- ggplot(scree, aes(x=PC, y=Variance, group=1)) +
    #   geom_point() +
    #   geom_line() +
    #   facet_wrap(~ Type) +
    #   theme(axis.text.x=element_blank())
  }
}

### Helper PCA Functions ###

helmert.ilr <- function(comp.data) {
  y <- log(as.matrix(comp.data))
  y <- y - rowMeans(y)
  k <- dim(y)[2]
  H <- contr.helmert(k)
  H <- t(H) / sqrt((2:k)*(2:k-1))
  z <- (y %*% t(H))
  colnames(z) <- colnames(comp.data)[-1]
  return(z)
}

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
    loadings <- pca.out$rotation
    p <- ggplot(as.data.frame(loadings), aes(x=PC1, y=PC2)) +
      geom_point() +
      geom_segment(aes(xend=PC1, yend=PC2), x=0, y=0, color="Maroon") +
      geom_label(aes(x=PC1, y=PC2, label=row.names(loadings)), size=2, vjust="outward")
  } else if (viz == 2) {
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
  } else if (viz == 3) {
    p <- ggbiplot(pca.out, scale=0)
    # p <- ggbiplot(pca.out)
  } else if (viz == 4) {
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

spca.viz <- function(comp.data, viz) {
  spr.out <- spca.comp(comp.data)
  if (viz == 1) {
    loadings <- spr.out$loadings
    p <- ggplot(as.data.frame(loadings), aes(x=PC1, y=PC2)) +
      geom_point() +
      geom_segment(aes(xend=PC1, yend=PC2), x=0, y=0, color="Grey") +
      geom_label(aes(x=PC1, y=PC2, label=row.names(loadings)), size=2, vjust="outward")
  } else if (viz == 4) {
    scree <- data.frame(PC=1:ncol(spr.out$loadings), Variance=spr.out$pev, Type="Variance") %>%
      rbind(data.frame(PC=1:ncol(spr.out$loadings), Variance=cumsum(spr.out$pev), Type="Cumulative"))
    p <- ggplot(scree, aes(x=PC, y=Variance, group=1)) +
      geom_point() + 
      geom_line() +
      facet_wrap(~ Type) +
      theme(axis.text.x=element_blank())
  } else {
    p <- "Only loadings plot and scree plot are supported."
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
arkx_outstanding <- 33.4e06

# Relevant CSVs
arkk <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKK.csv")
arkq <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKQ.csv")
arkw <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKW.csv")
arkg <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKG.csv")
arkf <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKF.csv")
arkx <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/ARKX.csv")
master <- read_csv("https://raw.githubusercontent.com/xinging-birds/ark-invest-history/master/fund-holdings/master.csv")

# Comp data dfs
arkk.comp <- process.comp(arkk)
arkq.comp <- process.comp(arkq)
arkw.comp <- process.comp(arkw)
arkg.comp <- process.comp(arkg)
arkf.comp <- process.comp(arkf)
arkx.comp <- process.comp(arkx)

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
  mutate(market_cap=ifelse(fund == "ARKX", close * arkx_outstanding, market_cap)) %>%
  mutate(market_cap_to_assets = market_cap / total_assets) %>%
  filter(market_cap_to_assets < 2)  # anything above 2 is consider outlier

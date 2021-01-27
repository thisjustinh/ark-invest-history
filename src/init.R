library(tidyverse)
library(readxl)

setwd("~/Development/ark-transactions")

options(scipen=999)

arkk <- read_excel("~/Downloads/ark_1_19_20.xlsx", 
                   sheet = "ARKK")
arkq <- read_excel("~/Downloads/ark_1_19_20.xlsx", 
                   sheet = "ARKQ")
arkw <- read_excel("~/Downloads/ark_1_19_20.xlsx", 
                   sheet = "ARKW")
arkg <- read_excel("~/Downloads/ark_1_19_20.xlsx", 
                   sheet = "ARKG")
arkf <- read_excel("~/Downloads/ark_1_19_20.xlsx", 
                   sheet = "ARKF")

trans <- read_excel("~/Downloads/ark_1_19_20.xlsx", 
                    sheet = "transactions", col_types = c("date", 
                                                          "text", "text", "text", "numeric", 
                                                          "text", "numeric", "numeric", "numeric", 
                                                          "text", "text", "numeric", "numeric", 
                                                          "numeric", "text"))

arkk$`market value($)`=as.numeric(gsub("[$,m]", "", arkk$`market value($)`)) * 1000000
arkq$`market value($)`=as.numeric(gsub("[$,m]", "", arkq$`market value($)`))* 1000000
arkw$`market value($)`=as.numeric(gsub("[$,m]", "", arkw$`market value($)`))* 1000000
arkg$`market value($)`=as.numeric(gsub("[$,m]", "", arkg$`market value($)`))* 1000000
arkf$`market value($)`=as.numeric(gsub("[$,m]", "", arkf$`market value($)`))* 1000000

arkk$`weight(%)` = arkk$`weight(%)`*100
arkq$`weight(%)` = arkq$`weight(%)`*100
arkw$`weight(%)` = arkw$`weight(%)`*100
arkg$`weight(%)` = arkg$`weight(%)`*100
arkf$`weight(%)` = arkf$`weight(%)`*100


arkk$date = as.character(format(arkk$date, format="%m/%d/%Y"))
arkq$date = as.character(format(arkq$date, format="%m/%d/%Y"))
arkw$date = as.character(format(arkw$date, format="%m/%d/%Y"))
arkg$date = as.character(format(arkg$date, format="%m/%d/%Y"))
arkf$date = as.character(format(arkf$date, format="%m/%d/%Y"))

trans$date = as.character(format(trans$date, format="%m/%d/%Y"))

trans$value=as.numeric(gsub("[,$m]", "", trans$value))
trans$flowValue=as.numeric(gsub("[,$m]", "", trans$flowValue))
trans$deltaValue=as.numeric(gsub("[,$m]", "", trans$deltaValue))

for(i in c(1:nrow(trans))) {
  if(trans$shares[i] == 0) {
    trans$action[i] <- "Exit"
  } else if (trans$value[i] == trans$flowValue[i] && trans$flowValue[i] == trans$deltaValue[i]) {
    trans$action[i] <- "Enter"
  } else if (trans$deltaShares[i] < 0) {
    trans$action[i] <- "Sell"
  } else {
    trans$action[i] <- "Buy"
  }
}

master <- read_csv("fund-holdings/master copy.csv", col_types = cols(date = col_character()))
master$date[1:10086] <- as.character(format(as.Date(master$date[1:10086]), "%m/%d/%Y"))

export <- rbind(master, trans)

write_csv(export, "transactions/master.csv")
write_csv(arkk, "fund-holdings/ARKK.csv")
write_csv(arkq, "fund-holdings/ARKQ.csv")
write_csv(arkw, "fund-holdings/ARKW.csv")
write_csv(arkg, "fund-holdings/ARKG.csv")
write_csv(arkf, "fund-holdings/ARKF.csv")

arkk %>% 
  filter(arkk$date == "01/25/2021") %>%
  write_csv("fund-holdings/latestARKK.csv")

arkq %>% 
  filter(arkq$date == "01/25/2021") %>%
  write_csv("fund-holdings/latestARKQ.csv")

arkw %>% 
  filter(arkw$date == "01/25/2021") %>%
  write_csv("fund-holdings/latestARKW.csv")

arkg %>% 
  filter(arkg$date == "01/25/2021") %>%
  write_csv("fund-holdings/latestARKG.csv")

arkf %>% 
  filter(arkf$date == "01/25/2021") %>%
  write_csv("fund-holdings/latestARKF.csv")

arkk %>%
  rbind(arkq, arkw, arkg, arkf) %>%
  arrange(date) %>%
  write_csv("fund-holdings/master.csv")

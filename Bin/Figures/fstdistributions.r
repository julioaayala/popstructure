#------------------------------------------------------------
# Julio Ayala
# Created on: May 2021
# Description: Script to create plots of FST distributions
# for Italian sparrow population pairs based on result analysis from ANGSD
# Note: Before running, set the working directory to the root of the project
#------------------------------------------------------------

rm(list = ls())
library(tidyverse)
library(data.table)  

setwd("Results/05_Fst/")
## FST Distributions
pairs <- data.frame(pair = c('II', 'IM', 'IM', 'IP', 'II', 'IM', 'II', 'IP', 'IM',
                             'IM', 'IP', 'II', 'IM', 'II', 'IP', 'MM', 'MP', 'IM',
                             'MM', 'IM', 'MP', 'MP', 'IM', 'MM', 'IM', 'MP', 'IP',
                             'MP', 'IP', 'PP', 'IM', 'II', 'IP', 'IM', 'MP', 'IP'), 
                    site = c('corsica.crete', 'corsica.crotone', 'corsica.guglionesi',
                             'corsica.house', 'corsica.malta', 'corsica.rimini',
                             'corsica.sicily', 'corsica.spanish', 'crete.crotone',
                             'crete.guglionesi', 'crete.house', 'crete.malta',
                             'crete.rimini', 'crete.sicily', 'crete.spanish',
                             'crotone.guglionesi', 'crotone.house', 'crotone.malta',
                             'crotone.rimini', 'crotone.sicily', 'crotone.spanish',
                             'guglionesi.house', 'guglionesi.malta', 'guglionesi.rimini',
                             'guglionesi.sicily', 'guglionesi.spanish', 'house.malta',
                             'house.rimini', 'house.sicily', 'house.spanish',
                             'malta.rimini', 'malta.sicily', 'malta.spanish',
                             'rimini.sicily', 'rimini.spanish', 'sicily.spanish'))

read_csv_filename <- function(filename){
  df <- read.csv(filename, sep = "\t")
  names(df) <- c("chr", "midPos", "Nsites", "FST")
  df$pos <- NULL
  df$site <- filename
  df$site <- gsub(".chrz\\..*","",df$site)
  df$site <- gsub(".autosomes\\..*","",df$site)
  df <- merge(df, pairs, by = "site")
  return(df)
}

files = list.files(pattern = "*.windowed")
temp <- lapply(files, read_csv_filename)
df <- rbindlist(temp)
df$chrgroup = ifelse(df$chr=="chrZ", "Z chromosome", "Autosomes")
df <- df[df$pair %in% c("II", "IM", "MM"),]
chrz <- df[df$pair %in% c("II", "IM", "MM") & df$chr == "chrZ",]
autosomes <- df[df$pair %in% c("II", "IM", "MM") & df$chr != "chrZ" & !grepl("scaffold", df$chr),]


p <- ggplot(df, aes(x=pair, y = FST, color = chrgroup))+
  geom_boxplot( outlier.size = 0.5) +
  labs(color="Population group") +
  xlab("Population group") +
  ggtitle("FST by italian sparrow population group pairs") +
  scale_x_discrete(labels=c("II" = "Island-Island", "IM" = "Island-Mainland",
                            "MM" = "Mainland-Mainland"))+
  theme_bw() +
  theme(plot.title = element_text(size = 12),
      legend.title = element_blank(), 
      legend.direction = "horizontal",
      legend.position = "bottom")
print(p)


setwd("../../")

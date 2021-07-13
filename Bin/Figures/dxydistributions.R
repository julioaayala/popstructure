#------------------------------------------------------------
# Julio Ayala
# Created on: May 2021
# Description: Script to create plots of Dxy
# for Italian sparrow populations pairs
# Note: Before running, set the working directory to the root of the project
#------------------------------------------------------------

rm(list = ls())
library(tidyverse)
library(data.table)  
setwd("Results/03_Dxy/Mafs")
## Dxy Distributions
pairs <- data.frame(pair = c('II', 'IM', 'IM', 'IP', 'II', 'IM', 'II', 'IP', 'IM',
                             'IM', 'IP', 'II', 'IM', 'II', 'IP', 'MM', 'MP', 'IM',
                             'MM', 'IM', 'MP', 'MP', 'IM', 'MM', 'IM', 'MP', 'IP',
                             'MP', 'IP', 'PP', 'IM', 'II', 'IP', 'IM', 'MP', 'IP'), 
                    site = c('corsica_vs_crete', 'corsica_vs_crotone', 'corsica_vs_guglionesi',
                             'corsica_vs_house', 'corsica_vs_malta', 'corsica_vs_rimini',
                             'corsica_vs_sicily', 'corsica_vs_spanish', 'crete_vs_crotone',
                             'crete_vs_guglionesi', 'crete_vs_house', 'crete_vs_malta',
                             'crete_vs_rimini', 'crete_vs_sicily', 'crete_vs_spanish',
                             'crotone_vs_guglionesi', 'crotone_vs_house', 'crotone_vs_malta',
                             'crotone_vs_rimini', 'crotone_vs_sicily', 'crotone_vs_spanish',
                             'guglionesi_vs_house', 'guglionesi_vs_malta', 'guglionesi_vs_rimini',
                             'guglionesi_vs_sicily', 'guglionesi_vs_spanish', 'house_vs_malta',
                             'house_vs_rimini', 'house_vs_sicily', 'house_vs_spanish',
                             'malta_vs_rimini', 'malta_vs_sicily', 'malta_vs_spanish',
                             'rimini_vs_sicily', 'rimini_vs_spanish', 'sicily_vs_spanish'))

read_csv_filename <- function(filename){
  df <- read.csv(filename, sep = "\t", fill = TRUE)
  df <- df[-c(6)] # Remove N
  df$site <- filename
  df$site <- gsub(".dxy\\.*","",df$site)
  df <- merge(df, pairs, by = "site")
  return(df)
}

files = list.files(pattern = "*.dxy")
temp <- lapply(files, read_csv_filename)
df <- rbindlist(temp)

df <- df[df$chrom != "mtDNA",]
df$chrgroup = ifelse(df$chrom=="chrZ", "Z chromosome", "Autosomes")
fulldf <- df
df <- df[df$pair %in% c("II", "IM", "MM"),]
chrz <- df[df$pair %in% c("II", "IM", "MM") & df$chrom == "chrZ",]
autosomes <- df[df$pair %in% c("II", "IM", "MM") & df$chrom != "chrZ" & !grepl("scaffold", df$chr),]


p <- ggplot(df, aes(x=pair, y = dxy, color = chrgroup))+
  geom_boxplot( outlier.size = 0.5) +
  labs(color="Population group") +
  xlab("Population group") +
  ylab("Dxy")+
  ggtitle("Dxy by italian sparrow population group pairs in 100-kb windows") +
  scale_x_discrete(labels=c("II" = "Island-Island", "IM" = "Island-Mainland",
                            "MM" = "Mainland-Mainland"))+
  theme_bw() +
  theme(plot.title = element_text(size = 12),
        legend.title = element_blank(), 
        legend.direction = "horizontal",
        legend.position = "bottom", axis.text.x = element_text(size = 12))+
  xlab(element_blank())
print(p)

setwd("../../")

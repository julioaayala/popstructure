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
library(cowplot)
library(grid)

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
  df$site <- gsub(".chrZ\\..*","",df$site)
  df$site <- gsub(".autosomes\\..*","",df$site)
  df <- merge(df, pairs, by = "site")
  return(df)
}

filesfst = list.files(pattern = "*.windowed")

temp <- lapply(filesfst, read_csv_filename)
dffst <- rbindlist(temp)
dffst$chrgroup = ifelse(dffst$chr=="chrZ", "Z chromosome", "Autosomes")
dffst <- dffst[dffst$pair %in% c("II", "IM", "MM"),]
dffst <- dffst[dffst$pair %in% c("II", "MM"),]
dffst$posMb <- as.integer(dffst$midPos/1000000)
chrz <- dffst[dffst$pair %in% c("II", "IM", "MM") & dffst$chr == "chrZ",]
autosomes <- dffst[dffst$pair %in% c("II", "IM", "MM") & dffst$chr != "chrZ" & !grepl("scaffold", dffst$chr),]
dffst$chr <- factor(dffst$chr, levels = c("chr1", "chr1A", "chr2", "chr3", 
                                              "chr4", "chr5", "chr6", "chr7", 
                                              "chr8", "chr9", "chr10", "chr11", 
                                              "chr12", "chr13", "chr14", "chr15",
                                              "chr17", "chr18", "chr19", "chr20", 
                                              "chr21", "chr22", "chr23", "chr24", 
                                              "chr25", "chr27", "chr28", "chrZ"))

avgfst <-  dffst %>% 
  group_by(posMb, pair, chr) %>%
  summarise(FST = mean(FST))

fstregions <- list()
chrindex <- 1
for (chromosome in levels(factor(dffst$chr))){
  temp <- dffst %>% 
    filter(chr == chromosome) %>%
    group_by(pair, posMb) %>%
    summarise(FST = mean(FST))
  p <- ggplot(temp, aes(x = posMb, y = FST, color = pair)) + 
    geom_line() +
    labs(color="Population group") +
    ggtitle(str_to_title(chromosome)) +
    theme_bw() +
    theme(plot.title = element_text(size = 12),
          legend.title = element_blank(), 
          legend.direction = "horizontal",
          legend.position = "none",
          axis.title.x=element_blank(),
          axis.text.x=element_blank())
  fstregions[[chrindex]] <- p
  chrindex <- chrindex + 1
}


allfst <- ggplot(avgfst) +
  geom_line(aes(x = posMb, y = FST, color = pair)) +
  theme_bw() +
  facet_grid(. ~ chr, space="free_x", scales="free_x", switch="x") +
  theme(plot.title = element_text(size = 12),
        legend.title = element_blank(), 
        legend.direction = "horizontal",
        legend.position = "bottom",
        axis.text.x = element_blank(),
        strip.placement = "outside",
        strip.background = element_rect(fill=NA, colour="grey50"),
        panel.spacing.x=unit(0,"cm"),
        panel.border = element_rect(colour = "grey60", fill=NA, size=1)) +
        xlab("Chromosome") +
        scale_color_discrete(name = "Pairs", labels = c("Islands", "Mainland"))


## Print all groups
setwd("../../")

######### Dxy
setwd("Results/03_Dxy/Mafs")
## FST Distributions
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

read_csv_filename_dxy <- function(filename){
  df <- read.csv(filename, sep = "\t", fill = TRUE)
  df <- df[-c(6)] # Remove N
  df$site <- filename
  df$site <- gsub(".dxy\\.*","",df$site)
  df <- merge(df, pairs, by = "site")
  return(df)
}

filesdxy = list.files(pattern = "*.dxy")

temp <- lapply(filesdxy, read_csv_filename_dxy)
dfdxy <- rbindlist(temp)
dfdxy$chrgroup = ifelse(dfdxy$chrom=="chrZ", "Z chromosome", "Autosomes")
# dfdxy <- dfdxy[dfdxy$pair %in% c("II", "IM", "MM"),]
dfdxy <- dfdxy[dfdxy$pair %in% c("II", "MM"),]
dfdxy$posMb <- as.integer( ((dfdxy$end + dfdxy$start)/2)/1000000)
dfdxy$chr <- factor(dfdxy$chrom, levels = c("chr1", "chr1A", "chr2", "chr3", 
                                          "chr4", "chr5", "chr6", "chr7", 
                                          "chr8", "chr9", "chr10", "chr11", 
                                          "chr12", "chr13", "chr14", "chr15",
                                          "chr17", "chr18", "chr19", "chr20", 
                                          "chr21", "chr22", "chr23", "chr24", 
                                          "chr25", "chr27", "chr28", "chrZ"))

avgdxy <-  dfdxy %>% 
  group_by(posMb, pair, chr) %>%
  summarise(Dxy = mean(dxy))

dxyregions <- list()
chrindex <- 1
for (chromosome in levels(factor(dfdxy$chr))){
  temp <- dfdxy %>% 
    filter(chr == chromosome) %>%
    group_by(pair, posMb) %>%
    summarise(Dxy = mean(dxy))
  p <- ggplot(temp, aes(x = posMb, y = Dxy, color = pair)) + 
    geom_line() +
    labs(color="Population group") +
    ggtitle(str_to_title(chromosome)) +
    theme_bw() +
    theme(plot.title = element_text(size = 12),
          legend.title = element_blank(), 
          legend.direction = "horizontal",
          legend.position = "none",
          axis.title.x=element_blank(),
          axis.text.x=element_blank())
  dxyregions[[chrindex]] <- p
  chrindex <- chrindex + 1
}


alldxy <- ggplot(avgdxy) +
  geom_line(aes(x = posMb, y = Dxy, color = pair)) +
  theme_bw() +
  facet_grid(. ~ chr, space="free_x", scales="free_x", switch="x") +
  theme(plot.title = element_text(size = 12),
        legend.title = element_blank(), 
        legend.direction = "horizontal",
        legend.position = "bottom",
        axis.text.x = element_blank(),
        strip.placement = "outside",
        strip.background = element_rect(fill=NA, colour="grey50"),
        panel.spacing.x=unit(0,"cm"),
        panel.border = element_rect(colour = "grey60", fill=NA, size=1)) +
  xlab("Chromosome") +
  scale_color_discrete(name = "Pairs", labels = c("Islands", "Mainland"))

## Print all groups
setwd("../../../")

######### Thetas (Tajima's, Pi)
setwd("Results/04_Theta/")
## Read from file
read_csv_filename_pestPG <- function(filename){
  ret <- read.csv(filename, sep = "\t")
  ret$site <- gsub("\\..*","",filename)
  ret
}


## open all files and group
files = list.files(pattern = "*.pestPG")
temp <- lapply(files, read_csv_filename_pestPG)
dfThetas <- rbindlist(temp)
dfThetas$Chr <- factor(dfThetas$Chr, levels = c("chr1", "chr1A", "chr2", "chr3", 
                                          "chr4", "chr5", "chr6", "chr7", 
                                          "chr8", "chr9", "chr10", "chr11", 
                                          "chr12", "chr13", "chr14", "chr15",
                                          "chr17", "chr18", "chr19", "chr20", 
                                          "chr21", "chr22", "chr23", "chr24", 
                                          "chr25", "chr27", "chr28", "chrZ"))

#Separate autosomes and chr z
autosomesdf <- dfThetas[dfThetas$Chr!="chrZ",]
chrzdf <- dfThetas[dfThetas$Chr=="chrZ",]
dfThetas$type <- ifelse(dfThetas$Chr=="chrZ", "Z Chromosome", "Autosomes")
dfThetas$posMb <- as.integer(dfThetas$WinCenter/1000000)



## Density distributions

colors <- c("#fb9a99", "#cab2d6", "#a6cee3", "#1f78b4", "#e31a1c", "#ff7f00", "#b2df8a", "#33a02c", "#fdbf6f")
populations <- c("house","spanish", "corsica", "crete", "malta", "sicily", "crotone", "guglionesi", "rimini")

tajimasregions <- list()
piregions <- list()
chrindex <- 1
for (chromosome in levels(factor(dfThetas$Chr))){
  temp <- dfThetas %>% 
    filter(Chr == chromosome) %>%
    group_by(posMb, site) %>%
    summarise(Tajima = mean(Tajima), Pi = mean(tP/nSites))
  p <- ggplot(temp, aes(x = posMb, y = Tajima, color = site)) + 
    geom_line() +
    labs(color="Population") +
    ggtitle(element_blank()) +
    theme_bw() +
    theme(plot.title = element_text(size = 12),
          legend.title = element_blank(), 
          legend.direction = "horizontal",
          legend.position = "bottom",
          axis.text.x = element_text(size = 12)) + 
    guides(colour = guide_legend(nrow = 1))

  p2 <- ggplot(temp, aes(x = posMb, y = Pi, color = site)) + 
    geom_line() +
    labs(color="Population") +
    ggtitle(element_blank()) +
    theme_bw() +
    theme(plot.title = element_text(size = 12),
          legend.title = element_blank(), 
          legend.direction = "horizontal",
          legend.position = "none",
          axis.title.x=element_blank(),
          axis.text.x=element_blank())
  tajimasregions[[chrindex]] <- p
  piregions[[chrindex]] <- p2
  chrindex <- chrindex + 1
}


plotlegend <- get_legend(tajimasregions[[1]])
for (i in 1:length(tajimasregions)) {
  tajimasregions[[i]] <- tajimasregions[[i]] + theme(legend.position="none", axis.title.x = element_blank())  
}


pdf("../../variationByChromosome.pdf")
for (i in 1:length(tajimasregions)) {
  pg <- plot_grid(fstregions[[i]], dxyregions[[i]], piregions[[i]], tajimasregions[[i]],
                  bottom = textGrob("Position (MB)"), 
                  plotlegend, 
                  ncol = 1,
                  rel_heights = c(0.95, 0.95, 0.95, 0.95, 0.1, 0.15))
  print(pg)  
}

dev.off()

pdf("../../fstGenome.pdf", width = 16, height = 9)
print(allfst)
dev.off()

pdf("../../dxyGenome.pdf", width = 16, height = 9)
print(alldxy)
dev.off()

setwd("../../")





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


### From https://stackoverflow.com/questions/35717353/split-violin-plot-with-ggplot2
GeomSplitViolin <- ggproto("GeomSplitViolin", GeomViolin, 
                           draw_group = function(self, data, ..., draw_quantiles = NULL) {
                             data <- transform(data, xminv = x - violinwidth * (x - xmin), xmaxv = x + violinwidth * (xmax - x))
                             grp <- data[1, "group"]
                             newdata <- plyr::arrange(transform(data, x = if (grp %% 2 == 1) xminv else xmaxv), if (grp %% 2 == 1) y else -y)
                             newdata <- rbind(newdata[1, ], newdata, newdata[nrow(newdata), ], newdata[1, ])
                             newdata[c(1, nrow(newdata) - 1, nrow(newdata)), "x"] <- round(newdata[1, "x"])
                             
                             if (length(draw_quantiles) > 0 & !scales::zero_range(range(data$y))) {
                               stopifnot(all(draw_quantiles >= 0), all(draw_quantiles <=
                                                                         1))
                               quantiles <- ggplot2:::create_quantile_segment_frame(data, draw_quantiles)
                               aesthetics <- data[rep(1, nrow(quantiles)), setdiff(names(data), c("x", "y")), drop = FALSE]
                               aesthetics$alpha <- rep(1, nrow(quantiles))
                               both <- cbind(quantiles, aesthetics)
                               quantile_grob <- GeomPath$draw_panel(both, ...)
                               ggplot2:::ggname("geom_split_violin", grid::grobTree(GeomPolygon$draw_panel(newdata, ...), quantile_grob))
                             }
                             else {
                               ggplot2:::ggname("geom_split_violin", GeomPolygon$draw_panel(newdata, ...))
                             }
                           })

geom_split_violin <- function(mapping = NULL, data = NULL, stat = "ydensity", position = "identity", ..., 
                              draw_quantiles = TRUE, trim = TRUE, scale = "area", na.rm = FALSE, 
                              show.legend = NA, inherit.aes = TRUE) {
  layer(data = data, mapping = mapping, stat = stat, geom = GeomSplitViolin, 
        position = position, show.legend = show.legend, inherit.aes = inherit.aes, 
        params = list(trim = trim, scale = scale, draw_quantiles = draw_quantiles, na.rm = na.rm, ...))
}

###

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
df <- df[df$pair %in% c("II", "MM"),]
chrz <- df[df$pair %in% c("II", "IM", "MM") & df$chr == "chrZ",]
autosomes <- df[df$pair %in% c("II", "IM", "MM") & df$chr != "chrZ" & !grepl("scaffold", df$chr),]


ggplot(df, aes(chrgroup, FST, fill = pair)) + geom_split_violin() +
  labs(color="Population group") +
  xlab("Population group") +
  ggtitle("FST by italian sparrow population group pairs") +
  theme_bw() +
  theme(plot.title = element_text(size = 12),
        legend.title = element_blank(), 
        legend.direction = "horizontal",
        legend.position = "bottom",
        axis.text.x = element_text(size = 12))


setwd("../../")

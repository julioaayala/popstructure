#------------------------------------------------------------
# Julio Ayala
# Created on: May 2021
# Description: Script to create plots of Tajima's D distributions
# for Italian sparrow population based on thetas Analysis from ANGSD
# Note: Before running, set the working directory to the root of the project
#------------------------------------------------------------
rm(list = ls())
library(tidyverse)
library(data.table)  
library(cowplot)
library(grid)

setwd("Results/04_Theta/")
## Read from file
read_csv_filename <- function(filename){
  ret <- read.csv(filename, sep = "\t")
  ret$site <- gsub("\\..*","",filename)
  ret
}


## open all files and group
files = list.files(pattern = "*.pestPG")
temp <- lapply(files, read_csv_filename)
df <- rbindlist(temp)

#Separate autosomes and chr z
autosomesdf <- df[df$Chr!="chrZ",]
chrzdf <- df[df$Chr=="chrZ",]
df$type <- ifelse(df$Chr=="chrZ", "Z Chromosome", "Autosomes")

## Tajima's D boxplot
t <- ggplot(df, aes(x = site, y = Tajima, color = type)) +
  geom_boxplot( outlier.size = 0.5) +
  ggtitle("Tajima's D distribution of 100-kb windows") +
  theme_bw() +
  theme(plot.title = element_text(size = 12),
        legend.title = element_blank(), 
        legend.direction = "horizontal",
        legend.position = "bottom",
        axis.text.x = element_text(size = 12)) +
  scale_x_discrete(limits=c("house","spanish",
                            "corsica", "crete", "malta", "sicily",
                            "crotone", "guglionesi", "rimini"),
                   labels=c("House","Spanish",
                            "Corsica", "Crete", "Malta", "Sicily",
                            "Crotone", "Guglionesi", "Rimini")) +
  xlab(element_blank())
print(t)

## Density distributions
density_plots <- list()
colors <- c("#fb9a99", "#cab2d6", "#a6cee3", "#1f78b4", "#e31a1c", "#ff7f00", "#b2df8a", "#33a02c", "#fdbf6f")
populations <- c("house","spanish", "corsica", "crete", "malta", "sicily", "crotone", "guglionesi", "rimini")
populations2 <- c(
  "house \nA:0.05243; Z:0.07870",
  "spanish \nA:-0.30463; Z:0.29069",
  "corsica \nA:-0.00663; Z:0.56125",
  "crete \nA:0.17773 ±; Z:0.31415",
  "malta \nA:-0.02135; Z:0.20169",
  "sicily \nA:-0.26238; Z:0.19086",
  "crotone \nA:-0.17396; Z:0.24187",
  "guglionesi \nA:-0.15184; Z:0.32074",
  "rimini \nA:-0.10783; Z:0.29392")
for (i in 1:9) {
  tmp <- autosomesdf[autosomesdf$site == populations[i],]
  tmp$type <- "Autosomes"
  tmp2 <- chrzdf[chrzdf$site == populations[i],]
  tmp2$type <- "Z Chromosome"
  tmp <- rbind(tmp, tmp2)
  tmpplot <- ggplot(tmp, aes(Tajima, color = type, fill = type)) +
    geom_density(alpha = 0.5) +
    ggtitle(str_to_title(populations2[i])) +
    xlab("Tajima's D") +
    theme_bw() +
    theme(plot.title = element_text(size = 10),
          legend.title = element_blank(), 
          legend.direction = "horizontal") 
  
  density_plots[[i]] <- tmpplot
}

# Get the legend and remove it from individual plots
tmpplot <- get_legend(density_plots[[1]])
for (i in 1:9){
  density_plots[[i]] <- density_plots[[i]] + theme(legend.position="none", 
                                                   axis.title.x = element_blank())
}

pg <- plot_grid(plotlist = density_plots, ncol = 3)
pg <- plot_grid(pg, bottom = textGrob("Tajima's D"), tmpplot, ncol = 1, rel_heights = c(1, 0.05, 0.05))
print(pg)

setwd("../../")

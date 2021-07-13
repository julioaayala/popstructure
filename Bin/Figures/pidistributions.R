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
df$Pi <- df$tP/df$nSites
#Separate autosomes and chr z
autosomesdf <- df[df$Chr!="chrZ",]
chrzdf <- df[df$Chr=="chrZ",]
df$type <- ifelse(df$Chr=="chrZ", "Z Chromosome", "Autosomes")

## Pi boxplots
t <- ggplot(df, aes(x = site, y = Pi, color = type)) +
  geom_boxplot( outlier.size = 0.5) +
  ggtitle("Pi's distribution of 100-kb windows") +
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

## Plots for pi by window
density_plots <- list()
# Custom order of populations
colors <- c("#fb9a99", "#cab2d6", "#a6cee3", "#1f78b4", "#e31a1c", "#ff7f00", "#b2df8a", "#33a02c", "#fdbf6f")
populations <- c("house","spanish", "corsica", "crete", "malta", "sicily", "crotone", "guglionesi", "rimini")
# Generate all plots for Z chr
for (i in 1:9) {
  tmp <- chrzdf[chrzdf$site == populations[i],]
  tmpplot <- ggplot(tmp, aes(x = WinCenter/100000, y = Pi)) +
    geom_density(stat = "identity", fill=colors[i], color = colors[i]) +
    ggtitle(str_to_title(populations[i])) +
    xlab("Position (100 Kb)") +
    theme_bw() +
    theme(plot.title = element_text(size=10))
  density_plots[[i]] <- tmpplot
  
}


# Draw all plots in a grid
pg <- plot_grid(plotlist = density_plots, ncol = 3)
pg <- plot_grid(pg, ncol = 1, scale = 0.95) +
  draw_label("Position (100-kb)", x=0.5, y=00, vjust=-0.5, angle=0) +
  draw_label("Pi", x=0, y=0.5, vjust=1.5, angle=90)

print(pg)


setwd("../../")

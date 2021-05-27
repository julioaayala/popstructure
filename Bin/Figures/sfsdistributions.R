#------------------------------------------------------------
# Julio Ayala
# Created on: May 2021
# Description: Script to create plots of SFS distributions
# for Italian sparrow populations
# Note: Before running, set the working directory to the root of the project
#------------------------------------------------------------

rm(list = ls())
library(tidyverse)
library(data.table)  
library(cowplot) # Used for arranging plots on a grid
library(grid)
setwd("Results/04_Sfs/")

## Function to normalize values
norm <- function(x) x/sum(x)
# Function to calculate expected  heterozygosuty
get_heterozygosity <- function(filename){
  contents <- scan(filename)
  return(contents[2]/sum(contents))
}

# Read file and assign name as column. Also applies normalization of sites.
read_filename <- function(filename){
  contents <- scan(filename)
  df <- do.call(rbind.data.frame, as.list(contents))
  names(df)[1] <- "sites"
  df$location <- gsub("\\..*","",filename)
  df$normalizedsites <- norm(df$sites)
  df$derivedalleles <- 0:(nrow(df)-1)
  df <- df[df$derivedalleles > 0 ,]
  df <- df[df$derivedalleles < (nrow(df)-1) ,]
  het <- get_heterozygosity(filename)
  df$expsfs <- het/df$derivedalleles
  return(df)
}

## chr Z
sfsfiles = list.files(pattern = "*.chrz.ml")
temp <- lapply(sfsfiles, read_filename) ## Read all files and create a dataframe
dfz <- rbindlist(temp)
dfz <- dfz[dfz$derivedalleles < 19 ,]
dfz <- dfz[dfz$location != "p_montanus" ,]
dfz$type <- "Z Chromosome"


## Autosomes
sfsfiles = list.files(pattern = "*.autosomes.ml")
temp <- lapply(sfsfiles, read_filename)
dfautosomes <- rbindlist(temp)
dfautosomes <- dfautosomes[dfautosomes$derivedalleles < 19 ,]
dfautosomes <- dfautosomes[dfautosomes$location != "p_montanus" ,]
dfautosomes$type <- "Autosomes"

density_plots <- list()
colors <- c("#fb9a99", "#cab2d6", "#a6cee3", "#1f78b4", "#e31a1c", "#ff7f00", "#b2df8a", "#33a02c", "#fdbf6f")
populations <- c("house","spanish", "corsica", "crete", "malta", "sicily", "crotone", "guglionesi", "rimini")
dfautosomes$location <- factor(dfautosomes$location, levels = populations)
dfz$location <- factor(dfz$location, levels = populations)

a <- ggplot(dfautosomes, aes(x = factor(derivedalleles), y = normalizedsites, fill = location)) +
  geom_bar(stat="identity", position = "dodge") +
  scale_fill_manual(values=colors, 
                    breaks=populations,
                    labels=str_to_title(populations)) +
  ylab("Density (Autosomes)") +
  theme_bw() + 
  theme(legend.title = element_blank(),
        legend.direction = "horizontal",
        legend.position = "bottom") +
  guides(fill=guide_legend(nrow=1, byrow = TRUE))

z <- ggplot(dfz, aes(x = factor(derivedalleles), y = normalizedsites, fill = location)) +
  geom_bar(stat="identity", position = "dodge") +
  scale_fill_manual(values=colors, 
                    breaks=populations,
                    labels=str_to_title(populations)) +
  ylab("Density (Z Chromosome)") +
  theme_bw() + 
  theme(legend.title = element_blank(),
        legend.direction = "horizontal",
        legend.position = "bottom") +
  guides(fill=guide_legend(nrow=1, byrow = TRUE))

plotlegend <- get_legend(a)
a <- a + theme(legend.position="none", axis.title.x = element_blank())
z <- z + theme(legend.position="none", axis.title.x = element_blank())

pg <- plot_grid(a, z,
                bottom = textGrob("# of Derived alleles"), 
                plotlegend, labels = c('a', 'b'), ncol = 1, rel_heights = c(1, 1, 0.1, 0.15))
print(pg)

setwd("../../")

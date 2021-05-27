#------------------------------------------------------------
# Julio Ayala
# Created on: May 2021
# Description: Script to create plots of nucleotide diversity 
# for Italian sparrow populations 
# Note: Before running, set the working directory to the root of the project
#------------------------------------------------------------

rm(list = ls())
library(tidyverse)
library(data.table)  
library(cowplot)

setwd("Results/02_Pi/100kb/")

# Function to read a file and set a column with the name of the population
read_csv_filename <- function(filename){
  ret <- read.csv(filename, sep = "\t")
  ret$site <- gsub("\\..*","",filename)
  ret
}



# Autosomes
# Get data from all populationa and bind
autosomes = list.files(pattern = "*.autosomes")
temp <- lapply(autosomes, read_csv_filename)
autosomesdf <- rbindlist( temp )
autosomesdf$chrgroup <- "Autosomes"

# chr Z
chrz = list.files(pattern = "*.chrZ")
temp <- lapply(chrz, read_csv_filename)
chrzdf <- rbindlist( temp )
chrzdf$chrgroup <- "Z Chromosome"
df <- rbind(autosomesdf, chrzdf)

# Plot distributions
p <- ggplot(df, aes(x = site, y = PI, color = chrgroup)) +
  geom_boxplot( outlier.size = 0.5) +
  ggtitle("Nucleotide diversity distribution in 100-kb windows") +
  theme_bw() +
  theme(plot.title = element_text(size = 12),
                    legend.title = element_blank(), 
                    legend.direction = "horizontal",
                    legend.position = "bottom") +
  scale_x_discrete(limits=c("house","spanish",
                            "corsica", "crete", "malta", "sicily",
                            "crotone", "guglionesi", "rimini"))
print(p)


## Plots for pi by window
density_plots <- list()
# Custom order of populations
colors <- c("#fb9a99", "#cab2d6", "#a6cee3", "#1f78b4", "#e31a1c", "#ff7f00", "#b2df8a", "#33a02c", "#fdbf6f")
populations <- c("house","spanish", "corsica", "crete", "malta", "sicily", "crotone", "guglionesi", "rimini")
# Generate all plots
for (i in 1:9) {
  tmp <- chrzdf[chrzdf$site == populations[i],]
  tmpplot <- ggplot(tmp, aes(x = BIN_START/100000, y = PI)) +
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


setwd("../../../")

#------------------------------------------------------------
# Julio Ayala
# Created on: April 2021
# Description: Script to create a map of italian sparrow populations 
# and plot a PCA of the same populations
# Note: Set the working directory to the root of the project
#------------------------------------------------------------
setwd("Results/01_Pca/Angsd/")
rm(list = ls())
library(tidyverse)
library(cowplot)
#Mapping libraries
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)


## Map

## Load list of countries
world <- ne_countries(scale = "medium", returnclass = "sf")
world_points<- st_centroid(world)

## Prepare data
## House is lat 59.9133301, but changed to fit on map
sites <- data.frame(latitude = c(42.1880896, 35.3084749, 39.1873894, 41.9138877, 48.9133301, 35.8885993, 43.9470982, 37.587794, 41.859439),
           longitude = c(9.0684138, 24.4633207, 16.8782819, 14.9136133, 10.7389701, 14.4476911, 12.6307686, 14.155048, 15.352741),
           site = c("Corsica", "Crete", "Crotone", "Guglionesi", "House (Oslo, Norway) ↑", "Malta", "Rimini", "Sicily", "Spanish"),
           species = c("Italian", "Italian", "Italian", "Italian", "House", "Italian", "Italian", "Italian", "Spanish"))

##Map
m <- ggplot(data = world) +
  geom_sf(fill="white", color="antiquewhite3") +
  geom_point(data = sites, aes(x = longitude, y = latitude, color = site, shape = species), size = 3) + #Add datapoints
  geom_text(data = sites, aes(ifelse(site %in% c("Spanish", "Guglionesi"), 
                                     ifelse(site=="Guglionesi",longitude-1.3, longitude+1.3),  # Arrange labels
                                     longitude),
                              ifelse(site=="Spanish", latitude-0.4, latitude+0.5),
                              label = site),
            size = 2.5) +
  coord_sf(xlim = c(-10, 30), ylim = c(32, 50), expand = TRUE) + # Limit map
  scale_color_brewer(palette="Paired") +
  theme(panel.background = element_rect(fill = "aliceblue"),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        legend.position = "none")

### PCA
pop<-read.table("all_populations.files")

C <- as.matrix(read.table("all_populations.cov"))
e <- eigen(C)

pca <- data.frame(PC1 = e$vectors[,1], PC2 = e$vectors[,2], Population = pop[,1])
pca$Population <- gsub("Data/Bamfiles/bamfiles/", "", pca$Population)
pca$Population <- str_to_title(gsub("/.*", "", pca$Population))
pca$Species <- ifelse(pca$Population %in% c("Spanish", "House"), pca$Population,
                      "Italian")

## plot pca
p <- ggplot(pca, aes(PC1, PC2, shape = Species, col = Population)) +
  geom_point(size = 2.5) +
  coord_equal() +
  scale_color_brewer(palette = "Paired") +
  theme_bw() +
  theme(legend.title = element_blank(), legend.position = "bottom")

leg <- get_legend(p)
p <- p + theme(legend.position="none", axis.title.x = element_blank())

pg <- plot_grid(m, p, ncol=2, labels = c("a", "b"))
plot <- plot_grid(pg, leg, ncol = 1, rel_heights = c(1, 0.1))
print(plot)


setwd("../../../")

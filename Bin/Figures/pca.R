#------------------------------------------------------------
# Julio Ayala
# Created on: April 2021
# Description: Script to create a map of italian sparrow populations 
# and plot a PCA of the same populations
# Note: Set the working directory to the root of the project
#------------------------------------------------------------
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
pca <- read_table2("Results/01_Pca/sparrows.eigenvec", col_names = F)
eigenval <- scan("Results/01_Pca/sparrows.eigenval")
names(pca)[1] <- "sample"

## Renaming Lesina and Rimini, since they are specieslit.
pca[pca$sample %in% c("Lesina", "Rimini"),]$sample <- paste(pca[pca$sample %in% c("Lesina", "Rimini"),]$sample
                                                            , pca[pca$sample %in% c("Lesina", "Rimini"),]$X2
                                                            , sep = "_")
## Remove the redundant column
pca$X2 <- NULL

## Load samples and assign species and location
speciesanish <- read_table2("Data/vcf_pop_names/spanish.txt", col_names = c("sample"))
speciesanish$species <- "Spanish"
speciesanish$location <- "Spanish"

house <- read_table2("Data/vcf_pop_names/house.txt", col_names = c("sample"))
house$species <- "House"
house$location <- "House"

corsica <- read_table2("Data/vcf_pop_names/corsica.txt", col_names = c("sample"))
corsica$species <- "Italian"
corsica$location <- "Corsica"

crete <- read_table2("Data/vcf_pop_names/crete.txt", col_names = c("sample"))
crete$species <- "Italian"
crete$location <- "Crete"

crotone <- read_table2("Data/vcf_pop_names/crotone.txt", col_names = c("sample"))
crotone$species <- "Italian"
crotone$location <- "Crotone"

guglionesi <- read_table2("Data/vcf_pop_names/guglionesi.txt", col_names = c("sample"))
guglionesi$species <- "Italian"
guglionesi$location <- "Guglionesi"

malta <- read_table2("Data/vcf_pop_names/malta.txt", col_names = c("sample"))
malta$species <- "Italian"
malta$location <- "Malta"

rimini <- read_table2("Data/vcf_pop_names/rimini.txt", col_names = c("sample"))
rimini$species <- "Italian"
rimini$location <- "Rimini"

sicily <- read_table2("Data/vcf_pop_names/sicily.txt", col_names = c("sample"))
sicily$species <- "Italian"
sicily$location <- "Sicily"


samples <- rbind(speciesanish, house, corsica, crete, crotone, guglionesi, malta, rimini, sicily)

pca <- merge(pca, samples, by="sample", all.x = T)
names(pca)[2:(ncol(pca)-2)] <- paste0("PC", 1:(ncol(pca)-3))
pve <- data.frame(PC = 1:20, pve = eigenval/sum(eigenval)*100)

## plot pca
p <- ggplot(pca, aes(PC1, PC2, shape = species, col = location)) +
  geom_point(size = 2.5) +
  xlab(paste0("PC1 (", signif(pve$pve[1], 3), "%)")) + 
  ylab(paste0("PC2 (", signif(pve$pve[2], 3), "%)")) +
  coord_equal() +
  scale_color_brewer(palette = "Paired") +
  theme_bw() +
  theme(legend.title = element_blank())

plot <- plot_grid(m, p, ncol=1, labels = c("a", "b"), rel_heights = c(0.8,1))
print(plot)

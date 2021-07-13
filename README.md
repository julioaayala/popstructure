# Patterns of genetic diversity across island and mainland populations of the Italian sparrow

### Julio Ayala
### May 2021

Code available at: https://github.com/julioaayala/popstructure_italiansparrow

## Getting started
This repository has the necessary scripts to generate different measures of population structure and genetic diversity in the Italian sparrow, a hybrid species.

The scripts can be run either by manually installing the listed requirements on a UNIX operating system, or by using the Swedish National Infrastructure for Computing (SNIC), in the UPPMAX centre (https://www.uppmax.uu.se).

## Requirements
- **Samtools/1.12** (https://samtools.github.io)
- **ANGSD/0.933** (http://www.popgen.dk/angsd/index.php/ANGSD#Overview)
- **SnpEff/5.0e** (Downloaded and installed in step 02 from http://pcingola.github.io/SnpEff/download/, which requires Java/1-8+)
- **Python/3.6.X**
  - Packages: Pandas/1.2.4
- **R/4.0.X** -> Used for data visualisation
  - Packages: Tidyverse/1.3.1, Cowplot/1.1.1, sf/0.9-8, rnaturalearth/0.1.0, rnaturalearthdata/0.1.0, data.table/1.14.0

## Workflow
### First steps
Modify .sh files to set the base path to the one corresponding to the project.
**Note: If this is run in UPPMAX and is submitted as a job and not an interactive session, all bash scripts need to be modified to set both variables at the beginning**

### Scripts
Each of the following scripts corresponds to each step of the analysis. They need to be executed sequentially in order to prevent errors.

#### 00_initialize.sh
This script is used to generate the folder structure needed for the analysis. After running this script, data needs to be deposited in the Data folder, with the Fasta file for the tree sparrow genome in `Data/Fasta`, and the Bam files in `Data/Bamfiles/bamfiles`. Data available upon request.

#### 01_pca_angsd.sh
This script will generate the files needed to create the PCA eigenvalues/eigenvector for the populations. Results can then be visualised using the R script in `Bin/Figures/pca.R`
Requires: ANGSD PCAngsd

#### 02_Sfs.sh
This script will generate the 1d and 2d Site frequency spectrum files for all populations. It also generates MAF and BCF files for all sites (Variants + invariants) Results can then be visualised using the R script in `Bin/Figures/sfsdistributions.R
Requires: ANGSD, SnpEff

#### 03_Dxy_maf.sh
This script will generate the files with Dxy values for each population, using MAF files as an input. Results can then be visualised using the R script in `Bin/Figures/dxydistributions.R
Requires: Python scripts located in `Bin/splitmaf.py` and `Bin/dxy_maf.py`

#### 06_Thetas.sh
This script will generate the Thetas files for all populations, which include, among other measures, Tajima's D and Neji's Pi. Results for Tajima's D can then be visualised using the R script in `Bin/Figures/tajimasdistributions.R`, and Pi with `Bin/Figures/pidistributions.R`
Requires: ANGSD

#### 05_Fst.sh
This script will generate the Fst files for all populations. Results can then be visualised using the R script in `Bin/Figures/fstdistributions.R`
Requires: ANGSD and Python script located in `Bin/filter_fst.py`


## Contact
ju7141ay-s@student.lu.se

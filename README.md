# Patterns of genetic diversity across island and mainland populations of the Italian sparrow

## Getting started
This repository has the necessary scripts to generate different measures of population structure and genetic diversity in the Italian sparrow, a hybrid species.

The scripts can be run either by manually installing the listed requirements on a UNIX operating system, or by using the Swedish National Infrastructure for Computing (SNIC), in the UPPMAX centre (https://www.uppmax.uu.se).

## Requirements
- **Plink/1.90b4.9** (https://www.cog-genomics.org/plink2)
- **Vcftools/0.1.16** (https://vcftools.github.io)
- **Samtools//1.12** ()
- **ANGSD/0.933** (http://www.popgen.dk/angsd/index.php/ANGSD#Overview)
- **SnpEff/5.0e** (Downloaded and installed in step 02 from http://pcingola.github.io/SnpEff/download/, which requires Java/1-8+)
- **Python/3.6.X**
  - Packages: Pandas/1.2.4
- **R/4.0.X)** -> Used for data visualisation
  - Packages: Tidyverse/1.3.1, Cowplot/1.1.1, sf/0.9-8, rnaturalearth/0.1.0, rnaturalearthdata/0.1.0, data.table/1.14.0

## Workflow
### First steps
Before running any scripts, a variable needs to be set for the root path of the project:
```bash
export BASE_PATH=/path/to/project/folder/
```

If this is run in UPPMAX, another variable needs to be set
```bash
export IS_UPPMAX=1
```
**Note: If this is run in UPPMAX and is submitted as a job and not an interactive session, all bash scripts need to be modified to set both variables at the beginning**

### Scripts
Each of the following scripts corresponds to each step of the analysis. They need to be executed sequentially in order to prevent errors.

#### 00_initialize.sh
This script is used to generate the folder structure needed for the analysis. After running this script, data needs to be deposited in the Data folder, with the Fasta file for the tree sparrow genome in `Data/Fasta`, and the Bam files in `Data/Bamfiles/bamfiles`. Data available upon request.

#### 01_Pca.sh
This script will generate the files needed to create the PCA eigenvalues/eigenvector for the population. Results can then be visualised using the R script in `Bin/Figures/pca.R`
Requires: Vcftools and Plink

#### 02_Pi.sh
This script will generate the files with nucleotide diversity values for each population. Results can then be visualised using the R script in `Bin/Figures/pidistributions.R`
Requires: Vcftools, the Pandas library for Python, and the Python script located in `Bin/getexonsandinter.py`

#### 03_Dxy.sh
This script will generate the files with Dxy values for each population. Results can then be visualised using the R script in `Bin/Figures/dxydistributions.R`
Requires: Vcftools and the Python script located in `Bin/dxy.py`

#### 04_Sfs.sh
This script will generate the 1d and 2d Site frequency spectrum files for all populations. Results can then be visualised using the R script in `Bin/Figures/sfsdistributions.R`
Requires: ANGSD, SnpEff

#### 05_Fst.sh
This script will generate the Fst files for all populations. Results can then be visualised using the R script in `Bin/Figures/fstdistributions.R`
Requires: ANGSD

#### 06_Thetas.sh
This script will generate the Thetas files for all populations, which include, among other measures, Tajima's D. Results for Tajima's D can then be visualised using the R script in `Bin/Figures/tajimasdistributions.R`
Requires: ANGSD

## Contact
ju7141ay-s@student.lu.se

This repository is part of a research project for 15 credits at Lund University, bioinformatics master's program.

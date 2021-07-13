#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 10:00:00
#SBATCH -J pca_sparrows
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

#----------------------------------------------------------------------------------------
# Julio Ayala
# Created on: May 2021
# PCA
# Calculate PCA for the italian sparrow populations from a vcf file using vcftools and plink
#----------------------------------------------------------------------------------------

## Load modules
module load bioinfo-tools
module load plink # plink/1.90b4.9
module load vcftools # vcftools/0.1.16
module list

cd $BASE_PATH

# Perform linkage prunning
## Use a 50 kb window with a 50 kb step  and 0.1 as the r2 value
plink --vcf Data/sparrows_anna.vcf.gz --aec --set-missing-var-ids @:# \
--out Results/01_Pca/sparrows \
--indep-pairwise 50 50 0.1 --chr-set 28

# Perform PCA
## Use the result from the linkage prunning step and set 28 chromosomes
plink --vcf Data/sparrows_anna.vcf.gz --aec --set-missing-var-ids @:# \
--out Results/01_Pca/sparrows --extract Results/01_Pca/sparrows.prune.in \
--make-bed --pca --chr-set 28

#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 10:00:00
#SBATCH -J dxy_sparrows
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

## Calculate DXY for all population pairs using a python script and vcf frequency data
## as an input

## Load modules
module load bioinfo-tools
module load vcftools # vcftools/0.1.16

cd $BASE_PATH

## Dxy
## Calculate frequencies
for file in Data/vcf_pop_names/*; do file=${file##*/}; site=${file%.txt}; vcftools \
--gzvcf Data/sparrows_anna.vcf.gz --counts --out Results/03_Dxy/Freq/$site \
--keep Data/vcf_pop_names/$file; done

## Calculate Dxy for each pair with a 100kb window
set -- Data/vcf_pop_names/*
for a; do shift; for b; do a=${a##*/}; b=${b##*/};a=${a%.txt}; b=${b%.txt}; \
python3 Bin/dxy.py --pop1 Results/03_Dxy/Freq/$a.frq.count --pop2 Results/03_Dxy/Freq/$b.frq.count \
--window 100000 > Results/03_Dxy/${a}_vs_${b}.dxy.windowed; done; done

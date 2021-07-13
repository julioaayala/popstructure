#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 10
#SBATCH -t 6:00:00
#SBATCH -J dxy_sparrows_p1_p2
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

module load bioinfo-tools
module load python3

cd /proj/snic2020-6-222/Projects/Pitaliae/working/Julio

mkdir Results/03_Dxy/Mafs/P1_vs_P2

for chr in chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 \
chr11 chr12 chr13 chr14 chr15 chr17 chr18 chr19 chr20 \
chr21 chr22 chr23 chr24 chr25 chr27 chr28 chr1A chrZ; do \
python3 Bin/dxy_maf.py --pop1 Results/03_Mafs/P1/P1_invariants.${chr}.maf --pop2 Results/03_Mafs/P2/P2_invariants.${chr}.maf \
--window 100000 > Results/03_Dxy/Mafs/P1_vs_P2/P1_vs_P2.${chr}.dxy.windowed; done

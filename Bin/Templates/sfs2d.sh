#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 20
#SBATCH -C mem256GB
#SBATCH -t 10:00:00
#SBATCH -J sfs2d_sparrows_p1_p2
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

module load bioinfo-tools
module load ANGSD

cd /proj/snic2020-6-222/Projects/Pitaliae/working/Julio
cd Results/02_Sfs

## Calculate 2d SFS for each population in autosomes and Z chromosome
realSFS p1/p1.chrZ.saf.idx p2/p2.chrZ.saf.idx -P 20 > Sfs2d/p1.p2.chrZ.ml
realSFS p1/p1.autosomes.saf.idx p2/p2.autosomes.saf.idx -P 20 > Sfs2d/p1.p2.autosomes.ml

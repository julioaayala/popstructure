#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 10
#SBATCH -t 8:00:00
#SBATCH -J theta_sparrows_pop
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

module load bioinfo-tools
module load ANGSD

cd /proj/snic2020-6-222/Projects/Pitaliae/working/Julio

# chrZ
# Prepare by position with 10 cores (-P=10)
realSFS saf2theta Results/02_Sfs/pop/pop.chrZ.saf.idx -sfs Results/02_Sfs/pop.chrz.ml \
-P 10 -outname Results/04_Theta/pop.chrz
# Calculate thetas over 100kb windows
thetaStat do_stat Results/04_Theta/pop.chrz.thetas.idx -win 100000 -step 100000 \
-outnames Results/04_Theta/pop.chrz

# Autosomes
# Prepare by position with 10 cores (-P=10)
realSFS saf2theta Results/02_Sfs/pop/pop.autosomes.saf.idx -sfs Results/02_Sfs/pop.autosomes.ml \
-P 10 -outname Results/04_Theta/pop.autosomes
# Calculate thetas over 100kb windows
thetaStat do_stat Results/04_Theta/pop.autosomes.thetas.idx -win 100000 -step 100000 \
-outnames Results/04_Theta/pop.autosomes

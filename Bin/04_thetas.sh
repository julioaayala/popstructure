#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 10:00:00
#SBATCH -J theta_sparrows
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

#----------------------------------------------------------------------------------------
# Julio Ayala
# Created on: May 2021
# Calculate thetas (tajimas D, waterson Theta, etc) for all populations
# Based on SFS using ANGSD
#----------------------------------------------------------------------------------------

module load bioinfo-tools
module load ANGSD # ANGSD/0.933

cd /proj/snic2020-6-222/Projects/Pitaliae/working/Julio

## Using the template, generate for all populations
mkdir -p Bin/04_Theta_scripts
for pop in $(ls -1 Data/Populations/*.filelist | sed 's/.*\///' | sed 's/.filelist//'); \
do sed "s/pop/$pop/g" Bin/Templates/theta.sh \
> Bin/04_Theta_scripts/$pop.sh; done

## Execute all scripts
for file in Bin/04_Theta_scripts/*; do chmod +x $file; sbatch $file; done

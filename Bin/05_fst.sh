#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 10:00:00
#SBATCH -J fst_sparrows
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

#----------------------------------------------------------------------------------------
# Julio Ayala
# Created on: May 2021
# Calculate FST for all population pairs
# Based on SFS using ANGSD
#----------------------------------------------------------------------------------------


module load bioinfo-tools
module load ANGSD # ANGSD/0.933

cd /proj/snic2020-6-222/Projects/Pitaliae/working/Julio

# Generate a script file for each population pair
mkdir Bin/05_Fst_scripts
set -- $(ls -1 Data/Populations/*.filelist | sed 's/.filelist//')
set -- $(ls -A1 Data/Populations/*.filelist | sed 's/.*\///'| sed 's/.filelist//')
for pop1; do shift; for pop2; do sed "s/p1/$pop1/g" Bin/Templates/fst.sh | sed "s/p2/$pop2/g" \
> Bin/05_Fst_scripts/$pop1.$pop2.fst.sh; done; done

# Execute all scripts
for file in Bin/05_Fst_scripts/*; do chmod +x $file; sbatch $file; done

## Calculate outliers with 4 standard deviations
for i in Results/05_Fst/*.windowed; do python3 Bin/filter_fst.py $i 4; done

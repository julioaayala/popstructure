#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 10:00:00
#SBATCH -J fst_sparrows
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

## Calculate for all population pairs
## Based on SFS using ANGSD

## Population structure in ANGSD
module load bioinfo-tools
module load ANGSD # ANGSD/0.933

cd $BASE_PATH

# Generate a script file for each population pair
mkdir Bin/05_Fst_scripts
set -- $(ls -1 Data/Populations/ | sed 's/.filelist//')
for pop1; do shift; for pop2; do sed "s/p1/$pop1/g" Bin/Templates/fst.sh | sed "s/p2/$pop2/g" \
> Bin/05_Fst_scripts/$pop1.$pop2.fst.sh; done; done

# Execute all scripts
for file in Bin/05_Fst_scripts/*; do chmod +x $file; ./$file; done

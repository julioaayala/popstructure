#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 10:00:00
#SBATCH -J dxy_sparrows
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

#----------------------------------------------------------------------------------------
# Julio Ayala
# Created on: June 2021
# Calculate DXY for all population pairs using a python script and maf allele frequencies as input
#----------------------------------------------------------------------------------------

module load bioinfo-tools
module load python3

cd /proj/snic2020-6-222/Projects/Pitaliae/working/Julio

## Split MAFs by chromosome
for i in ; do \
mkdir -p Results/03_Mafs/$i/; \
python3 Bin/splitmaf.py -i Results/02_Sfs/$i/${i}_invariants.mafs -o Results/03_Mafs/$i/; \
done

# Create script for each pop pair
set -- $(ls -A1 Data/Populations/*.filelist | sed 's/.*\///'| sed 's/.filelist//')
for pop1; do shift; for pop2; do \
sed "s/P1/$pop1/g" Bin/Templates/dxy.sh | sed "s/P2/$pop2/g" > \
Bin/03_Dxy_pairs/$pop1.$pop2.sh; done; done

## Chmod and execute each
for i in Bin/03_Dxy_pairs; do chmod +x $i; done
for i in Bin/03_Dxy_pairs; do sbatch $i; done

## Once complete
## Concatenate by chromosome for all populations
set -- $(ls -A1 Data/Populations/*.filelist | sed 's/.*\///'| sed 's/.filelist//')
for pop1; do shift; for pop2; do \
awk ' FNR==1 && NR!=1 { while (/^chrom/) getline; } 1 {print} ' Results/03_Dxy/Mafs/${pop1}_vs_${pop2}/*.windowed > \
Results/03_Dxy/Mafs/${pop1}_vs_${pop2}.dxy; \
done; done


## Dxy in Results/03_Dxy/Mafs/

#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 10:00:00
#SBATCH -J sfs_sparrows
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

#----------------------------------------------------------------------------------------
# Julio Ayala
# Created on: May 2021
# Population structure in ANGSD, generate SFS, MAF and BCF files for future analysis
#----------------------------------------------------------------------------------------

module load bioinfo-tools
module load ANGSD # ANGSD/0.933
module load samtools # samtools/1.12
module list

cd /proj/snic2020-6-222/Projects/Pitaliae/working/Julio

## Generate ancestral genome from outgroup (Passer montanus)

angsd -dofasta 2 -docounts 1 -bam Data/pmontanus.txt -out Data/Fasta/pmontanus
cd Data/Fasta
## Index the file
gzip -d pmontanus.fa.gz
samtools faidx Results/pmontanus.fa
cd ../..

## Generate list of bam files per population
for folder in $(ls -1 Data/Bamfiles/bamfiles/); do ls -1 Data/Bamfiles/bamfiles/$folder/*.bam \
> Data/Populations/$folder.filelist; done

## Create a directory for each population
cd Results/02_Sfs
mkdir $(ls -1 ../../Data/Populations/ | sed 's/.filelist//')
cd ../../

# Create folder for generated scripts
mkdir Bin/{02_Saf_scripts,02_Sfs2d_scripts}
## Create a bash file for each population
for pop in $(ls -1 Data/Populations/*.filelist | sed 's/.*\///' | sed 's/.filelist//'); do sed "s/p1/$pop/g" \
Bin/Templates/saf.sh > Bin/02_Saf_scripts/$pop.sh; done

## Execute each pop.sh
for file in Bin/02_Saf_scripts/*; do chmod +x $file; done
for file in Bin/02_Saf_scripts/*; do sbatch $file; done

## Once complete, generate Site frequency spectrum fies
## Calculate 1d sfs for chr Z
for pop in $(ls -1 Data/Populations/*.filelist | sed 's/.*\///' | sed 's/.filelist//'); do \
realSFS Results/02_Sfs/$pop/$pop.chrZ.saf.idx -p 16 > Results/02_Sfs/$pop/$pop.chrZ.sfs; \
done

# Autosomes
for pop in $(ls -1 Data/Populations/*.filelist | sed 's/.*\///' | sed 's/.filelist//'); do \
realSFS Results/02_Sfs/$pop/$pop.autosomes.saf.idx -p 16 > Results/02_Sfs/$pop/$pop.autosomes.sfs; \
done


## Calculate 2d SFS
set -- $(ls -A1 Data/Populations/*.filelist | sed 's/.*\///'| sed 's/.filelist//')
for pop1; do shift; for pop2; do sed "s/p1/$pop1/g" Bin/Templates/sfs2d.sh | sed "s/p2/$pop2/g" \
> Bin/02_Sfs2d_scripts/$pop1.$pop2.sh; done; done

## Execute the script for all population pairs
for file in Bin/02_Sfs2d_scripts/*; do chmod +x $file; done
for file in Bin/02_Sfs2d_scripts/*; do sbatch $file; done

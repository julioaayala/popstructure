#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 10:00:00
#SBATCH -J saf_sparrows
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

module load bioinfo-tools
module load ANGSD

cd $BASE_PATH

for chr in chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 \
chr11 chr12 chr13 chr14 chr15 chr17 chr18 chr19 chr20 \
chr21 chr22 chr23 chr24 chr25 chr27 chr28 chr1A chrZ; do angsd -doSaf 1 -GL 1 \
-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 \
-bam Data/Populations/p1.filelist \
-out Results/04_Sfs/p1/p1.$chr -anc Data/Fasta/pmontanus.fa -P 16 -r $chr; done

cd Results/04_Sfs/population

## Create a variable with the autosome names
files=$(find . -regex '.*[0-9][A]?.saf.idx')

## Merge autosomes
realSFS cat $files -outnames p1.autosomes

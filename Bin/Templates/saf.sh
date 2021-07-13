
#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 20:00:00
#SBATCH -J saf_sparrows_p1
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

module load bioinfo-tools
module load ANGSD

cd /proj/snic2020-6-222/Projects/Pitaliae/working/Julio

## Generate SAF files for each chromosome
for chr in chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 \
chr11 chr12 chr13 chr14 chr15 chr17 chr18 chr19 chr20 \
chr21 chr22 chr23 chr24 chr25 chr27 chr28 chr1A chrZ; do \
angsd -doSaf 1 -doCounts 1 \
-GL 1 -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 \
-doMajorMinor 1 -minMapQ 30 -minQ 20 -c 50 -SNP_pval 2e-6 \
-minInd 1 -setMinDepth 20 -setMaxDepth 200 \
-bam Data/Populations/p1.filelist \
-anc Data/Fasta/pmontanus.fa \
-ref Data/Fasta/pmontanus.fa -P 16 -r $chr \
-out Results/02_Sfs/p1/p1.$chr ; done

## Generate MAF and VCF with all sites (Variant + invariants)
mkdir -p Results/02_Sfs/p1/p1_invariants

angsd -baq 1 -doMaf 1 -doGlf 2 -doCounts 1 \
-GL 1 -doPost 1 -doGeno 1 \
-doBcf 1 -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 \
-doMajorMinor 1 -minMapQ 30 -minQ 20 -c 50 \
-minInd 1 -setMinDepth 20 -setMaxDepth 200 \
-bam Data/Populations/p1.filelist \
-anc Data/Fasta/pmontanus.fa \
-ref Data/Fasta/pmontanus.fa -P 16 \
-out Results/02_Sfs/p1/p1_invariants

## Merge autosomes for the SAF files
cd Results/02_Sfs/p1

# Create a variable with the autosome names
files=$(find . -regex '.*[0-9][A]?.saf.idx')

# Merge autosomes
realSFS cat $files -outnames p1.autosomes

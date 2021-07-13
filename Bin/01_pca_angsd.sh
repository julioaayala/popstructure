#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 5-00:00:00
#SBATCH -J pca_sparrows
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

module load bioinfo-tools
module load ANGSD
module load PCAngsd

cd /proj/snic2020-6-222/Projects/Pitaliae/working/Julio

for i in Data/Populations/*.filelist; do cat $i; done > all_populations.files

mkdir -p Results/01_Pca/{Angsd,Beagle}
## Generate the PCA files
# Arguments:
#  -GL 1 # Use Genotype likelihoods using SAMtools model
#  -P 16 # Run with 16 threads, can be modified
#  -doGlf 2 # Outputs the genotype likelihoods in Beagle format
#  -doMajorMinor 1 # Infer major and minor alleles from GL
#  -only_proper_pairs 1 # Include reads with both mates mapped correctly
#  -minInd 10 # Set the minimum number of samples with the base, I left it to the 10% of the total (10% of 99)
#  -setMinDepth 200 # Discard the site if the total sequencing depth is below the threshold. As a rule of thumb, I used 0.2*coverage*n
#  -setMaxDepth 2000 # Discard the site if the total sequencing depth is above the threshold. As a rule of thumb, I used 2*coverage*n
#  -minMapQ 30 # Use minimum mapping quality to 30
#  -c 50 # This is an adjustment that Zach recommended, it seems to be universally included
#  -uniqueOnly 1 # Only unique reads
#  -minQ 20 # Minimum base quality to 20
#  -baq 1 # Calculates baq
#  -doMaf 1 # Calculates Maf
#  -SNP_pval 2e-6 # SNP threshold in the Beagle file
#  -remove_bads 1 # Discard bad reads
#  -bam Data/Populations/all_populations.files # List of input bam files (Paths)
#  -ref Data/Fasta/pmontanus.fa # reference genome
#  -out Results/01_Pca/Beagle/1_all_populations # Output basename

angsd -baq 1 -doMaf 1 -doGlf 2 -doCounts 1 \
-GL 1 -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 \
-doMajorMinor 1 -minMapQ 30 -minQ 20 -c 50 -SNP_pval 2e-6 \
-minInd 10 -setMinDepth 200 -setMaxDepth 2000 \
-bam Data/Populations/all_populations.files \
-anc Data/Fasta/pmontanus.fa \
-ref Data/Fasta/pmontanus.fa -P 16 \
-out Results/01_Pca/Beagle/all_populations_fix

pcangsd.py \
  -beagle Results/01_Pca/Beagle/all_populations_fix.beagle.gz -threads 16 \
  -o Results/01_Pca/Angsd/all_populations

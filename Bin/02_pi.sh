#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 16
#SBATCH -t 10:00:00
#SBATCH -J pi_sparrows
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

# Nucleotide diversity
## Perform Nucleotide diversity analysis for each population with 100kb non overlappingwindows

## Load modules
module load bioinfo-tools
module load vcftools # vcftools/0.1.16

cd $BASE_PATH

for file in Data/vcf_pop_names/*; do file=${file##*/}; pop=${file%.txt}; vcftools \
--gzvcf Data/sparrows_anna.vcf.gz --window-pi 100000 --out Results/02_Pi/100kb/$pop \
--keep Data/vcf_pop_names/$file; done

## Split for autosomes, Z chromosome, and chromosome 5
for file in Results/02_Pi/100kb/*.pi; do cat $file | grep -E -v "chrZ|chrLGE22|scaffold" > $file.autosomes; done ## Exclude LGE22, chrZ and scaffolds
for file in Results/02_Pi/100kb/*.pi; do cat $file | grep -E "CHROM|chrZ" > $file.chrz; done ## Filter for chrZ
for file in Results/02_Pi/100kb/*.pi; do cat $file | grep -E "CHROM|chr5" > $file.chr5; done ## Filter for chr5


#----------------------------------------------------------------------------------------
# Intergenic and intronic regions
## Annotate VCF file
## Install SnpEff (5.0e (build 2021-03-09 06:01))
cd Bin
wget https://snpeff.blob.core.windows.net/versions/snpEff_latest_core.zip
unzip snpEff_latest_core.zip

## Add the house sparrow genome to the database
cd snpeff
echo "#House sparrow (Passer domesticus)" >> snpEff.config
echo "pdomesticus1.0.genome : Passer domesticus" >> snpEff.config

## Create a data folder and copy the gff file and genome
mkdir -p data/pdomesticus1.0
cp ../../Data/cass.gff data/pdomesticus1.0/genes.gff
cp ../../Data/house_sparrow_genome_assembly-18-11-14.fa data/pdomesticus1.0/sequences.fa

## Build database
java -jar snpEff.jar build -gff3 -v pdomesticus1.0

### go to the root folder
cd ../../

## Annotate vcf file and generate a new file
java -jar Bin/snpEff/snpEff.jar pdomesticus1.0 Data/sparrows_anna.vcf.gz -c \
Bin/snpEff/snpEff.config -v > Data/sparrows_anna.ann.vcf


## Filter
## Synonymous sites
cat Data/sparrows_anna.ann.vcf | grep -E \
"#CHROM|synonymous_variant|stop_retained_variant" > Data/sparrows_anna.syn.vcf
## Non-synonymous sites
cat Data/sparrows_anna.ann.vcf | grep -E \
"#CHROM|start_lost|stop_gained|stop_lost|missense_variant" > Data/sparrows_anna.nonsyn.vcf
## All variants
cat Data/sparrows_anna.ann.vcf | grep -E \
"#CHROM|start_lost|stop_gained|stop_lost|missense_variant|synonymous_variant" > Data/sparrows_anna.all_variants.vcf
## Intronic regions
cat sparrows_anna.ann.vcf | grep -E "#CHROM|intron" > sparrows_anna.intronic.vcf
## Intergenic regions
cat sparrows_anna.ann.vcf | grep -E "#CHROM|intergenic" > sparrows_anna.intergenic.vcf

## Get chromosome lengths
awk '/^>/ {if (seq) {printf("\t%d\n", seq)} \
printf("%s",gensub(">", "", $0)); seq=0; next} \
{seq+=length($0)} END {if(seq){printf("\t%d\n",seq)}}' \
house_sparrow_genome_assembly-18-11-14.fa > Data/chrlengths_tmp.txt
## Sort by length
#cat Data/chrlengths_tmp.txt | sort -k1 > Data/chrlengths.txt

## Calculate Pi per site in regions:
mkdir -p Results/02_Pi/Variants/{synonymous,nonsynonymous,allvariants,Intronic,Intergenic}
## Intronic
for file in Data/vcf_pop_names/*; do file=${file##*/}; site=${file%.txt}; vcftools \
--vcf Data/sparrows_anna.intronic.vcf --site-pi --out Results/02_Pi/Variants/Intronic/$site \
--keep Data/vcf_pop_names/$file; done

## Intergenic
for file in Data/vcf_pop_names/*; do file=${file##*/}; site=${file%.txt}; vcftools \
--vcf Data/sparrows_anna.intergenic.vcf --site-pi --out Results/02_Pi/Variants/Intergenic/$site \
--keep Data/vcf_pop_names/$file; done

## TODO: Add calculation of averages with py script

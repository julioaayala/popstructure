#!/bin/bash -l

#SBATCH -A snic2020-5-635
#SBATCH -p core
#SBATCH -n 20
#SBATCH -t 10:00:00
#SBATCH -J fst_sparrows_p1_p2
#SBATCH --mail-user=ju7141ay-s@student.lu.se
#SBATCH --mail-type=FAIL

module load bioinfo-tools
module load ANGSD

cd $BASE_PATH
cd Results

## Z chromosome
#Prepare files for analysis
realSFS fst index 04_Sfs/p1/p1.chrZ.saf.idx 04_Sfs/p2/p2.chrZ.saf.idx \
-sfs 04_Sfs/Sfs2d/p1.p2.chrZ.ml -outname 05_Fst/p1.p2.chrz
## Calculate FST with a 100kb window
realSFS fst stats2 05_Fst/p1.p2.chrz.fst.idx -win 100000 -step 100000 \
> 05_Fst/p1.p2.chrz.windowed

## Autosomes
#Prepare files for analysis
realSFS fst index 04_Sfs/p1/p1.autosomes.saf.idx 04_Sfs/p2/p2.autosomes.saf.idx \
-sfs 04_Sfs/Sfs2d/p1.p2.autosomes.ml -outname 05_Fst/p1.p2.autosomes
## Calculate FST with a 100kb window
realSFS fst stats2 05_Fst/p1.p2.autosomes.fst.idx -win 100000 -step 100000 \
> 05_Fst/p1.p2.autosomes.windowed

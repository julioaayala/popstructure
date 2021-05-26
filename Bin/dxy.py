#!/usr/bin/env python
import sys
import argparse

# **********************************
# Written by Julio Ayala
# Created on: April 2021
# Updated on: May 2021
# Based on script by Homa Papoli (Nov 2018)
# **********************************

# Usage: To calculate dxy between
# two populations, run the script simply as:
# Input is vcftools frequency files with the following structure:
# CHROM   POS     N_ALLELES       N_CHR   {ALLELE:COUNT}
# chr1    1701    2       20      G:10    A:10
# chr1    2587    2       16      T:15    G:1
# chr1    2750    2       20      T:1     C:19
# chr1    2867    2       20      G:19    A:1
# chr1    2876    2       20      G:17    T:3
# chr1    2916    2       20      G:20    T:0
# chr1    2953    2       20      C:20    A:0
# chr1    3047    2       18      T:17    C:1
# chr1    3124    2       18      T:4     C:14
# chr1    3129    2       18      G:1     T:17
## NOTE: Both allele count files must have the same length

# **********************************
# Function for dxy
# **********************************
def get_dxy(nchr_pop1, nchr_pop2, allele1_pop1, allele1_pop2):
  """
  Calculates dxy between two populations.
  """
  p1 = allele1_pop1/nchr_pop1
  p2 = allele1_pop2/nchr_pop2
  dxy = round(p1*(1-p2) + p2*(1-p1), 4)
  return dxy

# **********************************
# Function to get frequencies and number of alleles per site
# Returns a list with number of alleles and frequencies for two lines.
# **********************************
def split_frequency(site_pop1, site_pop2):
  l1 = site_pop1.strip("\n").split("\t")
  l2 = site_pop2.strip("\n").split("\t")
  chrom = l1[0] ## The position and chromosome are assumed to be the same since both files should have the same length
  pos = int(l1[1]) ## Get position
  ## Validate that alleles are the same in both populations
  allelecount1_pop1 = l1[4].split(":")
  allelecount2_pop1 = l1[5].split(":")
  allelecount1_pop2 = l2[4].split(":")
  allelecount2_pop2 = l2[5].split(":")
  if allelecount1_pop1[0] != allelecount1_pop2[0]: # If positions of alleles are switched
    tmp_allele1 = allelecount1_pop1
    allelecount1_pop1 = allelecount2_pop1
    allelecount2_pop1 = tmp_allele1

  allele1_pop1 = int(allelecount1_pop1[1])
  allele2_pop1 = int(allelecount2_pop1[1])
  nchr_pop1 = allele1_pop1 + allele2_pop1

  allele1_pop2 = int(allelecount1_pop2[1])
  allele2_pop2 = int(allelecount2_pop2[1])
  nchr_pop2 = allele1_pop2 + allele2_pop2

  return chrom, pos, allele1_pop1, allele1_pop2, nchr_pop1, nchr_pop2


if __name__ == "__main__":
  # Args *****************************
  parser = argparse.ArgumentParser(description = '''Calculate DXY for 2 populations.''')
  requiredNamed = parser.add_argument_group('Required:')
  requiredNamed.add_argument("--pop1", help="Frequency file for population 1", required=True)
  requiredNamed.add_argument("--pop2", help="Frequency file for population 2", required=True)
  parser.add_argument('--window',
      dest = 'window',
      help = 'Window size (Default 0)',
      type = int,
      default = 0)
  parser.add_argument('--step',
      dest = 'step',
      help = 'Step size  (Default: Window size)',
      type = int,
      default = 0)
  args = parser.parse_args()
  # **********************************

  # If no window is given, calculates dxy per site
  if args.window==0:
    with open(args.pop1, "r") as f1, open(args.pop2, "r") as f2:
      next(f1) # Skip headers
      next(f2)
      print("chrom"+"\t"+"pos"+"\t"+"dxy")
      # Parse file contents
      for site_pop1, site_pop2 in zip(f1, f2):
        chrom, pos, allele1_pop1, allele1_pop2, nchr_pop1, nchr_pop2 = split_frequency(site_pop1, site_pop2)
        if not chrom.startswith("scaffold") and "LGE" not in chrom:
          ## Excluding scaffolds, print the dxy values
          print(chrom+"\t"+str(pos)+"\t"+str(get_dxy(nchr_pop1, nchr_pop2, allele1_pop1, allele1_pop2)))
  # If a window is given
  else:
    current_chrom = ""
    current_pos = 1
    start_pos = 1
    nvariants = 0
    max_pos = args.step if args.step>0 else args.window
    dxy_values = []
    with open(args.pop1, "r") as f1, open(args.pop2, "r") as f2:
      next(f1) # Skip headers
      next(f2)
      print("chrom"+"\t"+"start"+"\t"+"end"+"\t"+"nVariants"+"\t"+"dxy")
      # Parse file contents
      for site_pop1, site_pop2 in zip(f1, f2):
        chrom, pos, allele1_pop1, allele1_pop2, nchr_pop1, nchr_pop2 = split_frequency(site_pop1, site_pop2)
        if not chrom.startswith("scaffold") and "LGE" not in chrom:
          if current_chrom=="" or current_chrom==chrom:
            current_chrom = chrom
            ## Add any windows between variants
            if pos>max_pos:
              while pos>max_pos:
                total_sites = max_pos-start_pos
                dxy_window = sum(dxy_values)/total_sites
                print(current_chrom+"\t"+str(start_pos)+"\t"+str(max_pos)+"\t"+str(nvariants)+"\t"+str(round(dxy_window, 8)))
                start_pos = max_pos+1
                max_pos += args.step if args.step>0 else args.window
                dxy_values = []
                nvariants = 0
            ## Current variant
            dxy_pos = get_dxy(nchr_pop1, nchr_pop2, allele1_pop1, allele1_pop2)
            current_pos = pos
            nvariants += 1
            dxy_values.append(dxy_pos)
          else: ## New chromosome
            ## Add last window of previous
            total_sites = max_pos-start_pos
            dxy_window = sum(dxy_values)/total_sites
            print(current_chrom+"\t"+str(start_pos)+"\t"+str(max_pos)+"\t"+str(nvariants)+"\t"+str(round(dxy_window, 8)))

            ## Reset variables
            start_pos = 1
            nvariants = 0
            max_pos = args.step if args.step>0 else args.window
            dxy_values = []
            current_chrom = chrom
            ## Add any first windows before first variant
            if pos>max_pos:
              while pos>max_pos:
                total_sites = max_pos-start_pos
                dxy_window = sum(dxy_values)/total_sites
                print(current_chrom+"\t"+str(start_pos)+"\t"+str(max_pos)+"\t"+str(nvariants)+"\t"+str(round(dxy_window, 8)))
                start_pos = max_pos+1
                max_pos += args.step if args.step>0 else args.window
                dxy_values = []
                nvariants = 0
            ## Current variant
            dxy_pos = get_dxy(nchr_pop1, nchr_pop2, allele1_pop1, allele1_pop2)
            current_pos = pos
            nvariants += 1
            dxy_values.append(dxy_pos)
      ## EOF window
      total_sites = max_pos-start_pos
      dxy_window = sum(dxy_values)/total_sites
      print(current_chrom+"\t"+str(start_pos)+"\t"+str(max_pos)+"\t"+str(nvariants)+"\t"+str(round(dxy_window, 8)))

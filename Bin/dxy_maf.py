#!/usr/bin/env python
import sys
import argparse
import pandas as pd
# **********************************
# Written by Julio Ayala
# Created on: June 2021
# **********************************

# Usage: To calculate dxy between
# two populations, run the script simply as:
# ./dxy_maf.py pop1.maf pop2.maf
# Input is two MAF files

# **********************************
# Function for dxy, receives allele frequencies for population 1 and population 2 in a locus
# **********************************
def get_dxy(p1, p2):
    """
    Calculates dxy between two populations, given the allele frequency.
    """
    dxy = round(p1*(1-p2) + p2*(1-p1), 4)
    return dxy


if __name__ == "__main__":
    # Args *****************************
    parser = argparse.ArgumentParser(description = '''Calculate DXY for 2 populations.''')
    requiredNamed = parser.add_argument_group('Required:')
    requiredNamed.add_argument("--pop1", help="MAF file for population 1", required=True)
    requiredNamed.add_argument("--pop2", help="MAF file for population 2", required=True)
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
        f1 = pd.read_csv(args.pop1, sep = "\t")
        f2 = pd.read_csv(args.pop2, sep = "\t")
        merged_mafs = pd.merge(f1,f2, on=["chromo", "position"])
        merged_mafs = merged_mafs.loc[(merged_mafs["chromo"].str.contains("LGE")==False) & (merged_mafs["chromo"].str.contains("scaffold")==False)]
        print("chromo"+"\t"+"pos"+"\t"+"dxy")
        for index,row in merged_mafs.iterrows():
            if row["major_x"]==row["major_y"]:
                dxy = get_dxy(row["knownEM_x"],row["knownEM_y"])
            elif row["major_x"]==row["minor_y"]  or row["major_y"]==row["minor_x"]:
                dxy = get_dxy(row["knownEM_x"], 1 - row["knownEM_y"])
            elif row["minor_x"]==row["minor_y"]:
                dxy = get_dxy(1 - row["knownEM_x"], 1 - row["knownEM_y"])
            else:
                ## TODO: Validate case
                dxy_pos = get_dxy(row["knownEM_x"], row["knownEM_y"])
            print(row["chromo"]+"\t"+str(row["position"])+"\t"+str(dxy))
    # If a window is given
    else:
        current_chrom = ""
        current_pos = 1
        start_pos = 1
        nvariants = 0
        max_pos = args.step if args.step>0 else args.window
        dxy_values = []
        f1 = pd.read_csv(args.pop1, sep = "\t")
        f2 = pd.read_csv(args.pop2, sep = "\t")
        merged_mafs = pd.merge(f1,f2, on=["chromo", "position"])
        merged_mafs = merged_mafs.loc[(merged_mafs["chromo"].str.contains("LGE")==False) & (merged_mafs["chromo"].str.contains("scaffold")==False)]

        print("chrom"+"\t"+"start"+"\t"+"end"+"\t"+"nVariants"+"\t"+"dxy"+"\tN="+str(len(merged_mafs)))
        # Parse file contents
        for index,row in merged_mafs.iterrows():
            chrom = row["chromo"]
            pos = row["position"]

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
                if row["major_x"]==row["major_y"]:
                    dxy_pos = get_dxy(row["knownEM_x"], row["knownEM_y"])
                elif row["major_x"]==row["minor_y"]  or row["major_y"]==row["minor_x"]:
                    dxy_pos = get_dxy(row["knownEM_x"], 1 - row["knownEM_y"])
                elif row["minor_x"]==row["minor_y"]:
                    dxy_pos = get_dxy(1 - row["knownEM_x"], 1 - row["knownEM_y"])
                else:
                    ## TODO: Validate case
                    dxy_pos = get_dxy(row["knownEM_x"], row["knownEM_y"])
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
                if row["major_x"]==row["major_y"]:
                    dxy_pos = get_dxy(row["knownEM_x"], row["knownEM_y"])
                elif row["major_x"]==row["minor_y"]  or row["major_y"]==row["minor_x"]:
                    dxy_pos = get_dxy(row["knownEM_x"], 1 - row["knownEM_y"])
                elif row["minor_x"]==row["minor_y"]:
                    dxy_pos = get_dxy(1 - row["knownEM_x"], 1 - row["knownEM_y"])
                else:
                    ## TODO: Validate case
                    dxy_pos = get_dxy(row["knownEM_x"], row["knownEM_y"])
                current_pos = pos
                nvariants += 1
                dxy_values.append(dxy_pos)

        ## EOF window
        total_sites = max_pos-start_pos
        dxy_window = sum(dxy_values)/total_sites
        print(current_chrom+"\t"+str(start_pos)+"\t"+str(max_pos)+"\t"+str(nvariants)+"\t"+str(round(dxy_window, 8)))

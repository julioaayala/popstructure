#!/usr/bin/env python
import sys
import argparse
# **********************************
# Written by Julio Ayala
# Created on: July 2021
# **********************************

# Usage: Script to split maf files by chromosomes
# run the script simply as:
# ./splitmaf.py -i pop1.maf -o outputfolder
# Input is two MAF files

if __name__ == "__main__":
    # Args *****************************
    parser = argparse.ArgumentParser(description = '''Split MAF file by chromosomes.''')
    requiredNamed = parser.add_argument_group('Required:')
    requiredNamed.add_argument("-i", help="Input file", required=True)
    requiredNamed.add_argument("-o", help="Output folder", required=True)
    args = parser.parse_args()
    # **********************************

    outputbase = args.o + "/" + args.i.split("/")[-1].replace(".maf","")
    wf = None
    with open(args.i, 'r') as rf: # Open read file
        curchr = ""
        header = rf.readline()
        for line in rf:
            chr = line.split()[0]
            if chr!=curchr:
                print(chr)
                if curchr!="":
                    wf.close() #Close the writing file
                curchr = chr
                curfile = outputbase + "." + curchr + ".maf"
                print("Writing to:", curfile)
                wf = open(curfile, "w")
                wf.write(header)
            wf.write(line)

    print("Done")

#!/usr/bin/python
import sys
import pandas as pd
import numpy as np

""" **********************************
# Julio Ayala
# 2021.04.29
# Script to calculate intron and intergenic regions from a GFF file.

# Usage:
# The script receives a gff input file, and two output files (For intronic and intergenic regions)
# ./getexonsandinter.py input.gff outputintrons.txt outputintergenic.txt
**********************************"""

## Function to merge exons in non overlapping regions
def merge_exons(exons):
    ## Receives a list of exons with start and end positions, return merged exons where there are overlaps
    merged = []
    excluded_indexes = []
    for i in range(len(exons)):
        for j in range(len(exons)):
            if i!=j:
                ## j between i
                if exons[i][0] <= exons[j][0] and exons[i][1] >= exons[j][1]:
                    excluded_indexes.append(j)
                ## j overlaps on one side
                if (exons[i][0] <= exons[j][0]) and (exons[i][1] <= exons[j][1]) and (exons[i][1] >= exons[j][0]):
                    merged.append([exons[i][0],exons[j][1]])
                    excluded_indexes.append(j)
                    excluded_indexes.append(i)
    for i in range(len(exons)):
        if i not in excluded_indexes:
            merged.append(exons[i])

    if merged!=exons: ## Recursive step for chained elements
        tmp = []
        for i in merged:
            if i not in tmp:
                tmp.append(i)
        merged = merge_exons(tmp)
    return merged

## Function to get intergenic regions
def get_intergenic(df, chrlengths):
    ## Sort by start
    df_sorted = df.sort_values(["seqname", "start", "end"])
    genes = df_sorted.loc[(df_sorted["feature"] == "gene") & (df_sorted["seqname"].str.contains("scaffold")==False)]

    ## Calculate intergenic regions
    intergenic = []
    previous = 0
    previouschr = ""
    for index,row in genes.iterrows():
        if len(intergenic)>0 and intergenic[-1][0] !=  row["seqname"]:
            if (row["seqname"] in chrlengths.keys()): ## Add the end of chromosome if it the previous is the last region (Untested)
                intergenic.append([row["seqname"], previous, chrlengths[row["seqname"]]])
                print([row["seqname"], previous, chrlengths[row["seqname"]]])
            previous = 0 ## Reset in new chromosomes
        if (previous<(row["start"]-1)): # Prevent adding overlapping genes
            intergenic.append([row["seqname"], previous, row["start"]-1])
        previous = row["end"]
        previouschr = row["seqname"]
    return intergenic

## Function to get intronic regions
def get_introns(df):
    genes_exons = df.loc[(df["feature"].isin(["gene", "exon"])) & (df["seqname"].str.contains("scaffold")==False)]
    ## Calculate introns
    all_introns = []
    exons = []
    seqname = ""
    for index,row in genes_exons.iterrows():
        seqname = row.seqname
        if row["feature"] == "gene":
            if exons: ## Add the last intron of the previous gene
                ## Sort the exons
                exons = merge_exons(exons)
                exons = sorted(exons, key = lambda x: x[0])
                ## Add the first intron
                introns.append([seqname, gene_start, exons[0][0]])
                for i in range(len(exons)-1): #Add the positions between exons
                    introns.append([seqname, exons[i][1], exons[i+1][0]])

                ## Add the last intron of the previous gene
                introns.append([seqname, exons[-1][1], gene_end])

                for i in introns:
                    all_introns.append(i)

            gene_start = row["start"]
            gene_end = row["end"]
            introns = []
            exons = []

        else: ## Process exons
            ##Exons
            exons.append([row["start"], row["end"]])

    ## Sort the exons
    exons = merge_exons(exons)
    exons = sorted(exons, key = lambda x: x[0])
    ## Add the first intron
    introns.append([seqname, gene_start, exons[0][0]])
    for i in range(len(exons)-1): #Add the positions between exons
        introns.append([seqname, exons[i][1], exons[i+1][0]])
    ## Add the last intron of the previous gene
    introns.append([seqname, exons[-1][1], gene_end])
    for i in introns:
        all_introns.append(i)

    return all_introns



if __name__ == '__main__':
    file = sys.argv[1]
    intronsfile = sys.argv[2]
    intergenicfile = sys.argv[3]
    chrlengthsfile = sys.argv[4] if len(sys.argv) > 4 else ""
    ## Open gff file
    df = pd.read_csv(file, sep = "\t", names = ["seqname", "source", "feature", "start", "end", "score", "strand", "frame", "attribute"])
    chrlengths = {}

    # ## Open chromosomes file # Untested
    # with open(chrlengthsfile, 'r') as f:
    #     chrlengths = {line.split()[0]:int(line.split()[1]) for line in f}

    intergenic = get_intergenic(df, chrlengths)
    introns = get_introns(df)
    intergenic_length = 0
    introns_length = 0

    ## Add positions of intronic regions
    f = open(intronsfile, 'w')
    f.write("## Intron positions from " + file + "\n")
    for i in introns:
        introns_length += (i[2] - i[1])
        for j in range(i[1], i[2]+1):
            line = i[0] + "\t" + str(j) + "\n"
            f.write(line)
    f.close()

    ## Add positions of intergenic regions
    f = open(intergenicfile, 'w')
    f.write("## Intergenic positions from " + file + "\n")
    for i in intergenic:
        intergenic_length += (i[2] - i[1])
        for j in range(i[1], i[2]+1):
            line = i[0] + "\t" + str(j) + "\n"
            f.write(line)
    f.close()

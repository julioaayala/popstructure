#!/usr/bin/python3

""" **********************************
# Julio Ayala
# 2021.04.12
# Simple script to calculate mean and standard deviation given a column

# Usage:
# The script receives a gff input file, and two output files (For intronic and intergenic regions)
# ./meanstdev.py file 0_based_column
**********************************"""

import sys
import statistics

file = sys.argv[1]
column = int(sys.argv[2])
contents = []

with open(file, 'r') as f:
    lines = f.readlines()
    for line in lines[1:]:
        if line.split()[column]!="nan":
            contents.append(float(line.split()[column]))

print(file +"\t"+str(statistics.mean(contents))+"\t"+str(statistics.stdev(contents)))

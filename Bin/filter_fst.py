#!/usr/bin/env python
import pandas as pd
import numpy as np
import sys

# **********************************
# Written by Julio Ayala
# Created on: June 2021
# Updated on: May 2021
# Script to get regions of outlier FST (>= x standard deviations) from an ANGSD FST file
# **********************************

# Usage: ./filter_fst.py input_file standard_deviations
# Example: ./filter_fst.py corsica.crete.autosomes.windowed 4

# Parse arguments
file = sys.argv[1]
standard_deviations = int(sys.argv[2])
out = sys.argv[1] + "_sd" + str(standard_deviations)
out_positions = sys.argv[1] + "_sd" + str(standard_deviations) + "_pos"

# Read file
df = pd.read_csv(file, sep = "\t", names = ["region", "chr", "midPos", "Nsites", "Fst"])
df = df.iloc[1:,:] ## Remove header

# Get normalized FST and filter
df["Z"] = df.Fst.apply(lambda x: (x - np.mean(df.Fst))/np.std(df.Fst))
filtered = df[df.Z >= standard_deviations]

# Write to output file
filtered.to_csv(out, sep = "\t", index = False)
print("Filtered file saved at: ",out)

#!/usr/bin/env python
"""Remove transcripts with duplicated accession numbers, GOs, and positions

For Claire Merot on 2021-10-21 on file `ncbi_genes_annot.txt`

Usage:
    <program> input_file output_file
"""

# Modules
import sys

# Parse user input
try:
    input_file = sys.argv[1]
    output_file = sys.argv[2]
except:
    print(__doc__)
    sys.exit(1)

# Let's go
prev = []


with open(input_file) as infile:
    with open(output_file, "wt") as outfile:
        for line in infile:
            l = line.strip().split("\t")

            if not prev:
                prev = l
                continue

            if l[5] != prev[5]:
                outfile.write("\t".join(prev) + "\n")
                prev = l

            else:
                # Increase range in prev if needed
                if int(l[1]) < int(prev[1]):
                    prev[1] = l[1]

                if int(l[2]) > int(prev[2]):
                    prev[2] = l[2]

        # Flush last line if not equal to prev
        outfile.write("\t".join(prev) + "\n")

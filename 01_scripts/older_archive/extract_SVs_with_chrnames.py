#!/usr/bin/env python3
"""Extract SVs and flanking regions from genome

Usage:
    <program> input_sv_file input_genome flanking_size output_fasta
"""

# Modules
from collections import defaultdict
import gzip
import sys

# Classes
class Fasta(object):
    """Fasta object with name and sequence
    """

    def __init__(self, name, sequence):
        self.name = name
        self.sequence = sequence

    def write_to_file(self, handle):
        handle.write(">" + self.name + "\n")
        handle.write(self.sequence + "\n")

    def __repr__(self):
        return self.name + " (" + str(len(self.sequence)) + "bp) " + self.sequence

# Defining functions
def myopen(_file, mode="rt"):
    if _file.endswith(".gz"):
        return gzip.open(_file, mode=mode)

    else:
        return open(_file, mode=mode)

def fasta_iterator(input_file):
    """Takes a fasta file input_file and returns a fasta iterator
    """
    with myopen(input_file) as f:
        sequence = []
        name = ""
        begun = False

        for line in f:
            line = line.strip()

            if line.startswith(">"):
                if begun:
                    yield Fasta(name, "".join(sequence))

                name = line[1:]
                sequence = ""
                begun = True

            else:
                sequence += line

        if name != "":
            yield Fasta(name, "".join(sequence))

# Parse user input
try:
    input_sv_file = sys.argv[1]
    input_genome = sys.argv[2]
    flanking_size = int(sys.argv[3])
    output_fasta = sys.argv[4]
except:
    print(__doc__)
    sys.exit(1)

# Read SV file
svs = defaultdict(list)
with myopen(input_sv_file) as infile:
    for line in infile:
        l = line.strip().split()
        _ch, _from, _to, _type, _len, _var1, _var2 = l
        svs[_ch].append((int(_from), int(_to), _type, abs(int(_len)), _var1, _var2))

# Iter through genome and extract SVs
sequences = fasta_iterator(input_genome)
sv_counter = 0

with myopen(output_fasta, "wt") as outfile:
    for seq in sequences:
        print(seq.name)

        for sv in svs[seq.name]:
            sv_counter += 1
            _from, _to, _type, _len, _var1, _var2 = sv

            if _type == "INS":
                if not "<INS>" in _var2:
                    sequence = _var2
                    left_pos = max(0, _from - flanking_size)
                    right_pos = min(_to + flanking_size - 1, len(seq.sequence))
                    left = Fasta("left", seq.sequence[left_pos: _from - 1])
                    middle = Fasta("middle", sequence)
                    right = Fasta("right", seq.sequence[_to - 1: right_pos])
                    wanted = Fasta("sv_" + seq.name + "_INS_" + str(sv_counter), left.sequence + middle.sequence + right.sequence)
                    wanted.write_to_file(outfile)

            elif _type == "DEL":
                sequence = _var1
                left_pos = max(0, _from - flanking_size)
                right_pos = min(_to + flanking_size - 1, len(seq.sequence))
                left = Fasta("left", seq.sequence[left_pos: _from])
                middle = Fasta("middle", seq.sequence[_from: _to - 1])
                right = Fasta("right", seq.sequence[_to - 1: right_pos])
                wanted = Fasta("sv_" + seq.name + "_DEL_" + str(sv_counter), left.sequence + right.sequence)
                wanted.write_to_file(outfile)

            elif _type == "INV":
                sequence = _var2
                left_pos = max(0, _from - flanking_size)
                right_pos = min(_to + flanking_size - 1, len(seq.sequence))
                left = Fasta("left", seq.sequence[left_pos: _from])
                middle = Fasta("middle", sequence)
                right = Fasta("right", seq.sequence[_to - 1: right_pos])
                wanted = Fasta("sv_" + seq.name + "_INV_" + str(sv_counter), left.sequence + middle.sequence + right.sequence)
                wanted.write_to_file(outfile)

            elif _type == "DUP":
                sequence = _var1
                left_pos = max(0, _from - flanking_size)
                right_pos = min(_to + flanking_size - 1, len(seq.sequence))
                left = Fasta("left", seq.sequence[left_pos: _from])
                middle = Fasta("middle", seq.sequence[_from: _to - 1])
                right = Fasta("right", seq.sequence[_to - 1: right_pos])
                wanted = Fasta("sv_" + seq.name + "_DUP_" + str(sv_counter), left.sequence + middle.sequence + middle.sequence + right.sequence)
                wanted.write_to_file(outfile)

            else:
                print(sv)
                print("Error: You should never get here!!!")
                sys.exit(1)

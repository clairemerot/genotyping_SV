#!/bin/bash
#SBATCH -J "vgcombine"
#SBATCH -o log_%j
#SBATCH -c 1 
#SBATCH -p large
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=21-00:00
#SBATCH --mem=150G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

# Loading module
#module load pggb/0.1.0
NB_CPU=1

# combine the gfa produce by chromosomes by pggb


#INPUT_DIR=06_pggb/genome_graph
INPUT_DIR=06_pggb/essai
OUT_GRAPH=06_pggb/merged.gfa

vg ids -j $(ls "$INPUT_DIR"/all_seq_Chr??.fasta.7405a83.d0e96a4.891e76b.smooth.gfa)

vg combine $(ls "$INPUT_DIR"/all_seq_Chr??.fasta.7405a83.d0e96a4.891e76b.smooth.gfa) > $OUT_GRAPH
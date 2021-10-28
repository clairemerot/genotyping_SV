#!/bin/bash
#SBATCH -J "vg_index"
#SBATCH -o vg_index_%j.out
#SBATCH -c 1 
#SBATCH -p small
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=1-00:00
#SBATCH --mem=20G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

# Loading the htslib module for compressing and indexing
module load htslib/1.10.2


##adjust ids when multiple chromosomes -> put them in a join id space.
#this is required befor indexing
vg ids -j $(ls 07_vg/genome_graph/Chr??.vgp)

#$vg index -L -p -k 16 -x graph.xg $(ls Gm??.vgp) 
#-L include alternative path, -p show progress, -k kmer size, -t threads
vg index -L -p -k 16 -x 07_vg/genome_graph/graph.xg $(ls 07_vg/genome_graph/Chr??.vgp) 

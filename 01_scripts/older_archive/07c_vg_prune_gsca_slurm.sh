#!/bin/bash
#SBATCH -J "vg_prune_index"
#SBATCH -o vg_prune_%j.out
#SBATCH -c 1 
#SBATCH -p small
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=1-00:00
#SBATCH --mem=100G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

NB_CPU=1



#prune complex regions from graph, parralelising each chromsome
#-t1 1 thread, -p show progress, -r restore edges

#ls -1 07_vg/genome_graph/Chr??.vgp | parallel -j 4 "vg prune -p -t1 -r {} > {.}.pruned.vgp"


mkdir 07_vg/tmpdir
#index the pruned graph
#for all chromosomes
vg index -p -t 1 -b 07_vg/tmpdir -g 07_vg/genome_graph/graph.gcsa $(ls 07_vg/genome_graph/*.pruned.vgp)








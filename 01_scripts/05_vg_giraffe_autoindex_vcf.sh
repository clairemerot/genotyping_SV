#!/bin/bash
#SBATCH -J "vg_autoindex"
#SBATCH -o vg_autoindex_%j.out
#SBATCH -c 8 
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=7-00:00
#SBATCH --mem=200G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

# Loading the htslib module for compressing and indexing
#module load htslib/1.10.2
NB_CPU=8

# Creating some variables for easier scripting
ref=03_genome/genome.fasta
vcf_file=04_vcfs/LR_SR_GA_sorted_noind.vcf.gz

#clean
rm -r 05_graph/TMPDIR


mkdir 05_graph/TMPDIR

#use the autoindex workflow to build the graph with genome + unpahsed vcf
#it would be better to use the gfa (from pggb) or a phsed vcf?
vg autoindex --workflow giraffe \
--prefix 05_graph/vcf_graph_giraffe \
--tmp-dir 05_graph/TMPDIR \
--target-mem 190G --threads 8 \
-R XG \
--ref-fasta $ref \
--vcf $vcf_file 


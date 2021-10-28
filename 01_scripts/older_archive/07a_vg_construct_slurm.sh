#!/bin/bash
#SBATCH -J "vg_construct"
#SBATCH -o log_vgconstruct_%j.out
#SBATCH -c 2 
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=7-00:00
#SBATCH --mem=10G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

# Loading the htslib module for compressing and indexing
#module load htslib/1.10.2
NB_CPU=2

# Creating some variables for easier scripting
ref=02_info/genome.fasta
vcf_file=03_vcf_SVlist/LR_SR_sorted_noind.vcf.gz

##step1: construct the graph per chromosome

#the vcf of variants needs to be bgzip with tabix: to do just once
# We may need to sort the vcf then compressing and indexing it
#I also use pre-steps to remove TRA, too long SVs and keep only Svs on chromosomes (remove scaf)
#all of this is the 03_filter_vcfs.sh script

# Running the command with option -a to ensure the paths will be kept for genotyping
#t1 and m32 are for computation? -C indicate it is just one chromosome 
#-a, --alt-paths        save paths for alts of variants by variant ID
#  -f, --flat-alts N      don't chop up alternate alleles from input VCF
#-S include SV
# -v input vcf (must be bgzip and tabix
# For large insertions it may be possible to give sequence with -S (handle SV) and -I, --insertions FILE  a FASTA file containing insertion sequences(referred to in VCF) to add to graph.

#to loop over chr
mkdir 07_vg/genome_graph
seq -w 01 40 | xargs -I {} echo Chr{} | parallel -j $NB_CPU "vg construct -a -t1 -m32 -C -S -R {} -r $ref -v $vcf_file --flat-alts > 07_vg/genome_graph/{}.vg"

#for one chr
#$vg construct -a -t1 -m32 -C -R Chr34 -r $ref -v $vcf_file --flat-alts > 07_vg/genome_graph/Chr34.vg

##step 2 pack the graph per chromosome
# Then converting the graphs to PackedGraph format in order to use less memory (as advised by JA Sibbesen)
ls 07_vg/genome_graph/Chr??.vg | parallel -j $NB_CPU "vg convert -p {} > {.}.vgp"

#$vg convert -p 07_vg/genome_graph/NC_027300.vg > 07_vg/genome_graph/NC_027300.vgp



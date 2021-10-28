#!/bin/bash
#SBATCH -J "pggb"
#SBATCH -o pggb_%j.out
#SBATCH -c 8 
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=4-00:00
#SBATCH --mem=350G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

# Loading module
module load pggb/0.1.0
module load samtools
NB_CPU=8

# Making a fasta file with the sequences from the genomes and the SVs
#we need to concatenate
#le chromosome i de genome.fasta
#les séquences autour des SVs
#les contigs qui alignent avec chr i
mkdir 06_pggb/genome_graph


SEG_LENGTH=25000
OUT_DIR=06_pggb/genome_graph

cat 02_info/chromosomes.bed | cut -f1 | while read i
do 
echo "build genome_graph for $i"

#if zipped
#for a mysterious reason it is not zipped
gunzip 04_fasta/all_seq_"$i".fasta.gz
#mv 04_fasta/all_seq_"$i".fasta.gz 04_fasta/all_seq_"$i".fasta

INPUT_FASTA=04_fasta/all_seq_"$i".fasta

samtools faidx $INPUT_FASTA
# Building the graph
pggb -i $INPUT_FASTA \
-s $SEG_LENGTH -n 1 \
-p 95 \
-k 200 \
-N \
-t $NB_CPU \
-o $OUT_DIR

gzip $INPUT_FASTA
done

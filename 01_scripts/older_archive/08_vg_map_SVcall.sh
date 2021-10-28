#!/bin/bash
#SBATCH -J "vgmap_SVcall"
#SBATCH -o vgm_SVcall_%j.out
#SBATCH -c 4 
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=7-00:00
#SBATCH --mem=120G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

NB_CPU=4

# Loading the htslib module and creating variables for easier scripting
module load htslib/1.10.2
module load bcftools/1.12


# Creating a variable for the id of the sample
#or loop over samples?
ref=02_info/genome.fasta
vcf_file=03_vcf_SVlist/final.vcf.gz
graph=07_vg/genome_graph/graph.xg

ind=HI.3815.008.Index_7.CN11
id=CN11

#getting stats
vg stats -a 08_vgmap/alignment/"$id"_paired.gam > 08_vgmap/alignment/"$id".stats

# Packing the alignments
vg pack -t $NB_CPU -Q 5 -x $graph -g 08_vgmap/alignment/"$id"_paired.gam -o 08_vgmap/alignment/"$id".pack

mkdir 08_vgmap/variants
# Calling variants based on the variant-aware graph
vg call -t $NB_CPU -v $vcf_file -k 08_vgmap/alignment/"$id".pack $graph > 08_vgmap/variants/"$id"_calls.vcf


# Compressing the vcf with bgzip

#bgzip 09_vgiraffe/vcf_graph/variants/"$id"_calls.vcf
#tabix 09_vgiraffe/vcf_graph/variants/"$id"_calls.vcf

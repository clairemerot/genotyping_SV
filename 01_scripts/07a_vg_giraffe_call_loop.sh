#!/bin/bash
#SBATCH -J "vgiraffe_SVcall"
#SBATCH -o vg_SVcall_%j.out
#SBATCH -c 6 
#SBATCH -p large
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=21-00:00
#SBATCH --mem=150G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

NB_CPU=6

# Loading the htslib module and creating variables for easier scripting
module load htslib/1.10.2
module load bcftools/1.12


#prepare
ref=02_info/genome.fasta
graph=05_graph/vcf_graph_giraffe.xg
snarls=05_graph/vcf_graph_giraffe.pb

#get the snarls
vg snarls -t $NB_CPU $graph > $snarls

cat 02_info/id.list 02_info/id_bis.list | while read id
do 

echo $id

# Calling variants based on the variant-aware graph
##the a option compute genotype for all snarls (not only not-ref)
##we have compute the snarls for all samples once earlier to make it faster
vg call -t $NB_CPU -a -k 09_vgiraffe/vcf_graph/alignment/"$id".pack -r $snarls -f $ref $graph > 07_variants/"$id"_calls.vcf
bgzip 07_variants/"$id"_calls.vcf

done
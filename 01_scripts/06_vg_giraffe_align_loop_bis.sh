#!/bin/bash
#SBATCH -J "vgiraffe"
#SBATCH -o vgirafalign_%j.out
#SBATCH -c 4 
#SBATCH -p large
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=21-00:00
#SBATCH --mem=100G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

NB_CPU=4

# Loading the htslib module and creating variables for easier scripting
module load htslib/1.10.2



cat 02_info/id_bis.list | while read id
do 

# Creating a variable for the id of the sample
#or loop over samples?

ind=$(grep $id 02_info/fq_bis.list)

echo $id
echo $ind

# Creating variables for the location of the input files
fq1=../wgs_sample_preparation_ALL/05_trimmed/${ind}_1.trimmed.fastq.gz
fq2=../wgs_sample_preparation_ALL/05_trimmed/${ind}_2.trimmed.fastq.gz


# Mapping the paired reads
# -t threads -f for the fastq

vg giraffe -t $NB_CPU \
-H 05_graph/vcf_graph_giraffe.giraffe.gbwt \
-g 05_graph/vcf_graph_giraffe.gg \
-m 05_graph/vcf_graph_giraffe.min \
-d 05_graph/vcf_graph_giraffe.dist \
-f $fq1 -f $fq2 -N $id > 06_alignment/"$id"_paired.gam

vg pack -t $NB_CPU -Q 5 -x 05_graph/vcf_graph_giraffe.xg -g 06_alignment/"$id"_paired.gam -o 06_alignment/"$id".pack

done

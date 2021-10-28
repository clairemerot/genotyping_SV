#!/bin/bash
#SBATCH -J "jasmine"
#SBATCH -o log_%j
#SBATCH -c 1 
#SBATCH -p small
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=1-00:00
#SBATCH --mem=20G

###this script will join Sv from SR and LR
#maybe edit
NB_CPU=1 #change accordingly in SLURM header

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

#load the program. It requires python 3
__conda_setup="$('/home/camer78/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/camer78/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/camer78/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/camer78/miniconda3/bin:$PATH"
    fiq
fi
unset __conda_setup

module load bcftools/1.12
module load samtools

jasmine=/home/camer78/miniconda3/bin/jasmine


#input a list of vcf files (should not be zip)
BASE="LR_SR_GA"

VCFlist=04_vcfs/"$BASE".list
OUTfile=04_vcfs/"$BASE".vcf
ref=03_genome/genome.fasta

jasmine file_list=$VCFlist out_file=$OUTfile  genome_file=$ref \
--ignore_strand --mutual_distance \
--max_dist_linear=0.1 --min_dist=50 --use_end \
--mutual_distance --output_genotypes --normalize_type threads=$NB_CPU 



#Export info to study overlap
bcftools query -f '%CHROM %POS %INFO/END %INFO/SVTYPE %INFO/SVLEN %INFO/SUPP_VEC %INFO/SUPP\n' $OUTfile > 04_vcfs/"$BASE".bed

echo "nb of SV"
grep -v ^\# 04_vcfs/"$BASE".vcf | wc -l #260940 (among which 40238 overlap)




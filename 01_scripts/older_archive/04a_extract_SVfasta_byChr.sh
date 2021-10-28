#!/bin/bash
#SBATCH -J "04extractfasta"
#SBATCH -o log_%j
#SBATCH -c 1 
#SBATCH -p small
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=1-00:00
#SBATCH --mem=10G

#This script may not need to be run via slurm.
#It takes the vcf with the relevant SVS, filter and format it, and keep some output 

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
    fi
fi
unset __conda_setup

module load bcftools/1.12

#split the information about SV by chromosomes and extract the fasta
ref=02_info/genome.fasta
flank_size=50000
sv_file=04_fasta/final_SV_with_seq.txt


cat 02_info/chromosomes.bed | cut -f1 | while read i
do 
echo "extract SV flanking seq for $i"

grep $i $sv_file > 04_fasta/final_SV_with_seq_"$i".txt

INPUT_SV_i=04_fasta/final_SV_with_seq_"$i".txt
OUTPUT_FASTA_i=04_fasta/final_SV_"$i"_"$flank_size".fasta

python 01_scripts/utility/extract_SVs_with_chrnames.py $INPUT_SV_i 02_info/genome.fasta $flank_size $OUTPUT_FASTA_i
gzip $OUTPUT_FASTA_i

rm $INPUT_SV_i
done

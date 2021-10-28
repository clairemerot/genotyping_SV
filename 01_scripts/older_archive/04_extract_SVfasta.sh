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


INPUT_SV=04_fasta/final_SV_with_seq.txt
flank_size=0
ref=02_info/genome.fasta
OUTPUT_FASTA=04_fasta/final_SV_"$flank_size".fasta

python 01_scripts/utility/extract_SVs.py $INPUT_SV $ref $flank_size $OUTPUT_FASTA


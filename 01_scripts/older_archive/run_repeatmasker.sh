#!/bin/bash
#SBATCH -J "RepeatMasker"
#SBATCH -o log_%j
#SBATCH -c 5 
#SBATCH -p medium
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=7-00:00
#SBATCH --mem=80G



# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

module load RepeatMasker/4.1.2

fasta_file=04_fasta/final_SV_0.fasta

RepeatMasker  $fasta_file -pa 5 -lib ../TE/lake_whitefish_families_renamed.fasta

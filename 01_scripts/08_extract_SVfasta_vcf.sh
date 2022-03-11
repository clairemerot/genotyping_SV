#!/bin/bash
#SBATCH -J "08extractfasta"
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

#☻variables: on which Sv dataset are we working?
INPUT_VCF=04_vcfs/LR_SR_GA_sorted.vcf
SEQ_SV=08_fasta_SV/LR_SR_GA
NB_CPU=5

##extract sequences into fasta
#very simple without flanking seq
module load bcftools
#bcftools query -f '%CHROM %POS %REF %ALT\n' $INPUT_VCF > $SEQ_SV

#Rscript 01_scripts/Rscripts/extract_SV_fasta.r "$SEQ_SV"
head -n 2 "$SEQ_SV".info
#less -S "$SEQ_SV".fasta


##run repeatMasker
module load RepeatMasker/4.1.2

RepeatMasker  "$SEQ_SV".fasta -pa $NB_CPU -lib ../TE/lake_whitefish_families_renamed.fasta -dir 08_fasta_SV


##convert in fasta
#we can use Eric's scripts that add a flanking sequence by looking into the genome...
#bcftools query -f '%CHROM %POS %INFO/END %INFO/SVTYPE %INFO/SVLEN %REF %ALT\n' $INPUT_VCF > $SEQ_SV

#__conda_setup="$('/home/camer78/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
#if [ $? -eq 0 ]; then
#    eval "$__conda_setup"
#else
#    if [ -f "/home/camer78/miniconda3/etc/profile.d/conda.sh" ]; then
#        . "/home/camer78/miniconda3/etc/profile.d/conda.sh"
#    else
#        export PATH="/home/camer78/miniconda3/bin:$PATH"
#    fi
#fi
#unset __conda_setup
#
#flank_size=0
#ref=03_genome/genome.fasta
#python 01_scripts/utility/extract_SVs.py $SEQ_SV $ref $flank_size $OUTPUT_FASTA
#

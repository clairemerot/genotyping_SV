#!/bin/bash
#SBATCH -J "04bextractfasta"
#SBATCH -o log_%j
#SBATCH -c 1 
#SBATCH -p small
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=1-00:00
#SBATCH --mem=10G

#This script may not need to be run via slurm.
#It takes list of chromosome or scaffold to extract and make a fasta
#then it gather everything into a single fasat (sequence form ref, sequence from 2nd genome, sequence from Sv)

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

#first run the extract SVfasta by chromosome
flank_size=50000

#path to the reference genome
REF_GENOME=02_info/genome.fasta
mkdir 02_info/chr_list

#path to the alternative gneome
ALT_GENOME=02_info/dwarf.contigs.fasta

#we need to know which contigs of the ALT genome aligned to each chromosome of the REF genome
#We run genome masking for reapeat and mummer alignement of the ALT genome on the REF genome to get the following file 
MUM_FILE=../assembly_sv/04_nucmer/dwarf.masked.contigsvsnormal.masked.chrsonly.mum
#then a Rscript to keep only contigs passing some filters
#and ouptut a 
SIM=80 #80 =min % of similarity
MIN_SIZE=500 #500 =min length of the aligned block
MIN_PROP=20 #20 =min % of the contig mapping to that chromosome
OUTPATH="02_info/chr_list/contigs"
Rscript 01_scripts/Rscripts/extract_contigs_nucmer.r "$MUM_FILE" "02_info/chromosomes.bed" "$SIM" "$MIN_SIZE" "$MIN_PROP" "$OUTPATH"




cat 02_info/chromosomes.bed | cut -f1 | while read i
do 

#make a file with the chromosome name, extract the fasta seq form the ref
echo "extract $i in reference genome"
#echo "$i" > 02_info/chr_list/"$i".txt
#python 01_scripts/utility/fasta_extract.py $REF_GENOME 02_info/chr_list/"$i".txt 04_fasta/ref_"$i".fasta
#gzip 04_fasta/ref_"$i".fasta

#then extract the fasta seq of contigs aligning to chr i in the alternative genome
echo "extract scaffolds corresponding to $i in altenative genome"
python 01_scripts/utility/fasta_extract.py $ALT_GENOME 02_info/chr_list/contigs_"$i".txt 04_fasta/alt_"$i".fasta

#rename Lg above a given size with a file of correpsondence
#uses Eric python scripts
# <program> input_fasta correspondence min_length output_fasta
python 01_scripts/utility/rename_scaffolds.py 04_fasta/alt_"$i".fasta 02_info/chr_list/contigs_"$i"_renaming.txt 500 04_fasta/alt_"$i"_renamed.fasta
gzip 04_fasta/alt_"$i"_renamed.fasta
rm 04_fasta/alt_"$i".fasta

#groupe all seq in one file for use in pggb
echo "concatenate fasta of ref genome, altenative genome, and SV for $i"
#gzip 04_fasta/final_SV_"$i".fasta
zcat 04_fasta/ref_"$i".fasta.gz 04_fasta/alt_"$i"_renamed.fasta.gz 04_fasta/final_SV_"$i"_"$flank_size".fasta.gz | gzip > 04_fasta/all_seq_"$i".fasta.gz

done

#rm 04_fasta/ref_*.fasta.gz
#rm 04_fasta/alt_*.fasta.gz
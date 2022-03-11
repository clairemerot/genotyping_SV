#!/bin/bash
#SBATCH -J "10_bypop_fromVCF"
#SBATCH -o log_%j
#SBATCH -c 4 
#SBATCH -p small
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=1-00:00
#SBATCH --mem=10G

###this script will work on all bamfiles and calculate saf, maf & genotype likelihood
#maybe edit
NB_CPU=4 #change accordingly in SLURM header
#REGIONS="-rf 02_info/regions_25kb_100snp.txt" #optional edit with your region selected file
REGIONS="" # to remove the options to focus on a limited number of regions

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

module load angsd
module load bcftools
ulimit -S -n 2048

#prepare variables - avoid to modify

VCF_FILE=09_angsd/ALLDP1_MISS50_2all_maf0.05.vcf.gz

cat 02_info/pop.txt | while read i
do
echo $i
N_IND=$(wc -l 02_info/"$i"id.filelist | cut -d " " -f 1)

#filter vcf
bcftools view -S 02_info/"$i"id.filelist -o 10_bypop/"$i".vcf.gz -Oz $VCF_FILE

echo " Calculate the SAF, MAF for $NIND in vcf $VCF_FILE"
####Calculate the SAF, MAF 
#with vcf input I can't get the beagle...
angsd -vcf-gl 10_bypop/"$i".vcf.gz \
-nind $N_IND -minInd 5 -fai 03_genome/genome.fasta.fai -anc 03_genome/genome.fasta -domaf 1 -dosaf 1 -doMajorMinor 5 \
-out 10_bypop/"$i"
done

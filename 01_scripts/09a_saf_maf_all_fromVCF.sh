#!/bin/bash
#SBATCH -J "09_maf_fromVCF"
#SBATCH -o log_%j
#SBATCH -c 1 
#SBATCH -p small
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=1-00:00
#SBATCH --mem=2G

###this script will work on all bamfiles and calculate saf, maf & genotype likelihood
#maybe edit
NB_CPU=4 #change accordingly in SLURM header

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

module load angsd
module load bcftools
ulimit -S -n 2048

#prepare variables - avoid to modify
N_IND=32
VCF_FILE=07_variants/ALLDP1_MISS50_2all.forangsd.vcf

echo " Calculate the SAF, MAF for $NIND in vcf $VCF_FILE"

####Calculate the SAF, MAF 
#with vcf input I can't get the beagle...
angsd -vcf-gl $VCF_FILE \
-nind $N_IND -fai 03_genome/genome.fasta.fai -anc 03_genome/genome.fasta -domaf 1 -dosaf 1 -doMajorMinor 5 \
-out 09_angsd/ALLDP1_MISS50_2all

#filter for maf >0.05 (and <0.95) as this is not a minor all freq but a reference all freq
gunzip -c 09_angsd/ALLDP1_MISS50_2all.mafs.gz | head
gunzip -c 09_angsd/ALLDP1_MISS50_2all.mafs.gz | awk '{ if ($6 >= 0.05 && $6<=0.95) { print } }' > 09_angsd/ALLDP1_MISS50_2all_maf0.05.mafs

wc -l 09_angsd/ALLDP1_MISS50_2all_maf0.05.mafs #110475

cat 09_angsd/ALLDP1_MISS50_2all_maf0.05.mafs | awk -v OFS='\t' '{print $1,$2-1,$2}' > 09_angsd/ALLDP1_MISS50_2all_maf0.05.bed
head 09_angsd/ALLDP1_MISS50_2all_maf0.05.bed

bgzip -c $VCF_FILE > $VCF_FILE.gz
tabix $VCF_FILE.gz
bcftools view -R 09_angsd/ALLDP1_MISS50_2all_maf0.05.bed -o 09_angsd/ALLDP1_MISS50_2all_maf0.05.vcf -Ov $VCF_FILE.gz

grep -v ^\# 09_angsd/ALLDP1_MISS50_2all_maf0.05.vcf | head
grep -v ^\# 09_angsd/ALLDP1_MISS50_2all_maf0.05.vcf | wc -l
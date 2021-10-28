#!/bin/bash
#SBATCH -J "vgiraffe_merge"
#SBATCH -o log_%j
#SBATCH -c 1 
#SBATCH -p small
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=1-00:00
#SBATCH --mem=5G

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

NB_CPU=1
module load bcftools/1.13


cat 02_info/id.list 02_info/id_bis.list | while read id
do 

echo $id

#renaming the file for sample name
echo $id > 07_variants/id_temp.txt
bcftools reheader -s 07_variants/id_temp.txt -o 07_variants/"$id"_calls_renamed.vcf 07_variants/"$id"_calls.vcf.gz

#count variants
gunzip -c 07_variants/"$id"_calls.vcf.gz | grep -v ^\#  | wc -l 

#Filtering based on filter
#bcftools filter -i 'FILTER="PASS"' -o 07_variants/"$id"_filter.vcf -Ov 07_variants/"$id"_calls_renamed.vcf
#grep -v ^\#\# 07_variants/"$id"_filter.vcf | wc -l 
#bgzip -c 07_variants/"$id"_filter.vcf > 07_variants/"$id"_filter.vcf.gz
#tabix 07_variants/"$id"_filter.vcf.gz

#Filtering based on depth
bcftools filter -e 'INFO/DP<1' -o 07_variants/"$id"_DP1.vcf -Ov 07_variants/"$id"_calls_renamed.vcf
grep -v ^\#\# 07_variants/"$id"_DP1.vcf | wc -l 
bgzip -c 07_variants/"$id"_DP1.vcf > 07_variants/"$id"_DP1.vcf.gz
tabix 07_variants/"$id"_DP1.vcf.gz

#unfiltered
bcftools filter -e 'INFO/DP<0' -o 07_variants/"$id"_unfiltered.vcf -Ov 07_variants/"$id"_calls_renamed.vcf
grep -v ^\#\# 07_variants/"$id"_unfiltered.vcf | wc -l 
bgzip -c 07_variants/"$id"_unfiltered.vcf > 07_variants/"$id"_unfiltered.vcf.gz
tabix 07_variants/"$id"_unfiltered.vcf.gz
done

#it reorders samples by alphabetical order at the same time
#bcftools merge $(ls 07_variants/*_filter.vcf.gz) -o 09_vgiraffe/vcf_graph/all_samples_filter.vcf -Ov
bcftools merge $(ls 07_variants/*_DP1.vcf.gz) -o 09_vgiraffe/vcf_graph/all_samples_DP1.vcf -Ov
bcftools merge $(ls 07_variants/*_unfiltered.vcf.gz) -o 09_vgiraffe/vcf_graph/all_samples_unfiltered.vcf -Ov

#clean by removing intermediate files
rm 07_variants/*_renamed*
#rm 07_variants/*filter*
rm 07_variants/*_DP1*
rm 07_variants/*_unfiltered*
rm 07_variants/id_temp.txt
#!/bin/bash
#SBATCH -J "svtyper"
#SBATCH -o log_%j
#SBATCH -c 1 
#SBATCH -p large
#SBATCH --mail-type=ALL
#SBATCH --mail-user=claire.merot@gmail.com
#SBATCH --time=10-00:00
#SBATCH --mem=10G

###this script will work on all bamfiles and run manta to detect SV
#maybe edit
NB_CPU=1 #change accordingly in SLURM header

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

#load the program. It requires python 2.7
#conda deactivate
module load python/2.7
module load svtyper


#run SVtyper
#it is super fast	
#it requires to add the information CIENd and CIPOS in the I§NFO field of the vcf,
#see utility script "annotate bcftools"
#it does not support some variants (INS)

#INPUT=02_info/test_CIPOS.vcf
#OUTPUT=05_svtyper/allsamples.kristina.vcf

INPUT=03_vcf_SVlist/LR_SR_sorted_noind.vcf_formatted_SVtyper
OUTPUT=05_svtyper/LR_SR


svtyper --input_vcf "$INPUT".vcf \
--output_vcf "$OUTPUT".vcf \
-B ../wgs_sample_preparation_AMER/09_no_overlap/CD17.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CD18.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CD19.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CD20.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CD21.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CD22.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CD28.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CD32.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CN10.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CN11.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CN12.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CN14.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CN15.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CN5.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CN6.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/CN7.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/ID13.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/ID14.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/ID1.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/ID2.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/ID3.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/ID4.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/ID7.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/ID9.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/IN10.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/IN12.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/IN14.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/IN5.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/IN6.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/IN7.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/IN8.bam\
,../wgs_sample_preparation_AMER/09_no_overlap/IN9.bam


#subsequent editing of vcfmodule load vcftools
module load vcftools
module load bcftools/1.12
#keep aside the information about variant position, end, precision, quality etc.
#NB the FILTER field is change from the original vcf so it is likely recalculated including Kyle samples
 grep -v ^\#\# "$OUTPUT".vcf | cut -f 1-8 > "$OUTPUT".variants

#keep only our samples
#bcftools view --samples-file 02_info/ind.list -Ov "$OUTPUT".vcf > "$OUTPUT"_AMERsamples.vcf

#get frequency, counts and 012 genotype
vcftools --vcf  "$OUTPUT".vcf --freq --out "$OUTPUT"
vcftools --vcf  "$OUTPUT".vcf --counts --out "$OUTPUT"
vcftools --vcf  "$OUTPUT".vcf --012 --recode --out "$OUTPUT"

#i should likley filter
#we can filter on GQ (genotype quality) or on SQ
#which threhold for GQ?? How to filter on SQ?
vcftools --vcf  "$OUTPUT".vcf --freq --minGQ 5 --out "$OUTPUT".minGQ5
vcftools --vcf  "$OUTPUT".vcf --counts --minGQ 5 --out "$OUTPUT".minGQ5
vcftools --vcf  "$OUTPUT".vcf --012 --minGQ 5 --out "$OUTPUT".minGQ5

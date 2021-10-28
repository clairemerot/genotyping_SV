#This script may not need to be run via slurm.it will need manual edits
#It takes the vcf with the relevant SVS, filter and format it, and keep some output 

# Important: Move to directory where job was submitted
cd $SLURM_SUBMIT_DIR

NB_CPU=1
module load htslib/1.10.2
module load bcftools/1.12
module load vcftools


VCF_FOLDER=04_vcfs/TMP_VCF
INPUT_VCF=04_vcfs/merge_iris_with_insertion_sequence.vcf.gz # we will try not to modify this one
OUT_VCF=04_vcfs/LR_final.vcf

mkdir  $VCF_FOLDER
cp $INPUT_VCF $VCF_FOLDER/raw.vcf.gz
gunzip $VCF_FOLDER/raw.vcf.gz

#check what it oolk like
#grep -v ^\#\# $VCF_FOLDER/raw.vcf | head 
#tail $VCF_FOLDER/raw.vcf 
echo "total number of SVs"
grep -v ^\# $VCF_FOLDER/raw.vcf | wc -l  #253114




#edit the header
grep ^"#" $VCF_FOLDER/raw.vcf > 02_info/header
# we have the following problem that we will sort by hand - this is because jasmine does not carry over information from vcf when merging different caller
#[W::vcf_parse_filter] FILTER 'q5' is not defined in the header
#[W::vcf_parse_info] INFO 'SUPPORT' is not defined in the header, assuming Type=String
#[W::vcf_parse_info] INFO 'STD_SPAN' is not defined in the header, assuming Type=String
#[W::vcf_parse_info] INFO 'STD_POS' is not defined in the header, assuming Type=String
#[W::vcf_parse_info] INFO 'CUTPASTE' is not defined in the header, assuming Type=String
#[W::vcf_parse_filter] FILTER 'STRANDBIAS' is not defined in the header
#This is in the lines of append_header.txt and they can be added to 02_info/header_corrected.
# cp 02_info/header 02_info/header_corrected
# nano 02_info/header_corrected
# lines to add are below

##FILTER=<ID=STRANDBIAS,Description="Undescribed">
##FILTER=<ID=q5,Description="Undescribed">
##FILTER=<ID=not_fully_covered,Description="Undescribed">
##INFO=<ID=SUPPORT,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=STD_SPAN,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=STD_POS,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=CUTPASTE,Number=1,Type=String,Description="Undescribed">

# we have the following problem that we will sort by hand
# there are some genotypes which are called "DUP:TANDEM" which make it read like htere were 7 fileds in the FORMAT instead of 6
#bcftools does not like that and does not run.
# we fix it manually as follow 
cat $VCF_FOLDER/raw.vcf | sed -e 's/DUP:TANDEM/NA/g'> $VCF_FOLDER/raw_fixed.vcf

#then we reconstruct the vcf and sort it

(cat 02_info/header_corrected; grep -v ^"#" $VCF_FOLDER/raw_fixed.vcf | sort -k1,1 -k2,2n) > $VCF_FOLDER/raw_sorted.vcf
grep -v ^\#\# $VCF_FOLDER/raw_sorted.vcf | head
echo "total number of SVs"
grep -v ^\# $VCF_FOLDER/raw_sorted.vcf | wc -l #253114 (this shouldn't have changed)



#filter out TRA
bcftools filter -i'INFO/SVTYPE!="TRA" & INFO/SVTYPE!="INVDUP"' -o $VCF_FOLDER/raw_sorted.noTRA.vcf -Ov $VCF_FOLDER/raw_sorted.vcf 
#grep -v ^\#\# $VCF_FOLDER/raw_sorted.noTRA.vcf | head
echo "total number of SVs restricted to INS, DEL, INV, DUP"
grep -v ^\# $VCF_FOLDER/raw_sorted.noTRA.vcf | wc -l #253114


#keep SV in chromosomes (it needs to be indexed to filter that
bgzip -f $VCF_FOLDER/raw_sorted.noTRA.vcf
tabix $VCF_FOLDER/raw_sorted.noTRA.vcf.gz
bcftools filter -R 02_info/chromosomes.bed -o $VCF_FOLDER/raw_sorted.noTRA_chr.vcf -O v $VCF_FOLDER/raw_sorted.noTRA.vcf.gz
echo "total number of SVs in chromosomes" 
grep -v ^\# $VCF_FOLDER/raw_sorted.noTRA_chr.vcf | wc -l #202257



#Export sequences for advanced filtering
bcftools query -f '%CHROM %POS %INFO/END %INFO/SVTYPE %INFO/SVLEN %REF %ALT\n' $VCF_FOLDER/raw_sorted.noTRA_chr.vcf > $VCF_FOLDER/SV_data_with_seq.txt

#blacklist because of N string > 10 (possible junction of contigs 
grep -P "N{10,}" $VCF_FOLDER/SV_data_with_seq.txt | awk '{print $1 "\t" $2 "\t" $6 "\t" $7}' > $VCF_FOLDER/N10_blacklist.bed
echo "SVs excluded because of >10N" 
wc -l $VCF_FOLDER/N10_blacklist.bed


#blacklist because missing seq
cat  $VCF_FOLDER/SV_data_with_seq.txt | awk '{if ($6 == "N") print $1 "\t" $2 "\t" $6 "\t" $7;}' > $VCF_FOLDER/N_blacklist.bed
echo "SVs excluded because absence of sequence ref" 
wc -l $VCF_FOLDER/N_blacklist.bed

#blacklist because missing seq
cat  $VCF_FOLDER/SV_data_with_seq.txt | awk '{if ($7 == "N") print $1 "\t" $2 "\t" $6 "\t" $7;}' > $VCF_FOLDER/N_blacklist_bis.bed
echo "SVs excluded because absence of sequence alt" 
wc -l $VCF_FOLDER/N_blacklist_bis.bed


#full blacklist
cat $VCF_FOLDER/N_blacklist.bed $VCF_FOLDER/N_blacklist_bis.bed $VCF_FOLDER/N10_blacklist.bed | sort -k1,1 -k2,2n > $VCF_FOLDER/blacklist.bed
head $VCF_FOLDER/blacklist.bed
bgzip -c $VCF_FOLDER/blacklist.bed > $VCF_FOLDER/blacklist.bed.gz
tabix -s1 -b2 -e2 $VCF_FOLDER/blacklist.bed.gz

#remove blacklist of variants
bcftools view -T ^$VCF_FOLDER/blacklist.bed.gz $VCF_FOLDER/raw_sorted.noTRA_chr.vcf > $VCF_FOLDER/raw_sorted.noTRA_chr_Nfiltered.vcf
grep -v ^\# $VCF_FOLDER/raw_sorted.noTRA_chr_Nfiltered.vcf | wc -l #201362

#remove variants with > 2 alleles (too complex for genome graph afterwards
bcftools view --max-alleles 2 $VCF_FOLDER/raw_sorted.noTRA_chr_Nfiltered.vcf > $VCF_FOLDER/raw_sorted.noTRA_chr_Nfiltered_biallelic.vcf
grep -v ^\# $VCF_FOLDER/raw_sorted.noTRA_chr_Nfiltered_biallelic.vcf | wc -l #194862

#remove geno information
bcftools view -s "1_sample" $VCF_FOLDER/raw_sorted.noTRA_chr_Nfiltered_biallelic.vcf --force-samples --no-update > $VCF_FOLDER/raw_sorted.noTRA_chr_Nfiltered_biallelic_noind.vcf


# remove non chromosomes from header (smaller file!)
(grep ^"#" $VCF_FOLDER/raw_sorted.noTRA_chr_Nfiltered_biallelic_noind.vcf | grep -v ^\#\#"contig=<ID=scaf"; grep -v ^"#" $VCF_FOLDER/raw_sorted.noTRA_chr_Nfiltered_biallelic.vcf) > $VCF_FOLDER/LR_final.vcf

grep -v ^\# $VCF_FOLDER/LR_final.vcf | wc -l #194862

bgzip -c $VCF_FOLDER/LR_final.vcf > $VCF_FOLDER/LR_final.vcf.gz
tabix $VCF_FOLDER/LR_final.vcf.gz

cp $VCF_FOLDER/LR_final.vcf  $OUT_VCF

#Export sequences for fasta transform if use in PGGB
#bcftools query -f '%CHROM %POS %INFO/END %INFO/SVTYPE %INFO/SVLEN %REF %ALT\n' $VCF_FOLDER/final.vcf > 04_fasta/final_SV_with_seq.txt



#essai vg
#vcf_file=
#vg construct -a -t1 -m32 -C -R Chr01 -r $ref -v $vcf_file --flat-alts > 07_vg/essai/Chr01.vg

#if needed Marc-André's correction
#Rscript 01_scripts/correct_sniffles.r # remember to change file name if needed - update soon to give input/output argumetns
#edits to Marc-André's script to try solving the error "Warning: insertion END and POS do not agree (complex insertions not canonicalizeable) "
#Rscript 01_scripts/correct_sniffles_claire.r # remember to change file name if needed - update soon to give input/output argumetns

#grep -v ^\#\# 02_info/SVs_kristina_corrected.sorted.vcf | head
#grep -v ^\#\# 02_info/SVs_kristina_corrected.sorted.vcf | wc -l
#bgzip 02_info/SVs_kristina_corrected.sorted.vcf
#tabix 02_info/SVs_kristina_corrected.sorted.vcf.gz






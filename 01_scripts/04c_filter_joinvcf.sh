
###this script should not be run in slurm. it will eed manual edits

module load bcftools/1.12
module load samtools

BASE=04_vcfs/"LR_SR_GA"
VCF_file=$BASE.vcf


#again header is missing information.
#we extract it and edit manually
grep ^"#" $VCF_file > 02_info/header
cp 02_info/header 02_info/header_corrected
nano 02_info/header_corrected

##FILTER=<ID=MaxDepth,Description="Undescribed">
##FILTER=<ID=NoPairSupport,Description="Undescribed">
##FILTER=<ID=Ploidy,Description="Undescribed">
##FILTER=<ID=MinQUAL,Description="Undescribed">
##FILTER=<ID=SampleFT,Description="Undescribed">
##FILTER=<ID=lowad,Description="Undescribed">
##FILTER=<ID=lowdepth,Description="Undescribed">
##FILTER=<ID=incomplete_inversion,Description="Undescribed">
##INFO=<ID=CIPOS,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=CIEND,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=HOMLEN,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=HOMSEQ,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=CIPOS95,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=CIEND95,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=SU,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=PE,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=SR,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=GCF,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=SVINSLEN,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=SVINSSEQ,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=CIGAR,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=AN,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=AC,Number=1,Type=String,Description="Undescribed">
##INFO=<ID=DP,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=FT,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=GQ,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=PL,Number=G,Type=String,Description="Undescribed">
##FORMAT=<ID=PR,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=SR,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=SQ,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=GL,Number=G,Type=String,Description="Undescribed">
##FORMAT=<ID=DP,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=RO,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=AO,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=QR,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=QA,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=RS,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=AS,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=ASC,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=RP,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=AP,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=AB,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=DHFC,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=DHFFC,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=DHBFC,Number=1,Type=String,Description="Undescribed">
##FORMAT=<ID=DHSP,Number=1,Type=String,Description="Undescribed">


(cat 02_info/header_corrected; grep -v ^"#" $VCF_file | sort -k1,1 -k2,2n) > "$BASE"_sorted.vcf
#bgzip -c "$BASE"_sorted.vcf > "$BASE"_sorted.vcf.gz
#tabix "$BASE"_sorted.vcf.gz

bcftools view -s "1_sample" "$BASE"_sorted.vcf --force-samples --no-update > "$BASE"_sorted_noind.vcf
grep -v ^\# "$BASE"_sorted_noind.vcf | wc -l
bgzip -c "$BASE"_sorted_noind.vcf > "$BASE"_sorted_noind.vcf.gz
tabix "$BASE"_sorted_noind.vcf.gz




#Export sequences for fasta transform to do pggb
#bcftools query -f '%CHROM %POS %INFO/END %INFO/SVTYPE %INFO/SVLEN %REF %ALT\n' "$BASE"_sorted_noind.vcf > 04_fasta/final_SV_with_seq.txt

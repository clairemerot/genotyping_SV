#this script will format the vcf output by vg call to make them into a beagle file

module load bcftools/1.13
module load vcftools

#which vcf to work with?
VCF_BASE=07_variants/ALLDP1

#how many variants?
grep -v ^\# "$VCF_BASE".vcf | wc -l  ##212176

#we use bcftools to add some tags (MAF, NS, etc)
bcftools +fill-tags "$VCF_BASE".vcf -o "$VCF_BASE"_tag.vcf -Ov -- --tag all


#filter for genotyped in >50% of samples
bcftools filter -i'INFO/NS>=16' -o "$VCF_BASE"_MISS50.vcf -Ov "$VCF_BASE"_tag.vcf 
grep -v ^\#\# "$VCF_BASE"_MISS50.vcf | wc -l #174735

#filter for maf >5%
#bcftools filter -i'INFO/MAF>=0.05 && INFO/MAF<=0.95' -o "$VCF_BASE"_MISS50_MAF5.vcf -Ov "$VCF_BASE"_MISS50.vcf 
#grep -v ^\#\# "$VCF_BASE"_MISS50_MAF5.vcf | wc -l #138360
##filter for SVs with only 2 alleles
#bcftools view --max-alleles 2 -o "$VCF_BASE"_MISS50_MAF5_2all.vcf -Ov "$VCF_BASE"_MISS50_MAF5.vcf
#grep -v ^\#\# "$VCF_BASE"_MISS50_MAF5_2all.vcf | wc -l #124720
##keep info about SV & extract it
#bcftools query -f '%CHROM %POS %REF %ALT\n' "$VCF_BASE"_MISS50_MAF5_2all.vcf > "$VCF_BASE"_MISS50_MAF5_2all.variants
#head -n 2 "$VCF_BASE"_MISS50_MAF5_2all.variants
#Rscript 01_scripts/Rscripts/extract_SV_info_graph.r "$VCF_BASE"_MISS50_MAF5_2all.variants
#head -n 2 "$VCF_BASE"_MISS50_MAF5_2all.variants.bed

#now we need to format the vcf for angsd, by changer the REF/ALT to make it like those are SNPs

#filter for SVs with only 2 alleles withou maf filter
bcftools view --max-alleles 2 -o "$VCF_BASE"_MISS50_2all.vcf -Ov "$VCF_BASE"_MISS50.vcf
grep -v ^\#\# "$VCF_BASE"_MISS50_2all.vcf | wc -l #158861

#keep info about SV & extract it
bcftools query -f '%CHROM %POS %REF %ALT\n' "$VCF_BASE"_MISS50_2all.vcf > "$VCF_BASE"_MISS50_2all.variants
bcftools query -f '%CHROM\t%POS\n' "$VCF_BASE"_MISS50_2all.vcf > "$VCF_BASE"_MISS50_2all.chrpos
head -n 2 "$VCF_BASE"_MISS50_2all.variants

Rscript 01_scripts/Rscripts/extract_SV_info_graph.r "$VCF_BASE"_MISS50_2all.variants
head -n 2 "$VCF_BASE"_MISS50_2all.variants.bed


#use Eric script (adapted by myself) to extract ref allele at position for dummy vcf
#It requires python 3
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

python3 01_scripts/utility/fasta_extract_flanking_regions_claire.py 03_genome/genome.fasta "$VCF_BASE"_MISS50_2all.chrpos 1 "$VCF_BASE"_MISS50_2all.variants.ref

#now we edit the vcf
#kjeep headr
grep ^"#" "$VCF_BASE"_MISS50_2all.vcf | grep -v ^\#\#"contig=<ID=scaf" > "$VCF_BASE"_MISS50_2all.variants.header

#keep withou header
grep -v ^"#" "$VCF_BASE"_MISS50_2all.vcf > "$VCF_BASE"_MISS50_2all.withoutheader

#edit in REF
Rscript 01_scripts/Rscripts/make_dummy_vcf_snp.r "$VCF_BASE"_MISS50_2all.withoutheader "$VCF_BASE"_MISS50_2all.variants.ref

#format vcf
cat "$VCF_BASE"_MISS50_2all.variants.header "$VCF_BASE"_MISS50_2all.withoutheader.withdummyREFALT > "$VCF_BASE"_MISS50_2all.forangsd.vcf


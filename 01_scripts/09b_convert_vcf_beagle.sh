#this script will format the vcf output by vg call to make them into a beagle file


#VCF_BASE=07_variants/ALLDP1_MISS50_2all.forangsd
VCF_BASE=09_angsd/ALLDP1_MISS50_2all.forangsd_maf0.05

#how many variants?
grep -v ^\#\# "$VCF_BASE".vcf | wc -l  ##110476


#convert vcf to beagle (this can be done only on one chromosome
cat 02_info/chromosomes.bed | cut -f1 | while read i
do 
echo "convert vcf to beagle for $i"
vcftools --vcf "$VCF_BASE".vcf --BEAGLE-GL --chr $i --out "$VCF_BASE"_$i
done

##merge beagles
#get the headerhead 
head -n 1 "$VCF_BASE"_Chr01.BEAGLE.GL > "$VCF_BASE".beagleheader
#make a new file with the header
cp "$VCF_BASE".beagleheader "$VCF_BASE".beagle

#remove header of individual beagles and append to global beagle
cat 02_info/chromosomes.bed | cut -f1 | while read i
do 
echo "append beagle from $i"
tail -n +2 "$VCF_BASE"_"$i".BEAGLE.GL >> "$VCF_BASE".beagle
done

wc -l "$VCF_BASE".beagle #this should be equal to the nb of variants in the vcf 110476
rm "$VCF_BASE"*log
rm "$VCF_BASE"*BEAGLE.GL

##replace the : by _ in the position information
sed -i 's/:/_/g' "$VCF_BASE".beagle


#now we need R ot normalized the genotype likelihoods as otherwise too small numbers are counted as zero and cannot be divided
#this is a small Rscript that does the job
INPUT_BEAGLE="$VCF_BASE".beagle
OUTPUT_BEAGLE="$VCF_BASE".normalized.beagle
Rscript 01_scripts/Rscripts/normalize_beagle.r "$INPUT_BEAGLE" "$OUTPUT_BEAGLE"

#then we add the  proper header again and zip
cat "$VCF_BASE".beagleheader "$OUTPUT_BEAGLE" > "$VCF_BASE".ready.beagle

head "$VCF_BASE".ready.beagle
gzip "$VCF_BASE".ready.beagle

bgzip $VCF_BASE.vcf
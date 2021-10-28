#generate pileup for a list of bam files using bcftools mpileup and call snps
#input: reference genome, bam list, specific region
#output: vcf


# Global variables
ID_SLURM="$1"


REGION=$(cat 02_info/chromosomes.txt | head -"$ID_SLURM" | tail -1) 
GENOME="02_info/genome.fasta"
OUTPUTPATH="11_SV50"
BAM="02_info/bam.filelist"


#verify that genome folder contains the genome:
#test if folder exists:
if [ ! -f $GENOME ]; then
   echo "no genome. genome.fasta should be in 02_genome"
   exit
fi

#check if output directory exist
if [ ! -d "$OUTPUTPATH" ]; then
	echo "creating output directory"
	mkdir $OUTPUTPATH
fi

###creating output file and command


# Load needed modules
 module load bcftools/1.13

#run samtools mpileup with default setting
#bcftools mpileup -Ou -f $GENOME --bam-list $BAM -q 5 -r $file -I -a FMT/AD | bcftools call -S $PLD -G - -f GQ -mv -Ov > "$OUTPUTPATH"/"$SPEC"_"$region".vcf 

bcftools mpileup -Ou -f $GENOME -b $BAM -q 30 -r $REGION -a AD,DP,SP -d 100 | bcftools call -G - -a GP,GQ --skip-variants snps -mv -Ov > "$OUTPUTPATH"/Indels_"$REGION".vcf   

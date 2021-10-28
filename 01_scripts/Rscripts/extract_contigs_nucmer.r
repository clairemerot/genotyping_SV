library(data.table)

argv <- commandArgs(T)
INPUT_MUM<-argv[1] #../assembly_sv/04_nucmer/dwarf.masked.contigsvsnormal.masked.chrsonly.mum"
CHR_LIST<-argv[2]
SIM<-as.numeric(argv[3]) #80 =min % of similarity
MIN_SIZE<-as.numeric(argv[4]) #500 =min length of the aligned block
MIN_PROP<-as.numeric(argv[5]) #20 =min % of the contig mapping to that chromosome
OUTPATH<-argv[6] #02_info/contigs

#read the file produce by nucmer (aligning dwarf genome in scaffolds on the normal genome in chromosomes
#with the alignment of unmasked genome, repeats create too many problems and each chromosome has 1000 dwarf cotnig on it!!

mum<-fread(INPUT_MUM)
#read the list of chromosomes
chr<-read.table(CHR_LIST)[,1]

head(mum)
dim(mum)
#we keep only similarity higher than SIM%
mum_filter<-mum[mum$V7>=SIM,]
dim(mum_filter)

#we keep length higher than MIN_SIZE
mum_filter2<-mum_filter[mum_filter$V5>=MIN_SIZE,]
dim(mum_filter2)

#we loop on chromosomes to extract contigs aligning to those chromosomes over a big ebough chunk

for (i in 1: length(chr))
{
chr_target<-chr[i]

mum_i<-mum_filter[mum_filter$V12==chr_target,]

contig_info<-as.data.frame(cbind(by(mum_i$V5,mum_i$V13,sum),by(mum_i$V9,mum_i$V13,mean)))
colnames(contig_info)[1:2]<-c("aligned_size","contig_size")
contig_info$contig_name<-row.names(contig_info)
contig_info$percent<-(contig_info$aligned_size/contig_info$contig_size)*100
contig_info$contig_rename<-paste0(contig_info$contig_name,"_",chr_target) 

head(contig_info)
contig_filter<-contig_info[contig_info$percent>=MIN_PROP,]
dim(contig_filter)
write.table(contig_filter$contig_name, paste0(OUTPATH,"_",chr_target,".txt"), row.names=F, col.names=F, quote=F)
write.table(cbind(contig_filter$contig_name,contig_filter$contig_rename), paste0(OUTPATH,"_",chr_target,"_renaming.txt"), row.names=F, col.names=F, quote=F, sep="\t")
}


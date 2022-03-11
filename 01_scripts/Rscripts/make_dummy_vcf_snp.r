library(data.table)
library(tidyr)
library(dplyr)
argv <- commandArgs(T)
INPUT<-argv[1]
SITES_FILE<-argv[2]



vcf<-fread(INPUT)
colnames(vcf)[1:2]<-c("CHR","POS")
ncol<-dim(vcf)[2]

sites<-fread(SITES_FILE)

colnames(sites)<-c("CHR_POS","REF")
head(sites)
sites2<-separate(sites, CHR_POS, c("CHR","POS"))
head(sites2)

#make a dummy alt allele diff from REF
sites2$ALT<-as.numeric(as.factor(sites$REF))
sites2$ALT[sites2$ALT=="1"]<-"C"
sites2$ALT[sites2$ALT=="2"]<-"G"
sites2$ALT[sites2$ALT=="3"]<-"T"
sites2$ALT[sites2$ALT=="4"]<-"A"
sites2$POS<-as.integer(sites2$POS)

head(sites2)
vcf_sites<-left_join(vcf,sites2)
vcf_sites$REF[which(is.na(vcf_sites$REF))]<-"N"
vcf_sites$ALT[which(is.na(vcf_sites$ALT))]<-"A"

head(vcf_sites)

head(vcf_sites[,c(1:3,42:43,6:41)])

write.table(vcf_sites[,c(1:3,42:43,6:41)], paste0(INPUT, ".withdummyREFALT"), sep="\t", col.names=F, row.names=F, quote=F)
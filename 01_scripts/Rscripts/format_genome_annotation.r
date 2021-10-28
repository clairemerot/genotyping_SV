setwd("E:/coregonus/transcriptome")
library(data.table)
library(tidyr)
library(stringr)
library(dplyr)

#read formatted gff
gff<-fread("GFF_ncbi_reformatted.gff", header=F)
head(gff,10)
colnames(gff)<-c("ncbi_chr","method","class","start", "stop","a","strand","b","info")
table(as.factor(gff$class))

#keep transcript lines # 64743 genes
gff_transcript<-gff[(gff$class=="mRNA"|gff$class=="transcript"|gff$class=="lncRNA"|gff$class=="rRNA"|gff$class=="snoRNA"|gff$class=="snRNA"),]
head(gff_transcript)
dim(gff_transcript)

#get the last 14 characteres which are transcript names
gff_transcript$id_transcript<-str_sub(gff_transcript$info, -14,-1)
head(gff_transcript)

#split the relevant info from
gff_transcript_split<-separate(gff_transcript, info, c("ID","Parent","Dbxref","Name"), sep=";")
head(gff_transcript_split)
#change chr name
chr_corres<-read.table("chr_correspondance.txt", header=T)
head(chr_corres)

gff_transcript_split_renamed<-left_join(gff_transcript_split, chr_corres)
head(gff_transcript_split_renamed)
#save as bed the gene position
write.table(gff_transcript_split_renamed[,c(14,4,5,13)], "ncbi_genes.bed", row.names=F, col.names=F, sep="\t", quote=F)

#add information from GAWN
gawn<-read.delim("transcriptome_annotation_table.tsv", header=T, sep="\t")
head(gawn)
colnames(gawn)[1]<-"id_transcript"

gff_transcript_annot<-left_join(gff_transcript_split_renamed[,c(14,4,5,13,10)], gawn[,c(1,2,6,3,4)])
#gff_transcript_annot$length<-(gff_transcript_annot$stop-gff_transcript_annot$start)

head(gff_transcript_annot)
levels(as.factor(gff_transcript_annot$Accession))[1:5]
gff_transcript_annot_only<-gff_transcript_annot[-which(gff_transcript_annot$Accession==""),]

#61159 ont une annotation

write.table(gff_transcript_annot_only, "ncbi_genes_annot.txt", row.names=F, col.names=F, sep="\t", quote=F)
write.table(gff_transcript_annot_only[,c(4,7)], "ncbi_genes_annot.go", row.names=F, col.names=F, sep="\t", quote=F)
write.table(gff_transcript_annot_only[,1:4], "ncbi_genes_annot.bed", row.names=F, col.names=F, sep="\t", quote=F)


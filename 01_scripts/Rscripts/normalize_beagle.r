#this script takes a beagle as input in the format (tab-delimited)
#CHR_POS alle1eA alleleB ind1 ind1 ind1 ind2 ind2 ind2
#Chr01_13254	0	1	8.1x10-12	0.00008	0.0001	1.2x10^-2 0.02	2.5x10-24
#and it will normalised the probabilities  (missing will become 0.33 0.33 0.33 instead of 1 1 1 for instance)
#that way it can be taken by ANGSD and PCANGSD

argv <- commandArgs(T)
INPUT_BEAGLE<-argv[1] 
OUTPUT_BEAGLE<-argv[2] 

input_beagle<-read.table(INPUT_BEAGLE, header=T)
head(input_beagle)

#how many individuals ?
Nind=(dim(input_beagle)[2]/3)-1 
print(paste("beagle include", Nind, "individuals"))

#initialised loop
sum_matrix<-matrix(nrow= dim(input_beagle)[1], ncol=Nind)
normalized_beagle<-matrix(nrow=dim(input_beagle)[1], ncol= dim(input_beagle)[2])
normalized_beagle[,1]<-as.character(input_beagle[,1])
normalized_beagle[,2]<-as.character(input_beagle[,2])
normalized_beagle[,3]<-as.character(input_beagle[,3])
head(normalized_beagle)
head(sum_matrix)

for (i in 1:Nind)
{
print(paste("working on sample", colnames(input_beagle)[(3+(3*i-2))]))
sum_matrix[,i]<-input_beagle[,(3+(3*i-2))]+input_beagle[,(3+(3*i-1))]+input_beagle[,(3+(3*i))]
normalized_beagle[,(3+(3*i-2))]<- input_beagle[,(3+(3*i-2))]/sum_matrix[,i]
normalized_beagle[,(3+(3*i-1))]<- input_beagle[,(3+(3*i-1))]/sum_matrix[,i]
normalized_beagle[,(3+(3*i))]<- input_beagle[,(3+(3*i))]/sum_matrix[,i]
}

head(normalized_beagle)

print("saving normalised beagle")
write.table(normalized_beagle, OUTPUT_BEAGLE, col.names=F, row.names=F, quote=F, sep="\t")
# genotyping_SV
Genotype SV in multiple samples sequenced with short-reads, using a catalog of SV

## 2/3- Gather input files and install vg
This uses vg: https://github.com/vgteam/vg

input data are:
- fastq files of samples sequenced with short-reads (id list is given in the 02_info folder)
- reference genome (indexed with samtools faidx) in 03_genome folder
- vcf of structural variants in 04_vcfs folder

## 4- Format the catalog of SVs 
For this study on whitefish we used:
- a vcf of SV detected with long-reads (see Kristina's pipeline)
- a vcf of SV detected with short-reads (see https://github.com/clairemerot/SR_SV )
- a vcf of SV detected by comparing genome assemblies (see assembly pipeline)

Script 4a reformat the vcf from long-reads as wanted
Script 4b join using Jasmine the 3 catalog of SV (https://github.com/mkirsche/Jasmine )
Script 4c filter and format the vcf of SV

## 5- Build genome graph with reference and SV variantion, then index it

Script 5 uses vg autoindex --giraffe

## 6- Align short-reads on the genome graph

Scripts 6 loop over samples to align short-reads on the graph and pack the alignments. 
There are two scripts as I splitted the 32 individuals into 2 loops of 16 to make it faster. This needs to be parallelize much better (by individuals) to save time.

## 7- Call variants, filter and merge

Script 7a loop over individuals to call variants based on the alignment in the graph. this could be parallelized by individuals
Script 7b filters individuals vcfs - filters can be adjuste to data. Here we are quite tolerant as data is low-medium coverage and we plan on working with genotype likelihoods.It also merge all vcfs into a single file with GL for all samples.

#!/bin/bash


#######################################################################################
#RNA QuantSeq Analysis: https://www.lexogen.com/quantseq-data-analysis/

#######################################################################################
#load modules
module load bbmap/38.86 
module load fastqc/0.11.9
#######################################################################################
#make sample files.txt for each sample
#from within fastq file folder: ls -R *fastq.gz > samples.txt

#run trim.sh srcipt:
#./trim.sh

#it contains this:
for sample in `cat ~/scratch/hscott/rowland-quantsec/samples.txt`
do
R1=${sample}
echo ${R1} "pre qc"

#fastqc on pre-trimmed file
fastqc ~/scratch/hscott/rowland-quantsec/${R1} --outdir ../../../scratch/st-aciernia-1/hscott/rowland-quantsec/fastqc_pretrim

### remove the adapter contamination, polyA read through, and low quality tails
##https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbduk-guide/
#In ktrim=r mode, once a reference kmer is matched in a read, that kmer and all the bases to the right will be trimmed, leaving only the bases to the left; this is the normal mode for adapter trimming
## quality-trim to Q10 using the Phred algorithm,
echo ${R1} "trimming"

bbduk.sh in=~/scratch/hscott/rowland-quantsec/${R1} out=${R1} ref=../../../scratch/st-aciernia-1/hscott/rowland-quantsec/polyA.fa.gz,truseq_rna.fa.gz k=13 ktrim=r forcetrimleft=11 useshortkmers=t mink=5 qtrim=t trimq=10 minlength=20


#fastqc on post-trimmed file
echo ${R1} "post qc"
fastqc ${R1} --outdir ../../../scratch/st-aciernia-1/hscott/rowland-quantsec/fastqc_posttrim

done

#move to trimmed sequences folder
mv *.fastq.gz trimmed_sequences/
#######################################################################################

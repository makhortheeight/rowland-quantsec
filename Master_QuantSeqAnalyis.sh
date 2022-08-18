#!/bin/bash
#PBS -l walltime=6:00:00,select=1:ncpus=4:mem=8000mb
#PBS -N Quantsec
#PBS -A st-aciernia-1
#PBS -v currUser=$USER
#PBS -o Quantsec.out

#run592 /Data/2c7dycd7ut/UnalignedL1/Project_PAAC_L1_H1401P_Ciernia
#run590 /Data/xfm70hwv8e/UnL6L7/Project_PAAC_H1401P_Ciernia
#run590 /Data/49bxhv50b5/UnL6L7/Project_PAAC_H1401P_Ciernia


#######################################################################################
#RNA QuantSeq Analysis: https://www.lexogen.com/quantseq-data-analysis/

#######################################################################################
#load modules
module load CVMFS_CC
module load gcc/9.3.0 cuda/11.2.2 openmpi/4.0.3
module load bbmap/38.86 

#######################################################################################
#move to the experiment folder
#make the following folders:
#mkdir fastqc_pretrim
#mkdir fastqc_posttrim
#mkdir trimmed_sequences

#place a copy of truseq.fa.gz into the top level folder
#this .fa contains the adapter for trimming

#######################################################################################

#make poly A tail file to filter out 
#printf ">polyA\nAAAAAAAAAAAAA\n>polyT\nTTTTTTTTTTTTT\n" | gzip - >  ~/../../scratch/st-aciernia-1/hscott/rowland-quantsec/polyA.fa.gz

#make sample files.txt for each sample
#from within fastq file folder: ls -R *fastq.gz > samples.txt
#all samples: find . -name '*fastq.gz' -print > samples.txt

#######################################################################################
#run trim.sh srcipt:
pwd
cd scratch/hscott/rowland-quantsec

~/scratch/hscott/rowland-quantsec/trim_L1.sh
#~/scratch/hscott/rowland-quantsec/trim_L2.sh

#trims and performs pre and post trim qc for each batch of sequencing independently
#collect all qc together with:
#module load multiqc/1.6

#multiqc fastqc_pretrim/ --filename PreTrim_multiqc_report.html --ignore-samples Undetermined* --interactive

#multiqc fastqc_posttrim/ --filename PostTrim_multiqc_report.html --ignore-samples Undetermined* --interactive

### Multiqc not available for Sockeye; fastqc done in trim_L1, possibly do multiqc locally?

#######################################################################################
#concatenate trimmed reads for each sample together into 1 fastq.gz for alignment
#cat 101123NT*.fastq.gz > 101123NT.fastq.gz
#~/scratch/hscott/rowland-quantsec/concatenate.sh 
#######################################################################################

#all samples: find . -name '*fastq.gz' -print > samples.txt
#run ./mm10STARbuild.sh to generate START indexes for 100bp reads for ensembl genes
#run ./START_alignmm10.sh to align to mm10

for sample in `cat samples.txt`
do
R1=${sample}

echo ${R1} "unzipping"

gunzip trimmed_sequences/${sample}

echo ${R1} "mapping started"

#fix the name of file being read in

STAR --runThreadN 12 --genomeDir STAR/GRCh38.p12/star_indices/ --readFilesIn  trimmed_sequences/${sample}.fastq --outFilterType BySJout --outFilterMultimapNmax 20 --alignSJoverhangMin 8 --alignSJDBoverhangMin 1 --outFilterMismatchNmax 999 --outFilterMismatchNoverLmax 0.1 --alignIntronMin 20 --alignIntronMax 1000000 --alignMatesGapMax 1000000 --outSAMattributes NH HI nM AS MD --outSAMtype BAM SortedByCoordinate --quantMode GeneCounts --outFileNamePrefix star_out/${sample} 


echo ${R1} "mapping completed"
done

echo "Finished all mapping!"

module load python/3.8.10
module load samtools/1.12

#Indexed bam files are necessary for many visualization and downstream analysis tools
cd star_out
for bamfile in */starAligned.sortedByCoord.out.bam ; do samtools index ${bamfile}; done

echo "Program finished, have a nice day"

#From this point any further analysis can be applied.


#!/bin/bash
#
#SBATCH --workdir /share/lasallelab/Annie/Ashwood_humanMacrophages/
#SBATCH -c 10                              # number of processors
#SBATCH -N 1                                # number of nodes
#SBATCH --time=0-03:00:00

#######################################################################################
#RNA QuantSeq Analysis: https://www.lexogen.com/quantseq-data-analysis/

#######################################################################################
#load modules
module load subread/1.6.0
#######################################################################################

#it contains this:
for sample in `cat samples.txt`
do
R1=${sample}

#echo ${R1} "unzipping"

#gunzip trimmed_sequences/combinedfastq/${sample}.fastq.gz
#quant seq kit is FWD stranded

echo ${R1} "count started"


#forward strand, exon counts by gene_id, 
featureCounts -T 10 -s 1 -t exon -g gene_id -a /share/lasallelab/Annie/Ashwood_humanMacrophages/STAR/GRCh38.p12/annotation/Homo_sapiens.GRCh38.94.gtf -o htcounts/${sample}.counts.txt star_out/${sample}Aligned.sortedByCoord.out.bam 



#featureCounts -T 10 -s 1 -t exon -g gene_id -a /share/lasallelab/Annie/Ashwood_humanMacrophages/STAR/GRCh38.p12/annotation/Homo_sapiens.GRCh38.94.gtf -o htcounts/101241LTA.counts.txt star_out/101241LTAAligned.sortedByCoord.out.bam 

#--quantMode GeneCounts 
echo ${R1} "count completed"
done

#######################################################################################
#collect all qc together with:
#module load multiqc/1.6

#multiqc star_out/*Log.final.out --filename STAR_AlignmentQC --interactive
#######################################################################################
#######################################################################################
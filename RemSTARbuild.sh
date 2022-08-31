#!/bin/bash
#PBS -l walltime=36:00:00,select=1:ncpus=5:mem=24000mb
#PBS -N STARCon
#PBS -A st-aciernia-1
#PBS -v currUser=$USER
#PBS -o STARCon.out

#build STAR indexes for GRCh38.p12 from ensemble
#https://leonjessen.wordpress.com/2014/12/01/how-do-i-create-star-indices-using-the-newest-grch38-version-of-the-human-genome/

#continued from locaSTARbuild.sh

module load CVMFS_CC
module load gcc/9.3.0 cuda/11.2.2 openmpi/4.0.3
module load star/2.7.8a
cd ../../../scratch/st-aciernia-1/hscott/rowland-quantsec

STAR --runThreadN 20 --runMode genomeGenerate --genomeDir ~/../../../scratch/st-aciernia-1/hscott/rowland-quantsec/STAR/GRCh38.p12/star_indices/ --genomeFastaFiles STAR/GRCh38.p12/sequence/GRCh38.r94.all.fa --sjdbGTFfile STAR/GRCh38.p12/annotation/Homo_sapiens.GRCh38.94.gtf --sjdbOverhang 99


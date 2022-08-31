#!/bin/bash
#PBS -l walltime=36:00:00,select=1:ncpus=5:mem=24000mb
#PBS -N STARCon
#PBS -A st-aciernia-1
#PBS -v currUser=$USER
#PBS -o STARCon.out

#build STAR indexes for GRCh38.p12 from ensemble
#https://leonjessen.wordpress.com/2014/12/01/how-do-i-create-star-indices-using-the-newest-grch38-version-of-the-human-genome/

#get fasta files GRCh38.p12:
#http://ftp.ensembl.org/pub/release-94/fasta/homo_sapiens/dna/

mkdir -p STAR/GRCh38.p12/sequence
cd STAR/GRCh38.p12/sequence/
wget ftp://ftp.ensembl.org/pub/release-94/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.{1..22}.fa.gz

wget ftp://ftp.ensembl.org/pub/release-94/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.chromosome.{MT,X,Y}.fa.gz

gunzip -c Homo_sapiens.GRCh38.dna.chromosome.* > GRCh38.r94.all.fa
cd ../../../

#annotation: ftp://ftp.ensembl.org/pub/release-92/gtf/mus_musculus
mkdir -p STAR/GRCh38.p12/annotation
cd STAR/GRCh38.p12/annotation/

wget ftp://ftp.ensembl.org/pub/release-94/gtf/homo_sapiens/Homo_sapiens.GRCh38.94.gtf.gz

gunzip Homo_sapiens.GRCh38.94.gtf.gz
cd ../../../

#generate the STAR indices for 100bp reads
#hhttps://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf
mkdir -p STAR/GRCh38.p12/star_indices/

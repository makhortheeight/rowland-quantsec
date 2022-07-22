#!/bin/bash
#

#make checksum master file for all fastq.gz
md5sum *.fastq.gz > checklistMD5.txt

#validate checksum
#those files whose hashes match will have duplicated lines, and won't appear in the output:
#sort servermd5Sum.md5 checklistMD5.txt | uniq --unique | grep -q .
#should return nothing

#check with R script
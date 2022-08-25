# Facts about this pipeline (rowland-quantsec) [25/08/2022 11:37]

This pipeline aims to profile mRNA responses. It uses Lexogen QuantSec 3' kit for sequencing platform and protocol --> info on RNA-to-cDNA conversion, as well as adaptor sequence and DNA amplification specifics, can be found on their website [linked at the bottom of page].

This pipeline uses Single-End sequencing, not Paired End --> Narrows down to 2 possible truseq files from Trimmomatic github.

NextGenSequencing is used after library amplification step --> reads are generated towards polyA tail, hence why that's still in the actual reads and needs to be filtered. 

Trim_L1.sh and trim_L2.sh both call bbduk.sh to remove the polyA tail, the adaptors attached to each read, as well as any low-quality tails. Fastqc is run on each file before and after the filtering by bbduk.sh.

Multiqc report generated after trimming is completed.

Files are aligned to human genome using a STAR command.

BAM files are then indexed using a samtools command.

Future analysis is applied after this pipeline --> FeatureCounts.sh script is included in directory, but is never called. An example of a full post-pipeline analysis can be found at https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8791942/

# fa.gz files that are used as reference

polyA.fa.gz is used to remove any polyA tails from the reads --> polyA tails not removed during cDNA conversion, ergo removed after the fact.

truseq.fa.gz is used to remove the adaptor sequences used during cDNA generation.

# Step by step of how this works
NOTES:
- This presumes you are already set up on Sockeye, refer to the slides from the training presentation by ARC 
- You *will* have to change the addresses for files, as my home directory is not the same as yours

1. After cloning this repository, download the needed fastq.gz files by using the online SRA Explorer tool (found at https://sra-explorer.info/). Simply type the accession number (found at https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE140702) into the field, and set the maximum number of results to 130 (by default, this is set to 100). 
2. Run checksum.sh locally to ensure that the fastq.gz files were downloaded correctly. Additionally, run localhg38STARbuild.sh locally to build some files needed much later, during the alignment phase.
3. Using the Globus Web Interface (found at https://confluence.it.ubc.ca/display/UARC/About+Globus), upload the entire rowland-quantsec directory, as well as the fastq.gz files, to /home/USER/project/Scripts/USER on Sockeye. You will want to store the fastq.gz files within the rowland-quantsec directory, so I'd recommend uploading rowland-quantsec first, and then uploading the directory containing the fastq.gz files. This should contain every script and file needed for this pipeline.
4. Within Sockeye, copy the rowand-quantsec directory to /scratch/st-aciernia-1/USER. /scratch is 2 levels higher than the default working directory, /home/USER, and is the only place within Sockeye where a submitted job has write privileges. The command to copy the directory as described varies slightly depending on how you have set up your directories, but should look something like:
```
cp -r ~/project/Scripts/USER/rowland-quantsec ~/../../scratch/st-aciernia-1/USER
```
5. Now, change your working directory to the copied rowland-quantsec directory within /scratch. Before we run the pipeline itself, we need to finish building our STAR indices, so you'll want to run the file RemSTARbuild.sh, using
```
qsub RemSTARbuild.sh
```
This will create a job id of the format "1111111.pbsha.ib.sockeye". You can check on this program while it's running by using the following command:
```
qstat 1111111.pbsha.ib.sockeye
```
Now that the STAR indices have been built, we can start the pipeline itself.
7. Use the command
```
qsub Master_QuantSeqAnalyis.sh
```
6. After Master_QuantSeqAnalyis.sh has finished running, you will want to verify the contents of both Quantsec.out (which contains the printed statements from the submitted program, like the output of an ls command) and Quantsec.e1111111 (which specifically contains error messages produced by the submitted program). You can do this in many ways, but here is an example:
```
vim Quantsec.out
vim Quantsec.e1111111
```
Use these to make sure that the entire pipeline executed without fault.
7. Assuming the entire pipeline executed without fault, you should be able to transfer the bamfile off of Sockeye for use in further analysis. Additionally, you will most likely want to transfer the fastqc .html report file for use in quality assurance. This must be done locally because Sockeye doesn't support the multiqc module.
8. Now that the pipeline has executed, some book-keeping. Remember how most of these steps have been using a copy of the /rowland-quantsec directory? Now that our work is done, we need to delete this copy. Optionally, if you want to save some of these genome files to make the next execution easier, feel free to transfer the copied directory back into the original cloned repository. Either way, you *must* delete the directory /scratch/st-aciernia-1/USER/rowland-quantsec.
9. This procedure is now finished! With this accomplished, you are now able to pursue your specialised protocol for tertiary analysis. The sections following this one describe quirks of this pipeline that are not necessary for its execution, but are invaluable if you are going to be altering it.

# How bbduk.sh works

Complete bbduk.sh documentation for every possible field can be found in the script itself.

Usage examples can be found in user guide at https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbduk-guide/

### Pipeline fields:

in=/path/to/sample/file
>Indicates the input file --> In this pipeline, that's the sequence that needs trimming

out=/path/to/output/file
>Indicates the output file --> In this pipeline, that's the trimmed sequence

ref=/path/to/polyA.fa.gz,/path/to/truseq.fa.gz
>Indicates the references file(s) --> in this case, parts of sequence that need to be removed (i.e. polyA tails & cDNA adaptors)

k=int
>Indicates length of k-mer sections --> in theory can be anything, in this case it's set to 13

ktrim=char
>Quote from in-script documentation: "Trim reads to remove bases matching reference kmers" --> in this pipeline, it's set to ktrim=r, meaning that bbduk.sh will trim to the right

forcetrimleft=int
>Makes bbduk.sh trim all bases to the left of a specified position --> set to 11

useshortkmers=bool [?]
>Old field that seems to no longer be supported, most likely a flag used in conjunction with mink, will probably delete --> set to 't'

mink=int
>Quote from in-script documentation: "Look for shorter kmers at read tips down to this length, when k-trimming" --> set to 5

qtrim=char
>Remove bases from read ends with a read quality below field trimq, can be set to specify end that is trimmed --> currently set to 't', which isn't a valid setting

trimq=int
>Sets minimum read quality value for removal --> bases with read quality less than this field will be removed via qtrim --> set to 10

minlength=int
>Reads shorter in length than this value after trimming are removed entirely --> set to 20

# Scripts that are present but uncalled

checksum.sh --> validates that .fastq.gz files are copied over correctly.

FeatureCounts.sh --> script that counts exons - best used after pipeline itself.

concatenate_rawfastq.sh --> alternative concatenation script that works (funnily enough) on raw fastq files.

# Current questions

~~Which truseq file from the trimmomatic github is the right truseq file for this pipeline?~~ File found!

~~Unclear why pipeline uses 2 identical trimming files?~~ The data came straight from sequencing service, these scripts were used for trimming the separate layers.

~~Why do the trimmed files need to be concatenated? They went through completely different treatments, why not align them as separate files?~~ The data came from the sequencing service, so was unconcatenated, but the files from the GEO Accession are already concatenated, making this step now redundant.

# Links and sources referred to

Background on rnaseq found at https://rnaseq.uoregon.edu/

Some sequencing protocol info found at https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8791942/

More sequencing protocol info found at https://www.lexogen.com/quantseq-workflow/

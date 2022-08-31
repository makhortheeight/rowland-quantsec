# RNAseq Secondary Analysis Pipeline (rowland-quantsec) [31/08/2022 15:13]

# Instructions for use
NOTES:
- This presumes you are already set up on Sockeye, refer to the slides from the training presentation by ARC 
- You *will* have to change the addresses for files (so go over all the scripts, see if they call to files in other directories, and adjust those paths), as my username is not the same as yours
- This section is strictly what you need to know to run the procedure. For a better understanding of what happens behind the curtain, see the sections after this

1. After cloning this repository, download the needed fastq.gz files by using the online SRA Explorer tool (found at https://sra-explorer.info/). Simply type the accession number (found at https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE140702) into the field, and set the maximum number of results to 130 (by default, this is set to 100). 
2. Run checksum.sh locally to ensure that the fastq.gz files were downloaded correctly. Additionally, run localhg38STARbuild.sh locally to build some files needed much later, during the alignment phase.
3. Using the Globus Web Interface (found at https://confluence.it.ubc.ca/display/UARC/About+Globus), upload the entire rowland-quantsec directory, as well as the fastq.gz files, to /home/USER/project/Scripts/USER on Sockeye. You will want to store the fastq.gz files within the rowland-quantsec directory, so I'd recommend uploading rowland-quantsec first, and then uploading the directory containing the fastq.gz files. This should contain every script and file needed for this pipeline.
4. Within Sockeye, copy the rowland-quantsec directory to /scratch/st-aciernia-1/USER. /scratch is 2 levels higher than the default working directory, /home/USER, and is the only place within Sockeye where a submitted job has write privileges. The command to copy the directory as described varies slightly depending on how you have set up your directories, but should look something like:
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
Use these to make sure that the entire pipeline executed without fault. The last line of Quantsec.out should be "Program finished, have a nice day".
7. Assuming the entire pipeline executed without fault, you should be able to transfer the bamfile off of Sockeye for use in further analysis. Additionally, you will most likely want to transfer the fastqc .html report file for use in quality assurance. This must be done locally because Sockeye doesn't support the multiqc module.
8. Now that the pipeline has executed, some book-keeping. Remember how most of these steps have been using a copy of the /rowland-quantsec directory? Now that our work is done, we need to delete this copy. Optionally, if you want to save some of these genome files to make the next execution easier, feel free to transfer the copied directory back into the original cloned repository. Either way, you *must* delete the directory /scratch/st-aciernia-1/USER/rowland-quantsec.
9. This procedure is now finished! With this accomplished, you are now able to pursue your specialised protocol for tertiary analysis. The sections following this one describe quirks of this pipeline that are not necessary for its execution, but are invaluable if you are going to be altering it. FeatureCounts.sh is an included script in this directory, and serves as an example of what could be done after this procedure. An example of a full post-pipeline analysis can be found at https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8791942/

More details about this pipeline, as well as how Sockeye functions, can be found below.

# What's going on under the hood

This section covers what happens within Master_QuantSeqAnalyis.sh as it runs.
1. Once Master_QuantSeqAnalyis.sh is called, it will call trim_L1.sh. This script creates fastqc reports of each fastq.gz file in samples.txt (which can be used to create a multiqc report locally afterwards), and then calls bbduk.sh. This program is used to filter out the contents of polyA.fa.gz and truseq_rna.fa.gz from the fastq.gz files in samples.txt. After that, trim_L1.sh creates fastqc reports of each file post-trim.
2. Once the trimming is done, Master_QuantSeqAnalyis.sh unzips all the fastq.gz files, and aligns them using STAR. The aligned files will be in the BAM file format. They should be in the directory star_out/.
3. After that is done, the Master_QuantSeqAnalyis.sh does its last step: it runs through all the BAM files in star_out/ and indexes them using samtools. 

# Sockeye facts

## Directory structure

Here's a handy graph:

[graph goes here]

As you can see, the structure is slightly confusing.

## Translating SLURM to PBS

Yes, Sockeye uses PBS. Here's an example PBS header that includes the essential parts for running on Sockeye, based heavily on what you'll find in this pipeline. These 2 headers convey the same information, for the same script, in 2 different formats.

PBS:
```
#PBS -l walltime=5:00:00,select=1:ncpus=20:mem=4000mb
#PBS -N DEpeaks_deeptools
#PBS -A st-aciernia-1
#PBS -v currUser=$USER
#PBS -o DEpeaks_deeptools.out
```
In this header, the first line, -l, defines the maximum time the script needs to run, the number of cpus the script will need, as well as how much memory per cpu is needed. The second line, -N, gives the name for the job (doesn't need to be the name of the script, which is why the file RemSTARbuild.sh as a -N name of STARCon).
The third line, -A, specifies whose allocation you are working in.
The fourth line, -v, tells Sockeye that the current user is the current user (I don't really understand either, but scripts don't run without this line being included)
The last line, -o, gives the name for the output file. It's best practice to use the same name as the -N field, but with an appended .out. 

To queue a script in Sockeye, you MUST include these 5 lines. Other fields may be included, but are optional. See PBS documentation to find a comprehensive list of the other fields.

SLURM:
```
#SBATCH -c 20
#SBATCH --mem-per-cpu=4000
#SBATCH --job-name=DEpeaks_deeptools
#SBATCH --output=DEpeaks_deeptools.out
#SBATCH --time=5:00:00
```
In this header, the first line, -c, defines the number of cpus, like a subsection of the -l line in PBS.
The second line, --mem-per-cpu, defines the memory per cpu, like a subsection of the -l line in PBS
The third line, --job-name, defines the name of the job, like the -N line in PBS
The fourth line, --output, defines the output file, just like the -o line in PBS
The fifth line, --time, define the maximum time the script needs to run, just like the walltime subsection of the -l line in PBS

##

# Misc facts about this pipeline

This pipeline aims to profile mRNA responses. It uses the Lexogen QuantSec 3' kit for sequencing platform and protocol (info on RNA-to-cDNA conversion, as well as adaptor sequence and DNA amplification specifics, can be found on their website, which is linked at the bottom of page).

This pipeline uses Single-End sequencing, not Paired End. If you want to use Paired End sequencing, some adjustments will need to be made during the trimming and alignment steps, as well as with file addresses (and possibly other places as well). 

NextGenSequencing is used after library amplification step. This means that the reads are generated towards polyA tail, which is why that tail's still in the actual reads and needs to be filtered out during the trimming stage. If the sequencing step your pipeline doesn't include the polyA tail, you won't need to filter it out, and can alter the trim_L1.sh file accordingly. 

# fa.gz files that are used as reference

polyA.fa.gz is used to remove any polyA tails from the reads --> polyA tails not removed during cDNA conversion, ergo removed after the fact.

truseq.fa.gz is used to remove the adaptor sequences used during cDNA generation.

# How bbduk.sh works

Complete documentation for every possible field in bbduk.sh can be found in the script itself.

Usage examples can be found in user guide at https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbduk-guide/

### Fields used in this procedure:

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
>Old field that seems to no longer be supported, most likely a flag used in conjunction with mink --> set to 't'

mink=int
>Quote from in-script documentation: "Look for shorter kmers at read tips down to this length, when k-trimming" --> set to 5

qtrim=char
>Remove bases from read ends with a read quality below field trimq, can be set to specify end that is trimmed --> currently set to 't', which isn't a valid setting

trimq=int
>Sets minimum read quality value for removal --> bases with read quality less than this field will be removed via qtrim --> set to 10

minlength=int
>Reads shorter in length than this value after trimming are removed entirely --> set to 20

# Scripts that are present but uncalled

Feel free to adapt these for adjusted uses of this pipeline!

FeatureCounts.sh --> script that counts exons - best used after pipeline itself, which is why Master_QuantSeqAnalyis.sh doesn't call it.

concatenate.sh --> concatenation script, no longer necessary in this procedure because the fastq files are already concatenated

concatenate_rawfastq.sh --> alternative concatenation script that works (funnily enough) on raw fastq files.

trim_L2.sh --> vestigial trimming script, works exactly like trim_L1.sh used to, and was used to trim the second layer of the sequenced data, hence the numbered trim scripts.

# Links and sources referred to

Background on rnaseq found at https://rnaseq.uoregon.edu/

Some sequencing protocol info found at https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8791942/

More sequencing protocol info found at https://www.lexogen.com/quantseq-workflow/

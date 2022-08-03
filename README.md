# Facts about this pipeline (rowland-quantsec) [03/08/2022 11:23]

This pipeline aims to profile mRNA responses. It uses Lexogen QuantSec 3' kit for sequencing platform and protocol --> info on RNA-to-cDNA conversion, as well as adaptor sequence and DNA amplification specifics, can be found on their website [linked at the bottom of page].

This pipeline uses Single-End sequencing, not Paired End --> Narrows down to 2 possible truseq files from Trimmomatic github.

NextGenSequencing is used after library amplification step --> reads are generated towards polyA tail, hence why that's still in the actual reads and needs to be filtered. 

Trim_L1.sh and trim_L2.sh both call bbduk.sh to remove the polyA tail, the adaptors attached to each read, as well as any low-quality tails. Fastqc is run on each file before and after the filtering by bbduk.sh.

Multiqc report generated after trimming is completed.

All trimmed files are concatenated into one file using concatenate.sh--> this is necessary before alignment.

Concatenated files are aligned to human genome using a STAR command.

BAM files are then indexed using a samtools command.

Future analysis is applied after this pipeline --> FeatureCounts.sh script is included in directory, but is never called. An example of a full post-pipeline analysis can be found at https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8791942/

# fa.gz files that are used as reference

polyA.fa.gz is used to remove any polyA tails from the reads --> polyA tails not removed during cDNA conversion, ergo removed after the fact.

truseq.fa.gz is used to remove the adaptor sequences used during cDNA generation.

# How bbduk.sh works

Complete bbduk.sh documentation for each field can be found in the script itself.

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

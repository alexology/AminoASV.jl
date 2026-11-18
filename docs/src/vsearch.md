# VSEARCH read quality

## Read quality with VSEARCH

```julia
asv_functional_structure(asvs;
    alignment_dir="references", output_dir="analysis",
    vsearch_path=raw"C:\tools\vsearch.exe",
    trimmed_folder="trimmed", ee=40)
```

Samples are selected from the numeric columns with abundance >0. A FASTQ file
belongs to a sample when the sample name is a whole token of the file name,
bounded by its ends or by non-alphanumeric characters: `S1` selects
`S1.fastq` and `trimmed_S1_R1.fq`, not `S10.fastq` (R aasv matches any
substring). A file matching several sample names stops the analysis before
any ASV is processed; samples without files are reported. Uncompressed FASTQ files
(`.fastq`, `.fq`) with Phred+33 qualities are supported. Error probabilities
are `10^(-Q/10)`; the `ee` filter uses their sum, and codon quality is
`1-sum(errors)` clamped to [0,1]. VSEARCH errors stop the analysis. The
probability computation is tested locally; integration with a real VSEARCH
executable requires installing it.

[![CI](https://github.com/tseemann/barrnap/workflows/CI/badge.svg)](https://github.com/tseemann/barrnap/actions)
[![GitHub release](https://img.shields.io/github/release/tseemann/barrnap.svg)](https://github.com/tseemann/barrnap/releases)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Conda](https://img.shields.io/conda/dn/bioconda/barrnap.svg)](https://anaconda.org/bioconda/barrnap)
[![Language: Perl 5](https://img.shields.io/badge/Language-Perl%205-blue.svg)](https://www.perl.org/)

# Barrnap

Annotate all the bacterial RNA in your genome

## Description

Barrnap is an annotation tool for identifying
RNA features in microbial genomes (bacteria,
arhchea, fungi). It can find:

* `rRNA` - ribosomal RNA
* `tRNA` - transfer RNA 
* `tmRNA` - transfer messenger RNA
* `ncRNA` - non-coding RNA 
* `mRNA` - messenger RNA, inc. `RBS`, `CDS`, `terminator`

You provide a FASTA file, you get a GFF3 file.
Too easy.

## Installation

```
conda create -n barrnap -c bioconda -c conda-forge barrnap
conda activate barrnap
```

## Quick start

```
# Backward compatible with the old versions - just rRNA

% barrnap test/small.fna
##gff-version 3
small	infernal:1.1.5	rRNA	293312	294796	1.7e-49	+	.	Name=16S_rRNA;Alias=SSU_rRNA_bacteria;Dbxref=Rfam:RF00177;product=16S ribosomal RNA
small	infernal:1.1.5	rRNA	295463	298336	4.8e-07	+	.	Name=23S_rRNA;Alias=LSU_rRNA_bacteria;Dbxref=Rfam:RF02541;product=23S ribosomal RNA
small	infernal:1.1.5	rRNA	298432	298548	1.1e-13	+	.	Name=5S_rRNA;Alias=5S_rRNA;Dbxref=Rfam:RF00001;product=5S ribosomal RNA

# Use --all to find all the RNA

% barrnap --all --threads 8 test/small.fna
##gff-version 3
mall   infernal:1.1.5    ncRNA          128     274  5.4e-05  +  .  Name=Cobalamin;Dbxref=Rfam:RF00174;product=Cobalamin riboswitch aptamer
small   aragorn:1.2.41   tmRNA        15305   15616  .        -  .  Name=tmRNA;product=transfer-messenger RNA (non-canonical) ANKIVSFSRQTAPVAA*
small  aragorn:1.2.41    tRNA         86968   87039  .        +  .  Name=tRNA-Asn;product=transfer RNA (gtt)
small  barrnap:1.6.0     mRNA        188710  189808  .        +  .  product=messenger RNA
small  pyrodigal:3.7.0   RBS         188710  188715  119.0    +  .  product=ribosome binding site AGGAG
small  pyrodigal:3.7.0   CDS         188726  189808  85.6     +  0  productr=hypothetical protein
small  TransTermHP:2.09  terminator  189857  189880  100      +  .  product=Rho-independent terminator
small  barrnap:1.6.0     operon      295463  298548  .        +  .  Name=rRNA operon;product=rRNA operon: rRNA-rRNA
small  infernal:1.1.5    rRNA        295463  298336  4.8e-07  +  .  Name=23S_rRNA;Alias=LSU_rRNA_bacteria;Dbxref=Rfam:RF02541;product=23S ribosomal RNA
small  infernal:1.1.5    rRNA        298432  298548  1.1e-13  +  .  Name=5S_rRNA;Alias=5S_rRNA;Dbxref=Rfam:RF00001;product=5S ribosomal RNA

# You can make full GFFs with header and sequence

% barrnap --incseq --incseqreg test/fake.fna
##gff-version 3
##sequence-region contig001 1 733412
##sequence-region contig002 1 542170
##sequence-region contig003 1 31088
...
##FASTA
>contig001
CCGATTAGACCACTTTGCTGATAACAGTATTCATATCAATTGATTAGAAAGATTTCTTTT
TTGGTCACATTTTGATCACTTTTGAAGAAAACAATTTTTCTTCTAGGTTTTCCTTATGAG
AAGGAATTAGAATATTGACTAGATAGGTTCTAATGGGAATCAGCCATTGGAGGTAACGGG
...
```

## Options

### General
* `--help` show help and exit
* `--version` print version in form `barrnap X.Y` and exit 
* `--citation` print a citation and exit
* `--debug` will write all tempfiles to '.' and print debug ingo

### Database management
* `--listdb` to see what DBs are installed
* `--updatedb` to update DBs from internet
* `--dbdir` to use a different DB folder

### Search
* `--kingdom` is the database to use: Bacteria:`bac`, Archaea:`arc`,   Fungi:`fun`
* `--all` only does rRNA scan, like versions < 1.0 did.
* `--no-rrna` disables rRNA scan
* `--trna` enables tRNA scan
* `--ncrna` enabled ncRNA scan
* `--mrna` enables mRNA scan (included CDS,RBS,sig_pep,terminator)

### Speed
* `--threads` is how many CPUs to uase
* `--fast` uses simpler HMMs instead of CMs and it less accurate

### Filtering
* `--evalue` is the cut-off for hits to keep

### Output
* `--quiet` will not print any messages to `stderr`
* `--incseq` will include the full input sequences in the output GFF
* `--incseqreg` will include `##sequence-region` headers in the GFF
* `--outseq` creates a FASTA file with the hit sequences
* `--adids` will add unique `ID=` tags to each  GFF3 feature

## FAQ

## What has changed since the 0.9 version?

* Barrnap now finds **all** RNA, not just `rRNA`. 
  Use the `--legacy` option for backward compatiblity
* I no longer use nucleotide HMMs and local alignment.
  To get that behaviour use `--fast`.
* The `mito` model is gone, the `fun` model is in.
* The `--reject` and `--lencutoff` paramters are
  ignored now, as we use global CMs now.
* SILVA is no longer used, all models are from Rfam.
* The `--reject` and `--lencutoff` parameters are no longer supported

## Can I use Barrnap instead of Prokka ?

Yes. It's faster, and finds more features.
It's missing some things like `EC_number`
and `COG` annotations, and doen't produce
Genbank files.

## Where does the name come from?

The name Barrnap was originally derived from _Bacterial/Archaeal Ribosomal RNA Predictor_.
However it has since been extended to support mitochondrial and eukaryotic rRNAs, and has been
given the new backronym _BAsic Rapid Ribosomal RNA Predictor_.
The project was originally spawned at CodeFest 2013 in Berlin, Germany 
by Torsten Seemann and Tim Booth.

## Databases

Barrnap sotres its database files in the `db` 
folder, with a subfolder for each `--kingdom`.
```
% barrnap --listdb

[barrnap] Database home: /home/tseemann/git/barrnap/db
[barrnap] --kingdom 'arc' has: tRNA tmRNA ncRNA rRNA
[barrnap] --kingdom 'bac' has: tRNA tmRNA ncRNA rRNA
[barrnap] --kingdom 'fun' has: tRNA tmRNA ncRNA rRNA
```
Because the Rfam database does not update very often,
you rarely need to update them yourself using `--updatedb`.
When there are new models, I will update them 
myself and make a new release of `barrnap` which
will likely have other bugfixes and features
you will want anyway.

## References

* [Rfam](https://rfam.org/)
* [Infernal](http://eddylab.org/infernal/)
* [Ribovore](https://pmc.ncbi.nlm.nih.gov/articles/PMC8359073/)
* [Aragorn](https://pmc.ncbi.nlm.nih.gov/articles/PMC373265/)
* [Pyrodigal](https://github.com/althonos/pyrodigal)
* [TransTermHP](https://transterm.cbcb.umd.edu/)
* [Ziggpep](https://github.com/tseemann/ziggypep)
* [Bedtools](https://bedtools.readthedocs.io/en/latest/)
* [Seqkit](https://bioinf.shenwei.me/seqkit/)
* [Diamond](https://github.com/bbuchfink/diamond)

## Feedback

File questions, bugs, or ideas on the 
[Issues page](https://github.com/tseemann/barrnap/issues)

## License

[GPLv3](https://raw.githubusercontent.com/tseemann/barrnap/master/LICENSE)

## Author

[Torsten Seemann](https://tseemann.github.io)



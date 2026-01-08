[![CI](https://github.com/tseemann/barrnap/workflows/CI/badge.svg)](https://github.com/tseemann/barrnap/actions)
[![GitHub release](https://img.shields.io/github/release/tseemann/barrnap.svg)](https://github.com/tseemann/barrnap/releases)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Conda](https://img.shields.io/conda/dn/bioconda/barrnap.svg)](https://anaconda.org/bioconda/barrnap)
[![Language: Perl 5](https://img.shields.io/badge/Language-Perl%205-blue.svg)](https://www.perl.org/)

# Barrnap

Annotate all the bacterial RNA in your genome

## Description

Barrnap is an annotation tool for identifying
RNA features in microbial genomes. It can find:
* `rRNA` - ribosomal RNA (5S,16S,23S)
* `tRNA` - transfer RNA 
* `tmRNA` - transfer messenger RNA
* `ncRNA` - non-coding RNA 
* `mRNA` - messenger RNA (containing CDS)
* `operon` - specifically the rRNA/tRNA operon

You provide a FASTA file, you get a GFF3 file.
Too easy.

## Installation

```
conda install -c bioconda -c conda-forge barrnap
```

## Usage

```
% barrnap --quiet examples/small.fna
##gff-version 3
P.marinus	barrnap:1.0.1	rRNA	353314	354793	0	+	.	Name=16S_rRNA;product=16S ribosomal RNA
P.marinus	barrnap:1.0.1	rRNA	355464	358334	0	+	.	Name=23S_rRNA;product=23S ribosomal RNA
P.marinus	barrnap:1.0.1	rRNA	358433	358536	7.5e-07	+	.	Name=5S_rRNA;product=5S ribosomal RNA

% barrnap -q -k mito examples/mitochondria.fna 
##gff-version 3
AF346967.1	barrnap:1.0.1	rRNA	643	1610	.	+	.	Name=12S_rRNA;product=12S ribosomal RNA
AF346967.1	barrnap:1.0.1	rRNA	1672	3228	.	+	.	Name=16S_rRNA;product=16S ribosomal RNA
  
% barrnap -o rrna.fa - < contigs.fa > rrna.gff
% head -n 3 rrna.fa
>16S_rRNA::gi|329138943|tpg|BK006945.2|:455935-456864(-)
ACGGTCGGGGGCATCAGTATTCAATTGTCAGAGGTGAAATTCTTGGATT
TATTGAAGACTAACTACTGCGAAAGCATTTGCCAAGGACGTTTTCATTA
```

## Options

### General
* `--help` show help and exit
* `--version` print version in form `barrnap X.Y` and exit 
* `--citation` print a citation and exit
* `--debug` will write all tempfiles to '.' and print gumpf

### Database management
* `--listdb` to see what DBs are installed
* `--updatedb` to update DBs from internet
* `--dbdir` to use a different DB folder

### Search
* `--kingdom` is the database to use: Bacteria:`bac`, Archaea:`arc`,   Fungi:`fub`
* `--no-rrna` disables rRNA scan
* `--no-trna` disables tRNA scan
* `--no-ncrna` disables ncRNA scan
* `--no-mrna` disables mRNA scan
* `--no-operon` disables RNA-operon annotation

### Speed
* `--threads` is how many CPUs to uase
* `--fast` uses simpler HMMs instead of CMs and it less accurate

### Filtering
* `--evalue` is the cut-off for hits to keep
* `--lencutoff` is the proportion of the full length that qualifies as `partial` match
* `--reject` will not include hits below this proportion of the expected length

### Output
* `--quiet` will not print any messages to `stderr`
* `--incseq` will include the full input sequences in the output GFF
* `--incseqreg` will include `##sequence-region` headers in the GFF
* `--outseq` creates a FASTA file with the hit sequences

## Where does the name come from?

The name Barrnap was originally derived from _Bacterial/Archaeal Ribosomal RNA Predictor_.
However it has since been extended to support mitochondrial and eukaryotic rRNAs, and has been
given the new backronym _BAsic Rapid Ribosomal RNA Predictor_.
The project was originally spawned at CodeFest 2013 in Berlin, Germany 
by Torsten Seemann and Tim Booth.

## License

* Barrnap: [GPLv3](https://raw.githubusercontent.com/tseemann/barrnap/master/LICENSE)
* Rfam: [CC0](https://raw.githubusercontent.com/tseemann/barrnap/master/LICENSE.Rfam)

## Author

Torsten Seemann


# Barrnap

Bacterial ribosomal RNA predictor

## Description

Barrnap predicts the location of 5S, 16S and 23S ribosomal RNA genes in Bacterial genome sequences. 
It takes FASTA DNA sequence as input, and write GFF3 as output. 
It uses the new NHMMer tool that comes with HMMER 3.1-dev for HMM searching in DNA:DNA style. 
NHMMer binaries for 64-bit Linux and Mac OS X are included and will be auto-detected. 
Multithreading is supported through NHMMer and one can expect roughly linear speed-ups with more CPUs.

This tool is designed to be a replacement for RNAmmer for bacteria. 
RNAmmer is slower, but slightly more accurate, because it uses HMMER 2.x in glocal alignment mode, 
and does other smarter things. Barrnap simply aligns full length rRNA models, 
and uses HMMER 3.x which currently only supports local alignments, 
If you want to find rRNA genes in Archaea or Eukaryota then you should continue to use RNAmmer. 
Barrnap is for bacteria (prokaryota) only. The HMM models it uses are derived from RFAM, Silva, and GreenGenes.

The name Barrnap is derived from BActerial Ribosomal RNA Predictor. 
It was spawned at CodeFest 2013 in Berlin, Germany by Torsten Seemann and Tim Booth.

## Download

* Tarball: http://www.vicbioinformatics.com/software.barrnap.shtml
* Source: https://github.com/Victorian-Bioinformatics-Consortium/barrnap

## Install

   % cd $HOME
   % tar zxvf barnapp-XXX.tar.gz
   % echo 'PATH=$PATH:$HOME/barnapp-XXX' >> .bashrc
   (logout and log back in)

## Usage

    % barrnap --quiet --threads 16 examples/small.fna

    ##gff-version 3
    P.marinus  barnapp	rRNA	353307	354799	.	-	.	Name=16S_rRNA;product=16S ribosomal RNA
    P.marinus	 barnapp	rRNA	355464	358331	.	-	.	Name=23S_rRNA;product=23S ribosomal RNA
    P.marinus  barnapp	rRNA	358433	358536	.	-	.	Name=5S_rRNA;product=5S ribosomal RNA
    P.marinus  barnapp	rRNA	1156211	1158743	.	+	.	Name=16S_rRNA;product=16S ribosomal RNA (partial)

## Caveats

* Barrnap does not do anything fancy. It has 3 HM models - 5S, 16S, and 23S. They are built from full length seed alignments. 

## Requirements

* Linux x86_64 or Mac OS X
* Perl >= 5.6

## License

Barrnap is free software, released under the GPL (version 3).

## Author

Torsten Seemann<BR>
Email: torsten.seemann@monash.edu<BR>
Victorian Bioinformatics Consortium http://bioinformatics.net.au




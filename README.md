# Barrnap

Bacterial ribosomal RNA predictor

## Description

Barrnap predicts the location of 5S, 16S and 23S ribosomal RNA genes in Bacterial genome sequ
It takes FASTA DNA sequence as input, and write GFF3 as output.
It uses the new NHMMER tool that comes with HMMER 3.1-dev for HMM searching in DNA:DNA style.
NHMMER binaries for 64-bit Linux and Mac OS X are included and will be auto-detected.
Multithreading is supported and one can expect roughly linear speed-ups with more CPUs.

This tool is designed to be a substitute for RNAmmer for bacteria. It was motivated by
my desire to remove <A HREF="software.prokka.shtml">Prokka's</A> dependency on RNAmmer
which is encumbered by an free-for-academic sign-up license, and by needed legacy HMMER 2.x
which conflicts with HMMER 3.x that most people are using now.

RNAmmer is more sophisticated than Barrnap, and more accurate.
because it uses HMMER 2.x in glocal alignment mode, whereas                            
HMMER 3.x currently only supports local alignment (Sean Eddy expects glocal to be supported in 2014).
In practice, Barrnap will find all the typical
5/16/23S genes in bacteria, but may get the end points out by a few bases
and will probably miss wierd rRNAs.
The HMM models it uses are derived from RFAM, Silva, and GreenGenes.

Barrnap is for bacteria (prokaryota) only. 
If you want to find rRNA genes in
Archaea or Eukaryota then you should continue to use RNAmmer.

The name Barrnap is derived from <I>BActerial Ribosomal RNA Predictor</I>.
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
    P.marinus  barrnap	rRNA	353307	354799	.	-	.	Name=16S_rRNA;product=16S ribosomal RNA
    P.marinus  barrnap	rRNA	355464	358331	.	-	.	Name=23S_rRNA;product=23S ribosomal RNA
    P.marinus  barrnap	rRNA	358433	358536	.	-	.	Name=5S_rRNA;product=5S ribosomal RNA
    P.marinus  barrnap	rRNA	1156211	1158743	.	+	.	Name=16S_rRNA;product=16S ribosomal RNA (partial)

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




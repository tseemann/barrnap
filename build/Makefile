# Buld barrnap CMs and HMMs

MAKEFLAGS += --warn-undefined-variables

DBDIR := ../db/
KINGS := bac arc fun
CLASSES := rRNA ncRNA

.SUFFIXES:
.DELETE_ON_ERROR:
.SECONDARY:
.ONESHELL:
.DEFAULT: all
.PHONY: all install clean

SHELL := bash
GUNZIP := gzip -d -c 
RM := rm -f -v
CP := cp -f -v
WGET ::= wget --continue
CURL := curl -L

MODELS := $(foreach K,$(KINGS),$(foreach C,$(CLASSES),$(K).$(C)))
CMS := $(patsubst %,%.cm,$(MODELS))
DMNDS := $(patsubst %,%.dmnd,$(KINGS))

CMDB_URL := "http://ftp.ebi.ac.uk/pub/databases/Rfam/CURRENT/Rfam.cm.gz"
CMDB := Rfam

SPROT_URL := "https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete/uniprot_sprot.fasta.gz"
SPROT := Sprot

all: $(CMS) $(DMNDS)

install : $(CMS) $(DMNDS)
	for K in $(KINGS); do \
	  dir="$(DBDIR)/$$K" ; \
	  mkdir -p "$$dir" ;
	  $(RM) "$$dir"/* ; \
	  $(CP) $$K.dmnd "$$dir/" ; \
	  $(CP) $$K.*.cm "$$dir/" ; \
	  for C in "$$dir"/*.cm ; do \
	    cmpress "$$C" ; \
	  done ; \
	done
	ls -1s $(DBDIR)/*/*.{cm,dmnd}

$(SPROT) :
	$(CURL) $(SPROT_URL) | $(GUNZIP) > $@

# the \K tells grep to discard around the match?
$(SPROT).taxids : $(SPROT)
	grep -oP 'OX=\K[0-9]+' $< \
	| sort | uniq > $@

taxdump.tar.gz :
	$(CURL) http://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz \
	> $@

names.dmp : taxdump.tar.gz
	tar zxvf $<

$(SPROT).lineages : $(SPROT).taxids names.dmp
	taxonkit lineage --data-dir . $< > $@

bac.ox : $(SPROT).lineages
	grep -F ';Bacteria;' $< \
	| cut -f1 | sed -E 's/(.*)/ OX=\1 /' > $@
arc.ox : $(SPROT).lineages
	grep -F ';Archaea;' $< \
	| cut -f1 | sed -E 's/(.*)/ OX=\1 /' > $@
fun.ox : $(SPROT).lineages
	grep -F ';Fungi;' $< \
	| cut -f1 | sed -E 's/(.*)/ OX=\1 /' > $@

%.dmnd : %.faa
	diamond makedb --quiet \
	--in $< --db $*

%.faa : %.seq
	#TDIR=$(shell mktemp -d)
	mmseqs easy-linclust \
	$< mm.$* mm.dir.$* \
	--min-seq-id 0.9 -c 0.8 -v 2 --shuffle 0
	$(CP) mm.$(*)_rep_seq.fasta $@

%.seq : %.ox $(SPROT)
	seqkit fx2tab $(SPROT) \
	| cut -f1,2 \
	| grep -F -f $< \
	| grep -v -i -F 'fragment' \
	| grep -v -P 'UPF\d{4}' \
	| grep -v -F 'Uncharacterized protein' \
	| seqkit tab2fx \
	| seqkit rmdup -w 0 --by-seq \
	| seqkit sort -w 0 -r --by-length \
	| sed -E 's/^>sp\|/>sp:/' \
	| sed -E 's/\|[^ ]* / /' \
	| sed -E 's/ OS=.*$$//' \
	> $@

%.cm : %.tsv $(CMDB)
	cmfetch -f $(CMDB) <(cut -f1 $<) > $@

$(CMDB) :
	$(CURL) $(CMDB_URL) | $(GUNZIP) > $@

blacklist.txt : BLACKLIST.tsv
	cut -f 1 $< | sort | uniq > $@

%.tsv : %.csv blacklist.txt
	tail -n +2 $< \
	| cut -d, -f 1 \
	| grep -v -F -f blacklist.txt \
	> $@

bac.ncRNA.csv :
	$(CURL) https://raw.githubusercontent.com/Rfam/rfam-taxonomy/refs/heads/master/domains/bacteria.csv > $@
	
arc.ncRNA.csv :
	$(CURL) https://raw.githubusercontent.com/Rfam/rfam-taxonomy/refs/heads/master/domains/archaea.csv > $@
	
fun.ncRNA.csv :
	$(CURL) https://raw.githubusercontent.com/Rfam/rfam-taxonomy/refs/heads/master/domains/eukaryota.csv > $@

clean :
	$(RM) *.cm *.ids *.i1? *~
	$(RM) *.ncRNA.tsv blacklist.txt
	$(RM) *.taxids *.lineages
	$(RM) *.ox *.seq *.faa *.dmnd
	$(RM) -r mm.*
	$(RM) *.dmp readme.txt gc.prt

bigclean : clean
	$(RM) $(CMDB) *.csv

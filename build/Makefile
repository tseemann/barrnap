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
CURL := curl

MODELS := $(foreach K,$(KINGS),$(foreach C,$(CLASSES),$(K).$(C)))
CMS := $(patsubst %,%.cm,$(MODELS))

CMDB_URL := "http://ftp.ebi.ac.uk/pub/databases/Rfam/CURRENT/Rfam.cm.gz"
CMDB := Rfam

all: $(CMS)

install : $(CMS)
	for K in $(KINGS); do \
	  dir="$(DBDIR)/$$K" ; \
	  mkdir -p "$$dir" ;
	  $(RM) "$$dir"/* ; \
	  $(CP) $$K.*.cm "$$dir/" ; \
	  for C in "$$dir"/*.cm ; do \
	    cmpress "$$C" ; \
	  done ; \
	done

%.cm : %.tsv $(CMDB)
	cmfetch -f $(CMDB) <(cut -f1 $<) > $@

$(CMDB) :
	$(CURL) $(CMDB_URL) | $(GUNZIP) > $@

blacklist.txt : $(shell echo *.rRNA.tsv)
	echo "RF00005" > $@ # tRNA model
	echo "RF00023" >> $@ # tmRNA model
	cat $^ | cut -f 1 | sort | uniq >> $@

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

bigclean : clean
	$(RM) $(CMDB) *.csv
	

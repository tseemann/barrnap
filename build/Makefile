all: hmm/bacteria.hmm hmm/archaea.hmm hmm/eukaryota.hmm hmm/mitocondria.hmm

install: hmm/bacteria.hmm hmm/archaea.hmm hmm/eukaryota.hmm hmm/mitocondria.hmm
	cp hmm/bacteria.hmm ../db/bac.hmm
	cp hmm/archaea.hmm ../db/arc.hmm
	cp hmm/eukaryota.hmm ../db/euk.hmm
	cp hmm/mitocondria.hmm ../db/mito.hmm

###############################
#
# Build individual HMMs
#
###############################

# Can be overwritten using `make CPU=x`
CPU := 1

get_gene_name = $(shell jq '. | flatten | map(select(.file == "$(notdir $@)")) | .[0].name' data/genes.json)

%.hmm: %.aln data/genes.json
	@mkdir -p $(dir $@)
	hmmbuild \
		--cpu $(CPU) \
		--rna \
		-n $(get_gene_name) \
		$@ $<

gene/silva/%.aln: inputs/silva
	@mkdir -p $(dir $@)
	esl-reformat -r stockholm inputs/silva/LSU.$*.aln > $@

gene/rfam/%.aln: inputs/rfam.stm
	@mkdir -p $(dir $@)
	esl-afetch $< $* > $@

gene/curated/%.aln: curated/%.aln
	@mkdir -p $(dir $@)
	cp $< $@

###############################
#
# Input data files
#
###############################

RFAM  = ftp://ftp.ebi.ac.uk/pub/databases/Rfam/CURRENT/Rfam.seed.gz
SILVA = https://www.arb-silva.de/fileadmin/silva_databases/current/Exports/SILVA_128_LSURef_tax_silva_full_align_trunc.fasta.gz
WGET  = wget --quiet --output-document -

inputs/rfam.stm.ssi: inputs/rfam.stm
	esl-afetch --index $<

inputs/rfam.stm:
	@mkdir -p $(dir $@)
	$(WGET) $(RFAM) | gunzip > $@

inputs/silva: inputs/silva.fa
	./fix-SILVA.pl --seed --type LSU inputs/silva.fa
	@mkdir -p $@
	mv LSU.*.aln $@
	touch $@

inputs/silva.fa:
	@mkdir -p $(dir $@)
	$(WGET) $(SILVA) | gunzip > $@

clean:
	rm -rf inputs gene hmm

###############################
#
# Build dependencies and check binaries
#
###############################

# Dynamically generate a Makefile dependency graph from the gene groups
hmm/dependencies.mk: data/genes.json
	@mkdir -p $(dir $@)
	jq -r 'to_entries | map("hmm/" + .key + ".hmm: " + (.value | map("gene/\(.source)/\(.file)") | join(" ")) + "\n\tcat $$^ > $$@") | join("\n")' $< > $@

-include hmm/dependencies.mk

# http://stackoverflow.com/a/25668869/91144
EXECUTABLES = esl-afetch jq hmmbuild esl-reformat
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "No $(exec) in PATH)))

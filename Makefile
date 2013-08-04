
EXE=barrnap

.PHONY: database test help clean tarball

help:
	@echo "make database    # rebuild the pressed HMM files"
	@echo "make test        # run a short test to see if it works"
	@echo "make clean       # remove useless files"

	
database:
	cd db && cat *.hmm > $(EXE).hmm && hmmpress $(EXE).hmm && rm -f $(EXE).hmm

	
test:
	./$(EXE) examples/small.fna

	
clean:
	rm -f *~ core foo DEADJOE

TARNAME=$(shell ./$(EXE) --version 2>&1 | sed 's/ /-/')	
TGZ=/tmp/$(strip $(TARNAME)).tar.gz

tarball: clean
	rm -fr /tmp/$(TARNAME)
	rm -f $(TGZ)
	mkdir /tmp/$(TARNAME)
	cp -rv LICENSE Makefile README.md barrnap binaries db examples /tmp/$(TARNAME)
	tar -C /tmp -zcvf $(TGZ) $(TARNAME)
	rm -fr /tmp/$(TARNAME)
	ls -lsa $(TGZ)
	
	
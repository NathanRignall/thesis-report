# requires GNU make
SHELL=/bin/bash

.DELETE_ON_ERROR:

LATEXMK=latexmk
LATEXMK_FLAGS=-pdf -halt-on-error -file-line-error

# Find all .tex files in the repository (including subfolders)
TEX_FILES=$(shell find . -type f -name '*.tex')

%.pdf: %.tex
	$(LATEXMK) $(LATEXMK_FLAGS) $<

all: report.pdf report-submission.pdf

report-submission.tex: report.tex
	sed -e 's/^%\(\\submissiontrue\)/\1/' $< >$@

report.pdf: logo-dcst-colour.pdf $(TEX_FILES)

# extract number of first and last page of the main chapters from the AUX file
WORDCOUNT_FILE=report-submission
FIRSTPAGE?=$(shell sed -ne 's/^\\newlabel{firstcontentpage}{{[0-9\.]*}{\([0-9]*\)}.*/\1/p' $(WORDCOUNT_FILE).aux)
LASTPAGE ?=$(shell sed -ne 's/^\\newlabel{lastcontentpage}{{[0-9\.]*}{\([0-9]*\)}.*/\1/p' $(WORDCOUNT_FILE).aux)

# requires ghostscript
wordcount: $(WORDCOUNT_FILE).pdf
	gs -q -dSAFER -sDEVICE=txtwrite -o - \
	   -dFirstPage=$(FIRSTPAGE) -dLastPage=$(LASTPAGE) $< | \
	egrep '[A-Za-z]{3}' | wc -w

clean:
	rm -f *.log *.aux *.toc *.bbl *.ind *.lot *.lof *.out *.bcf *.blg *.fdb_latexmk *.fls *.run.xml *~
	rm -f report-submission.tex
	$(LATEXMK) -C

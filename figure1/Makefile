OBJECT=figure1

$(OBJECT).pdf: $(OBJECT).tex
	pdflatex $(OBJECT)
	pdflatex $(OBJECT)
	pdflatex $(OBJECT)

clean:
	rm -f *.aux *.fls *.bbl *.blg *.log *.out *.fdb* *.synctex* *converted*.pdf #$(OBJECT).pdf


main: build
	cd .build ; pdflatex main
	cp .build/main.pdf .

refs: build
	cd .build ; pdflatex main
	# cd .build ; bibtex main
	# cd .build ; bibtex main
	cd .build ; pdflatex main
	cd .build ; pdflatex main
	cp .build/main.pdf .

build:
	rm -rf ./.build
	mkdir -p ./.build
	rsync -av --exclude='.build' ./* .build/

clean:
	rm -rf .build

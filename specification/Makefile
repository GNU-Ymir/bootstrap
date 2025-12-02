main: build
	cd .build ; lualatex main
	cp .build/main.pdf .

refs: build
	cd .build ; lualatex main
	# cd .build ; bibtex main
	# cd .build ; bibtex main
	cd .build ; lualatex main
	cd .build ; lualatex main
	cp .build/main.pdf .

build:
	rm -rf ./.build
	mkdir -p ./.build
	rsync -av --exclude='.build' ./* .build/

clean:
	rm -rf .build

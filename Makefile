all: carcass.min.js

carcass.min.js: carcass.js
	uglifyjs --ascii --comments --output dist/carcass.min.js dist/carcass.js
	sed -i '' -e '1 N;s/\n/ /;' -e '2 N;s/\n/ /;' -e '3 N;s/\n/ /;' \
		-e '4 N;s/\n//;' dist/carcass.min.js
	
carcass.js:
	coffee -c src/carcass.coffee
	sed -i '' -e '1,2 d' dist/carcass.js

.PHONY: lint
lint:
	coffeelint src/carcass.coffee
	coffeelint test.coffee

docs:
	
	codo \
		--name 'Carcass' \
		--title 'Carcass API Documentation' \
		--output-dir 'docs/api' \
		src/carcass.coffee
		
	docco --output 'docs/annotated-src' src/carcass.coffee

.PHONY: clean
clean:
	rm -rf dist/carcass.js dist/carcass.min.js docs

.PHONY: test
test: lint dist/carcass.js
	mocha --reporter spec --compilers coffee:coffee-script test.coffee

all: carcass.min.js

carcass.min.js: carcass.js
	uglifyjs --ascii --comments --output carcass.min.js carcass.js
	sed -i '' -e '1 N;s/\n/ /;' -e '2 N;s/\n/ /;' -e '3 N;s/\n/ /;' \
		-e '4 N;s/\n//;' carcass.min.js
	
carcass.js:
	coffee -c carcass.coffee
	sed -i '' -e '1,2 d' carcass.js

.PHONY: lint
lint:
	coffeelint carcass.coffee
	coffeelint test.coffee

docs:
	
	codo \
		--name 'Carcass' \
		--title 'Carcass API Documentation' \
		--output-dir 'docs/api' \
		carcass.coffee
		
	docco --output 'docs/annotated-src' carcass.coffee

.PHONY: clean
clean:
	rm -rf carcass.js carcass.min.js docs

.PHONY: test
test: lint carcass.js
	mocha --reporter spec --compilers coffee:coffee-script test.coffee

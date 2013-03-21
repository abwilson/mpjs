#include ../make/rules.mk

.PRECIOUS: %.js %.coffee 

#export NODE_PATH=$(shell pwd)

files.mp := $(wildcard tests/*.mp rules/*.mp)

mpjs = emitter.js grammar.js mpjs.js nodes.js functions.js clearing_houses.js

.PHONY: all
all: check_rules.js $(mpjs) $(files.mp:%.mp=%.js) functions.js rulebase.js
	node $<

grammar.js: grammar.y grammar.l

%.js: %.y %.l
	jison $^

%.js: %.coffee
	coffee -c $<

%.coffee: %.mp $(mpjs)
	node mpjs.js $< -o $@

%.js: %.mpl mpl2js.js
	node mpl2js.js $< > $@

# files.coffee := $(wildcard *.coffee *.coffee) \
#                 $(files.mp:.mp=.coffee) 

%.d: %.mp Makefile
	sed -n "/include:/s,include: *\(.*\)$$,$(<:.mp=.coffee): $(<D)/\1\.js,p" $< > $@

#all: $(files.coffee:.coffee=.js) $(files.mp:.mp=.js) 

rename_rules:
	for i in rules/*; \
	do \
	  mv "$$i" `echo $$i | sed "s/ /_/g"`.mp ; \
	done

clean:
	rm -f {tests,rules}/*.{d,js,coffee,ok}
	rm -f *.js

../mpjs.tar: *
	cd ..; tar cf mpjs.tar mpjs

%.gz: %
	gzip -f $<

pkg: ../mpjs.tar.gz

-include $(files.mp:.mp=.d)

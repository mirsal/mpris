all:

GIT = git
GZIP = gzip
TAR = tar
XSLTPROC = xsltproc --xinclude --nonet
CANONXML = xmllint --nsclean --noblanks --c14n --nonet
XML_LINEBREAKS = perl -pe 's/>/>\n/g'
DROP_NAMESPACE = perl -pe '$$hash = chr(35); s{xmlns:tp="http://telepathy\.freedesktop\.org/wiki/DbusSpec$${hash}extensions-v0"}{}g'
PYTHON = python
PYTHON = $(shell if python --version 2>/dev/null | grep "Python 3" >/dev/null 2>/dev/null; then echo python; else echo python2; fi)

XMLS = $(wildcard spec/*.xml)
TEMPLATES = $(wildcard doc/templates/*)
INTERFACE_XMLS = $(filter spec/[[:upper:]]%.xml,$(XMLS))
INTROSPECT = $(INTERFACE_XMLS:spec/%.xml=introspect/%.xml)
CANONICAL_NAMES = $(INTERFACE_XMLS:spec/%.xml=tmp/%.name)

$(CANONICAL_NAMES): tmp/%.name: spec/%.xml tools/extract-nodename.py
	@install -d tmp
	python tools/extract-nodename.py $< > $@
	tr a-z A-Z < $@ > $@.upper
	tr A-Z a-z < $@ > $@.lower
	tr -d _ < $@ > $@.camel

GENERATED_FILES = \
	doc/spec/index.html \
	FIXME.out \
	$(INTROSPECT) \
	$(CANONICAL_NAMES)

doc/spec.html: doc/templates/oldspec.html
	cp $< $@

doc/spec/index.html: $(XMLS) tools/doc-generator.py tools/specparser.py $(TEMPLATES)
	@install -d doc
	$(PYTHON) tools/doc-generator.py spec/all.xml doc/spec/ mpris-spec \
		org.mpris

$(INTROSPECT): introspect/%.xml: spec/%.xml tools/spec-to-introspect.xsl
	@install -d introspect
	$(XSLTPROC) tools/spec-to-introspect.xsl $< | $(DROP_NAMESPACE) > $@

all: $(GENERATED_FILES)
	@echo "Your spec HTML starts at:"
	@echo
	@echo file://$(CURDIR)/doc/spec/index.html
	@echo

FIXME.out: $(XMLS)
	@echo '  GEN   ' $@
	@egrep -A 5 '[F]IXME|[T]ODO|[X]XX' $(XMLS) \
		> FIXME.out || true

clean:
	rm -f $(GENERATED_FILES)
	rm -f doc/spec.html
	rm -fr introspect
	rm -rf tmp
	rm -rf doc/spec


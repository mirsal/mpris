all:

INSTALL ?= install
XSLTPROC ?= xsltproc
PYTHON ?= python
XMLLINT ?= xmllint
EGREP ?= egrep

XSLTPROCCMD = $(XSLTPROC) --xinclude --nonet
XML_LINEBREAKS = perl -pe 's/>/>\n/g'
DROP_NAMESPACE = perl -pe '$$hash = chr(35); s{xmlns:tp="http://telepathy\.freedesktop\.org/wiki/DbusSpec$${hash}extensions-v0"}{}g'

XMLS = $(wildcard spec/*.xml)
TEMPLATES = $(wildcard doc/templates/*)
INTERFACE_XMLS = $(filter spec/[[:upper:]]%.xml,$(XMLS))
INTROSPECT = $(INTERFACE_XMLS:spec/%.xml=introspect/%.xml)
CANONICAL_NAMES = $(INTERFACE_XMLS:spec/%.xml=tmp/%.name)

$(CANONICAL_NAMES): tmp/%.name: spec/%.xml tools/extract-nodename.py
	@$(INSTALL) -d tmp
	$(PYTHON) tools/extract-nodename.py $< > $@
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
	@$(INSTALL) -d doc
	$(PYTHON) tools/doc-generator.py spec/all.xml doc/spec/ mpris-spec \
		org.mpris

$(INTROSPECT): introspect/%.xml: spec/%.xml tools/spec-to-introspect.xsl
	@$(INSTALL) -d introspect
	$(XSLTPROCCMD) tools/spec-to-introspect.xsl $< | $(DROP_NAMESPACE) > $@

all: $(GENERATED_FILES)
	@echo "Your spec HTML starts at:"
	@echo
	@echo file://$(CURDIR)/doc/spec/index.html
	@echo

FIXME.out: $(XMLS)
	@echo '  GEN   ' $@
	@$(EGREP) -A 5 '[F]IXME|[T]ODO|[X]XX' $(XMLS) \
		> FIXME.out || true

clean:
	rm -f $(GENERATED_FILES)
	rm -f doc/spec.html
	rm -fr introspect
	rm -rf tmp
	rm -rf doc/spec
	rm -rf tools/*.pyc


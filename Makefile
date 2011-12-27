all:

INSTALL = install
PYTHON = $(shell if python --version 2>&1 | grep "Python 3" >/dev/null 2>/dev/null; then echo python2; else echo python; fi)
EGREP = egrep

XMLS = $(wildcard spec/*.xml)
TEMPLATES = $(wildcard doc/templates/*)

GENERATED_FILES = \
	doc/spec/index.html \
	FIXME.out \
	$(NULL)

doc/spec/index.html: $(XMLS) tools/doc-generator.py tools/specparser.py $(TEMPLATES)
	@$(INSTALL) -d doc
	$(PYTHON) tools/doc-generator.py spec/all.xml doc/spec/ mpris-spec \
		org.mpris

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
	rm -rf tmp
	rm -rf doc/spec

distclean: clean
	rm -rf tools/*.pyc

# automake requires these rules for anything that's in DIST_SUBDIRS
maintainer-clean: distclean
distdir:
	@echo distdir not implemented; exit 1
dist:
	@echo dist not implemented; exit 1

.PHONY: \
	all \
	clean \
	dist \
	distclean \
	distdir \
	maintainer-clean \
	$(NULL)


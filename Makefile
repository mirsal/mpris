all:

INSTALL = install
EGREP = egrep
XMLTO = xmlto
XSLTPROC = xsltproc

DBUS_SPEC = spec/org.mpris.MediaPlayer2.xml
DOCBOOK = spec/specification.xml
HTMLDIR = doc/html

DBUS_DOCBOOK = spec/reference.xml

GENERATED_FILES = \
	$(DBUS_DOCBOOK) \
	$(HTMLDIR)/index.html \
	FIXME.out

$(DBUS_DOCBOOK): $(DBUS_SPEC) tools/spec-to-docbook.xsl tools/resolve-type.xsl
	@echo '  GEN   ' $@
	@$(XSLTPROC) tools/spec-to-docbook.xsl $(DBUS_SPEC) > $@

$(HTMLDIR)/index.html: $(DOCBOOK) $(DBUS_DOCBOOK) docbook-params.xsl
	@echo '  GEN   ' $@
	@$(INSTALL) -d $(HTMLDIR)
	@xmlto --skip-validation -o $(HTMLDIR)/ -x docbook-params.xsl xhtml $(DOCBOOK)

all: $(GENERATED_FILES)
	@echo "Your spec HTML starts at:"
	@echo
	@echo file://$(CURDIR)/$(HTMLDIR)/index.html
	@echo

FIXME.out: $(DOCBOOK) $(DBUS_SPEC)
	@echo '  GEN   ' $@
	@$(EGREP) -A 5 '[F]IXME|[T]ODO|[X]XX' $(DOCBOOK) $(DBUS_SPEC) \
		> FIXME.out || true

clean:
	rm -f $(GENERATED_FILES)
	rm -f $(HTMLDIR)/*.html

distclean: clean

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


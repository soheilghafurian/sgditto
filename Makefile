PREFIX ?= /usr/local
BINDIR  = $(PREFIX)/bin

.PHONY: install uninstall test

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 bin/sgditto $(DESTDIR)$(BINDIR)/sgditto

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/sgditto

test:
	bats test/

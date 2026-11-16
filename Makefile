#
#	Makefile for anthra_OSt for text2skin
#
#	based on text2skin Makefile.example by Thomas Günther <tom@toms-cafe.de>
#
#	Copyright (C) 2010-2014 Tomas Saxer <tsaxer@gmx.de>
#	Copyright (C) 2026 Frank Neumann <fnu@vdr-portal.de> (text2skin 2.0 port)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# The skin needs text2skin >= 2.0 (skin format 1.2). The skin file is put
# together from xml/*.xml, there are no build options: the options of the
# skin are set in the setup menu of text2skin, the skin scales itself to the
# size of the OSD.

SKIN = anthra_OSt
MAIL = https://github.com/unf/vdr-skin-anthra-ost/issues

### The directory environment (from vdr.pc if available):

PKGCFG     = $(shell pkg-config --variable=$(1) vdr 2>/dev/null)
VDRCONFDIR ?= $(or $(call PKGCFG,configdir),/var/lib/vdr)
LOCDIR     ?= $(or $(call PKGCFG,locdir),/usr/share/locale)

DESTDIR   ?=
SKINDIR    = $(VDRCONFDIR)/plugins/text2skin/$(SKIN)
THEMESDIR  = $(VDRCONFDIR)/themes

### The main target:

all: $(SKIN).skin i18n

$(SKIN).skin: $(sort $(wildcard xml/*.xml))
	cat $^ > $@

### Internationalization (I18N):

PODIR     = po
LOCALEDIR = locale

I18Npo    = $(notdir $(wildcard $(PODIR)/*.po))
I18Npot   = $(PODIR)/$(SKIN).pot

# texts to translate: trans('...') in the skin, titles and values of the options
$(I18Npot): $(SKIN).skin
	@{ sed -e "s/('/(\"/g;s/')/\")/g" $< | grep -o "trans([^)]*)"; \
	   grep -o '<option [^>]*>' $< | sed -n 's/.* title="\([^"]*\)".*/trans("\1")/p'; \
	   grep -o '<option [^>]*>' $< | sed -n 's/.* values="\([^"]*\)".*/\1/p' | tr ',' '\n' | sed 's/.*/trans("&")/'; } | \
	xgettext -C --no-wrap --no-location -k -ktrans --from-code=UTF-8 \
	         --package-name=vdr-text2skin-$(SKIN) --msgid-bugs-address='<$(MAIL)>' -o $@ -

%.po: $(I18Npot)
	msgmerge -U --no-wrap --no-location --backup=none -q $@ $<
	@touch $@

$(LOCALEDIR)/%/LC_MESSAGES/vdr-text2skin-$(SKIN).mo: $(PODIR)/%.po
	@mkdir -p $(dir $@)
	msgfmt -c -o $@ $<

i18n: $(I18Npo:%.po=$(LOCALEDIR)/%/LC_MESSAGES/vdr-text2skin-$(SKIN).mo)

### Targets:

install-i18n: i18n
	@mkdir -p $(DESTDIR)$(LOCDIR)
	@cp -r $(LOCALEDIR)/* $(DESTDIR)$(LOCDIR)

install: $(SKIN).skin install-i18n
	@mkdir -p $(DESTDIR)$(SKINDIR) $(DESTDIR)$(THEMESDIR)
	@cp $(SKIN).skin $(SKIN).colors COPYING $(DESTDIR)$(SKINDIR)
	@cp -r images menulogos $(DESTDIR)$(SKINDIR)
	@cp themes/*.theme $(DESTDIR)$(THEMESDIR)

uninstall:
	@-rm -rf $(DESTDIR)$(SKINDIR)
	@-rm -f $(addprefix $(DESTDIR)$(THEMESDIR)/,$(notdir $(wildcard themes/*.theme)))
	@-rm -f $(DESTDIR)$(LOCDIR)/*/LC_MESSAGES/vdr-text2skin-$(SKIN).mo

clean:
	@-rm -rf $(LOCALEDIR) $(I18Npot) $(SKIN).skin *~

.PHONY: all i18n install install-i18n uninstall clean

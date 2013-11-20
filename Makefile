#!/usr/bin/make -f

THIS := $(lastword $(MAKEFILE_LIST))

prefix ?= /usr/local
datarootdir ?= $(prefix)/share/sqitch
datadir ?= $(datarootdir)

sysconfdir ?= $(prefix)/etc
exec_prefix ?= $(prefix)
bindir ?= $(exec_prefix)/bin

libdir ?= $(datadir)/lib
libexecdir ?= $(datadir)/libexec

define \n


endef
INSTALL_DIRS = $(foreach dir,$(shell cd $(1); find . -type d),install --directory $(DESTDIR)$(2)/$(dir)$(\n))
INSTALL_FILES = $(foreach file,$(shell cd $(1); find . -type f),install $(1)/$(file) $(DESTDIR)$(2)/$(file)$(\n))
INSTALL = $(foreach func,INSTALL_DIRS INSTALL_FILES,$(call $(func),$(1),$(2)))

BIN_WRAPPER=\
'\#!/bin/sh\n'\
'export PERL5LIB=$(libdir)/perl5\n'\
'export PATH=$(libexecdir):$$PATH\n'\
'exec $(libexecdir)/$(1)' '"$$@"'
INSTALL_WRAPPER = install --directory $(2); echo $(BIN_WRAPPER) | sed 's/^ *//' > $(2)/$(1)

build: validate
	carton install --deployment

validate:
ifneq ($(THIS), Makefile)
		$(error This needs to be run without specifying this Makefile manually)
endif

install: validate
	@$(call INSTALL,local/etc,$(sysconfdir))
	@$(call INSTALL,local/bin,$(libexecdir))
	@$(call INSTALL,local/lib,$(libdir))
	@$(call INSTALL_WRAPPER,sqitch,$(DESTDIR)$(bindir))

clean:
	rm --recursive --force local/

update: validate
	git rm -r --force --quiet --ignore-unmatch vendor/
	carton install
	carton bundle
	git add cpanfile cpanfile.snapshot vendor
	git status
	@echo ""
	@echo "Staged changes ready for you to review and commit!"
	@echo ""

.PHONY : validate build install clean update

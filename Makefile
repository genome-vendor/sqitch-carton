#!/usr/bin/make -f

THIS := $(lastword $(MAKEFILE_LIST))

validate:
ifneq ($(THIS), Makefile)
		$(error This needs to be run without specifying this Makefile manually)
endif

build: validate
	carton install --deployment

install: validate
	@echo Install!

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

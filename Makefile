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
	git rm -rf vendor/
	carton install
	carton bundle
	git add cpanfile cpanfile.snapshot vendor
	@echo "Staged changes ready for you to review and commit!"

.PHONY : validate build install clean update

UPSTREAM_URL    = https://github.com/NLnetLabs/unbound-manual.git
LOCALE_DIR      = unbound-manual/source/locale/ja/LC_MESSAGES
OMEGAT_SOURCE   = omegat/source
OMEGAT_TARGET   = omegat/target
HTML_DIR        = html

.PHONY: prepare
prepare: unbound-manual build-sphinx

unbound-manual:
	git clone $(UPSTREAM_URL)

.PHONY: build-sphinx
build-sphinx:
	docker build -t sphinx-intl:latest .

.PHONY: pull
pull: unbound-manual
	cd unbound-manual && git checkout source/conf.py && git pull
	sed -i '.orig' "s/^language = None/language = 'ja'\\nlocale_dirs = ['locale']/" unbound-manual/source/conf.py
	docker run --rm -v $(CURDIR)/unbound-manual:/doc sphinx-intl bash -c "make gettext; sphinx-intl update -p build/gettext -l ja"
	cp -p $(LOCALE_DIR)/*.po $(OMEGAT_SOURCE)/

.PHONY: push
push:
	cp -p $(OMEGAT_TARGET)/*.po $(LOCALE_DIR)/
	docker run --rm -v $(CURDIR)/unbound-manual:/doc sphinx-intl make html
	cp -Rp unbound-manual/build/html/ html/


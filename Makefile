.PHONY: all dist clean api deploy_pubnix pubnix extension

TEMPLATES_API=$(shell ls templates/api)
TEMPLATES_PUBNIX=$(shell ls templates/pubnix)

all: api pubnix extension

dist:
	mkdir -p dist/api/test
	mkdir -p dist/api/deploy
	mkdir -p dist/pubnix/test
	mkdir -p dist/pubnix/deploy

main.js: $(shell find src)
	purs-nix bundle

# api
deploy_api: dist $(addprefix dist/api/deploy/,$(TEMPLATES_API)) dist/api/deploy/assets dist/api/deploy/main.js dist/api/deploy/main.css

api: dist $(addprefix dist/api/test/,$(TEMPLATES_API)) dist/api/test/assets dist/api/test/main.js dist/api/test/main.css

dist/api/%/main.js: main.js dist
	cp $< $@

dist/api/%/main.css: main.css dist
	cp $< $@

dist/api/%/assets: $(shell find assets) dist
	rm -rf $@
	mkdir -p $@
	cp -r assets/* $@

define GEN_RULE_API
dist/api/%/$(template): config/%.m4 templates/api/$(template)
	sh -c "m4 $$^ >$$@"
endef
$(foreach template,$(TEMPLATES_API), $(eval $(GEN_RULE_API)))

# pubnix
deploy_pubnix: dist $(addprefix dist/pubnix/deploy/,$(TEMPLATES_PUBNIX)) dist/pubnix/deploy/assets dist/pubnix/deploy/main.js dist/pubnix/deploy/main.css
	rsync -av dist/pubnix/deploy/ "pub.colonq.computer:~/public_html/"

pubnix: dist $(addprefix dist/pubnix/test/,$(TEMPLATES_PUBNIX)) dist/pubnix/test/assets dist/pubnix/test/main.js dist/pubnix/test/main.css

dist/pubnix/%/main.js: main.js dist
	cp $< $@

dist/pubnix/%/main.css: main.css dist
	cp $< $@

dist/pubnix/%/assets: $(shell find assets) dist
	rm -rf $@
	mkdir -p $@
	cp -r assets/* $@

define GEN_RULE_PUBNIX
dist/pubnix/%/$(template): config/%.m4 templates/pubnix/$(template)
	sh -c "m4 $$^ >$$@"
endef
$(foreach template,$(TEMPLATES_PUBNIX), $(eval $(GEN_RULE_PUBNIX)))

# extension
extension: dist dist/extension/assets dist/extension/manifest.json dist/extension/background.js dist/extension/main.js dist/extension/main.css dist/extension/config.js

dist/extension/main.css: extension/main.css dist
	cp $< $@

dist/extension/manifest.json: extension/manifest.dhall
	dhall-to-json <$< >$@

dist/extension/config.js: config/extension.js
	cp $< $@

dist/extension/%: extension/%
	cp $< $@

clean:
	rm main.js
	rm -r dist/

.PHONY: all clean dist extension deploy_api api deploy_pubnix pubnix deploy_auth auth deploy_greencircle greencircle

TEMPLATES_API=$(shell ls templates/api)
TEMPLATES_PUBNIX=$(shell ls templates/pubnix)
TEMPLATES_AUTH=$(shell ls templates/auth)
TEMPLATES_GREENCIRCLE=$(shell ls templates/greencircle)

all: api pubnix extension auth greencircle

clean:
	rm -r build/
	rm -r dist/

dist:
	mkdir -p dist/api/test
	mkdir -p dist/api/deploy
	mkdir -p dist/pubnix/test
	mkdir -p dist/pubnix/deploy
	mkdir -p dist/auth/test
	mkdir -p dist/auth/deploy
	mkdir -p dist/greencircle/test
	mkdir -p dist/greencircle/deploy

build/main.js: $(shell find src)
	purs-nix bundle

# extension
extension: dist dist/extension/assets dist/extension/manifest.json dist/extension/background.js dist/extension/main.js dist/extension/main.css dist/extension/config.js

dist/extension/main.css: extension/main.css dist
	cp $< $@

dist/extension/manifest.json: extension/manifest.dhall dist
	dhall-to-json <$< >$@

dist/extension/config.js: config/extension.js dist
	cp $< $@

dist/extension/main.js: build/main.js dist
	cp $< $@

dist/extension/%: extension/% dist
	cp $< $@

dist/extension/assets: $(shell find assets) dist
	rm -rf $@
	mkdir -p $@
	cp -r assets/* $@

# api
deploy_api: dist $(addprefix dist/api/deploy/,$(TEMPLATES_API)) dist/api/deploy/assets dist/api/deploy/main.js dist/api/deploy/newton dist/api/deploy/ranch

api: dist $(addprefix dist/api/test/,$(TEMPLATES_API)) dist/api/test/assets dist/api/test/main.js dist/api/test/newton dist/api/test/ranch

dist/api/%/newton: ${NEWTON_PATH}
	rm -rf $@
	mkdir -p $@
	cp -r --no-preserve=mode,ownership $</snippets $@
	install $</newton_shader-*.js $@/throwshade.js
	install $</newton_shader-*.wasm $@/throwshade.wasm
	chmod -R 0755 $@

dist/api/%/ranch: ${RANCH_PATH}
	rm -rf $@
	mkdir -p $@
	cp -r $</* $@/
	chmod -R 0755 $@

dist/api/%/main.js: build/main.js dist
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
deploy_pubnix: dist $(addprefix dist/pubnix/deploy/,$(TEMPLATES_PUBNIX)) dist/pubnix/deploy/assets dist/pubnix/deploy/main.js
	rsync -av dist/pubnix/deploy/ "pub.colonq.computer:~/public_html/"

pubnix: dist $(addprefix dist/pubnix/test/,$(TEMPLATES_PUBNIX)) dist/pubnix/test/assets dist/pubnix/test/main.js

dist/pubnix/%/main.js: build/main.js dist
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

# auth
deploy_auth: dist $(addprefix dist/auth/deploy/,$(TEMPLATES_AUTH)) dist/auth/deploy/assets dist/auth/deploy/main.js

auth: dist $(addprefix dist/auth/test/,$(TEMPLATES_AUTH)) dist/auth/test/assets dist/auth/test/main.js

dist/auth/%/main.js: build/main.js dist
	cp $< $@

dist/auth/%/assets: $(shell find assets) dist
	rm -rf $@
	mkdir -p $@
	cp -r assets/* $@

define GEN_RULE_AUTH
dist/auth/%/$(template): config/%.m4 templates/auth/$(template)
	sh -c "m4 $$^ >$$@"
endef
$(foreach template,$(TEMPLATES_AUTH), $(eval $(GEN_RULE_AUTH)))

# greencircle
deploy_greencircle: dist $(addprefix dist/greencircle/deploy/,$(TEMPLATES_GREENCIRCLE)) dist/greencircle/deploy/assets dist/greencircle/deploy/main.js

greencircle: dist $(addprefix dist/greencircle/test/,$(TEMPLATES_GREENCIRCLE)) dist/greencircle/test/assets dist/greencircle/test/main.js

dist/greencircle/%/main.js: build/main.js dist
	cp $< $@

dist/greencircle/%/assets: $(shell find assets) dist
	rm -rf $@
	mkdir -p $@
	cp -r assets/* $@

define GEN_RULE_GREENCIRCLE
dist/greencircle/%/$(template): config/%.m4 templates/greencircle/$(template)
	sh -c "m4 $$^ >$$@"
endef
$(foreach template,$(TEMPLATES_GREENCIRCLE), $(eval $(GEN_RULE_GREENCIRCLE)))

.PHONY: all dist clean api deploy_pubnix pubnix extension

TEMPLATES_API=$(shell ls templates/api)
TEMPLATES_PUBNIX=$(shell ls templates/pubnix)
TEMPLATES_AUTH=$(shell ls templates/auth)
TEMPLATES_GREENCIRCLE=$(shell ls templates/greencircle)
TEMPLATES_THROWSHADE=$(shell ls templates/greencircle)

all: api pubnix extension auth greencircle throwshade

dist:
	mkdir -p dist/api/test
	mkdir -p dist/api/deploy
	mkdir -p dist/pubnix/test
	mkdir -p dist/pubnix/deploy
	mkdir -p dist/auth/test
	mkdir -p dist/auth/deploy
	mkdir -p dist/greencircle/test
	mkdir -p dist/greencircle/deploy
	mkdir -p dist/throwshade/test
	mkdir -p dist/throwshade/deploy

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

# auth
deploy_auth: dist $(addprefix dist/auth/deploy/,$(TEMPLATES_AUTH)) dist/auth/deploy/assets dist/auth/deploy/main.js dist/auth/deploy/main.css

auth: dist $(addprefix dist/auth/test/,$(TEMPLATES_AUTH)) dist/auth/test/assets dist/auth/test/main.js dist/auth/test/main.css

dist/auth/%/main.js: main.js dist
	cp $< $@

dist/auth/%/main.css: main.css dist
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
deploy_greencircle: dist $(addprefix dist/greencircle/deploy/,$(TEMPLATES_GREENCIRCLE)) dist/greencircle/deploy/assets dist/greencircle/deploy/main.js dist/greencircle/deploy/main.css

greencircle: dist $(addprefix dist/greencircle/test/,$(TEMPLATES_GREENCIRCLE)) dist/greencircle/test/assets dist/greencircle/test/main.js dist/greencircle/test/main.css

dist/greencircle/%/main.js: main.js dist
	cp $< $@

dist/greencircle/%/main.css: main.css dist
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

# throwshade
deploy_throwshade: dist $(addprefix dist/throwshade/deploy/,$(TEMPLATES_THROWSHADE)) dist/throwshade/deploy/assets dist/throwshade/deploy/main.js dist/throwshade/deploy/main.css dist/throwshade/deploy/newton

throwshade: dist $(addprefix dist/throwshade/test/,$(TEMPLATES_THROWSHADE)) dist/throwshade/test/assets dist/throwshade/test/main.js dist/throwshade/test/main.css dist/throwshade/test/newton

dist/throwshade/%/newton: ${NEWTON_PATH}
	rm -rf $@
	mkdir -p $@
	cp -r --no-preserve=mode,ownership $</snippets $@
	install $</throwshade-*.js $@/throwshade.js
	install $</throwshade-*.wasm $@/throwshade.wasm
	chmod -R 0755 $@

dist/throwshade/%/main.js: main.js dist
	cp $< $@

dist/throwshade/%/main.css: main.css dist
	cp $< $@

dist/throwshade/%/assets: $(shell find assets) dist
	rm -rf $@
	mkdir -p $@
	cp -r assets/* $@

define GEN_RULE_THROWSHADE
dist/throwshade/%/$(template): config/%.m4 templates/throwshade/$(template)
	sh -c "m4 $$^ >$$@"
endef
$(foreach template,$(TEMPLATES_THROWSHADE), $(eval $(GEN_RULE_THROWSHADE)))

# extension
extension: dist dist/extension/assets dist/extension/manifest.json dist/extension/background.js dist/extension/main.js dist/extension/main.css dist/extension/config.js

dist/extension/main.css: extension/main.css dist
	cp $< $@

dist/extension/manifest.json: extension/manifest.dhall dist
	dhall-to-json <$< >$@

dist/extension/config.js: config/extension.js dist
	cp $< $@

dist/extension/main.js: main.js dist
	cp $< $@

dist/extension/%: extension/% dist
	cp $< $@

dist/extension/assets: $(shell find assets) dist
	rm -rf $@
	mkdir -p $@
	cp -r assets/* $@

clean:
	rm main.js
	rm -r dist/

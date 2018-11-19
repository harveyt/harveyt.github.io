# Useful Makefile scripts.
DEPLOY_PATH = .deploy
PREVIEW_PATH = .preview
THEME = hyde-x

deploy: themes
	dep push
	hugo-deploy -d $(DEPLOY_PATH) -b master

preview: themes
	rm -rf $(PREVIEW_PATH)
	hugo server -v -d $(PREVIEW_PATH) --renderToDisk --disableFastRender --watch

themes:
	[[ -d themes/$(THEME) ]] || dep refresh

update-themes:
	@cd themes/$(THEME); \
	if [[ "$$(git status -s)" != "" ]]; then \
		echo "Changes in theme, need to be commited first"; \
		exit 1; \
	fi
	cd themes/$(THEME); \
	git checkout master; \
	git pull; \
	if ! git config remote.upstream.url >/dev/null; then \
		git remote add upstream https://github.com/zyro/hyde-x; \
	fi; \
	git merge upstream/master; \
	git push; \
	git checkout harveyt; \
	echo "Now do: cd themes/$(THEME); git rebase master"

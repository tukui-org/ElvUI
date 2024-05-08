PACKAGER_URL := https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh

.PHONY: libs

all:

libs:
	curl -s $(PACKAGER_URL) | bash -s -- -c -d -z
	cp -a .release/ElvUI_Libraries/* ElvUI_Libraries/

.PHONY: test hooks setup arch-setup arch-pre-setup

hooks:
	cp hooks/* .git/hooks/
	chmod +x .git/hooks/pre-commit

setup:
	sudo npm install -g luamin
	sudo luarocks install busted

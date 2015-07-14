.PHONY: test hooks setup arch-setup arch-pre-setup

hooks:
	cp hooks/* .git/hooks/
	chmod +x .git/hooks/pre-commit

setup:
	sudo npm install -g luamin
	sudo luarocks install busted

performance-test:
	lua5.1 perf/base.lua

test:
	busted

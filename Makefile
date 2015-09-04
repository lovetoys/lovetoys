.PHONY: test hooks setup arch-setup arch-pre-setup

setup:
	sudo luarocks install busted

performance-test:
	lua5.1 perf/base.lua

test:
	busted

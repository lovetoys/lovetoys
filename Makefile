.PHONY: test hooks setup arch-setup arch-pre-setup

default: test

setup:
	sudo luarocks install busted

performance-test:
	lua5.1 perf/base.lua

test:
	busted

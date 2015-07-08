.PHONY: test hooks setup arch-setup arch-pre-setup

hooks:
	chmod 700 hooks/*
	cp hooks/* .git/hooks/

setup:
	sudo npm install -g luamin
	sudo luarocks install busted

arch-pre-setup:
	sudo pacman -Sy luarocks nodejs --needed --noconfirm

arch-setup: arch-pre-setup setup

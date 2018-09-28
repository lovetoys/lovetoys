default: build run

clean:
	@[[ ! -e test.love ]] || rm test.love
	@[[ ! -e pkg ]] || rm -r pkg

build: clean
	@find  -L . -maxdepth 5 -name ".git" -prune -o -print 2>/dev/null | zip -@ test.love

run: build
	@love test.love

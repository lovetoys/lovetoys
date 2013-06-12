default: build run

clean:
	@[[ ! -e test.love ]] || rm test.love
	@[[ ! -e pkg ]] || rm -r pkg		

build: clean
	@zip -r test.love *

run: build
	@love test.love

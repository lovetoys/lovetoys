default: build run

clean:
	@[[ ! -e test.love ]] || rm test.love
	@[[ ! -e pkg ]] || rm -r pkg		

build: clean
	@zip -r test.love *
	@cd .. && zip -r example/test.love lovetoys/*

run: build
	@love test.love

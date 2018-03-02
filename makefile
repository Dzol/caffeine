.PHONY: all shell nuke init

all:
	mix test
	mix dialyzer
	mix format

shell:
	iex -S mix

nuke:
	rm -rf _build
	rm -rf deps
	rm -rf .dialyzer
	rm -rf doc

init:
	mkdir .dialyzer

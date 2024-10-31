-include .env

.PHONY: all test deploy

help:
	@echo "Useage:"
	@echo "make deploy [ARGS=...]"

build:; forge build

install:; forge in

initialise:
	pre-commit --version || brew install pre-commit
	pre-commit install

build:
	docker build -t engineering-wiki .

run:
	docker run --rm -it -p 8000:8000 -v `pwd`:/docs squidfunk/mkdocs-material
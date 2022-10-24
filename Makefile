initialise:
	pre-commit --version || brew install pre-commit
	pre-commit install

run:
	docker run --rm -it -p 8000:8000 -v `pwd`:/docs squidfunk/mkdocs-material

reset:
	rm -rf .git
	git init --initial-branch=main
	git add .
	git commit -m "Initial commit"
	git remote add origin https://github.com/ksoclabs/batten-the-hatches-workshop.git
	git push -u origin main -f
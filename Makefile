PROJECT=devlogs

console:
	@bundle exec bin/console

setup:
	@bundle exec bin/setup

install:
	@bundle exec rake install

build:
	@bundle exec rake build

release:
	@bundle exec rake release

release.gh:
	@gh release create

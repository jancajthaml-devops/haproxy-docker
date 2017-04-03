NAME = jancajthaml/haproxy
VERSION = latest
CORES := $$(getconf _NPROCESSORS_ONLN)

.PHONY: all image tag publish teardown

all: image teardown

image:
	docker build -t $(NAME):$(VERSION) .

tag:
	git checkout -B release/$(VERSION)
	git add --all
	git commit -a --allow-empty-message -m '' 2> /dev/null || true
	git rebase --no-ff --autosquash release/$(VERSION)
	git pull origin release/$(VERSION) 2> /dev/null || true
	git push origin release/$(VERSION)
	git checkout master

run: image
	docker run $(NAME):$(VERSION) /bin/true

publish: image tag
	docker push $(NAME)
	make teardown

teardown:
	@echo "deleting images"
	@images=$$(docker images | grep -i "^<none>" | awk '{ print $$3 }')
	@[ $$($$images | wc -l | sed 's/[^0-9]*//g') -gt 0 ] && docker rmi -f $$images || true
	@echo "deleting containers"
	@containers=$$(docker ps -a -q)
	@[ $$($$containers | wc -l | sed 's/[^0-9]*//g') -gt 0 ] && docker rm -f $$containers || true
	@echo "cleaning volumes"
	@zombies=$$(docker volume ls -qf dangling=true)
	@[ $$($$zombies | wc -l | sed 's/[^0-9]*//g') -gt 0 ] && docker volume rm $$zombies || true
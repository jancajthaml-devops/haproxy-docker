NAME = jancajthaml/haproxy
VERSION = latest
CORES := $$(getconf _NPROCESSORS_ONLN)

.PHONY: all image tag_git tag publish clean

all: image clean

image:
	docker build -t $(NAME):$(VERSION) .

tag_git:
	git checkout -B release/$(VERSION)
	git add --all
	git commit -a --allow-empty-message -m '' 2> /dev/null || true
	git rebase --no-ff --autosquash release/$(VERSION)
	git pull origin release/$(VERSION) 2> /dev/null || true
	git push origin release/$(VERSION)
	git checkout master


run: image
	docker run $(NAME):$(VERSION) /bin/true

tag: image tag_git
	docker export $$(docker ps -q -n=1) | docker import - $(NAME):stripped
	docker tag $(NAME):stripped $(NAME):$(VERSION)
	docker rmi $(NAME):stripped

publish: tag
	docker push $(NAME)
	make clean

clean:
	docker images | grep -i "^<none>" | awk '{ print $$3 }' | xargs -P$(CORES) -I{} docker rmi -f {}
	docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs -P$(CORES) -I{} docker rm -f {}
	zombies=$$(docker volume ls -qf dangling=true)
	[ $$($$zombies | wc -l) -gt 0 ] && docker volume rm $$zombies || true
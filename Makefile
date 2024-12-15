# Number of bits per word
W ?= 32

# Prime sieve size
N ?= 100000

DOCKER_TAG := whitespace-primes:latest
META_DOCKER := .meta-docker

help:
	@echo "generate - Generate a Whitespace program. Make variables:"
	@echo "           - W=Number of bits per word. Default: $(W)"
	@echo "build    - Build Whitespace docker image"
	@echo "run      - Run Whitespace program using docker image. Make variables:"
	@echo "           - W=Number of bits per word. Default: $(W)"
	@echo "           - N=Prime sieve size. Default: $(N)"

generate:
	poetry run python generate_whitespace.py "$(W)"

build: $(META_DOCKER)
$(META_DOCKER): Dockerfile
	docker build -t $(DOCKER_TAG) .
	touch $@

run: $(META_DOCKER)
	docker run -it --rm -v $$(pwd):/local -w /local $(DOCKER_TAG) python3 run_whitespace.py $(W) $(N)

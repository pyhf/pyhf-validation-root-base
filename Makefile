default: image

all: image

image:
	docker build . \
	-f Dockerfile \
	--build-arg BASE_IMAGE=python:3.7-slim \
	--build-arg ROOT_VERSION=6.20.00 \
	--tag pyhf/pyhf-validation-root-base:root6.20.00 \
	--tag pyhf/pyhf-validation-root-base:root6.20.00-python3.7 \
	--tag pyhf/pyhf-validation-root-base:latest

run:
	docker run --rm -it pyhf/pyhf-validation-root-base:latest

test:
	# Import order safe
	docker run \
		--rm \
		pyhf/pyhf-validation-root-base:latest \
		-c "python -m pip install numpy; python -c 'import ROOT; import numpy as np'"
	# Can run RooFit
	docker run \
		--rm \
		-v $(shell pwd):$(shell pwd) \
		-w $(shell pwd) \
		pyhf/pyhf-validation-root-base:latest \
		-c "python -m pip install numpy; python tests/rf308_normintegration2d.py"

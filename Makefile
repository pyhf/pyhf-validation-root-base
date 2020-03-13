default: image

all: image

image:
	docker build . \
	-f Dockerfile \
	--build-arg BASE_IMAGE=debian:stable-slim \
	--build-arg ROOT_VERSION=6.20.00 \
	--build-arg PYTHON_VERSION=3.7 \
	--tag pyhf/pyhf-validation-root-base:root6.20.00 \
	--tag pyhf/pyhf-validation-root-base:root6.20.00-python3.7 \
	--tag pyhf/pyhf-validation-root-base:latest

run:
	docker run --rm -it pyhf/pyhf-validation-root-base:latest

test:
	# Can run RooFit
	# https://github.com/root-project/root/blob/master/tutorials/roofit/rf202_extendedmlfit.py
	docker run \
		--rm \
		-v $(shell pwd):$(shell pwd) \
		-w $(shell pwd) \
		pyhf/pyhf-validation-root-base:latest \
		-c "python -m pip install numpy; python tests/rf308_normintegration2d.py"
	# Import order safe
	docker run \
		--rm \
		-v $(shell pwd):$(shell pwd) \
		-w $(shell pwd) \
		pyhf/pyhf-validation-root-base:latest \
		-c "python -m pip install numpy; python tests/test_import_numpy_ROOT.py; python tests/test_import_ROOT_numpy.py"

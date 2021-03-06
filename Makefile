default: image

all: image

image:
	docker build . \
	-f Dockerfile \
	--build-arg BASE_IMAGE=atlasamglab/stats-base:root6.22.02-python3.8 \
	--tag pyhf/pyhf-validation-root-base:root6.22.02 \
	--tag pyhf/pyhf-validation-root-base:root6.22.02-python3.8 \
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

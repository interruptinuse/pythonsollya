PYTHON ?= python2
SAGE ?= sage
PREFIX = /usr/local
SOLLYA_DIR = /usr/local
CPPFLAGS = -I${SOLLYA_DIR}/include
LDFLAGS = -L${SOLLYA_DIR}/lib
PYTHONPATH = $(shell PYTHONUSERBASE=${PREFIX} ${PYTHON} -c "import site; \
	     print(site.getusersitepackages())")

export LDFLAGS CPPFLAGS PYTHONPATH

.PHONY: install clean srctarball test generated

GEN_DEPS := sollya_func.pxi sollya_settings.pxi sollya_ops.pxi csollya_ops.pxd
DEPS := csollya.pxd sollya.pyx sollya_extra_functions.pyx ${GEN_DEPS}
SOBJ := sollya.so sagesollya.so sollya_extra_functions.so

sollya.so sollya_extra_functions.so: ${DEPS}
	${PYTHON} setup.py build_ext --inplace

build: sollya.so sollya_extra_functions.so

sagesollya.so: ${DEPS}
	WITH_SAGE=foo ${SAGE} -python setup.py build_ext --inplace

csollya_ops.pxd sollya_ops.pxi: gen_ops.py
	> /dev/null echo '#include <sollya.h>' | cpp "${CPPFLAGS}" && \
	    echo '#include <sollya.h>' | cpp "${CPPFLAGS}" \
	    | grep SOLLYA_BASE_FUNC_ \
	    | ${PYTHON} $< csollya_ops.pxd sollya_ops.pxi

sollya_%.pxi: gen_%.py
	PATH="${SOLLYA_DIR}:${PATH}" ${PYTHON} $< > $@

# Target called by setup.py (so that, when running "make" without arguments, the
# makefile calls setup.py which calls the makefile)
generated: ${GEN_DEPS}

install: sollya.so sollya_extra_functions.so
	pip install --system --target=${PREFIX} .

clean:
	${PYTHON} setup.py clean
	rm -rf ${GEN_DEPS} ${SOBJ} ${SOBJ:.so=.c}

gitrev = $(shell git rev-parse --short HEAD)

srctarball:
	git archive -o cythonsollya-$(gitrev).tar.gz HEAD

TESTS=${wildcard examples/*.py}

test: sollya.so ${TESTS}
	@for f in ${TESTS}; do \
	    echo Testing $$f; \
	    LD_LIBRARY_PATH=${SOLLYA_DIR}/lib \
	    ${PYTHON} -m doctest $$f; \
	done
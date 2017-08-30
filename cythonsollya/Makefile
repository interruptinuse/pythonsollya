PYTHON = python2
PREFIX = /usr/local
SOLLYA_DIR = /usr/local
CPPFLAGS = -I${SOLLYA_DIR}/include
LDFLAGS = -L${SOLLYA_DIR}/lib
PYTHONPATH = $(shell PYTHONUSERBASE=${PREFIX} ${PYTHON} -c "import site; \
	     print(site.getusersitepackages())")

export LDFLAGS CPPFLAGS PYTHONPATH

.PHONY: build install srctarball

build: sollya_func.pxi sollya_settings.pxi sollya_ops.pxi csollya_ops.pxd
	${PYTHON} setup.py build_ext --inplace

install:
	@mkdir -p ${PYTHONPATH}
	${PYTHON} setup.py install --prefix ${PREFIX}

csollya_ops.pxd sollya_ops.pxi: gen_ops.py
	> /dev/null echo '#include <sollya.h>' | cpp "${CPPFLAGS}" && \
	    echo '#include <sollya.h>' | cpp "${CPPFLAGS}" \
	    | grep SOLLYA_BASE_FUNC_ \
	    | ${PYTHON} $< csollya_ops.pxd sollya_ops.pxi

sollya_%.pxi: gen_%.py
	${PYTHON} $< > $@

gitrev = $(shell git rev-parse --short HEAD)

srctarball:
	git archive -o cythonsollya-$(gitrev).tar.gz HEAD

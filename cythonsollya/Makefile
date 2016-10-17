PREFIX = /usr/local
SOLLYA_DIR = /usr/local
CPPFLAGS = -I${SOLLYA_DIR}/include
LDFLAGS = -L${SOLLYA_DIR}/lib

export LDFLAGS CPPFLAGS

.PHONY: build install srctarball

build: sollya_func.pxi sollya_settings.pxi sollya_ops.pxi csollya_ops.pxd
	python2 setup.py --verbose build

install:
	python2 setup.py install --prefix ${PREFIX}

csollya_ops.pxd sollya_ops.pxi: gen_ops.py
	> /dev/null echo '#include <sollya.h>' | cpp "${CPPFLAGS}" && \
	    echo '#include <sollya.h>' | cpp "${CPPFLAGS}" \
	    | grep SOLLYA_BASE_FUNC_ \
	    | python2 $< csollya_ops.pxd sollya_ops.pxi

sollya_%.pxi: gen_%.py
	python2 $< > $@

gitrev = $(shell git rev-parse --short HEAD)

srctarball:
	git archive -o cythonsollya-$(gitrev).tar.gz HEAD

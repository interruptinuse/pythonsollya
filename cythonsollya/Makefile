.PHONY: build

build: sollya_func.pxi sollya_settings.pxi sollya_ops.pxi csollya_ops.pxd
	python setup.py build

# Generalize this model? Or go back to a single generator?
csollya_ops.pxd sollya_ops.pxi: gen_ops.py
	grep SOLLYA_BASE_FUNC_ ${SOLLYA_INSTALL_DIR}/include/sollya.h \
	    | python $< csollya_ops.pxd sollya_ops.pxi

sollya_%.pxi: gen_%.py
	python $< > $@

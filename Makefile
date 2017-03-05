.PHONY: build

build: sollya_func.pxi sollya_settings.pxi sollya_ops.pxi csollya_ops.pxd
	python2 setup.py build

# Generalize this model? Or go back to a single generator?
csollya_ops.pxd sollya_ops.pxi: gen_ops.py ${SOLLYA_INSTALL_DIR}/include/sollya.h
	grep SOLLYA_BASE_FUNC_ ${SOLLYA_INSTALL_DIR}/include/sollya.h \
	    | python2 $< csollya_ops.pxd sollya_ops.pxi

clean:
	rm -f *.pxi csollya_ops.pxd

install:
	python2 setup.py install 

test:
	# LD_LIBRARY_PATH=$(SOLLYA_INSTALL_DIR)/lib:$(LD_LIBRARY_PATH) python2 ./examples/custom.py
	LD_LIBRARY_PATH=$(SOLLYA_INSTALL_DIR)/lib:$(LD_LIBRARY_PATH) python2 ./tests/check001.sollya.py

sollya_%.pxi: gen_%.py
	python2 $< > $@

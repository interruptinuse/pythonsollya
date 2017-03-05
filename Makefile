# list of tests
TESTS := func basic
TEST_GEN_DIR := ./output

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
	export LD_LIBRARY_PATH=$(SOLLYA_INSTALL_DIR)/lib:$(LD_LIBRARY_PATH) 



# $1 test name
define gen_test_rule

$1.test:
	mkdir -p $(TEST_GEN_DIR) 
	python2 ./tests/test_$1.py > $(TEST_GEN_DIR)/test_$1.gen && diff $(TEST_GEN_DIR)/test_$1.gen tests/test_$1.reference && echo "test_$1: success" || echo "test_$1 failed"

test: $1.test

endef

$(foreach test,$(TESTS),\
	$(eval $(call gen_test_rule,$(test))))


sollya_%.pxi: gen_%.py
	python2 $< > $@

.PHONY: build

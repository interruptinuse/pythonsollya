.PHONY: build

build: sollya_func.pxi sollya_settings.pxi
	python setup.py build

sollya_%.pxi: gen_%.py
	python $< > $@

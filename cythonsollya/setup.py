# -*- coding: utf-8 -*- vim:sw=2

import logging
from setuptools import setup
from Cython.Distutils.extension import Extension
from Cython.Distutils.build_ext import build_ext

logging.basicConfig(level=logging.INFO)

options = {
  "cython_compile_time_env": {}
}
try:
  import sage.env
  logging.info("Building with SageMath support")
  options["include_dirs"] = sage.env.sage_include_directories()
  options["cython_compile_time_env"]["HAVE_SAGE"] = True
except ImportError:
  logging.info("SageMath not found, building in pure Python mode")
  options["cython_compile_time_env"]["HAVE_SAGE"] = False
  pass

ext_modules = [
  Extension(
    "sollya",
    ["sollya.pyx"],
    libraries=["sollya"],
    **options
  ),
]

setup(
  name="sollya",
  version="0.1",
  description="Python wrapper to sollya library",
  author="Nicolas Brunie, Marc Mezzarobba",
  author_email="nicolas.brunie@kalray.eu",
  ext_modules=ext_modules,
  cmdclass = {'build_ext': build_ext},
)

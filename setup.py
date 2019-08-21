# -*- coding: utf-8 -*- vim:sw=2
# Note that this setup.py calls "make", while some targets in the Makefile
# run setup.py.

import os, setuptools, subprocess
from distutils.core import Extension
from setuptools.command.build_ext import build_ext as st_build_ext

name = "sollya"
ext_options = {}
cy_options = {
  "compile_time_env": {
    "HAVE_SAGE": False
  }
}

if "WITH_SAGE" in os.environ:
  import sage.env
  name = "sagesollya"
  cy_options["compile_time_env"]["HAVE_SAGE"] = True
  ext_options["include_dirs"] = sage.env.sage_include_directories()

extensions = [
  Extension(
    name,
    [name + ".pyx"],
    libraries=["sollya"],
    **ext_options
  ),
  Extension(
    "sollya_extra_functions",
    ["sollya_extra_functions.pyx"],
    libraries=["sollya"],
    **ext_options
  ),
]

# Not ideal, but this is the only way I found to be able both to pass compile
# time options and to generate the required .pxi files before cython looks for
# them while resolving dependencies.
class build_ext(st_build_ext, object):
  def finalize_options(self):
    subprocess.call(["make", "generated"])
    from Cython.Build.Dependencies import cythonize
    self.distribution.ext_modules[:] = cythonize(
            self.distribution.ext_modules,
            **cy_options)
    super(build_ext, self).finalize_options()

setuptools.setup(
  name=name,
  ext_modules=extensions,
  version="0.3.1",
  description="Cython wrapper for the Sollya library",
  url="https://gitlab.com/metalibm-dev/pythonsollya",
  author="Nicolas Brunie, Marc Mezzarobba",
  license="CeCILL-C V2.1",
  author_email="nicolas.brunie@kalray.eu",
  setup_requires=["cython"],
  install_requires=["six"],
  cmdclass = {"build_ext": build_ext},
)

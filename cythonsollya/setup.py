from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
  name = "sollya",
  version = "0.1",
  description = "Python wrapper to sollya library",
  author = "Nicolas Brunie, Marc Mezzaroba",
  author_email = "nicolas.brunie@kalray.eu",
  ext_modules = 
    cythonize(
    [
      Extension(
        "sollya", 
        ["sollya.pyx"],
        libraries = ["sollya"]
      )
    ]
  ),
)

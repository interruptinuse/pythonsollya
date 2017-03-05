from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import os

# if env's variable SOLLYA_INSTALL_DIR is set
# use it to determine path for sollya header
# and library
# if not fallback on default directories
sollya_include_dir = os.path.join(os.environ['SOLLYA_INSTALL_DIR'], "include") if "SOLLYA_INSTALL_DIR" in os.environ else ""
sollya_library_dir = os.path.join(os.environ['SOLLYA_INSTALL_DIR'], "lib") if "SOLLYA_INSTALL_DIR" in os.environ else ""


setup(
  name = "sollya",
  version = "0.1",
  description = "Python wrapper to sollya library",
  author = "Nicolas Brunie, Marc Mezzarobba",
  author_email = "nicolas.brunie@kalray.eu",
  ext_modules = 
    cythonize(
    [
      Extension(
        "sollya", 
        ["sollya.pyx"],
        include_dirs = [sollya_include_dir], 
        library_dirs = [sollya_library_dir], 
        libraries = ["sollya"]
      )
    ],
  ),
)

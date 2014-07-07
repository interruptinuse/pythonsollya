# -*- coding: utf-8 -*-
from distutils.core import setup, Extension
import sys
import os
import wrapper.wrapper_generator as wrapper_generator



# Directory containing pythonsollya sources
PYTHONSOLLYA_DIR = "./pythonsollya/"
# root directory to find ./include and ./lib containing sollya 
# TODO: to be replace by your own directory
LOCAL_INSTALL_DIR = "/work1/hardware/users/nbrunie/MetaLibmProject/ProofOfConcept/local"

if "build" in sys.argv:
    # testing existence of PYTHONSOLLYA_DIR/build dir
    build_path = os.path.join(PYTHONSOLLYA_DIR, "build")
    if not os.path.isdir(build_path):
        # making directory if it does not exist
        os.makedirs(build_path)

    # call to the automatic wrapper generator
    print "generating: PythonSollyaInterface_functions"
    wrapper_generator.main("%s/build/PythonSollyaInterface_functions.cpp" % (PYTHONSOLLYA_DIR))
    print "generating: PythonSollyaInterface_gen_functions"
    wrapper_generator.main("%s/build/PythonSollyaInterface_gen_functions.cpp" % (PYTHONSOLLYA_DIR))

PSI_module = Extension("PythonSollyaInterface", 
	libraries = ['boost_regex', 'mpfr', 'gmp', 'xml2', 'mpfi', 'sollya'], 
    # if sollya svn is not build in the most current directories (/usr/lib ... /usr/local)
    # sollya.h directory should be added in the following list
	include_dirs = ["%s/include" % LOCAL_INSTALL_DIR, 'pythonsollya/cpp', 'pythonsollya/build'],
    # if sollya svn is not build in the most current directories (/usr/lib ... /usr/local)
    # libsollya directory should be added in the following list
	library_dirs = ["%s/lib" % LOCAL_INSTALL_DIR],
    # the following list should contains the directory towar sollya.so.?
	runtime_library_dirs = ["%s/lib" % LOCAL_INSTALL_DIR],
	sources = [	
                # code source files
                "%s/cpp/PythonSollyaInterface.cpp" % (PYTHONSOLLYA_DIR), 
				"%s/cpp/lexerRule.cpp" % (PYTHONSOLLYA_DIR),   
				"%s/cpp/utils.cpp" % (PYTHONSOLLYA_DIR), 
				"%s/cpp/PythonSollyaObject.cpp" % (PYTHONSOLLYA_DIR), 
				"%s/cpp/parserRule.cpp" % (PYTHONSOLLYA_DIR),  
				#"%s/cpp/StringProcessing.cpp" % (PYTHONSOLLYA_DIR),
				"%s/build/PythonSollyaInterface_functions.cpp" % (PYTHONSOLLYA_DIR),
				"%s/build/PythonSollyaInterface_gen_functions.cpp" % (PYTHONSOLLYA_DIR),
                ],
    headers = [
                # headers
                "%s/build/PythonSollyaInterface_functions.hpp" % (PYTHONSOLLYA_DIR),
                "%s/build/PythonSollyaInterface_gen_functions.hpp" % (PYTHONSOLLYA_DIR),
                "%s/cpp/parserRule.hpp" % (PYTHONSOLLYA_DIR),
                "%s/cpp/PythonSollyaObject.hpp" % (PYTHONSOLLYA_DIR),
                "%s/cpp/PythonDouble.hpp" % (PYTHONSOLLYA_DIR),
                #"%s/cpp/StringProcessing.hpp" % (PYTHONSOLLYA_DIR),
                "%s/cpp/PythonSollyaInterface.hpp" % (PYTHONSOLLYA_DIR),
                "%s/cpp/utils.hpp" % (PYTHONSOLLYA_DIR),
                "%s/cpp/python_sollyaObject_struct.h" % (PYTHONSOLLYA_DIR),
                "%s/cpp/ParserContext.h" % (PYTHONSOLLYA_DIR),
                ],

	)

setup(name = "PythonSollyaInterface", 
	version = "0.1", 
	description = "python wrapper for the sollya library", 
	author = "Nicolas Brunie", 
	author_email = "nicolas.brunie@kalray.eu",
	url = "none",
	ext_modules = [PSI_module], 
    scripts = ["setup.py"],
    packages = ["pythonsollya"],
	 py_modules = [#"%s/python/__init__.py" % (PYTHONSOLLYA_DIR),
                 "pythonsollya",
                 "pythonsollya.python.interval",
                 "pythonsollya.python.utils"
                ],

)

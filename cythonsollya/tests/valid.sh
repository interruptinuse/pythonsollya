
export LD_LIBRARY_PATH=$PWD/../../local/lib/:$LD_LIBRARY_PATH
export PYTHONPATH=.
python tests/test_build.py
python tests/test_list.py
python tests/test_cmp.py

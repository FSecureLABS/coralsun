from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

import os

extra_link_args = ['-framework', 'CoreFoundation', '-framework', 'IOKit']

setup(
    ext_modules = cythonize([Extension("iokitlib", ["iokitlib.pyx"],extra_link_args = extra_link_args)])
)

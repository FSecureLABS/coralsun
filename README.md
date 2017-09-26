# coralsun

Coralsun is a small utility cython library used to provide python support for low level kernel features. 

Currently only IOKit and Mach IPC is supported. The fuzzer opalrobot depends on this utility library. 

Support for Mach IPC messaging is partially broken and under development currently. 

Version 0.1 

<h2>Dependencies</h2>

* pip install cython

<h2>Build Instructions</h2>

```python setup.py build_ext --inplace```

<h2>Installation</h2>

```python setup.py install```

<h2>API Usage</h2>

Examples of usage are inclided the iokit_test.py unit test script. 
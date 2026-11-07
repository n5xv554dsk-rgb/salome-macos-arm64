# -*- coding: utf-8 -*-
import os


def value_repr_name(values):
    """
    Create a directory name using the representation of the values.
    Example:
    >>> valueReprName([0.5, 3.0 / 7.0])
    'c0.5_0.42857142857142855_'
    """
    s = "c"
    for v in values:
        s += repr(v) + "_"
    return s


def hashname(values):
    """
    Create a directory name using a hash function.
    Example:
    >>> hashName([0.5, 3.0 / 7.0])
    '6f454e45e9a4fa8856688e80de6bfc58'
    """
    import hashlib

    h = hashlib.md5(repr(values))
    return h.hexdigest()


def temp_dirname():
    """
    Create a temporary directory in the current directory.
    """
    import tempfile

    return tempfile.mkdtemp(dir=os.getcwd())


def replace_data(filename, key_values, filename_out=""):
    """
    Modify an input file using replace function.
    Example:
    origin file: "CPHY_MAT_ISO= $rho $cp $lambda -1 "
    key_values: {'$rho':'3', '$cp':'5', '$lambda':7}
    modified file: "CPHY_MAT_ISO= 3 5 7 -1"
    """
    with open(filename, "r") as f:
        filedata = f.read()
    for key, value in key_values.items():
        filedata = filedata.replace(key, value)
    if len(filename_out) == 0:
        filename_out = filename
    with open(filename_out, "w") as f:
        f.write(filedata)


def format_data(filename, key_values):
    """
    Modify an input file using format function.
    Example:
    origin file: "CPHY_MAT_ISO= {rho} {cp} {lambda} -1 "
    key_values: {'rho':'3', 'cp':'5', 'lambda':'7'}
    modified file: "CPHY_MAT_ISO= 3 5 7 -1"
    """
    with open(filename, "r") as f:
        filedata = f.read()
        filedata = filedata.format(**key_values)
    with open(filename, "w") as f:
        f.write(filedata)

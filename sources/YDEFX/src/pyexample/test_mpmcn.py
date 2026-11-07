
#!/usr/bin/env python3
#  -*- coding: utf-8 -*-
# 

# multiple processes on multiple compute nodes

def f(x):
    return x*x*x
    
def f2(x):
    if x==3:
        raise RuntimeError("lllll")
    return x*x*x

import mpmcn

def gg():
    # case 0 : normal behavior with no raise
    params = mpmcn.init("localhost")
    with mpmcn.Pool(params) as p:
        res = p.map(f,list(range(10)))
        # getResultDirectory : for advanced users
        p.getResultDirectory()
    if res != [0.0, 1.0, 8.0, 27.0, 64.0, 125.0, 216.0, 343.0, 512.0, 729.0]:
        raise RuntimeError("Test Failed !")
    # case 1 : behavior with raise
    params = mpmcn.init("localhost")
    with mpmcn.Pool(params) as p2:
        try:
            res = p2.map(f2,list(range(10)))
            raise RuntimeError("Exception not thrown -> Error !")
        except RuntimeError as e:
            strExpected = "Error for sample # 3 : \'lllll\'"
            # tmp_dir attr of e returns the ResultDirectory to dive into
            if str(e)[:len(strExpected)] != strExpected or not hasattr(e,"tmp_dir"):
                raise RuntimeError("Test Failed 2 !")

if __name__ == "__main__":
    gg()

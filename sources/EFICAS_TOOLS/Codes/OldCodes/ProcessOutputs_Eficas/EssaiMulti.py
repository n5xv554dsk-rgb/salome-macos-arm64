#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
from multiprocessing import Process
from multiprocessing import Lock
from multiprocessing import Pool

def worker(num):
    """thread worker function"""
    print 'Worker:', num
    return

def test1():
    for i in range(5):
        p = Process(target=worker, args=(i,))
        p.start()
        p.join()

def info(title):
    print(title)
    print('parent process:', os.getppid())
    print('process id:', os.getpid())

def f(name):
    info('function f')
    print('hello', name)

def test2():
    info('test2')
    p = Process(target=f, args=('pascale',))
    p.start()
    p.join()

def f(l, i):
    l.acquire()
    try:
        print('hello world', i)
    finally:
        l.release()


def test3(lock):
    for num in range(10):
        Process(target=f, args=(lock, num)).start()

    # sorties evt desordonnees
    for i in range(50):
        p = Process(target=worker, args=(i,)).start()

def g(x):
    return x*x


def test4():
    import traceback
    traceback.print_stack()
    num_cores = 4
    FolderPath='tmp'

    monPool=Pool(maxtasksperchild=1) #create a multiprocessing.Pool object
    for l in range(num_cores):
        print(" lct on core "+str(l) )
        p= monPool.apply_async(g,(l,))

    res = monPool.apply_async(g, (20,))      # runs in *only* one process
    print res.get(timeout=1)                 # prints "400"

    # evaluate "os.getpid()" asynchronously
    res = monPool.apply_async(os.getpid, ()) # runs in *only* one process
    print res.get(timeout=1)              # prints the PID of that process

    # launching multiple evaluations asynchronously *may* use more processes
    multiple_results = [monPool.apply_async(os.getpid, ()) for i in range(4)]
    print [res.get(timeout=1) for res in multiple_results]



if __name__ == '__main__':
   #test1()

   #test2()
   
   #lock = Lock()
   #test3(lock)
   print ('je suis dans main du run')
   test4()


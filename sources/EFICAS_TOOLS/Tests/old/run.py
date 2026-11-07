"""
This program executes all unitest tests that are found in 
    - directories with name test* or Test*
    - files with name test* or Test*

unitest tests are :
    - functions and class with names test* or Test*
    - methods with name test* or Test* from classes with name test* or Test*

Typical uses are :
   
    - execute all tests with text output : python2.4 run.py 
    - execute all tests with html output : python2.4 run.py --html
    - execute some tests with text output : python2.4 run.py testelem
    - execute one test with text output : python2.4 run.py testelem/testsimp1.py
    - execute all tests with verbosity and html output : python2.4 run.py -v --html
"""

import sys,types,os
import sre
import unittest
from optparse import OptionParser

import config

testMatch = sre.compile(r'^[Tt]est')

class TestSuite(unittest.TestSuite):
    ignore=[]
    loader = unittest.defaultTestLoader

    def __init__(self, names=[]):
        self.names=names
        super(TestSuite,self).__init__()
        tests=self.collectTests()
        self.addTests(tests)

    def _import(self,name):
        mod = __import__(name,{},{})
        components = name.split('.')
        for comp in components[1:]:
            mod = getattr(mod,comp)
        return mod

    def importdir(self,rep,path):
        init = os.path.abspath(os.path.join(path,'__init__.py'))
        if os.path.isfile(init):
           package=self._import(rep)
           if package:
              return TestPackageSuite(package)
        else:
           return TestDirectorySuite(path)

    def importfile(self,item,path):
        root, ext = os.path.splitext(item)
        if ext != '.py':
           return  
        if root.find('/') >= 0:
           dirname, file = os.path.split(path)
           root, ext = os.path.splitext(file)
           sys.path.insert(0,dirname)
           mod=self._import(root)
           sys.path.remove(dirname)
        else:
           mod=self._import(root)
        return ModuleTestSuite(mod)

    def collectTests(self):
        if self.names:
           entries=self.names
        else:
           entries = [ item for item in os.listdir(os.getcwd())
                        if item.lower().find('test') >= 0 ]
        self.path=os.getcwd()
        return self._collectTests(entries)

    def _collectTests(self,entries):
        tests=[]
        for item in entries:
            if (item[0] == '.'
                or item in self.ignore
                or not testMatch.search(item)):
                continue
            path=os.path.abspath(os.path.join(self.path,item))
            if os.path.isfile(path):
               t=self.importfile(item,path)
               if t:tests.append(t)
            elif os.path.isdir(path):
               tests.append(self.importdir(item,path))
        return tests

class TestDirectorySuite(TestSuite):
    def __init__(self,path):
        self.path=path
        super(TestDirectorySuite,self).__init__()

    def collectTests(self):
        tests=[]
        if self.path:
            sys.path.insert(0,self.path)
            entries = os.listdir(self.path)
            entries.sort()
            tests=self._collectTests(entries)
            sys.path.remove(self.path)
        return tests

class TestPackageSuite(TestDirectorySuite):
    def __init__(self,package):
        self.package=package
        path=os.path.abspath(os.path.dirname(self.package.__file__))
        super(TestPackageSuite,self).__init__(path)

    def importdir(self,item,path):
        init = os.path.abspath(os.path.join(path,'__init__.py'))
        if os.path.isfile(init):
           name="%s.%s" % (self.package.__name__,item)
           package=self._import(name)
           if package:
              return TestPackageSuite(package)
        else:
           return TestDirectorySuite(path)

    def importfile(self,item,path):
        root, ext = os.path.splitext(item)
        if ext != '.py':
           return
        name="%s.%s" % (self.package.__name__,root)
        mod=self._import(name)
        return ModuleTestSuite(mod)

class ModuleTestSuite(TestSuite):

    def __init__(self, module):
        self.module = module
        super(ModuleTestSuite,self).__init__()

    def collectTests(self):
        def cmpLineNo(a,b):
            a_ln = a.func_code.co_firstlineno
            b_ln = b.func_code.co_firstlineno
            return cmp(a_ln,b_ln)

        entries = dir(self.module)
        tests = []
        func_tests = []
        for item in entries:
            test = getattr(self.module,item)
            if (isinstance(test, (type, types.ClassType))
                and issubclass(test,unittest.TestCase)):
                if testMatch.search(item):
                    [ tests.append(case) for case in
                      self.loader.loadTestsFromTestCase(test)._tests ]
            elif callable(test) and testMatch.search(item):
                # simple functional test
                func_tests.append(test)

        # run functional tests in the order in which they are defined
        func_tests.sort(cmpLineNo)
        [ tests.append(unittest.FunctionTestCase(test))
          for test in func_tests ]
        return tests


class TestProgram(unittest.TestProgram):
    USAGE="""
"""
    def __init__(self):
        self.testRunner = None
        self.verbosity = 1
        self.html=0
        self.parseArgs(sys.argv)
        if self.html:
           import HTMLTestRunner
           self.testRunner = HTMLTestRunner.HTMLTestRunner(verbosity=self.verbosity)
        self.createTests()
        self.runTests()

    def parseArgs(self,argv):
        parser = OptionParser(usage=self.USAGE)
        parser.add_option("-v","--verbose",action="count",
                          dest="verbosity",default=1,
                          help="Be more verbose. ")
        parser.add_option("--html",action="store_true",
                          dest="html",default=0,
                          help="Produce HTML output ")

        options, args = parser.parse_args(argv)
        self.verbosity = options.verbosity
        self.html=options.html

        if args:
            self.names = list(args)
            if self.names[0] == 'run.py':
                self.names = self.names[1:]

    def createTests(self):
        self.test = TestSuite(self.names)

if __name__ == "__main__":
    TestProgram()


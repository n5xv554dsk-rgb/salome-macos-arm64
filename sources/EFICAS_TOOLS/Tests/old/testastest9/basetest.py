import os,glob,sys
import unittest
import difflib

from InterfaceTK import appli

from config import ASTERDIR

version="v9"

def cdiff(text1,text2):
    return " ".join(difflib.context_diff(text1.splitlines(1),text2.splitlines(1)))

def make_tests(files):
    class TestCase(unittest.TestCase):
       app=None

       def setUp(self):
          if self.app == None:
             self.app=appli.STANDALONE(version=version)
          pass

       def tearDown(self):
          CONTEXT.unset_current_step()

       i=0
       for f in glob.glob(os.path.join(ASTERDIR[version],files)):
          ff=open(f)
          text=ff.read()
          ff.close()
          if text.find("VISU_EFICAS='NON'") != -1:continue
          for o in ('3','2','1','0','m'):
           f=f[:-1]+o
           if os.path.isfile(f):break
          i=i+1
          name=os.path.splitext(os.path.basename(f))[0]
    
          exec """def test_%s(self,file="%s"):
                      "fichier:%s"
                      self.commtest(file)
""" % (name,f,f)
       del i,f,ff,text,o,name
    
       def commtest(self,file):
          """ Test generique"""
          name=os.path.splitext(os.path.basename(file))[0]
          errfile=os.path.join(os.path.dirname(__file__),name+".err")
          err=""
          if os.path.isfile(errfile):
              f=open(errfile)
              err=f.read()
              f.close()
          try:
            j=self.app.openJDC(file=file)
            if err == "":
              assert j.isvalid(),j.report()
            else:
              txt=str(j.report())
              assert txt == err,cdiff(err,txt)
              j.supprime()
              assert sys.getrefcount(j) == 2,sys.getrefcount(j)
          except ValueError,e:
            txt=str(e)
            if err == "":
                raise
            else:
                assert txt == err,cdiff(err,txt)
    
    return TestCase

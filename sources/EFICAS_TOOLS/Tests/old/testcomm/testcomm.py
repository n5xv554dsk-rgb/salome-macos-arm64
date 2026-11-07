import os,glob,sys
import unittest
import difflib

import prefs
from InterfaceTK import appli

def add_param(j,pos,nom,valeur):
    co=j.addentite("PARAMETRE",pos)
    co.set_nom(nom)
    co.set_valeur(valeur)
    return co

def add_mcsimp(obj,nom,valeur):
    mcs=obj.get_child(nom,restreint='oui')
    if mcs is None:
       pos=obj.get_index_child(nom)
       mcs=obj.addentite(nom,pos)
    mcs.set_valeur(mcs.eval_val(valeur))
    return mcs

def cdiff(text1,text2):
    return " ".join(difflib.context_diff(text1.splitlines(1),text2.splitlines(1)))

class TestCase(unittest.TestCase):
   app=None
   def setUp(self):
      if self.app == None:
         self.app=appli.STANDALONE(version='v8')
      pass

   def tearDown(self):
      CONTEXT.unset_current_step()

   i=0
   files= os.path.join(os.path.dirname(__file__),"*.comm")
   for f in glob.glob(files):
      for o in ('3','2','1','0','m'):
       f=f[:-1]+o
       if os.path.isfile(f):break

      i=i+1
      exec """def test%s(self,file="%s"):
                  "fichier:%s"
                  self.commtest(file)
""" % (i,f,f)
   del i

   def commtest(self,file):
      """ Test generique"""
      #print file
      name=os.path.splitext(os.path.basename(file))[0]
      errfile=os.path.join(os.path.dirname(__file__),name+".err")
      err=""
      if os.path.isfile(errfile):
          f=open(errfile)
          err=f.read()
          f.close()
      j=self.app.openJDC(file=file)
      assert j.cr.get_mess_exception() == ""

      if err == "":
        assert j.isvalid(),j.report()
      else:
        txt=str(j.report())
        assert txt == err,cdiff(err,txt)

      CONTEXT.unset_current_step()
      j.supprime()
      assert sys.getrefcount(j) == 2,sys.getrefcount(j)

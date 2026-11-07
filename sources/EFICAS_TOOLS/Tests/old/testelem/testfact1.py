# coding=utf-8
from Accas import SIMP,FACT

import unittest

class TestFactCase(unittest.TestCase):
   def setUp(self):
      self.cata=FACT(a=SIMP(typ='I',statut='o'),
                     b=SIMP(typ='R'),
                     c=SIMP(typ='C',defaut=('RI',1,0)),
                    )

   def tearDown(self):
      del self.cata

   def testStatut1(self):
      o=self.cata({'a':1},'mcs1',None)
      cr=o.report()
      self.assert_(cr.estvide())

   def testStatut2(self):
      o=self.cata(None,'mcs1',None)
      cr=o.report()
      expected_cr="""Mot cle Facteur :mcs1
   Mot-clé simple : a
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! Mot-clé :  a  obligatoire non valorisé !
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! None n'est pas une valeur autorisée !
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   Fin Mot-clé simple : a
Fin Mot cle Facteur :mcs1
"""
      self.assertEqual(str(cr) , expected_cr)

   def testType1(self):
      """Verification de type"""
      #Ne leve plus d'exception
      #self.assertRaises(AttributeError,self.cata,1,'mcs1',None)
      o=self.cata({'a':1.2},'mcs1',None)
      cr=o.report()
      expected_cr="""Mot cle Facteur :mcs1
   Mot-clé simple : a
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! 1.2 (de type <type 'float'>) n'est pas d'un type autorisé: ('I',) !
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   Fin Mot-clé simple : a
Fin Mot cle Facteur :mcs1
"""
      msg="le rapport d'erreur est incorrect.\n expected =\n%s\n got =\n%s " % (expected_cr,str(cr))
      self.assertEqual(str(cr) , expected_cr,msg=msg)

   def test031(self):
       cata=FACT(min=2,max=3,a=SIMP(typ='I',statut='o'),)

       liste=(
             (({'a':1},{'a':2}),1),
             (({'a':1},{'a':2},{'a':3},{'a':4}),0),
             (({'a':1},{'a':2},{'a':3}),1),
             (({'a':1},),0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcf',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))

   def test032(self):
       cata=FACT(max=3,a=SIMP(typ='I',statut='o'),)
       mcfact=cata({'a':1},'mcf',None)
       self.assertEqual(mcfact[0].get_mocle('a') , 1)
       self.assertEqual(mcfact['a'] , 1)

       mcfact=cata(({'a':1},{'a':2}),'mcf',None)
       self.assertEqual(mcfact[0]['a'] , 1)
       self.assertEqual(mcfact[1]['a'] , 2)
       self.assertRaises(TypeError,mcfact.__getitem__, 'a')
       def f():
           return mcfact['a']
       self.assertRaises(TypeError,f)

   def test033(self):
       cata=FACT(xx=FACT(statut='o',max=3,a=SIMP(typ='I'),))
       mcfact=cata({},'mcf',None)
       valid=0
       liste=(
             ({},1),
             ({'xx':{}},1),
             ({'xx':{'a':1}},1),
             ({'xx':"error"},0),
             ({'xx':("error","err2","err3")},0),
             ({'xx':({'a':1},"err2","err3")},0),
             ({'xx':("err1",{'a':1},"err3")},0),
             ({'xx':("err1",{'a':1},"err3","err4")},0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcf',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))

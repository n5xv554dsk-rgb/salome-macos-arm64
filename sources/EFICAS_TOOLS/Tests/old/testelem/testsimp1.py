# coding=utf-8
import types
from Accas import SIMP,ASSD,geom,assd
class maillage(ASSD):pass
class maillage_sdaster(ASSD):pass

import unittest

class TestMCSimpCase(unittest.TestCase):
   def setUp(self):
      self.cata=SIMP(typ='I',statut='o')

   def tearDown(self):
      del self.cata

   def testStatut1(self):
      o=self.cata(1,'mcs1',None)
      cr=o.report()
      self.assert_(cr.estvide())

   def testStatut2(self):
      o=self.cata(None,'mcs1',None)
      cr=o.report()
      expected_cr="""Mot-clé simple : mcs1
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! Mot-clé :  mcs1  obligatoire non valorisé !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! None n'est pas une valeur autorisée !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs1
"""
      self.assertEqual(str(cr) , expected_cr)

   def testType1(self):
      o=self.cata(1,'mcs1',None)
      cr=o.report()
      expected_cr="""Mot-clé simple : mcs1
Fin Mot-clé simple : mcs1
"""
      self.assertEqual(str(cr) , expected_cr)

   def test004(self):
       cata=SIMP(typ='shell',statut='o')
       liste=((1,0),("a",1), (1.,0),(('RI',1.,0.),0), (('RI',1,0),0),
              (1+0j,0), ("('RI',1,0)",1), ("toto",1), (None,0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   # Chaines
   def test040(self):
       cata=SIMP(typ='TXM',statut='o')
       liste=((1,0),("a",1), (1.,0),(('RI',1.,0.),0),
              (('RI',1,0),0), (1+0j,0),
              ("('RI',1,0)",1), ("toto",1), (None,0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test041(self):
       cata=SIMP(typ='TXM',statut='o',max=3)
       liste=((1,0),("a",1), (1.,0),(('RI',1.,0.),0),
              (('RI',1,0),0), (1+0j,0),
              (("toot","titi"),1),
              (("toot","titi","tutu"),1),
              (("toot","titi",1),0),
              (("toot","titi","tutu","tata"),0),
              ("('RI',1,0)",1), ("toto",1), (None,0), 
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur) 

   def test042(self):
       cata=SIMP(typ='TXM',statut='o',into=("toto","titi"),max=3)
       liste=((1,0),("a",0), (1.,0),(('RI',1.,0.),0),
              (('RI',1,0),0), (1+0j,0),
              (("toto","titi"),1),
              (("toot","titi","tutu"),0),
              (("toot","titi",1),0),
              (("toot","titi","tutu","tata"),0),
              ("('RI',1,0)",0), ("toto",1), (None,0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test043(self):
       cata=SIMP(typ='TXM',statut='o',into=("toto","titi"),min=2,max=3)
       liste=((1,0),("a",0), (1.,0),(('RI',1.,0.),0),
              (('RI',1,0),0), (1+0j,0),
              (("toto","titi"),1),
              (("toot","titi","tutu"),0),
              (("toot","titi",1),0),
              (("toot","titi","tutu","tata"),0),
              ("('RI',1,0)",0), ("toto",0), (None,0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   # Reels
   def test020(self):
       cata=SIMP(typ='R',statut='o',max=4)
       liste=((1,1),("a",0), (1.,1),(('RI',1.,0.),0), ((1.,2.,3.),1),
              ((1.,2.,3.,4.),1), ((1.,2.,3.,4.,5.),0), ("toto",0), (None,0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test021(self):
       cata=SIMP(typ='R',statut='o',min=2,max=4)
       liste=((1,0),("a",0), (1.,0),(('RI',1.,0.),0),
              ((1.,2.),1), ((1.,2.,3.),1), ((1.,2.,3.,4.),1),
              ((1.,2.,3.,4.,5.),0), ("toto",0), (None,0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)


   def test022(self):
       cata=SIMP(typ='R',statut='o',val_min=2,val_max=4)
       liste=((1,0),("a",0), (1.,0),(('RI',1.,0.),0), (3,1),
              (6,0), ((1.,2.),0), ((1.,2.,3.),0), ((1.,2.,3.,4.),0),
              ((1.,2.,3.,4.,5.),0), ("toto",0), (None,0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test023(self):
       cata=SIMP(typ='R',statut='o',val_min=2,val_max=4,max=4)
       liste=((1,0),("a",0), (1.,0),(('RI',1.,0.),0), (3,1),
              (6,0), ((1.,6.),0), ((3.,2.),1), ((1.,2.,3.),0),
              ((1.,2.,3.,4.),0), ((1.,2.,3.,4.,5.),0), ("toto",0),
              (None,0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test024(self):
       cata=SIMP(typ='R',statut='o')
       liste=((1,1),("a",0), (1.,1),(('RI',1.,0.),0), (('RI',1,0),0),
              (1+0j,0), ("('RI',1,0)",0), ((1.,2.,3.),0), ("toto",0),
              (None,0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)


   # Entiers
   def test030(self):
       cata=SIMP(typ='I',statut='o')
       liste=((1,1),("a",0), (1.1,0),(('RI',1.,0.),0),
              (('RI',1,0),0), (1+0j,0), ("1",0), ("toto",0), (None,0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test031(self):
       cata=SIMP(typ='I',statut='o',into=(1,5,8),max=4)
       liste=((1,1),("a",0), ("toto",0), (None,0),
              (1.1,0),(('RI',1.,0.),0),
              (3,0), (6,0), ((1,5),1), ((1,5,8),1), ((1,5,8,5),1),
              ((1,5,8,5,1),0), ((1.,6.),0), ((3.,2.),0), ((1.,2.,3.),0),
              ((1.,2.,3.,4.),0), ((1.,2.,3.,4.,5.),0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   # Complexes
   def test010(self):
       cata=SIMP(typ='C',statut='o',into=(('RI',1,0),('RI',2,0),('RI',3,0)),max=4)
       liste=((1,0),("a",0), (1.,0),(('RI',1.,0.),1), ("toto",0), (None,0),
              ((('RI',1.,0.),('RI',2,0)),1),
              ((('RI',1.,0.),('RI',2,0),('RI',3,0)),1),
              ((('RI',1.,0.),('RI',2,0),('RI',3,0),('RI',3,0)),1),
              ((('RI',1.,0.),('RI',2,0),('RI',3,0),('RI',3,0),('RI',1,0)),0),
              ((1,5),0), ((1,5,8,5,1),0),
              ((1.,6.),0), ((3.,2.),0), ((1.,2.,3.),0), ((1.,2.,3.,4.,5.),0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test011(self):
       cata=SIMP(typ='C',statut='o',max=3)
       liste=((1,1),("a",0), (1.,1),(('RI',1.,0.),1), ("toto",0), (None,0),
              ((('RI',1.,0.),('RI',2,0)),1),
              ((('RI',1.,0.),('RI',2,0),('RI',3,0)),1),
              ((('RI',1.,0.),('RI',2,0),('RI',3,0),('RI',3,0)),0),
              ((('RI',1.,0.),('RI',2,0),('RI',3,0),('RI',3,0),('RI',1,0)),0),
              ((1,5),1), ((1,5,8,5,1),0),
              ((1.,6.),1), ((3.,2.),1), ((1.,2.,3.),1), ((1.,2.,3.,4.,5.),0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test012(self):
       cata=SIMP(typ='C',statut='o')
       liste=((1,1),("a",0), (1.,1),(('RI',1.,0.),1), (('RI',1,0),1), (1+0j,1),
              ("('RI',1,0)",0), ("toto",0), (None,0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,"erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test013(self):
       cata=SIMP(typ=('R',maillage),statut='o')
       liste=((1,1),
              (maillage(),1),
              (maillage_sdaster(),0),
              ("aa",0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,
                "erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test014(self):
       cata=SIMP(typ=geom,statut='o')
       liste=((1,0),
              ("aaaa",1),
            )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,
                "erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test015(self):
       cata=SIMP(typ=assd,statut='o')
       liste=((1,1),
              ("aaaa",1),
            )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,
                "erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)

   def test016(self):
       class LongStr:
         def __init__(self,min,max):
            self.min=min
            self.max=max
         def __convert__(self,valeur):
            if type(valeur) == types.StringType:
               if self.min < len(valeur) < self.max:return valeur
            return None

       cata=SIMP(typ=LongStr(5,8),statut='o')
       liste=(("aaaaaa",1),
              ("aaaaaaa",1),
              ("aaaaaaaaaaaaaaa",0),
              ("aa",0),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           self.assertEqual(o.isvalid(),valid,
                     "erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report()))
           if valid: self.assertEqual(o.get_valeur(),valeur)


# coding=utf-8
from Accas import SIMP,ASSD

import unittest

class TestSimpCase(unittest.TestCase):
   def setUp(self):
       pass

   def tearDown(self):
       pass

   def test001(self):
       cata=SIMP(statut='o',typ='TXM',defaut="d")
       liste=((1,0),("a",1), (1.,0),(('RI',1.,0.),0), (('RI',1,0),0),
              (1+0j,0), ("('RI',1,0)",1), ("toto",1), (None,1),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           msg="erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report())
           self.assertEqual(o.isvalid(),valid,msg=msg)

   def test002(self):
       cata=SIMP(statut='f',typ='TXM',defaut="d")
       liste=((1,0),("a",1), (1.,0),(('RI',1.,0.),0), (('RI',1,0),0),
              (1+0j,0), ("('RI',1,0)",1), ("toto",1), (None,1),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           msg="erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report())
           self.assertEqual(o.isvalid(),valid,msg=msg)

   def test003(self):
       cata=SIMP(statut='o',typ='R',max=3)
       class mylist(list):pass
       liste=((1,1),(mylist((0.,1.)),1), (1.,1),(mylist((0.,1.)),1), (('RI',1,0),0),
              (1+0j,0), ("('RI',1,0)",0), ("toto",0), (None,0),
              (mylist(("aaaa",1.)),0), (mylist((0.,1.,2.,3.)),0), 
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           msg="erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report())
           self.assertEqual(o.isvalid(),valid,msg=msg)

   def test004(self):
       cata=SIMP(statut='f',typ=('R','I'),max=5)
       liste=((1,1),(1.5,1), ((1,2),1),
              ((2.3,3.4),1),((1,2.0),1),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           msg="erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report())
           self.assertEqual(o.isvalid(),valid,msg=msg)

   def _test005(self):
       cata=SIMP(statut='f',typ='I',max=5)
       liste=((1,1),(1.0,1), ((1,2),1),
              ((2.3,3.4),0),((1,2.0),1),
             )
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           msg="erreur sur le test %s %s" % (valeur,valid)+'\n'+str(o.report())
           self.assertEqual(o.isvalid(),valid,msg=msg)


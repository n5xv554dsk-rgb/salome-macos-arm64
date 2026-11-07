# coding=utf-8
from Accas import *

import unittest

class myparam:
    def __init__(self,valeur):
        self.valeur=valeur
    def __adapt__(self,protocol):
        return protocol.adapt(self.valeur)

from Accas.processing.P_VALIDATOR import listProto,TypeProtocol,IntoProtocol
class param:
    def __init__(self,valeur):
        self.valeur=valeur

def hasvaleur(obj,protocol,**args):
    return protocol.adapt(obj.valeur)

listProto.register(param,hasvaleur)
TypeProtocol.register(param,hasvaleur)
IntoProtocol.register(param,hasvaleur)
OrdList.register(param,hasvaleur)

class TestValidCase(unittest.TestCase):
   def setUp(self):
       pass

   def tearDown(self):
       pass

   def _test(self,cata,liste):
       for valeur,valid in liste:
           o=cata(valeur,'mcs',None)
           msg=None
           if valid != o.isvalid() :
              if not valid:
                 msg="erreur : le mot cle devrait etre invalide. valeur = %s, valid = %s " % (valeur,valid)
              else:
                 msg="erreur : le mot cle devrait etre valide. valeur = %s, valid = %s " % (valeur,valid) + '\n' + str(o.report())
           self.assertEqual(o.isvalid(),valid,msg)
           if valid: 
              self.assertEqual(o.get_valeur(),valeur)

   def test001(self):
       cata=SIMP(typ='TXM',validators=LongStr(3,5))
       liste=(("aa",0),("aaa",1),
              ("aaaa",1),("aaaaa",1),
              ("axyzaa",0),("bbbbaaa",0),
             )
       self._test(cata,liste)

   def test002(self):
       cata=SIMP(statut='o',typ='TXM',min=1,max=4,validators=LongStr(3,5))
       liste=(
              ("aa",0),("aaa",1),
              (("aaaa","aaaaa","axyzaa","bbbbaaa","zzz"),0),
              (("aaaa","aaaaa","axyz","bbbb","zzz"),0),
              (("aaaa","axyz","bbbb","zzz"),1),
              ("aaaa",1),("aaaaa",1),
              ("axyzaa",0),("bbbbaaa",0),
              (("aaaa",param("axyz"),"bbbb","zzz"),1),
             )
       self._test(cata,liste)

   def test003(self):
       cata=SIMP(statut='o',typ='I',validators=TypeVal(1))
       liste=(
               (1,1),(1.1,0),(1.25,0),
               (('RI',0.,1.),0),
             )
       self._test(cata,liste)

   def test004(self):
       cata=SIMP(statut='o',typ='I',into=(1,2,3,4,5,6),max='**',validators=OrdList("croissant"))
       liste=(
              (1,1),((1,3),1),
              ((3,1),0),
              ((1,3,2),0),
              ((1.1,2.),0),
              (myparam((1.,2.)),0),
              (myparam((1,2)),1),
              (myparam((1,2,3,4,5)),1),
              (myparam((1,2,myparam(3),4,5)),1),
              (myparam((1,2,myparam(6),4,5)),0),
              (param((1.,2.)),0),
              (param((1,2)),1),
              (param((1,2,3,4,5)),1),
              (param((1,2,myparam(3),4,5)),1),
              (param((1,2,param(3),4,5)),1),
              (param((1,2,param(6),4,5)),0),
             )
       self._test(cata,liste)

   def test005(self):
       cata=SIMP(statut='o',typ='I',validators=EnumVal((3,2,4,8,9,15)))
       liste=(
              (1,0),(9,1),(15,1),
              (50,0),(1.25,0),
             )
       self._test(cata,liste)

   def test006(self):
       cata=SIMP(statut='o',typ='I',max='**',validators=OrdList("croissant"))
       liste=(
              (1,1),((1,3),1),
              ((50,60,701),1),
              ((100,50,60,701),0),
              ((3,1),0),
              ((1,3,2),0),
              ((1.1,2.),0),
             )
       self._test(cata,liste)

   def test007(self):
       cata=SIMP(statut='o',typ='I',min=1,max=4,validators=PairVal())
       liste=(
             (2,1),((2,4),1),
             (3,0),((3,4),0),
             ((2,3),0),((3,5),0),
             ((2,4,6,8),1),
             ((2,4,6,8,10),0),
             )
       self._test(cata,liste)

   def test008(self):
       cata=SIMP(statut='o',typ='I',validators=RangeVal(3,15))
       liste=(
             (2,0),(4,1),
             (16,0),(14,1),
             )
       self._test(cata,liste)

   def test009(self):
       cata=SIMP(statut='o',typ='I',max='**',validators=CardVal(3,15))
       liste=(
             (2,0),((2,4),0),
             (3,0),((3,4),0),
             ((2,3),0),((3,5),0),
             ((2,4,6,8),1),
             ((2,4,6,8,10),1),
             )
       self._test(cata,liste)

   def test010(self):
       cata=SIMP(statut='o',typ='TXM',min=1,max=6,validators=NoRepeat())
       liste=(
              ("aa",1),("aaa",1),
              (("aaaa","aaaaa","axyzaa","bbbbaaa","zzz"),1),
              (("aaaa","aaaa","axyz","bbbb","zzz"),0),
              (("aaaa","axyz","bbbb","zzz"),1),
              ("aaaa",1),("aaaaa",1),
              ("axyzaa",1),("bbbbaaa",1),
              (("aaaa",param("aaaaa"),"axyzaa","bbbbaaa","zzz"),1),
              (("aaaa",param("aaaa"),"axyzaa","bbbbaaa","zzz"),0),
              (("aaaa",myparam("aaaaa"),"axyzaa","bbbbaaa","zzz"),1),
              (("aaaa",myparam("aaaa"),"axyzaa","bbbbaaa","zzz"),0),
             )
       self._test(cata,liste)

   def test011(self):
       cata=SIMP(statut='o',typ='TXM',min=1,max=6,into =( "TUTU","TATA","CCCC"),validators=NoRepeat())
       liste=(
              ("TUTU",1),("TATA",1),
              (("TUTU","TATA","CCCC"),1),
              (("TUTU","TATA","CCCC","TUTU","TATA","CCCC"),0),
              (("TUTU","TATA","CCCC","TUTU","TATA","CCCC","TUTU","TATA","CCCC"),0),
             )
       self._test(cata,liste)

   def test012(self):
       cata=SIMP(statut='o',typ='I',min=1,max=1,into =( 1,2,3),validators=PairVal())
       liste=(
              (2,1),(1,0),(3,0),(4,0),
              (param(2),1),(param(3),0),
              (myparam(2),1),(myparam(3),0),
             )
       self._test(cata,liste)

   def test013(self):
       cata=SIMP(statut='o',typ='I',min=1,max=1,validators=PairVal())
       liste=(
              (2,1),(1,0),(3,0),(4,1),
             )
       self._test(cata,liste)

   def test014(self):
       cata=SIMP(statut='o',typ='I',min=1,max=6,validators=PairVal())
       liste=(
              (2,1),(1,0),(3,0),(4,1),
              ((2,4,6,8),1),((2,4,6,8,10,12,14),0),
              ((2,4,6,8,7),0),((2,4,6,8,10,12,14,23),0),
             )
       self._test(cata,liste)

   def test015(self):
       """Test du validateur OU : pas de doublon OU valeur paire """
       cata=SIMP(statut='o',typ='I',min=1,max=6,validators=(NoRepeat(),PairVal()))
       liste=(
              (2,1),(1,1),(3,1),(4,1),
              ((2,4,6,8),1),((2,4,6,8,10,12,14),0),
              ((1,2,3,4),1),
              ((2,4,6,8,7),1),((2,4,6,8,10,12,14,23),0),
             )
       self._test(cata,liste)

   def test016(self):
       """Test du validateur ET : pas de doublon ET valeur paire """
       cata=SIMP(statut='o',typ='I',min=1,max=6,validators=[NoRepeat(),PairVal()])
       liste=( (2,1),(None,0),((1,3,5),0),
               ((2,4,6),1),
               ((1,3,5),0),
               ((2,4,4),0),
             )
       self._test(cata,liste)

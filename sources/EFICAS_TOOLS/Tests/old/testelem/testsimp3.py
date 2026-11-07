# coding=utf-8
from Accas import *

import unittest
import compare
OK="""Mot-clé simple : mcs
Fin Mot-clé simple : mcs
"""
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


class TestValidCase(unittest.TestCase):
   def setUp(self):
       pass

   def tearDown(self):
       pass

   def _test(self,cata,liste):
       for valeur,report in liste:
           o=cata(valeur,'mcs',None)
           msg=""
           rep=str(o.report())
           valid=compare.check(rep,report)
           if not valid:
              msg="le rapport d'erreur est incorrect.\n valeur = %s\n expected =\n%s\n got =\n%s " % (valeur,report,rep)
              print msg
           self.assert_(valid,msg=msg)

   def test010(self):
       """Test de listes de string"""
       cata=SIMP(statut='o',typ='TXM',min=1,max=6)
       liste=(
              ("aa",OK),("aaa",OK),
              (("aaaa","aaaaa","axyzaa","bbbbaaa","zzz"),OK),
              (("aaaa","aaaa","axyz","bbbb","zzz"),OK),
              (("aaaa","axyz","bbbb","zzz"),OK),
              ("aaaa",OK),("aaaaa",OK),
              ("axyzaa",OK),("bbbbaaa",OK),
             )
       self._test(cata,liste)

   def test011(self):
       """Test de listes de string avec into"""
       cata=SIMP(statut='o',typ='TXM',min=1,max=6,into =( "TUTU","TATA","CCCC"))
       liste=(
              ("TUTU",OK),("TATA",OK),
              (("TUTU","TATA","CCCC"),OK),
              (("TUTU","TATA","CCCC","TUTU","TATA","CCCC"),OK),
              (("TUTU","TATA","CCCC","TUTU","TATA","CCCC","TUTU","TATA","CCCC"),
"""Mot-clé simple : mcs
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! Nombre d'arguments de ('TUTU', 'TATA', 'CCCC', 'TUTU', 'TATA', 'CCCC', 'TUTU', !
   ! 'TATA', 'CCCC') incorrect (min = 1, max = 6)                                   !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs
"""),
              (("TUTU","TATA","CCCC","TUTU","TATA",1,"TUTU","TATA","CCCC"),
"""Mot-clé simple : mcs
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! 1 (de type <type 'int'>) n'est pas d'un type autorisé: ('TXM',) !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! La valeur : 1  ne fait pas partie des choix possibles ('TUTU', 'TATA', 'CCCC') !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! Nombre d'arguments de ('TUTU', 'TATA', 'CCCC', 'TUTU', 'TATA', 1, 'TUTU', 'TATA', !
   !  'CCCC') incorrect (min = 1, max = 6)                                             !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs
"""),
             )
       self._test(cata,liste)

   def test016(self):
       """Test de listes d'entiers """
       cata=SIMP(statut='o',typ='I',min=1,max=6)
       liste=( ((2,),OK),(None,
"""Mot-clé simple : mcs
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! Mot-clé :  mcs  obligatoire non valorisé !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! None n'est pas une valeur autorisée !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs
"""),
               ((1,3,5),OK),
               ((2,4,6),OK),
               ((2,4,4),OK),
               (myparam((2,4,4)),OK),
               (myparam((2,4.5,4)),
"""Mot-clé simple : mcs
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! 4.5 (de type <type 'float'>) n'est pas d'un type autorisé: ('I',) !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs
"""),
               (myparam((2,myparam(4.5),4)),
"""Mot-clé simple : mcs
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! 4.5 (de type <type 'float'>) n'est pas d'un type autorisé: ('I',) !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs
"""),
               (param((2,4,4)),OK),
               (param((2,4.5,4)),
"""Mot-clé simple : mcs
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! 4.5 (de type <type 'float'>) n'est pas d'un type autorisé: ('I',) !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs
"""),
               (param((2,param(4.5),4)),
"""Mot-clé simple : mcs
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! 4.5 (de type <type 'float'>) n'est pas d'un type autorisé: ('I',) !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs
"""),
             )
       self._test(cata,liste)

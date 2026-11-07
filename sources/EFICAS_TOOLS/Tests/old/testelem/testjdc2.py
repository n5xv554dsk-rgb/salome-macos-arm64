# -*- coding: iso-8859-1 -*-
import cata5

import unittest,re,os
import compare

class TestJDCCase(unittest.TestCase):

   def test1(self):
      text="""
# OP2 : CO converti en concept2 ou concept2. Retourne concept
# OP6 : uniquement CO converti en concept2. Retourne concept
# OP3 : CO converti en concept ou concept. Retourne concept
co0=OP2(MATR=CO("x1"))
co2=OP6(MATR=CO("xx"))
co3=OP3(MATR={"CHAM":"R","MM":co2})
"""
      self.execute(cata5,text)

   def test2(self):
      text="""
# OP2 : CO converti en concept2 ou concept2. Retourne concept
# OP5 : uniquement CO converti en concept2. Retourne concept
co0=OP2(MATR=CO("x1"))
co1=OP5(MATR=co0)
"""
      expected="""DEBUT CR validation : bidon
   Etape : OP5    ligne : 5    fichier : 'bidon'
      Mot-clé simple : MATR
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         ! concept co0 de type concept (de type <class 'cata5.concept'>) n'est pas d'un !
         ! type autorisé: (<class 'Accas.A_ASSD.CO'>,)                                  !
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      Fin Mot-clé simple : MATR
   Fin Etape : OP5
FIN CR validation :bidon
"""
      self.execute(cata5,text,err3=expected)

   def test3(self):
      text="""
# OP2 : CO converti en concept2 ou concept2. Retourne concept
co0=OP2(MATR=CO("x1"))
co1=OP2(MATR=x1)
co2=OP2(MATR=co0)
"""
      expected="""DEBUT CR validation : bidon
   Etape : OP2    ligne : 5    fichier : 'bidon'
      Mot-clé simple : MATR
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         ! concept co0 de type concept (de type <class 'cata5.concept'>) n'est pas d'un !
         ! type autorisé: (<class 'Accas.A_ASSD.CO'>, <class 'cata5.concept2'>)         !
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      Fin Mot-clé simple : MATR
   Fin Etape : OP2
FIN CR validation :bidon
"""
      self.execute(cata5,text,err3=expected)

   def test8(self):
      text="""
co2=OP14(MATR=CO("xx"))
"""
      expected=""
      self.execute(cata5,text,err4=expected)

   def test12(self):
      text="""
co2=OP18(MATR=CO("xx"))
co3=OP2(MATR=xx)
co4=OP11(MATR=xx)
"""
      expected=""
      self.execute(cata5,text,err4=expected)

   def test13(self):
      text="""
co2=OP10(MATR=CO("xx"))
"""
      expected="""DEBUT CR validation : bidon
   Etape : OP10    ligne : 2    fichier : 'bidon'
      Mot-clé simple : MATR
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         ! concept xx de type CO (de type <class 'Accas.A_ASSD.CO'>) n'est pas d'un type !
         ! autorisé: (<class 'cata5.concept2'>,)                                         !
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      Fin Mot-clé simple : MATR
   Fin Etape : OP10
FIN CR validation :bidon
"""
      self.execute(cata5,text,err3=expected)

   def test16(self):
      text="""
co=OP22(MATR=CO("xx"))
"""
      self.execute(cata5,text)

   def test17(self):
      text="""
co=OP22(MATR=CO("xx"))
co2=OP22(MATR=xx)
"""
      expected="""DEBUT CR validation : bidon
   Etape : OP22    ligne : 3    fichier : 'bidon'
      Mot-clé simple : MATR
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         ! concept xx de type concept4 (de type <class 'cata5.concept4'>) n'est pas d'un !
         ! type autorisé: (<class 'Accas.A_ASSD.CO'>,)                                   !
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      Fin Mot-clé simple : MATR
   Fin Etape : OP22
FIN CR validation :bidon
"""
      self.execute(cata5,text,err3=expected)

   def setUp(self):
      pass

   def tearDown(self):
      pass

   def execute(self,cata,text_jdc,err1="",err2="",err3="",err4=""):
      j=cata.JdC(procedure=text_jdc,cata=cata,nom="bidon")
      j.actif_status=1
      j.fico=None
      j.set_par_lot("OUI")
      # On compile le texte Python
      j.compile()
      # On initialise les tops de mesure globale de temps d'execution du jdc
      j.cpu_user=os.times()[0]
      j.cpu_syst=os.times()[1]
      j.impr_macro='NON'

      #print j.cr
      if err1 == "":
        self.assert_(j.cr.estvide(),msg='Erreur non attendue dans compile (err1):\n%s' % str(j.cr))
      else:
        self.assert_(self.check(err1,str(j.cr)),msg='Erreur non attendue dans compile (err1):\n%s\n!=\n%s' % (str(j.cr),err1))
        j.supprime()
        return

      j.exec_compile()
      #print j.cr
      if err2 == "":
        self.assert_(j.cr.estvide(),msg='Erreur non attendue dans exec_compile (err2):\n%s' % str(j.cr))
      else:
        self.assert_(self.check(err2,str(j.cr)),msg='Erreur non attendue dans exec_compile(err2):\n%s\n!=\n%s' % (str(j.cr),err2))
        j.supprime()
        return

      cr=j.report()
      #print cr
      if err3 == "":
        self.assert_(cr.estvide(),msg='Erreur non attendue dans exec_compile (err3):\n%s' % str(cr))
      else:
        self.assert_(self.check(err3,str(cr)),msg='Erreur non attendue dans exec_compile(err3):\n%s\n!=\n%s' % (str(cr),err3))
        j.supprime()
        return

      j.set_par_lot("NON")

      j.supprime()

   def check(self,want,got):
      return compare.check(want,got)

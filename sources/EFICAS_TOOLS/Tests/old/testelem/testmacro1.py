import cata2
from cata2 import OP1,OP2,OP3,OP4,OP5,OP6

from Accas import AsException,CO

import unittest

class TestMacroCase(unittest.TestCase):
   def setUp(self):
      pass

   def tearDown(self):
      pass

   def test1(self):
      co2=OP4()
      cr=co2.etape.report()
      self.assert_(cr.estvide(),msg='Erreur non attendue:\n%s' % str(cr))
      co2.etape.supprime()

   def test4(self):
      co1=OP1(a=1)
      co2=OP2(MATR=CO("xx"))
      cr=co2.etape.report()
      self.assert_(cr.estvide(),msg='Erreur non attendue:\n%s' % str(cr))
      co1.etape.supprime()
      co2.etape.supprime()

   def test3(self):
      co1=OP1(a=1)
      co2=OP3(MATR={"CHAM":"R","MM":CO("xx")})
      cr=co2.etape.report()
      self.assert_(cr.estvide(),msg='Erreur non attendue:\n%s' % str(cr))
      co1.etape.supprime()
      co2.etape.supprime()

   def test2(self):
      co1=OP1(a=1)
      co2=OP3(MATR=({"CHAM":"R","MM":CO("xx")},
                    {"CHAM":"R","MM":CO("xx")},
                   ),
             )
      cr=co2.etape.report()
      self.assert_(cr.estvide(),msg='Erreur non attendue:\n%s' % str(cr))
      co1.etape.supprime()
      co2.etape.supprime()

   def test5(self):
      co2=OP5(MATR=CO("xx"))
      co3=OP3(MATR={"CHAM":"R","MM":co2})
      #print co3.etape.report()
      cr=co2.etape.report()
      #print cr
      self.assert_(cr.estvide(),msg='Erreur non attendue:\n%s' % str(cr))
      co2.etape.supprime()
      co3.etape.supprime()

   def test6(self):
      co2=OP6(MATR=CO("xx"))
      co3=OP3(MATR={"CHAM":"R","MM":co2})
      #print co3.etape.report()
      cr=co2.etape.report()
      #print cr
      self.assert_(cr.estvide(),msg='Erreur non attendue:\n%s' % str(cr))
      co2.etape.supprime()
      co3.etape.supprime()


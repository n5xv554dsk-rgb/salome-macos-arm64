from Accas.processing import SIMP

import unittest

class TestSimpCase(unittest.TestCase):
   def testStatut1(self):
      a=SIMP(typ='I',statut='o')
      cr=a.report()
      self.assert_(cr.estvide())

   def testStatut2(self):
      a=SIMP(typ='I')
      cr=a.report()
      self.assert_(cr.estvide())

   def testStatut3(self):
      a=SIMP(typ='I',statut='s')
      cr=a.report()
      expected_cr="""
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! L'attribut 'statut' doit valoir 'o','f','c' ou 'd' : 's' !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

"""
      self.assertEqual(str(cr) , expected_cr)

   def testPosition1(self):
      a=SIMP(typ='I',position='total')
      cr=a.report()
      expected_cr="""
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! L'attribut 'position' doit valoir 'local','global' ou 'global_jdc' : 'total' !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

"""
      self.assertEqual(str(cr) , expected_cr)

   def testMinMax1(self):
      a=SIMP(typ='I',min='**',max=12)
      cr=a.report()
      expected_cr="""
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! Nombres d'occurrence min et max invalides : '**' 12 !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

"""
      self.assertEqual(str(cr) , expected_cr)

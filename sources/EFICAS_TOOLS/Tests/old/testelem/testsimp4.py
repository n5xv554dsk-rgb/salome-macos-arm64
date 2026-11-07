# coding=utf-8
from Accas import SIMP,ASSD
class maillage(ASSD):pass
class maillage_sdaster(ASSD):pass

import unittest

class TestMCSimpCase(unittest.TestCase):
   def setUp(self):
      self.cata=SIMP(typ='I',statut='o')

   def tearDown(self):
      del self.cata

   def test001(self):
      cata=SIMP(typ='I',max=5)
      o=cata((1,2,'aa','bb',7,'cc'),'mcs1',None)
      cr=o.report()
      expected_cr="""Mot-clé simple : mcs1
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! 'aa' (de type <type 'str'>) n'est pas d'un type autorisé: ('I',) !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! Nombre d'arguments de (1, 2, 'aa', 'bb', 7, 'cc') incorrect (min = 1, max = 5) !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs1
"""
      self.assertEqual(str(cr) , expected_cr,msg='Erreur :\n%s\n!=\n%s' % (str(cr),expected_cr))

   def test002(self):
      cata=SIMP(typ='I',max=7,into=(1,2,'aa','bb',7,'cc'))
      o=cata((1,2,'aa','bb',7,'cc'),'mcs1',None)
      cr=o.report()
      expected_cr="""Mot-clé simple : mcs1
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! 'aa' (de type <type 'str'>) n'est pas d'un type autorisé: ('I',) !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs1
"""
      self.assertEqual(str(cr) , expected_cr,msg='Erreur :\n%s\n!=\n%s' % (str(cr),expected_cr))

   def test003(self):
      cata=SIMP(typ='R',max=7,into=(1,2,7))
      o=cata((1,2,7,3,4,5,6),'mcs1',None)
      cr=o.report()
      expected_cr="""Mot-clé simple : mcs1
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! La valeur : 3.0  ne fait pas partie des choix possibles (1, 2, 7) !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs1
"""
      self.assertEqual(str(cr) , expected_cr,msg='Erreur :\n%s\n!=\n%s' % (str(cr),expected_cr))

   def test004(self):
      cata=SIMP(typ='R',max=7,val_max=6)
      o=cata((1,2,7,3,4,5,6),'mcs1',None)
      cr=o.report()
      expected_cr="""Mot-clé simple : mcs1
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! La valeur : 7.0 est en dehors du domaine de validité [ ** , 6 ] !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs1
"""
      self.assertEqual(str(cr) , expected_cr,msg='Erreur :\n%s\n!=\n%s' % (str(cr),expected_cr))

   def test005(self):
      cata=SIMP(typ='R',max=6,val_max=6)
      o=cata((1,2,7,3,4,5,6),'mcs1',None)
      cr=o.report()
      expected_cr="""Mot-clé simple : mcs1
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! La valeur : 7.0 est en dehors du domaine de validité [ ** , 6 ] !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! Nombre d'arguments de (1.0, 2.0, 7.0, 3.0, 4.0, 5.0, 6.0) incorrect (min = 1, !
   ! max = 6)                                                                      !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs1
"""
      self.assertEqual(str(cr) , expected_cr,msg='Erreur :\n%s\n!=\n%s' % (str(cr),expected_cr))

   def test006(self):
      cata=SIMP(typ='R',max=6,val_max=6)
      o=cata((1,2,7,"aa",4,"bb",6),'mcs1',None)
      cr=o.report()
      expected_cr="""Mot-clé simple : mcs1
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! 'aa' (de type <type 'str'>) n'est pas d'un type autorisé: ('R',) !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! La valeur : 7.0 est en dehors du domaine de validité [ ** , 6 ] !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! Nombre d'arguments de (1.0, 2.0, 7.0, 'aa', 4.0, 'bb', 6.0) incorrect (min = 1, !
   ! max = 6)                                                                        !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs1
"""
      self.assertEqual(str(cr) , expected_cr,msg='Erreur :\n%s\n!=\n%s' % (str(cr),expected_cr))

   def futuretest007(self):
      """
        Ce test échoue alors qu'il ne devrait pas. Le parametre de definiton homo
        qui vaut 1 par defaut indique que la liste devrait etre homogene en type
        ce qui n'est pas le cas.
      """
      cata=SIMP(typ=('R','TXM'),max=6,val_max=6)
      o=cata((1,2,7,"aa",4,"bb",6),'mcs1',None)
      cr=o.report()
      expected_cr="""Mot-clé simple : mcs1
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! 'aa' n'est pas d'un type autorisé !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! La valeur : 7  du mot-clé  mcs1  est en dehors du domaine de validité [ 6 , 6 ] !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ! Nombre d'arguments de (1, 2, 7, 'aa', 4, 'bb', 6) incorrect pour mcs1 (min = 1, !
   ! max = 6)                                                                        !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Fin Mot-clé simple : mcs1
"""
      self.assertEqual(str(cr) , expected_cr,msg='Erreur :\n%s\n!=\n%s' % (str(cr),expected_cr))


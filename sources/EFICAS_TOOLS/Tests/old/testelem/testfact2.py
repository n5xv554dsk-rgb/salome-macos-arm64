from Accas import SIMP,FACT,BLOC

import unittest


class TestFactCase(unittest.TestCase):

   def test001(self):
      """
       Cas test avec un bloc conditionnel active par un mot cle simple avec 
       valeur par defaut, non present
       Le bloc contient un mot cle simple avec defaut non present
       On s'attend a recuperer les 2 mots cles simples avec leur valeur par 
       defaut.
      """
      cata=FACT(ZORGLUB  =SIMP(statut='f',typ='TXM',defaut='OOO'),
                b_unit1  =BLOC(condition = "ZORGLUB=='OOO'",
                               TOTO  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),  
                              ),
                    )
      mcfact=cata({},'mcf',None)
      valeur_attendue={'ZORGLUB':'OOO','TOTO':'AAA'}
      dico=mcfact[0].cree_dict_valeurs(mcfact[0].mc_liste)
      #dico=mcfact.cree_dict_valeurs(mcfact.mc_liste)
      self.assertEqual(dico , valeur_attendue)
      self.assertEqual(mcfact[0].get_mocle('TOTO') , 'AAA')
      self.assertEqual(mcfact[0].get_mocle('ZORGLUB') , 'OOO')
      self.assertEqual(mcfact['TOTO'] , 'AAA')
      self.assertRaises(IndexError, mcfact.__getitem__, 'TITI')

   def test002(self):
      cata=FACT(ZORGLUB  =SIMP(statut='f',typ='TXM',defaut='OOO'),
                b_unit1  =BLOC(condition = "ZORGLUB=='ZZZ'",
                               TOTO  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),
                              ),
                    )
      mcfact=cata({},'mcf',None)
      valeur_attendue={'ZORGLUB':'OOO'}
      dico=mcfact[0].cree_dict_valeurs(mcfact[0].mc_liste)
      #dico=mcfact.cree_dict_valeurs(mcfact.mc_liste)
      self.assertEqual(dico , valeur_attendue)
      self.assertEqual(mcfact[0].get_mocle('ZORGLUB') , 'OOO')

   def test003(self):
      cata=FACT(ZORGLUB  =SIMP(statut='f',typ='TXM',defaut='OOO'),
                b_unit1  =BLOC(condition = "ZORGLUB=='ZZZ'",
                               TOTO  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),
                              ),
                    )
      mcfact=cata({'ZORGLUB':'ZZZ'},'mcf',None)
      valeur_attendue={'ZORGLUB':'ZZZ', 'TOTO':'AAA'}
      dico=mcfact[0].cree_dict_valeurs(mcfact[0].mc_liste)
      self.assertEqual(dico , valeur_attendue)
      self.assertEqual(mcfact[0].get_mocle('ZORGLUB') , 'ZZZ')
      self.assertEqual(mcfact['TOTO'] , 'AAA')

   def test004(self):
      cata=FACT(ZORGLUB  =SIMP(statut='f',typ='TXM',defaut='OOO'),
                b_unit1  =BLOC(condition = "ZORGLUB=='OOO'",
                               TOTO  =SIMP(statut='f',typ='TXM',into=('AAA','BBB'),),
                              ),
                    )
      mcfact=cata({},'mcf',None)
      valeur_attendue={'ZORGLUB':'OOO','TOTO':None}
      dico=mcfact[0].cree_dict_valeurs(mcfact[0].mc_liste)
      self.assertEqual(dico , valeur_attendue)
      self.assertEqual(mcfact[0].get_mocle('TOTO') , None)
      self.assertEqual(mcfact[0].get_child('ZORGLUB').get_valeur() , 'OOO')
      self.assertEqual(mcfact[0].get_child('b_unit1').get_child('TOTO').get_valeur() , None)
      self.assertEqual(mcfact['TOTO'] , None)

   def test005(self):
      cata=FACT(
                TOTO=FACT(statut='d',
                          TITI=SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),
                          b_unit1  =BLOC(condition = "TITI=='AAA'",
                                         TOTO  =SIMP(statut='f',typ='TXM',into=('AAA','BBB'),),
                                        ),
                         ),
               )
      mcfact=cata({},'mcf',None)
      dico=mcfact[0].cree_dict_valeurs(mcfact[0].mc_liste)
      self.assertNotEqual(dico["TOTO"] , None)

   def test010(self):
      """
      """
      cata=FACT(ZORGLUB  =SIMP(statut='f',typ='TXM',defaut='OOO'),
                     b_unit1  =BLOC(condition = "ZORGLUB=='OOO'",
                                         TOTO  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),  
                                         b_unit2       =BLOC(condition = "TOTO == 'BBB'",
                                                             UNITE   =SIMP(statut='f',typ='I',defaut=25),  
                                                            ),
                                   ),
                    )
      mcfact=cata({'TOTO' : 'BBB'},'mcf',None)
      valeur_attendue={'UNITE':25, 'ZORGLUB':'OOO','TOTO':'BBB'}
      dico=mcfact[0].cree_dict_valeurs(mcfact[0].mc_liste)
      self.assertEqual(dico , valeur_attendue)

   def test011(self):
      """
      """
      cata=FACT(
                TITI  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),
                TUTU  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),
                TATA  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),
                TOTO  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),
                b_unit1  =BLOC(condition = "TITI =='AAA'",
                               TOTO1  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),
                               c_unit1       =BLOC(condition = "TOTO1 == 'AAA'", UNITE1   =SIMP(statut='f',typ='I',defaut=25),),
                              ),
                b_unit2  =BLOC(condition = "TUTU =='AAA'",
                               TOTO2  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),
                               c_unit2       =BLOC(condition = "TOTO2 == 'BBB'", UNITE2   =SIMP(statut='f',typ='I',defaut=25),),
                              ),
                b_unit3  =BLOC(condition = "TATA =='BBB'",
                               TOTO3  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),
                               c_unit3       =BLOC(condition = "TOTO3 == 'BBB'", UNITE3   =SIMP(statut='f',typ='I',defaut=25),),
                              ),
                b_unit4  =BLOC(condition = "TOTO =='BBB'",
                               TOTO4  =SIMP(statut='f',typ='TXM',defaut='AAA',into=('AAA','BBB'),),
                               c_unit4       =BLOC(condition = "TOTO4 == 'AAA'", UNITE4   =SIMP(statut='f',typ='I',defaut=25),),
                              ),
               )
      mcfact=cata({'TOTO' : 'BBB'},'mcf',None)
      valeur_attendue={
          'TITI': 'AAA', 'TOTO': 'BBB', 'TUTU': 'AAA', 'TATA': 'AAA',
          'TOTO1': 'AAA', 'UNITE1': 25, 
          'TOTO2': 'AAA',
          'TOTO4': 'AAA', 'UNITE4': 25, 
                      }
      dico=mcfact[0].cree_dict_valeurs(mcfact[0].mc_liste)
      self.assertEqual(dico , valeur_attendue)

      self.assertEqual(mcfact[0].get_child('TATA').get_valeur() , 'AAA')
      self.assertEqual(mcfact[0].get_child('TITI').get_valeur() , 'AAA')
      self.assertEqual(mcfact[0].get_child('TUTU').get_valeur() , 'AAA')
      self.assertEqual(mcfact[0].get_child('TOTO').get_valeur() , 'BBB')
      self.assertEqual(mcfact['TITI'] , 'AAA')
      self.assertEqual(mcfact['TUTU'] , 'AAA')
      self.assertEqual(mcfact['TATA'] , 'AAA')
      self.assertEqual(mcfact['TOTO'] , 'BBB')

      self.assertEqual(mcfact['TOTO1'] , 'AAA')
      self.assertEqual(mcfact['TOTO2'] , 'AAA')
      self.assertEqual(mcfact['TOTO4'] , 'AAA')
      self.assertRaises(IndexError, mcfact[0].get_mocle, 'TOTO3')

      self.assertEqual(mcfact['UNITE1'] , 25)
      self.assertEqual(mcfact['UNITE4'] , 25)
      self.assertRaises(IndexError, mcfact.__getitem__, 'UNITE2')
      self.assertRaises(IndexError, mcfact.__getitem__, 'UNITE3')
      self.assertRaises(IndexError, mcfact[0].get_mocle, 'UNITE2')
      self.assertRaises(IndexError, mcfact[0].get_mocle, 'UNITE3')

      self.assertEqual(mcfact[0].get_child('b_unit4').get_child('TOTO4').get_valeur(),'AAA')
      self.assertEqual(mcfact[0].get_child('b_unit4').get_valeur(),{'TOTO4': 'AAA', 'UNITE4': 25})

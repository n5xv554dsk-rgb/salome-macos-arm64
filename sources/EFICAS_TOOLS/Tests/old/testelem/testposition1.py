# coding=utf-8
import os
import cata3
from Accas import AsException,ASSD,OPER,SIMP,FACT,BLOC,_F

import Noyau

class concept(ASSD,Noyau.AsBase):pass

import unittest

class TestCase(unittest.TestCase):
   def setUp(self):
      self.j=cata3.JdC(procedure="",nom="bidon")
      self.j.actif_status=1
      CONTEXT.set_current_step(self.j)

   def tearDown(self):
      CONTEXT.unset_current_step()
      self.j.supprime()

   def test001(self):
      """ Test position = global
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(typ='I'),
                   c=SIMP(statut='o',typ='TXM',position='global',
                          into=("TABLEAU","AGRAF"),
                         ),
                   b=FACT(statut='o',max='**',
                          b_forme=BLOC(condition="c == 'TABLEAU'",
                                       d=SIMP(statut='f',typ='TXM'),
                                      ),
                         ),
                 )
      co1=OP10(a=1,c="TABLEAU",b=_F(d='rr'))
      msg=co1.etape.report()
      self.assertEqual(co1.etape.isvalid(),1,msg=msg)

   def test002(self):
      """ Test position=global_jdc
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(typ='I'),
                   c=SIMP(statut='o',typ='TXM',position='global_jdc',
                          into=("TABLEAU","AGRAF"),
                         ),
                 )
      OP11 = OPER(nom='OP11',op=10,sd_prod=concept,
                  b=FACT(statut='o',max='**',
                         b_forme=BLOC(condition="c == 'TABLEAU'",
                                      d=SIMP(statut='f',typ='TXM'),
                                     ),
                        ),
                 )
      co1=OP10(a=1,c="TABLEAU",)
      co2=OP11(b=_F(d='rr'))
      msg=co1.etape.report()
      self.assertEqual(co1.etape.isvalid(),1,msg=msg)
      msg=co2.etape.report()
      self.assertEqual(co2.etape.isvalid(),1,msg=msg)

   def test003(self):
      """ Test position=global_jdc
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(typ='I'),
                   b=FACT( c=SIMP(statut='o',typ='TXM',position='global_jdc',
                                    into=("TABLEAU","AGRAF"),
                                 ),
                         ),
                 )
      OP11 = OPER(nom='OP11',op=10,sd_prod=concept,
                   b=FACT(statut='o',max='**',
                          b_forme=BLOC(condition="c == 'TABLEAU'",
                                       d=SIMP(statut='f',typ='TXM'),
                                       ),
                         ),
                 )
      OP12 = OPER(nom='OP12',op=10,sd_prod=concept,
                   b=FACT(statut='o',max='**',
                          b_forme=BLOC(condition="c == 'TABLEAU'",
                                       d=SIMP(statut='o',typ='TXM'),
                                       ),
                         ),
                 )
      co1=OP10(a=1,b=_F(c="TABLEAU"))
      co2=OP11(b=_F(d='rr'))
      co3=OP11()
      co4=OP12(b=_F(d='rr'))
      msg=co1.etape.report()
      self.assertEqual(co1.etape.isvalid(),1,msg=msg)
      msg=co2.etape.report()
      self.assertEqual(co2.etape.isvalid(),1,msg=msg)
      msg=co3.etape.report()
      self.assertEqual(co3.etape.isvalid(),1,msg=msg)
      msg=co4.etape.report()
      self.assertEqual(co4.etape.isvalid(),1,msg=msg)

   def futuretest004(self):
      """ Test position = global
      """
      msg0= """ 
          PROBLEME : les mots cles globaux ne sont pas forcément vus
          dans les mots cles facteurs (dépendant de l'ordre de création)
          Dans ce test xx est avant b qui est avant g : g voit c mais pas xx.
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(typ='I'),
                   b=FACT( c=SIMP(statut='o',typ='TXM',position='global',
                                    into=("TABLEAU","AGRAF"),
                                 ),
                         ),
                   g=FACT(statut='o',max='**',
                          b_forme=BLOC(condition="c == 'TABLEAU'",
                                       d=SIMP(statut='f',typ='TXM'),
                                       ),
                         ),
                   xx=FACT(statut='o',max='**',
                          b_forme=BLOC(condition="c == 'TABLEAU'",
                                       d=SIMP(statut='f',typ='TXM'),
                                       ),
                         ),
                 )
      co1=OP10(a=1,b=_F(c="TABLEAU"),g=_F(d='rr'))
      msg=msg0+str(co1.etape.report())
      self.assertEqual(co1.etape.isvalid(),1,msg=msg)
      co2=OP10(a=1,b=_F(c="TABLEAU"),xx=_F(d='rr'))
      msg=msg0+str(co2.etape.report())
      self.assertEqual(co2.etape.isvalid(),1,msg=msg)

   def test005(self):
      """ Test position = global
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(typ='I'),
                   g=FACT( c=SIMP(statut='o',typ='TXM',position='global',
                                    into=("TABLEAU","AGRAF"),
                                 ),
                         ),
                   b_forme=BLOC(condition="c == 'TABLEAU'",
                                d=SIMP(statut='f',typ='TXM'),
                               ),
                 )
      co1=OP10(a=1,g=_F(c="TABLEAU"),d='rr')
      msg=co1.etape.report()
      self.assertEqual(co1.etape.isvalid(),1,msg=msg)

   def test006(self):
      """ Test position = global
          ATTENTION : Un mot cle global, facultatif avec defaut (c) défini dans un mot clé facteur 
          n'est pas vu globalement
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(typ='I'),
                   g=FACT(a=SIMP(typ='I'),
                          c=SIMP(typ='TXM',position='global',into=("TABLEAU","AGRAF"),defaut="TABLEAU"),
                         ),
                   b_forme=BLOC(condition="c == 'TABLEAU'",
                                d=SIMP(statut='f',typ='TXM'),
                               ),
                 )
      co1=OP10(a=1,g=_F(a=1),d='rr')
      msg=co1.etape.report()
      self.assertEqual(co1.etape.isvalid(),0,msg=msg)

   def test007(self):
      """ Test position = global
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                  c=SIMP(typ='TXM',position='global',into=("TABLEAU","AGRAF"),defaut="TABLEAU"),
                  b=FACT(statut='o',max='**',
                         b_forme=BLOC(condition="c == 'TABLEAU'",
                                      d=SIMP(statut='f',typ='TXM'),
                                     ),
                        ),
                 )
      co1=OP10(b=_F(d='rr'))
      msg=co1.etape.report()
      self.assertEqual(co1.etape.isvalid(),1,msg=msg)

   def test008(self):
      """ Test position = global
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                  c=SIMP(typ='TXM',position='global',into=("TABLEAU","AGRAF"),defaut="TABLEAU"),
                  b_forme=BLOC(condition="c == 'TABLEAU'",
                               d=SIMP(statut='f',typ='TXM'),
                              ),
                 )
      co1=OP10(d='rr')
      msg=co1.etape.report()
      self.assertEqual(co1.etape.isvalid(),1,msg=msg)

   def test009(self):
      """ Test position = global
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                  c=SIMP(statut='o',typ='TXM',position='global',into=("TABLEAU","AGRAF"),defaut="TABLEAU"),
                  b_forme=BLOC(condition="c == 'TABLEAU'",
                               d=SIMP(statut='f',typ='TXM'),
                              ),
                 )
      co1=OP10(d='rr')
      msg=co1.etape.report()
      self.assertEqual(co1.etape.isvalid(),1,msg=msg)

   def test010(self):
      """ Test position = global
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   g=FACT(a=SIMP(typ='I'),
                          c=SIMP(statut='o',typ='TXM',position='global',into=("TABLEAU","AGRAF"),defaut="TABLEAU"),
                         ),
                   b_forme=BLOC(condition="c == 'TABLEAU'",
                                d=SIMP(statut='f',typ='TXM'),
                               ),
                 )
      co1=OP10(g=_F(a=1),d='rr')
      msg=co1.etape.report()
      self.assertEqual(co1.etape.isvalid(),1,msg=msg)

   def test011(self):
      """ Test position = global
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   g=FACT(statut='o',
                          c=SIMP(statut='o',typ='TXM',position='global',into=("TABLEAU","AGRAF"),defaut="TABLEAU"),
                         ),
                   b_forme=BLOC(condition="c == 'TABLEAU'",
                                d=SIMP(statut='f',typ='TXM'),
                               ),
                 )
      co1=OP10(d='rr')
      msg=co1.etape.report()
      self.assertEqual(co1.etape.isvalid(),1,msg=msg)

   def test012(self):
      """ Test position = global
          ATTENTION : Un mot cle global, facultatif avec defaut (c) défini dans un mot clé facteur 
          n'est pas vu globalement
      """
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   g=FACT(statut='o',
                          c=SIMP(typ='TXM',position='global',into=("TABLEAU","AGRAF"),defaut="TABLEAU"),
                         ),
                   b_forme=BLOC(condition="c == 'TABLEAU'",
                                d=SIMP(statut='f',typ='TXM'),
                               ),
                 )
      co1=OP10(d='rr')
      msg=co1.etape.report()
      self.assertEqual(co1.etape.isvalid(),0,msg=msg)
      co2=OP10(g=_F(c="TABLEAU"),d='rr')
      msg=co2.etape.report()
      self.assertEqual(co2.etape.isvalid(),1,msg=msg)

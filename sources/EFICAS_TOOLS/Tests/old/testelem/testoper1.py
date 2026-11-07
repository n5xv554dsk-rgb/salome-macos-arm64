# coding=utf-8
import cata1
from cata1 import OP1,OP2,OP3,OP4,OP5,OP6,OP7
from Accas import AsException,ASSD,OPER,SIMP,FACT,BLOC,_F

import Noyau

class concept(ASSD,Noyau.AsBase):pass

import unittest

class TestOperCase(unittest.TestCase):
   def setUp(self):
      pass

   def tearDown(self):
      pass

   def test01(self):
      co1=OP1(a=1)
      cr=co1.etape.report()
      self.assert_(cr.estvide())
      co1.etape.supprime()

   def test02(self):
      """ Test fonction sd_prod
      """
      co1=OP2(TYPE_RESU="TRANS")
      cr=co1.etape.report()
      self.assert_(cr.estvide())
      co1.etape.supprime()

   def test04(self):
      """ Test fonction sd_prod
          Test du type d'un argument avec AsType
      """
      co1=OP1(a=1)
      co2=OP3(MATR=co1)
      cr=co2.etape.report()
      self.assert_(cr.estvide())
      co1.etape.supprime()
      co2.etape.supprime()

   def test05(self):
      """ Test fonction sd_prod
          Test sur un mot-clé simple d'un mot-clé facteur : mcf[mcs]
      """
      co1=OP4(MESURE={'NOM_PARA':'INST'})
      cr=co1.etape.report()
      self.assert_(cr.estvide())
      co1.etape.supprime()

   def test06(self):
      """ Test fonction sd_prod
          Test sur un mot-clé simple d'un mot-clé facteur : mcf.get_child(mcs).get_valeur()
      """
      co2=OP1(a=1)
      co1=OP5(FFT={'FONCTION':co2})
      cr=co1.etape.report()
      self.assert_(cr.estvide())
      co1.etape.supprime()
      co2.etape.supprime()

   def test07(self):
      """ Test fonction sd_prod
          Test sur un mot-clé simple d'un mot-clé facteur : mcf[0][mcs]
      """
      co2=OP1(a=1)
      co1=OP6(FILTRE={'MODE':co2})
      cr=co1.etape.report()
      self.assert_(cr.estvide())
      co1.etape.supprime()
      co2.etape.supprime()

   def test08(self):
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
      cr=co1.etape.report()
      self.assertEqual(co1.etape['a'],1)
      self.assertEqual(co1.etape['c'],'TABLEAU')
      self.assertEqual(co1.etape['b']['d'],'rr')
      self.assert_(cr.estvide())
      co1.etape.supprime()

   def test09(self):
      co2=OP1(a=1)
      co1=OP5(FFT={'FONCTION':co2})
      l= co1.etape.get_sd_utilisees()
      self.assert_(len(l)==1)
      self.assert_(co2 in l )
      d=co1.etape.get_sd_mcs_utilisees()
      self.assert_(len(d.keys())==1)
      self.assert_(len(d['FONCTION'])==1)
      self.assert_(co2 in d['FONCTION'])
      co1.etape.supprime()
      co2.etape.supprime()

   def test10(self):
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(statut='o',typ='R',max=5),
                 )
      class mylist(list):pass
      valeur=(0,1)
      co1=OP10(a=mylist(valeur))
      #n,v=co1.etape.getvr8("","a",0,1,3)
      v=tuple(co1.etape["a"])
      msg="erreur sur le test " +'\n'+str(co1.etape.report())
      self.assertEqual(v,valeur,msg=msg)
      co1.etape.supprime()

   def futuretest11(self):
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(statut='o',typ='R',into=(0,1,2),max=5),
                 )
      class mylist(list):pass
      valeur=(2,0,1)
      co1=OP10(a=mylist(valeur))
      v=tuple(co1.etape["a"])
      #n,v=co1.etape.getvr8("","a",0,1,3)
      msg="erreur sur le test " +'\n'+str(co1.etape.report())
      self.assertEqual(v,valeur,msg=msg)
      co1.etape.supprime()

   def futuretest12(self):
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(statut='o',typ='R',into=(2,4,3,5),max=5),
                 )
      class mylist(list):pass
      valeur=(2,0,1)
      co1=OP10(a=mylist(valeur))
      msg="erreur sur le test " +'\n'+str(co1.etape.report())
      self.assertEqual(co1.etape.isvalid(),0,msg=msg)
      co1.etape.supprime()

   def futuretest13(self):
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(statut='o',typ='R',val_min=0,val_max=3,max=5),
                 )
      class mylist(list):pass
      valeur=(2,0,1)
      co1=OP10(a=mylist(valeur))
      msg="erreur sur le test " +'\n'+str(co1.etape.report())
      self.assertEqual(co1.etape.isvalid(),1,msg=msg)
      co1.etape.supprime()

   def futuretest14(self):
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(statut='o',typ='R',val_min=0,val_max=1,max=5),
                 )
      class mylist(list):pass
      valeur=(2,0,1)
      co1=OP10(a=mylist(valeur))
      msg="erreur sur le test " +'\n'+str(co1.etape.report())
      self.assertEqual(co1.etape.isvalid(),0,msg=msg)
      co1.etape.supprime()

   def test15(self):
      """ Test mot cle facteur incorrect
      """
      co1=OP7(FILTRE="coucou")
      cr=co1.etape.report()
      msg="erreur sur le test " +'\n'+str(cr)
      self.assertEqual(co1.etape.isvalid(),0,msg=msg)
      co1.etape.supprime()

   def test16(self):
      OP10 = OPER(nom='OP10',op=10,sd_prod=concept,
                   a=SIMP(statut='o',typ='R',val_min=0,val_max=1,max=5),
                 )
      valeur=(2,0,1)
      co1=OP10(a=valeur)
      msg="erreur sur le test " +'\n'+str(co1.etape.report())
      self.assertEqual(co1.etape.isvalid(),0,msg=msg)
      co1.etape.supprime()

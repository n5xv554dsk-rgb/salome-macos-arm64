# coding=utf-8
from Accas import SIMP,FACT,BLOC,UN_PARMI,OPER,ASSD,MACRO,_F
import Noyau

class concept(ASSD,Noyau.AsBase):pass

import unittest

class CATA:
   def __init__(self):
      CONTEXT.unset_current_cata()
      CONTEXT.set_current_cata(self)
   def enregistre(self,cmd):
      pass

cata=CATA()


OP1 = OPER(nom='OP1',op=1, sd_prod=concept, 
      WWWW=SIMP(statut='o',typ='TXM', position='global'),
      XXXX=SIMP(typ='TXM', position='global',defaut='XXXX'),
    traitement=FACT(statut='o',
      TATA=SIMP(typ='TXM', position='global',defaut='DDD'),
      TTTT=SIMP(statut='o',typ='TXM', position='global',defaut='EEE'),
      UUUU=SIMP(typ='TXM', position='global'),
      VVVV=SIMP(statut='o',typ='TXM', position='global'),
      regles=( UN_PARMI('TYPE_RAFFINEMENT_LIBRE','TYPE_RAFFINEMENT_UNIFORME'),),
      TYPE_RAFFINEMENT_LIBRE = FACT(statut='f',
                RAFFINEMENT   = SIMP(statut='o',typ='TXM', position='global',
                                     into=("LIBRE","UNIFORME",) ),
                DERAFFINEMENT = SIMP(statut='o',typ='TXM', position='global',
                                     into=("LIBRE",),),
                TOTO=SIMP(statut='o',typ='TXM', position='global'),
                # un mot cle global facultatif ne sera pas visible tant
                # qu'il n'aura pas de valeur meme s'il a un defaut
                TITI=SIMP(typ='TXM', position='global',defaut='BBB'),
                TUTU=SIMP(statut='o',typ='TXM', position='global',defaut='CCC'),
      ),
      b_maj_champ =BLOC(condition="(RAFFINEMENT!=None) or (DERAFFINEMENT!=None)",
                       NITER =SIMP(statut='o',typ='I',),
                       NOM_MED_MAILLAGE_NP1 =SIMP(statut='o',typ='TXM',),
                       FICHIER_MED_MAILLAGE_NP1 =SIMP(statut='o',typ='TXM',),
      ),
    ),
    trait=FACT(statut='o',
      FFFF=SIMP(typ='TXM',),
      b_champ =BLOC(condition="WWWW=='WWWW'",
                    N =SIMP(statut='o',typ='I',),
      ),
    ),
)

MACR_BIDON=OPER(nom="MACR_BIDON",op=None,sd_prod=concept,
                 reentrant='n',UIinfo={"groupes":("Outils métier",)},fr="",
                 NOM_CHAM=SIMP(statut='f',typ='TXM',into=('ACCE','DEPL'),position="global"),
                 RESULTAT=FACT(statut='o',b_acce=BLOC(condition="NOM_CHAM=='ACCE'",
                                                       VAL1=SIMP(statut='o',typ='R'),
                                                     ),
                                VAL2=SIMP(statut='o',typ='R'),
                              ),
                )
import pprint

class TestMCBlocCase(unittest.TestCase):

   def test001(self):
      """ bloc conditionnel declenche par mot cle global avec defaut
      """
      mcf={'TYPE_RAFFINEMENT_LIBRE':{'TOTO':'AAA'}}
      co=OP1(traitement=mcf,WWWW='WWWW')
      mcfact=co.etape['traitement']
      self.assertEqual(mcfact['TYPE_RAFFINEMENT_LIBRE']['DERAFFINEMENT'] , None)
      dico=mcfact[0].cree_dict_valeurs(mcfact[0].mc_liste)
      self.assertEqual(dico['DERAFFINEMENT'] , None)
      self.assertEqual(dico['RAFFINEMENT'] , None)
      self.assertEqual(dico['WWWW'] , 'WWWW')
      self.assertRaises(IndexError, mcfact.__getitem__, 'NITER')

      mcfact=co.etape['trait'][0]
      dico=mcfact.cree_dict_valeurs(mcfact.mc_liste)
      self.assertEqual(dico['DERAFFINEMENT'] , None)
      self.assertEqual(dico['RAFFINEMENT'] , None)
      self.assertEqual(dico['WWWW'] , 'WWWW')
      self.assertEqual(dico['TOTO'] , 'AAA')
      self.assertEqual(dico['TUTU'] , 'CCC')
      self.assertEqual(dico['FFFF'] , None)
      self.assertEqual(dico['VVVV'] , None)
      self.assertEqual(dico['TTTT'] , 'EEE')
      self.assertEqual(dico['XXXX'] , 'XXXX')
      self.assertEqual(mcfact['N'] , None)
      self.assertRaises(KeyError, dico.__getitem__, 'TITI')

   def test002(self):
      mcf={'TYPE_RAFFINEMENT_LIBRE':{'RAFFINEMENT':'LIBRE'},'NITER':1}
      co=OP1(traitement=mcf)
      mcfact=co.etape['traitement']
      self.assertEqual(mcfact['TYPE_RAFFINEMENT_LIBRE']['RAFFINEMENT'] , 'LIBRE')
      self.assertEqual(mcfact['NITER'] , 1)

   def test003(self):
      co=MACR_BIDON(NOM_CHAM='ACCE',RESULTAT=_F(VAL2=3.4))
      mcfact=co.etape['RESULTAT']
      self.assertEqual(co.etape.isvalid(), 0)

   def test004(self):
      mcf={'VVVV':'',
           'TYPE_RAFFINEMENT_LIBRE':{'RAFFINEMENT':'LIBRE','DERAFFINEMENT':'LIBRE','TOTO':'AA'},
           'NITER':1,
           'FICHIER_MED_MAILLAGE_NP1':'',
           'NOM_MED_MAILLAGE_NP1':'',
           }
      co=OP1(traitement=mcf,WWWW="WWWW",trait={'N':1})
      val=co.etape.isvalid()
      if not val:msg=co.etape.report()
      else:msg=""
      self.assertEqual(co.etape.isvalid() , 1,msg=msg)

      co=OP1(traitement=mcf,WWWW="WWWW")
      val=co.etape.isvalid()
      if not val:msg=co.etape.report()
      else:msg=""
      self.assertEqual(co.etape.isvalid() , 0,msg=msg)

      co=OP1(traitement=mcf,WWWW="WW",trait={'N':1})
      val=co.etape.isvalid()
      if not val:msg=co.etape.report()
      else:msg=""
      self.assertEqual(co.etape.isvalid() , 0,msg=msg)

      co=OP1(traitement=mcf,WWWW="WW",trait={'FFFF':'X'})
      val=co.etape.isvalid()
      if not val:msg=co.etape.report()
      else:msg=""
      self.assertEqual(co.etape.isvalid() , 1,msg=msg)

      co=OP1(traitement=mcf,WWWW="WW",)
      val=co.etape.isvalid()
      if not val:msg=co.etape.report()
      else:msg=""
      self.assertEqual(co.etape.isvalid() , 1,msg=msg)

   def test005(self):
      OP1 = OPER(nom='OP1',op=1, sd_prod=concept,
                 MASS = FACT(statut='f',max='**',
                               Y  = SIMP(statut='f',typ='I',),
                               Z  = FACT(T=SIMP(typ='I')),
                            ),
                 b_mass = BLOC(condition = "MASS != None",
                               MODE   = SIMP(statut='o',typ='I',)
                              ),
                 bb_mass = BLOC(condition = "MASS and len(MASS) > 1 ",
                               XX   = SIMP(statut='o',typ='I',)
                              ),
                 bbb_mass = BLOC(condition = "MASS and MASS[0]['Y'] == 1 ",
                               YY   = SIMP(statut='o',typ='I',)
                              ),
                 bbbb_mass = BLOC(condition = "MASS and MASS[0]['Z'] and MASS[0]['Z'][0]['T'] == 1 ",
                               ZZ   = SIMP(statut='o',typ='I',)
                              ),
                )
      co=OP1()
      msg=co.etape.report()
      self.assertEqual(co.etape.isvalid() , 1,msg=msg)
      co=OP1(MASS={},MODE=1)
      msg=co.etape.report()
      self.assertEqual(co.etape.isvalid() , 1,msg=msg)
      co=OP1(MASS=({},{}),MODE=1,XX=1)
      msg=co.etape.report()
      self.assertEqual(co.etape.isvalid() , 1,msg=msg)
      co=OP1(MASS=({'Y':1},{}),MODE=1,XX=1,YY=1)
      msg=co.etape.report()
      self.assertEqual(co.etape.isvalid() , 1,msg=msg)
      co=OP1(MASS=({'Y':1,'Z':{'T':1}},{}),MODE=1,XX=1,YY=1,ZZ=1)
      msg=co.etape.report()
      self.assertEqual(co.etape.isvalid() , 1,msg=msg)


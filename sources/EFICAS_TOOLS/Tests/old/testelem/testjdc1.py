# coding=utf-8

import os
import unittest
import difflib
import compare

import prefs
from InterfaceTK import appli
#from Editeur import appli

def add_param(j,pos,nom,valeur):
    co=j.addentite("PARAMETRE",pos)
    co.set_nom(nom)
    co.set_valeur(valeur)
    return co

def add_mcsimp(obj,nom,valeur):
    mcs=obj.get_child(nom,restreint='oui')
    if mcs is None:
       pos=obj.get_index_child(nom)
       mcs=obj.addentite(nom,pos)
    mcs.set_valeur(mcs.eval_val(valeur))
    return mcs

def cdiff(text1,text2):
    return " ".join(difflib.context_diff(text1.splitlines(1),text2.splitlines(1)))

version='v9'

class TestCase(unittest.TestCase):
   def setUp(self):
      pass

   def tearDown(self):
      CONTEXT.unset_current_step()

   def test000(self):
      app=appli.STANDALONE(version=version)
      j=app.newJDC()

# commande DEBUT
      co=j.addentite("DEBUT",0)
      co=add_param(j,1,"P1",None)
      x=co.valeur or "coucou"
      assert x == "coucou"
      assert len(co) == 0
      co.set_valeur(1)
      assert len(co) == 1
      co.set_valeur([1,2])
      assert len(co) == 2

   def test001(self):
      """ Test d'insertion de commandes dans fichier toto.comm"""
      app=appli.STANDALONE(version=version)
      file=os.path.join(prefs.INSTALLDIR,"Tests/testelem/toto.comm")
      j=app.openJDC(file=file)
      expected="""DEBUT CR validation : toto.comm
FIN CR validation :toto.comm
"""
      cr=str(j.report())
      assert cr == expected, cr + "!=" + expected
      co=j.etapes[1]
      mcs=co.addentite("INFO")
      
      cr=app.get_text_JDC(j,'python')
      expected="""
DEBUT();

MA=LIRE_MAILLAGE(INFO=1,);

FIN();
"""
      assert cr == expected, cr + "!=" + expected
      co=j.addentite("LIRE_MAILLAGE",2)
      test,mess=co.nomme_sd("MA2")
      assert test == 1

      cr=app.get_text_JDC(j,'python')
      expected="""
DEBUT();

MA=LIRE_MAILLAGE(INFO=1,);

MA2=LIRE_MAILLAGE();

FIN();
"""
      assert cr == expected, cr + "!=" + expected

   def test002(self):
      """ Test de construction du fichier de commandes az.comm de zero"""

      app=appli.STANDALONE(version=version)
      j=app.newJDC()
# commande DEBUT
      co=j.addentite("DEBUT",0)
# commande FIN
      co=j.addentite("FIN",1)
# parametres
      pos=0
      pos=pos+1
      co=add_param(j,pos,"P1","9.8")
      pos=pos+1
      co=add_param(j,pos,"P2","8.8")
      pos=pos+1
      co=add_param(j,pos,"P3","7")
      pos=pos+1
      co=add_param(j,pos,"P5","P3*P1")
      pos=pos+1
      co=add_param(j,pos,"P6","P1-3")
      pos=pos+1
      co=add_param(j,pos,"P4","[2,3,4]")
# commentaire
      pos=pos+1
      co=j.addentite("COMMENTAIRE",pos)
      co.set_valeur("Pas trouve   shellpanel")
# commande LIRE_MAILLAGE
      pos=pos+1
      co=j.addentite("LIRE_MAILLAGE",pos)
      test,mess=co.nomme_sd("MAILLA2")
      mcs=co.addentite("UNITE")
      valeur=mcs.eval_val("P4[1]")
      test=mcs.set_valeur(valeur)
# formule
      pos=pos+1
      co=j.addentite("FORMULE",pos)
      co.update_formule_python(("aaa","REEL","a+z","(a,z)"))
# commande LIRE_MAILLAGE
      pos=pos+1
      ma=co=j.addentite("LIRE_MAILLAGE",pos)
      test,mess=co.nomme_sd("MAIL")
      mcs=co.addentite("UNITE")
      valeur,validite=mcs.eval_valeur("P3")
      test=mcs.set_valeur(valeur)
#
      pos=pos+1
      co=j.addentite("COMMENTAIRE",pos)
      co.set_valeur(" 'LIRE_MAILLAGE', 'UNITE'            --> uniquebasepanel")
# formule
      pos=pos+1
      co=j.addentite("FORMULE",pos)
      co.update_formule_python(("az","REEL","aaaaa","(ae,inst)"))
# commande AFFE_MODELE
      pos=pos+1
      co=j.addentite("AFFE_MODELE",pos)
      mcs=co.get_child("MAILLAGE")
      valeur,validite=mcs.eval_valeur("MAIL")
      assert valeur == ma.sd
      test=mcs.set_valeur(valeur)
      assert valeur == co["MAILLAGE"]
      mcf=co.addentite("AFFE")
      mcs=mcf[0].get_child("PHENOMENE")
      valeur=mcs.eval_val_item('MECANIQUE')
      assert valeur=='MECANIQUE',str(valeur)
      test=mcs.set_valeur(valeur)
      assert mcf["PHENOMENE"] == 'MECANIQUE'
      mcs=mcf[0].get_child("b_mecanique").get_child("MODELISATION")
      mcs.set_valeur(mcs.eval_val_item('DIS_T'))
      assert mcf["MODELISATION"] == 'DIS_T'
      mcs=add_mcsimp(mcf[0],"GROUP_MA",('RESSORT','eee',))

      mcf=co.addentite("AFFE")
      mcs=mcf[1].get_child("PHENOMENE")
      mcs.set_valeur(mcs.eval_val_item('MECANIQUE'))
      mcs=mcf[1].get_child("b_mecanique").get_child("MODELISATION")
      mcs.set_valeur(mcs.eval_val_item('DIS_T'))
      mcs=add_mcsimp(mcf[1],"GROUP_MA",'MASSES')

      mcf=co.addentite("AFFE")
      mcs=mcf[2].get_child("PHENOMENE")
      mcs.set_valeur(mcs.eval_val_item('ACOUSTIQUE'))
      mcs=mcf[2].get_child("b_acoustique").get_child("MODELISATION")
      mcs.set_valeur(mcs.eval_val_item('PLAN'))
      #mcs=add_mcsimp(mcf[2],"GROUP_NO",'GNP3,GNP5,GNP6,GNP7,GNP8,GNP9,GNP10,GNP11,GNP12')
      mcs=add_mcsimp(mcf[2],"GROUP_NO","'GNP3','GNP5','GNP6','GNP7','GNP8','GNP9','GNP10','GNP11','GNP12'")

      co.nomme_sd("AFFE1")
# commande AFFE_MODELE
      pos=pos+1
      co=j.addentite("AFFE_MODELE",pos)
      mcs=co.get_child("MAILLAGE")
      mcs.set_valeur(mcs.eval_val("MAIL"))

      mcf=co.addentite("AFFE")
      mcs=mcf[0].get_child("PHENOMENE")
      valeur=mcs.eval_val_item('MECANIQUE')
      test=mcs.set_valeur(valeur)
      mcs=mcf[0].get_child("b_mecanique").get_child("MODELISATION")
      mcs.set_valeur(mcs.eval_val_item('DIS_T'))
      mcs=add_mcsimp(mcf[0],"GROUP_MA",'RESSORT')

      mcf=co.addentite("AFFE")
      mcs=mcf[1].get_child("PHENOMENE")
      mcs.set_valeur(mcs.eval_val_item('MECANIQUE'))
      mcs=mcf[1].get_child("b_mecanique").get_child("MODELISATION")
      mcs.set_valeur(mcs.eval_val_item('DIS_T'))
      mcs=add_mcsimp(mcf[1],"GROUP_MA",'MASSES')

      mcf=co.addentite("AFFE")
      mcs=mcf[2].get_child("PHENOMENE")
      mcs.set_valeur(mcs.eval_val_item('THERMIQUE'))
      mcs=mcf[2].get_child("b_thermique").get_child("MODELISATION")
      mcs.set_valeur(mcs.eval_val_item('COQUE'))
      mcs=add_mcsimp(mcf[2],"TOUT",'OUI')

      co.nomme_sd("MOD")
#CARA=AFFE_CARA_ELEM(MODELE=MOD,
#                    POUTRE=_F(GROUP_MA='MA',
#                              SECTION='CERCLE',
#                              CARA='R',
#                              VALE=(3.0,P6,),),);
      pos=pos+1
      co=j.addentite("AFFE_CARA_ELEM",pos)
      mcs=co.get_child("MODELE")
      mcs.set_valeur(mcs.eval_val("MOD"))
      mcf=co.addentite("POUTRE")
      mcs=mcf[0].get_child("SECTION")
      mcs.set_valeur(mcs.eval_val('CERCLE'))
      assert mcf[0]["SECTION"] == 'CERCLE'
      mcs=add_mcsimp(mcf[0],"GROUP_MA",'MA')
      mcs=mcf[0].get_child("b_cercle").get_child("b_constant").get_child("CARA")
      mcs.set_valeur(mcs.eval_val('R'))
      mcs=mcf[0].get_child("b_cercle").get_child("b_constant").get_child("VALE")
      mcs.set_valeur(mcs.eval_val('3.0,P6'))
      co.nomme_sd("CARA")
# commentaire
      pos=pos+1
      co=j.addentite("COMMENTAIRE",pos)
      text=""" 'AFFE_MODELE', 'MAILLAGE'           --> uniqueassdpanel
  AFFE_MODELE', 'AFFE', 'GROUP_MA'   --> plusieursbasepanel 
 'AFFE_MODELE', 'AFFE', 'PHENOMENE'  --> uniqueintopanel
 'AFFE_MODELE', 'AFFE', 'b_mecanique'--> plusieursintopanel"""
      co.set_valeur(text)
#F1=DEFI_FONCTION(NOM_PARA='DX',
#                 VALE=(5.0,3.0,P4[1],P3,),);
      pos=pos+1
      co=j.addentite("DEFI_FONCTION",pos)
      mcs=co.get_child("NOM_PARA")
      mcs.set_valeur(mcs.eval_val("DX"))
      mcs=co.addentite("VALE")
      mcs.set_valeur(mcs.eval_val("5.0,3.0,P4[1],P3"))
      co.nomme_sd("F1")
#F3=DEFI_FONCTION(NOM_PARA='DRX',
#                 VALE_C=(5.0,7.0,9.0,9.0,8.0,7.0,),);
      pos=pos+1
      co=j.addentite("DEFI_FONCTION",pos)
      mcs=co.get_child("NOM_PARA")
      mcs.set_valeur(mcs.eval_val("DRX"))
      mcs=co.addentite("VALE_C")
      mcs.set_valeur(mcs.eval_val("5.0,7.0,9.0,9.0,8.0,7.0"))
      co.nomme_sd("F3")
# commentaire
      pos=pos+1
      co=j.addentite("COMMENTAIRE",pos)
      co.set_valeur(" 'DEFI_FONCTION', 'VALE'             --> fonctionpanel  ")
#MATER2=DEFI_MATERIAU(ELAS=_F(E=100000000000.0,
#                             NU=0.0,),
#                     ECRO_ASYM_LINE=_F(DC_SIGM_EPSI=0.0,
#                                       SY_C=200000000.0,
#                                       DT_SIGM_EPSI=0.0,
#                                       SY_T=50000000.0,),);
      pos=pos+1
      co=j.addentite("DEFI_MATERIAU",pos)
      mcf=co.addentite("ELAS")
      mcs=mcf[0].get_child("E")
      mcs.set_valeur(mcs.eval_val("100000000000.0"))
      mcs=mcf[0].get_child("NU")
      mcs.set_valeur(mcs.eval_val("0.0"))
      mcf=co.addentite("ECRO_ASYM_LINE")
      mcs=mcf[0].get_child("DC_SIGM_EPSI")
      mcs.set_valeur(mcs.eval_val("0.0"))
      mcs=mcf[0].get_child("DT_SIGM_EPSI")
      mcs.set_valeur(mcs.eval_val("0.0"))
      mcs=mcf[0].get_child("SY_C")
      mcs.set_valeur(mcs.eval_val("200000000.0"))
      mcs=mcf[0].get_child("SY_T")
      mcs.set_valeur(mcs.eval_val("50000000.0"))
      co.nomme_sd("MATER2")
#PS1=DEFI_PARA_SENSI(VALE=1.0,);
#PS2=DEFI_PARA_SENSI(VALE=1.0,);
#PS3=DEFI_PARA_SENSI(VALE=1.0,);
      pos=pos+1
      co=j.addentite("DEFI_PARA_SENSI",pos)
      mcs=co.get_child("VALE")
      mcs.set_valeur(mcs.eval_val("1.0"))
      co.nomme_sd("PS1")
      pos=pos+1
      co=j.addentite("DEFI_PARA_SENSI",pos)
      mcs=co.get_child("VALE")
      mcs.set_valeur(mcs.eval_val("1.0"))
      co.nomme_sd("PS2")
      pos=pos+1
      co=j.addentite("DEFI_PARA_SENSI",pos)
      mcs=co.get_child("VALE")
      mcs.set_valeur(mcs.eval_val("1.0"))
      co.nomme_sd("PS3")
#CHMAT2=AFFE_MATERIAU(MAILLAGE=MAIL,
#                     AFFE=_F(TOUT='OUI',
#                             MATER=MATER2,),);
      pos=pos+1
      co=j.addentite("AFFE_MATERIAU",pos)
      add_mcsimp(co,"MAILLAGE","MAIL")
      mcf=co.get_child("AFFE")
      add_mcsimp(mcf[0],"TOUT","OUI")
      add_mcsimp(mcf[0],"MATER","MATER2")
      co.nomme_sd("CHMAT2")
#AAAZ=AFFE_CHAR_THER(MODELE=AFFE1,
#                    TEMP_IMPO=_F(TOUT='OUI',
#                                 TEMP=0.0,),);
      pos=pos+1
      co=j.addentite("AFFE_CHAR_THER",pos)
      add_mcsimp(co,"MODELE","AFFE1")
      mcf=co.addentite("TEMP_IMPO")
      add_mcsimp(mcf[0],"TOUT","OUI")
      add_mcsimp(mcf[0],"TEMP","0.0")
      co.nomme_sd("AAAZ")
#TH1=THER_LINEAIRE(MODELE=AFFE1,
#                  CHAM_MATER=CHMAT2,
#                  EXCIT=_F(CHARGE=AAAZ,),
#                  SENSIBILITE=(PS1,PS2,),);
      pos=pos+1
      co=j.addentite("THER_LINEAIRE",pos)
      add_mcsimp(co,"MODELE","AFFE1")
      add_mcsimp(co,"CHAM_MATER","CHMAT2")
      mcf=co.get_child("EXCIT")
      add_mcsimp(mcf[0],"CHARGE","AAAZ")
      add_mcsimp(co,"SENSIBILITE","PS1,PS2")
      co.nomme_sd("TH1")
# commentaire
      pos=pos+1
      co=j.addentite("COMMENTAIRE",pos)
      co.set_valeur(" 'THER_LINEAIRE', 'SENSIBILITE'       --> plusieursassdpanel")
#ACA1=AFFE_CHAR_ACOU(MODELE=AFFE1,
#                    PRES_IMPO=_F(TOUT='OUI',
#                                 PRES=('RI',3.0,3.0,),),);
      pos=pos+1
      co=j.addentite("AFFE_CHAR_ACOU",pos)
      add_mcsimp(co,"MODELE","AFFE1")
      mcf=co.addentite("PRES_IMPO")
      add_mcsimp(mcf[0],"TOUT","OUI")
      add_mcsimp(mcf[0],"PRES","'RI',3.0,3.0")
      co.nomme_sd("ACA1")
# commentaire
      pos=pos+1
      co=j.addentite("COMMENTAIRE",pos)
      co.set_valeur(" 'AFFE_CHAR_ACOU', 'PRES_IMPO', 'PRES' --> uniquecomppanel")

# 'AFFE_CHAR_ACOU', 'PRES_IMPO', 'PRES' --> uniquecomppanel

#MACRO_MATR_ASSE(MODELE=AFFE1,
#                NUME_DDL=CO('DDL1'),
#                MATR_ASSE=_F(MATRICE=CO('MAT1'),
#                             OPTION='RIGI_THER',),);
      pos=pos+1
      co=j.addentite("MACRO_MATR_ASSE",pos)
      add_mcsimp(co,"MODELE","AFFE1")
      mcs=co.get_child("NUME_DDL")
      mcs.set_valeur_co('DDL1')
      mcf=co.get_child("MATR_ASSE")
      add_mcsimp(mcf[0],"OPTION","RIGI_THER")
      mcs=mcf[0].get_child("MATRICE")
      mcs.set_valeur_co('MAT1')
# commentaire
      pos=pos+1
      co=j.addentite("COMMENTAIRE",pos)
      co.set_valeur(" 'MACRO_MATR_ASSE', 'MATR_ASSE', 'MATRICE'  --> uniquesdcopanel")

      assert j.isvalid(),j.report()

      text1=app.get_text_JDC(j,'python')
      file=os.path.join(prefs.INSTALLDIR,"Tests/testelem/az.comm")
      f=open(file)
      text2=f.read()
      f.close()
      assert text1 == text2 , cdiff(text1,text2)

   def test003(self):
      """ Test de construction du fichier de commandes az.comm de zero"""

      app=appli.STANDALONE(version=version)
      j=app.newJDC()
# commande DEBUT
      co=j.addentite("DEBUT",0)
# commande FIN
      co=j.addentite("FIN",1)
#parametre
      pos=0
      pos=pos+1
      co=add_param(j,pos,"P1","9.8")
      pos=pos+1
      co=add_param(j,pos,"P2","sin(P1)")
# formule
      pos=pos+1
      co=j.addentite("FORMULE",pos)
      co.update_formule_python(("aaa","REEL","a+z","(a,z)"))
#parametre de formule
      pos=pos+1
      co=add_param(j,pos,"P3","aaa(P1,2.)")
#commande defi_list_reel
      pos=pos+1
      co=j.addentite("DEFI_LIST_REEL",pos)
      add_mcsimp(co,"VALE","1.,2.,3.")
      co.nomme_sd("LI1")
#commande defi_list_reel
      pos=pos+1
      co=j.addentite("DEFI_LIST_REEL",pos)
      add_mcsimp(co,"VALE","sin(1.)")
      co.nomme_sd("LI2")
#commande defi_list_reel
      pos=pos+1
      co=j.addentite("DEFI_LIST_REEL",pos)
      add_mcsimp(co,"VALE","aaa(1.,2.)")
      co.nomme_sd("LI3")
#commande defi_list_reel
      pos=pos+1
      co=j.addentite("DEFI_LIST_REEL",pos)
      add_mcsimp(co,"VALE","sin(1.,2)")
      co.nomme_sd("LI4")
#commande defi_list_reel
      pos=pos+1
      co=j.addentite("DEFI_LIST_REEL",pos)
      add_mcsimp(co,"VALE","aaa(1.)")
      co.nomme_sd("LI5")
#commande defi_list_reel
      pos=pos+1
      co=j.addentite("DEFI_LIST_REEL",pos)
      add_mcsimp(co,"VALE","1,sin(1.),2")
      co.nomme_sd("LI6")

      expected="""DEBUT CR validation : SansNom
   Etape : DEFI_LIST_REEL    ligne : ...
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! Concept retourné non défini !
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      Mot-clé simple : VALE
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         ! 'sin(1.,2)' (de type <type 'str'>) n'est pas d'un type autorisé: ('R',) !
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      Fin Mot-clé simple : VALE
   Fin Etape : DEFI_LIST_REEL
   Etape : DEFI_LIST_REEL    ligne : ...
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! Concept retourné non défini !
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      Mot-clé simple : VALE
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
         ! 'aaa(1.)' (de type <type 'str'>) n'est pas d'un type autorisé: ('R',) !
         !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      Fin Mot-clé simple : VALE
   Fin Etape : DEFI_LIST_REEL
FIN CR validation :SansNom
"""
      msg=str( j.report())
      assert compare.check(expected,msg),cdiff(expected,msg)

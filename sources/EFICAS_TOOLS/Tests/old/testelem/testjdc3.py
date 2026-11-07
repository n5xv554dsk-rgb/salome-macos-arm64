# coding=utf-8
import os
import unittest
import difflib
import compare

import prefs
from InterfaceTK import appli
#from Editeur import appli
from Accas import AsException

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

   def test001(self):
      """ Test de commentarisation/decommentarisation de commandes dans fichier az.comm"""
      app=appli.STANDALONE(version=version)
      file=os.path.join(prefs.INSTALLDIR,"Tests/testelem/az.comm")
      j=app.openJDC(file=file)
      assert j.isvalid(),j.report()
      # on commente la commande LIRE_MAILLAGE
      for co in j.etapes:
        if co.nom == "LIRE_MAILLAGE" and co.sd.nom == "MAIL":break
      cco=co.get_objet_commentarise(format=app.format_fichier.get())
      # on decommente la commande LIRE_MAILLAGE
      commande,nom = cco.uncomment()
      # on reaffecte l'objet MAIL
      for co in j.etapes:
        if co.nom in ("AFFE_MODELE","AFFE_MATERIAU") :
           add_mcsimp(co,"MAILLAGE",'MAIL')

      text1=app.get_text_JDC(j,'python')
      f=open(file)
      text2=f.read()
      f.close()
      assert text1 == text2 , cdiff(text1,text2)

   def test002(self):
      """ Test de commentarisation/decommentarisation de macro commande dans fichier az.comm"""
      app=appli.STANDALONE(version=version)
      file=os.path.join(prefs.INSTALLDIR,"Tests/testelem/az.comm")
      j=app.openJDC(file=file)
      assert j.isvalid(),j.report()
      # on commente la commande MACRO_MATR_ASSE
      for co in j.etapes:
        if co.nom == "MACRO_MATR_ASSE" :break
      cco=co.get_objet_commentarise(format=app.format_fichier.get())
      # on decommente la commande MACRO_MATR_ASSE
      commande,nom = cco.uncomment()
      assert j.isvalid(),j.report()

   def test003(self):
      """ Test de commentarisation/decommentarisation de commandes dans fichier az.comm"""
      app=appli.STANDALONE(version=version)
      text="""
DEBUT()
MA=LIRE_MAILLAGE()
FIN()
"""
      j=app.openTXT(text)
      assert j.isvalid(),j.report()
      # on commente la commande LIRE_MAILLAGE
      co=j.etapes[1]
      cco=co.get_objet_commentarise(format=app.format_fichier.get())
      co=j.addentite("LIRE_MAILLAGE",2)
      test,mess=co.nomme_sd("MA")
      # on decommente la commande LIRE_MAILLAGE
      commande,nom = cco.uncomment()
      expected="""DEBUT CR validation : TEXT
   Etape : LIRE_MAILLAGE    ligne : ...
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      ! Concept retourné non défini !
      !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   Fin Etape : LIRE_MAILLAGE
FIN CR validation :TEXT
"""
      msg=str( j.report())
      assert compare.check(expected,msg),cdiff(expected,msg)

   def test004(self):
      """ Test de commentarisation/decommentarisation de commandes dans fichier az.comm"""
      app=appli.STANDALONE(version=version)
      text="""
DEBUT()
MA=LIRE_MAILLAGE()
AFFE_MODELE(MAILLAGE=MA)
FIN()
"""
      j=app.openTXT(text)
      # on commente la commande LIRE_MAILLAGE
      co=j.etapes[1]
      cco=co.get_objet_commentarise(format=app.format_fichier.get())
      # on commente la commande AFFE_MODELE
      co=j.etapes[2]
      cco2=co.get_objet_commentarise(format=app.format_fichier.get())
      # on decommente la commande AFFE_MODELE
      commande,nom = cco2.uncomment()
      assert commande["MAILLAGE"] == None

   def test005(self):
      """ Test de commentarisation/decommentarisation de commandes dans fichier az.comm"""
      app=appli.STANDALONE(version=version)
      text="""
DEBUT()
MA=LIRE_MAILLAGE()
AFFE_MODELE(MAILLAGE=MA)
FIN()
"""
      j=app.openTXT(text)
      # on commente la commande AFFE_MODELE
      co=j.etapes[2]
      cco2=co.get_objet_commentarise(format=app.format_fichier.get())
      # on commente la commande LIRE_MAILLAGE
      co=j.etapes[1]
      cco=co.get_objet_commentarise(format=app.format_fichier.get())
      # on decommente la commande AFFE_MODELE
      self.assertRaises(AsException, cco2.uncomment, )


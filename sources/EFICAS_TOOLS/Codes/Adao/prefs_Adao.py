# -*- coding: utf-8 -*-
import os,sys

try :
  repIni=os.path.dirname(os.path.abspath(__file__))
  INSTALLDIR=os.path.join(repIni,'../..')
  sys.path[:0]=[INSTALLDIR]
except :
  repIni=".."
  pass


# Choix des catalogues
# format du Tuple (code,version,catalogue,formatOut, finit par defaut eventuellement)
catalogues = ( ('Adao','V95',os.path.join(repIni,'ADAO_Cata_V0_pour_V9_5_0.py'),'python','python'),)

# lang indique la langue utilisee pour les chaines d'aide : fr ou ang
#lang='ang'
lang='fr'

closeAutreCommande = True
closeFrameRechercheCommande = True
closeArbre = True
translatorFile = os.path.join(repIni,'Adao')
nombreDeBoutonParLigne=1
#dumpXSD=True
#afficheIhm=False

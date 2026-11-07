# -*- coding: utf-8 -*-
# Copyright (C) 2007-2026   EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
"""
    Ce module sert pour charger les parametres de configuration d'EFICAS
"""
import os, sys
from Accas.extensions.eficas_translation import tr


class BaseConfiguration(object):
    """
    Classe de base permettant de  lire les fichiers de preference 
        1) de l installation eficas  : prefs.py (ou prefs_salome.py) dans
           la directory du catalogue
        2) contenu dans la variable d environnement : ${PREFS_CATA_$CODE}
           Cela permet d avoir une installation partagée d Eficas avec une possibilité de 
           moduler les préférences selon les machines
        3) le(s) fichier(s) de preference utilisateurs : 
           prefs_code.ini ou pref_salome_code.ini 
           contenu dans la directory $HOME/.config/Eficas/code
                        
    Seuls les labels contenus dans labelsStandards sont pris en compte dans le fichier prefs.ini ou dans ${PREFS_CATA_$CODE}/prefs.py
    Seuls les labels contenus dans labelsUser sont pris en compte dans le fichier prefs.ini de l utilisateur
    Ainsi si le fichier prefs.py contient UneVariableQuelconque = 3, UneVariableQuelconque ne sera pas integree a l objet configuration
    """
    # ------------------------------
    def __init__(self, appliEficas):
    # ------------------------------

        self.appliEficas = appliEficas
        self.code = appliEficas.code
        self.salome = appliEficas.salome
        self.info = True

        if self.salome: name = "prefs_eficas_salome.ini"
        else: name = "prefs_eficas.ini"
        if self.code != None : 
            if sys.platform == 'linux' : self.repUser = os.path.join( os.path.expanduser("~"), '.config/Eficas',self.code)
            else : self.repUser = os.path.join('C:/','.config/Eficas',self.code)
        else :
            if sys.platform == 'linux' : self.repUser = os.path.join( os.path.expanduser("~"), '.config/Eficas')
            else : self.repUser = os.path.join('C:/','.config/Eficas')
        if self.appliEficas.prefsFile : self.fichierPrefsUtilisateur = self.appliEficas.prefsFile 
        else : self.fichierPrefsUtilisateur = os.path.join(self.repUser, name)

        self.labelsStandards = ('PdfReader', 'saveDir', 'modeNouvCommande', 'afficheUQ', 'closeAutreCommande', 'closeFrameRechercheCommande', 
           'closeFrameRechercheCommandeSurPageDesCommandes', 'closeEntete', 'closeArbre', 'demandeLangue', 'suiteTelemac', 
           'nombreDeBoutonParLigne', 'translatorFile', 'dicoImages', 'dicoIcones', 'afficheCommandesPliees', 'afficheFirstPlies', 
           'simpleClic', 'afficheOptionnelVide', 'afficheListesPliees', 'boutonDsMenuBar', 'ficIcones', 
           'repIcones', 'differencieSiDefaut', 'typeDeCata', 'closeParenthese', 'closeOptionnel', 
           'afficheFactOptionnel', 'enleverActionStructures', 'enleverPoubellePourCommande', 'enleverParametres',
           'enleverSupprimer', 'ajoutExecution', 'utilParextensions', 'rendVisiblesLesCaches',
           'readerModule', 'writerModule', 'lang',
           'pasDeMCOptionnels', 'dumpXSD', 'withXSD', 'afficheIhm', 'catalogues', 'taille' )

        self.labelsUser = ('PdfReader', 'saveDir', ' closeArbre', 'demandeLangue','taille' ,
           'nombreDeBoutonParLigne', 'translatorFile', 'afficheCommandesPliees', 'afficheFirstPlies',
           'simpleClic', 'afficheOptionnelVide', 'afficheListesPliees', 'differencieSiDefaut', 'lang') 

        self.setValeursParDefaut()

        if self.code != "" and self.code != None:
            self.lectureFichierIniStandard()
            self.lectureFichierIniIntegrateur()
            self.lectureFichierIniUtilisateur()

        # coherence des parametres -)
        if self.boutonDsMenuBar:
            self.closeAutreCommande = True
            self.closeFrameRechercheCommande = True

        if not os.path.isdir(self.saveDir):
            if sys.platform == 'linux' :
               self.saveDir = os.path.join( os.path.expanduser("~"), 'Eficas', self.code)
            else :
               self.saveDir = os.path.join('C:/','Eficas',self.code)

        # on ecrase la langue si elle a ete definie dans Salome
        if self.appliEficas.langue != None :
           self.lang=self.appliEficas.langue

    # ----------------------------
    def setValeursParDefaut(self):
    # ----------------------------

        # Valeurs par defaut
        self.pathDoc = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..","Doc"))
        self.PdfReader = "evince"
         
        if self.code :
           nomDir = "Eficas_" + self.code
           self.saveDir = os.path.abspath(os.path.join(os.path.expanduser("~"), nomDir))
        else :
           self.saveDir = os.path.abspath(os.path.expanduser("~"))
        self.modeNouvCommande = "initial"
        self.affiche = "alpha"
        self.closeAutreCommande = False
        self.closeFrameRechercheCommande = False
        self.closeFrameRechercheCommandeSurPageDesCommandes = False
        self.closeEntete = False
        self.closeArbre = False
        self.demandeLangue = False
        self.suiteTelemac = False
        self.nombreDeBoutonParLigne = 0
        self.translatorFile = None
        self.dicoImages = {}
        self.dicoIcones = {}
        self.afficheCommandesPliees = False
        self.afficheFirstPlies = False
        self.simpleClic = False
        self.afficheOptionnelVide = False
        self.afficheListesPliees = True
        self.boutonDsMenuBar = False
        self.ficIcones = None
        self.repIcones = None
        self.differencieSiDefaut = False
        self.typeDeCata = "Python"
        self.closeParenthese = False
        self.closeOptionnel = False
        self.afficheFactOptionnel = False
        self.enleverActionStructures = False
        self.enleverPoubellePourCommande = False
        self.enleverParametres = False
        self.enleverSupprimer = False
        self.ajoutExecution = False
        self.utilParextensions = []
        self.rendVisiblesLesCaches = False
        self.pasDeMCOptionnels = False
        self.taille=1700

        self.dumpXSD = False
        self.withXSD = False
        self.afficheIhm = True
        self.afficheUQ = False

        self.readerModule = None
        self.writerModule = None

        # pour garder ce qui existait pour Aster
        self.repMat = None
        self.lang='fr'

    # ---------------------------------
    def lectureFichierIniStandard(self):
    # ----------------------------------

        if self.salome : name = "prefs_salome_" + self.appliEficas.code
        else : name = "prefs_" + self.appliEficas.code
        if self.appliEficas.cataFile != None :
            dirCata=os.path.dirname(self.appliEficas.cataFile)
            sys.path.append(os.path.abspath(dirCata))
            self.appliEficas.listePathAEnlever.append(dirCata)
        try:
            prefsCode = __import__(name)
        except:
            self.catalogues = []
            if self.info : print("pas de fichier de prefs {} dans eficas".format(name))
            return
        for k in dir(prefsCode):
            if k in self.labelsStandards:
                valeur=getattr(prefsCode,k)
                setattr(self,k,valeur)
        if self.info : print("prise en compte du  fichier de prefs {} dans eficas".format(name))

    # --------------------------------------
    def lectureFichierIniIntegrateur(self):
    # --------------------------------------
        # Verifie l'existence du fichier "standard"
        # appelle la lecture de ce fichier
        clef = "PREFS_CATA_" + self.code
        # utilise par ADA0 dans Salome
        if hasattr(self.appliEficas, clef) : 
           fichierPrefsIntegrateur = getattr(self.appliEficas,clef)
           try : 
               m = __import__(fichierPrefsIntegrateur)
               d = m.__dict__
           except :
               titre = tr("Import du fichier de Configuration")
               texte = "Erreur a la lecture du fichier de configuration {} ".format(str(fichierPrefsIntegrateur))
               self.appliEficas.afficheMessage(titre, texte)
               return
        elif clef in os.environ.keys() : 
            fic = os.environ[clef]
            fichierPrefsIntegrateur = os.path.abspath(fic)
            if not os.path.isfile(fichierPrefsIntegrateur): 
                if self.info : print("impossible de trouver le fichier {}".format(fichierPrefsIntegrateur))
                return
            try : 
                with open(fichierPrefsIntegrateur) as fd: txt = fd.read()
            except:
                titre = tr("Import du fichier de Configuration")
                texte = "Erreur a la lecture du fichier de configuration {} ".format(str(fichierPrefsIntegrateur))
                self.appliEficas.afficheMessage(titre, texte)
                return
            d = {}
            try:
                exec(txt, d)
            except:
                titre = tr("Import du fichier de Configuration")
                texte = "Erreur a l execution du fichier de configuration {} ".format(str(fichierPrefsIntegrateur))
                self.appliEficas.afficheMessage(titre, texte)
                return
        else : 
            if self.info : print("pas de fichier defini pour les preferences integrateur")
            return

        for k in d:
            if k in self.labelsStandards:
                try:
                    setattr(self, k, d[k])
                except:
                    pass
        if self.info : print("le fichier {} de preferences integateur a ete pris en compte".format(fichierPrefsIntegrateur))

    # --------------------------------------
    def lectureFichierIniUtilisateur(self):
    # --------------------------------------
        # Surcharge les parametres standards par les parametres utilisateur s'ils existent
        if not os.path.isfile(self.fichierPrefsUtilisateur): 
            if self.info : print("Pas de fichier {} de preference utilisateur".format(self.fichierPrefsUtilisateur))
            return
        try :
            with open(self.fichierPrefsUtilisateur) as fd: txt = fd.read()
        except:
            titre = tr("Import du fichier de Configuration"),
            texte = "Erreur a la lecture du fichier de configuration {} ".format(str(fself.ichierPrefsUtilisateur))
            self.appliEficas.afficheMessage(titre, texte)
            return
        d = {}
        try:
        #if 1 :
            print (txt)
            exec(txt, d)
        except:
            titre = tr("Import du fichier de Configuration"),
            texte = "Erreur a l execution du fichier de configuration {} ".format(str(self.fichierPrefsUtilisateur))
            self.appliEficas.afficheMessage(titre, texte)
            return
        for k in d:
            if k in self.labelsUser:
                try:
                    setattr(self, k, d[k])
                except:
                    pass
            if k == 'catalogues' :
               self.catalogues = d[k]
        if self.info : print("le fichier {} de preferences utilisateurs a ete pris en compte".format(self.fichierPrefsUtilisateur))

    # --------------------------------------
    def saveParams(self):
    # --------------------------------------
        # sauvegarde
        # les nouveaux parametres dans le fichier de configuration utilisateur
        #
        texte = ""
        for clef in self.labelsUser:
            if hasattr(self, clef):
                valeur = getattr(self, clef)
                texte = texte + clef + "      = " + repr(valeur) + "\n"
        f = open(self.fichierPrefsUtilisateur, "w+")
        f.write(texte)
        f.close()



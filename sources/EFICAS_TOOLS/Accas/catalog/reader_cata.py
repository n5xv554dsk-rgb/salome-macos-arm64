# -*-  coding: utf-8 -*-
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
    Ce module sert a lire un catalogue et a construire
    un objet CataItem pour Eficas.
    Il s'appuie sur la classe READERCATA
"""
# Modules Python
import os, sys

# Modules Eficas
from Accas.processing.P_CR import CR
from Accas.catalog.catadesc import CatalogDescription
from Accas.catalog import analyse_ordre_catalogue
from Accas.catalog import analyse_ordre_impose
from Accas.catalog import uiinfo
from Accas.extensions.eficas_translation import tr
from Accas.extensions.eficas_exception import EficasException

debug = 0

# -----------------------------
class ReaderCataCommun(object):
# -----------------------------
# le catacommun a ete mis en place
# lors des tentatives pour decrire le catalogue en XML
# Garde pour pouvoir demander un cata en web
# mais il va falloir revoir quelle fonction est ou (exple askChoixCata est mal place)
# en tenant compte de cette nouvelle division

    def askChoixCatalogue(self, cataListeChoix):
    #____________________________________________
        """
        Ouvre une fenetre de selection du catalogue dans le cas où plusieurs
        ont ete definis dans Accas/editeur.ini
        """
        if self.appliEficas == None :
            print("Pas de choix interactif sans qt")
            return

        code = getattr(self.appliEficas.maConfiguration, "code", None)
        if code != None: title = tr("Choix d une version du code ") + str(code)
        else: title = tr("Choix d une version ")

        # a Reflechir
        # Pourquoi 2 fois MonChoixCata -- je ne comprends pas mais cela fonctionne
        pathGui='InterfaceGUI.'+ self.appliEficas.GUIPath + '.monChoixCata'
        MonChoixCata =__import__(pathGui, globals(), locals(), ['MonChoixCata,'])
        widgetChoix = MonChoixCata.MonChoixCata(
            self.appliEficas, [cata.versionCode for cata in cataListeChoix], title
        )
        ret = widgetChoix.exec_()
        #if ret == QDialog.Accepted:
        if ret == 1:
            cata = cataListeChoix[widgetChoix.CBChoixCata.currentIndex()]
            self.cataFile = cata.cataFile
            self.versionCode = cata.versionCode
            self.appliEficas.formatFichierOut = cata.formatFichierOut
            self.appliEficas.formatFichierIn = cata.formatFichierIn
            titre='{} pour {} avec le catalogue {}'.format(self.appliEficas.versionEficas,self.code,self.versionCode)
            self.appliEficas.setWindowTitle(titre)
            widgetChoix.close()
        else:
            widgetChoix.close()
            raise EficasException()

    #--------------------#
    def choisitCata(self):
    #--------------------#

        listeTousLesCatas = []
        listeCataPossibles = []
        for catalogue in self.appliEficas.maConfiguration.catalogues:
            if isinstance(catalogue, CatalogDescription):
                listeTousLesCatas.append(catalogue)
            elif isinstance(catalogue, tuple):
                listeTousLesCatas.append(CatalogDescription.createFromTuple(catalogue))
            else:
                print(("Catalog description cannot be interpreted: ", catalogue))

        if self.versionCode is None:
            listeCataPossibles = listeTousLesCatas
        else:
            # a priori impossible sans l idee du sousCode
            for catalogue in listeTousLesCatas:
                if catalogue.code == self.code and catalogue.versionCode == self.versionCode:
                    listeCataPossibles.append(catalogue)

        if len(listeCataPossibles) == 0:
            self.appliEficas.afficheMessage(
                    tr("Import du catalogue"),
                    tr("Pas de catalogue defini pour le code {}".format(self.code)))
            #self.appliEficas.close()
            if self.appliEficas.salome == 0: sys.exit(1)
            return

        if self.versionCode is not None:
            # La version a ete fixee
            for cata in listeCataPossibles:
                if self.versionCode == cata.versionCode:
                    self.cataFile = cata.cataFile
                    self.versionCode = cata.versionCode
                    self.appliEficas.formatFichierOut = cata.formatFichierOut
                    self.appliEficas.formatFichierIn = cata.formatFichierIn
        else:
            cataChoiceList = []
            for cata in listeCataPossibles:
                if cata.selectable:
                    if cata.default:
                        cataChoiceList.insert(0, cata)
                    else:
                        cataChoiceList.append(cata)

        # le catalogue est fixe dans la ligne de commande
        if self.appliEficas.cataFile != None:
            trouve = False
            for catalogue in listeTousLesCatas:
                if os.path.abspath(catalogue.cataFile) == ( os.path.abspath(self.appliEficas.cataFile)):
                    listeCataPossibles = (catalogue,)
                    trouve = True
                    break
            if not trouve:
                # utilise par Telemac
                catalogue = CatalogDescription.createFromTuple(
                    ( self.code, self.code, self.appliEficas.cataFile, "python", "python",)
                )
                listeCataPossibles = (catalogue,)

        if len(listeCataPossibles) == 0:
            self.appliEficas.afficheMessage(
                 tr("Import du catalogue"),
                 tr("Pas de catalogue defini pour le code ") + self.code,
            )
            self.appliEficas.close()
            if self.appliEficas.salome == 0: sys.exit(1)
            return

        # le label est fixe dans la ligne de commande
        if self.versionCode is not None:
            # La version a ete fixee
            for cata in listeCataPossibles:
                if self.versionCode == cata.versionCode:
                    self.cataFile = cata.cataFile
                    self.appliEficas.formatFichierIn = cata.formatFichierIn
                    self.appliEficas.formatFichierOut = cata.formatFichierOut
        else:
            cataListeChoix = []
            for cata in listeCataPossibles:
                if cata.default: cataListeChoix.insert(0, cata)
                else: cataListeChoix.append(cata)

            if len(cataListeChoix) == 0:
                self.appliEficas.afficheMessage( 
                    tr("Import du catalogue"),
                    tr("Aucun catalogue trouve"),)
                self.appliEficas.close()
                if self.appliEficas.salome == 0: sys.exit(1)

            elif len(cataListeChoix) == 1:
                self.cataFile = cataListeChoix[0].cataFile
                self.versionCode = cataListeChoix[0].versionCode
                self.appliEficas.formatFichierOut = cataListeChoix[0].formatFichierOut
                self.appliEficas.formatFichierIn = cataListeChoix[0].formatFichierIn

            else:
                # plusieurs catalogues sont disponibles : il faut demander a l'utilisateur
                # lequel il veut utiliser ...
                #self.appliEficas.afficheMessage( tr("Import du catalogue"), tr('Aucun catalogue choisi'), critique = True)
                self.demandeCatalogue = True
                self.askChoixCatalogue(cataListeChoix)

        if self.cataFile == None:
            if self.appliEficas.salome == 0:
                print( "Pas de catalogue pour code %s, version %s" % (self.code, self.versionCode))
                sys.exit(1)
            else:
                self.appliEficas.close()
                return


# ------------------------------------
class ReaderCata(ReaderCataCommun):
# ------------------------------------

    def __init__(self, appliEficas, editor):
    # _________________________________

        self.appliEficas = appliEficas
        self.editor = editor
        self.versionEficas = self.appliEficas.versionEficas
        self.demandeCatalogue = False
        self.code = self.appliEficas.code
        self.titre = self.appliEficas.code
        # on positionne par defaut mais est-ce vraiment necessaire
        self.appliEficas.formatFichierIn = "python"
        self.appliEficas.formatFichierOut = "python"
        self.versionCode = self.appliEficas.versionCode
        # TODO
        # En transitoire pour garder la versionQT5 compatbile avec la nouvelle API 
        # Bien reflechir  pour conserver la possibilité du prefs_Code.py
        if self.editor.cataFile != None :
            self.cataFile = self.editor.cataFile
        else :
            self.cataFile = self.appliEficas.cataFile
        if debug : print ('ReaderCata self.cataFile =', self.cataFile)
        self.openCata()
        self.traiteIcones()
        self.cataitem = None
        self.creeDicoInverse()
        if self.code == "TELEMAC": self.creeDicoCasToCata()

    def openCata(self):
    # _________________
        """
        Ouvre le catalogue standard du code courant, cad le catalogue present
        dans le repertoire Cata
        """
        # import du catalogue
        if self.cataFile == None: self.choisitCata()

        self.cata = self.importCata(self.cataFile)
        if self.code == "NonConnu": self.code = self.cata.JdC.code
        #if self.code == "NonConnu": self.code = 'aaaaa'
        modeleMetier = None
        dicoEltDif = {}
        listeTypeWithUnit = ()
        if not(self.appliEficas.genereXSD) and self.appliEficas.withXSD:
                try:
                    import pyxb
                except:
                    self.appliEficas.afficheMessage(
                        "environnement", "please source pyxb environment"
                    )
                    exit()
                try:
                    debug = 0
                    nomCataXsd = os.path.splitext(os.path.basename(self.cataFile))[0]
                    cataFileTrunc = os.path.splitext( os.path.basename(self.cataFile))[0]
                    nomCataXsd = cataFileTrunc + "_driver"

                    if os.path.dirname(self.cataFile) == "":
                        pathCata = "./raw/" + nomCataXsd + ".py"
                    else:
                        #pathCata = ( os.path.dirname(self.cataFile) + "/raw/" + nomCataXsd + ".py")
                        # PN 4 fevrier --> pourquoi raw ?
                        pathCata = ( os.path.dirname(self.cataFile) + "/" + nomCataXsd + ".py")

                    #self.cata.fileModeleMetier = ( os.path.dirname(self.cataFile) + "/raw/" + nomCataXsd + ".xsd")
                    self.cata.fileModeleMetier = ( os.path.dirname(self.cataFile) + "/" + nomCataXsd + ".xsd")
                   
                    if debug : print ('nomCataXsd , pathCata ',nomCataXsd,pathCata)
                    import imp
                    modeleMetier = imp.load_source(nomCataXsd, pathCata)
                    if debug : print ('modeleMetier', modeleMetier)
                    try:
                        monObjetAnnotation = getattr(modeleMetier, "PNEFdico")
                        texte = monObjetAnnotation.__doc__
                    except:
                        texte = None
                    if texte != None and texte != "":
                        l = {}
                        texte = "dicoEltDif = " + texte
                        exec(texte, globals(), l)
                        dicoEltDif = l["dicoEltDif"]
                    try:
                        monObjetAnnotation = getattr(modeleMetier, "listeTypeWithUnit")
                        texte = monObjetAnnotation.__doc__
                    except:
                        texte = None
                    if texte != None and texte != "":
                        l = {}
                        texte = "listeTypeWithUnit = " + texte
                        exec(texte, globals(), l)
                        listeTypeWithUnit = l["listeTypeWithUnit"]

                except Exception as e :
                    self.appliEficas.afficheMessage( "XSD driver", "unable to load xsd driver" + str(e))
                    modeleMetier = None

        self.cata.DicoNomTypeDifferentNomElt = dicoEltDif
        self.cata.listeEltWithUnit = listeTypeWithUnit
        if self.cata.listeEltWithUnit != () : self.cata.unitAsAttribut = True
        else : self.cata.unitAsAttribut = False

        if hasattr(self.cata, "implement"):
            self.cata.JdC.implement = self.cata.implement
        else:
            self.cata.JdC.implement = ""
        if hasattr(self.cata, "importedBy"):
            self.cata.JdC.importedBy = self.cata.importedBy
        else:
            self.cata.JdC.importedBy = []
        self.cata.JdC.versionCode = self.versionCode
        if not (hasattr(self.cata, "dict_condition")):
            self.cata.dict_condition = {}

        # pointeur pour le dumpXSD
        self.cata.JdC.cata = self.cata

        self.cata.modeleMetier = modeleMetier
        if not self.cata:
            self.appliEficas.afficheMessage(
                "Catalogue", "Impossible d'importer le catalogue " + self.cataFile
            )
            self.appliEficas.close()
            if self.appliEficas.salome == 0:
                sys.exit(1)
        #
        # retrouveOrdreCataStandard fait une analyse textuelle du catalogue
        # retrouveOrdreCataImpose utilise une numerotation des mots cles a la creation
        self.retrouveOrdreCata()
        self.retrouveOrdreCataImpose()
        if hasattr(self.cata, "ordreDesCommandes"): 
           self.ordreDesCommandes = self.cata.ordreDesCommandes
        else:
           self.ordreDesCommandes = []
           for cmd in self.cata.JdC.commandes:
               self.ordreDesCommandes.append(cmd.nom)

        if hasattr(self.cata, "Classement_Commandes_Ds_Arbre"):
            self.Classement_Commandes_Ds_Arbre = self.cata.Classement_Commandes_Ds_Arbre
        else:
            self.Classement_Commandes_Ds_Arbre = ()
        if hasattr(self.cata, "enum"):
            try:
                _temp = __import__(
                    self.cata.enum,
                    globals(),
                    locals(),
                    ["DicoEnumCasFrToEnumCasEn", "TelemacdicoEn"],
                    0,
                )
                self.DicoEnumCasFrToEnumCasEn = _temp.DicoEnumCasFrToEnumCasEn
                self.TelemacdicoEn = _temp.TelemacdicoEn
            except:
                pass

        # print self.cata.ordreDesCommandes

        #
        # analyse des donnees liees l'IHM : UIinfo
        #
        uiinfo.traite_UIinfo(self.cata)

        self.titre = (
            self.versionEficas + tr(" avec le catalogue ")
            + os.path.basename(self.cataFile)
        )
        self.editor.titre = self.titre
        if hasattr(self.appliEficas, 'setWindowTitle') :
            self.appliEficas.setWindowTitle(self.titre)

        # incertitude ou modification du Catalogue
        if hasattr(self.cata, "avecIncertitude"): self.appliEficas.ajoutUQ()
        if hasattr(self.cata, "modifieCatalogueDeterministe"):
            self.cata.modifieCatalogueDeterministe(self.cata)

    def importCata(self, cataFile):
        """
        Realise l'import du catalogue dont le chemin d'acces est donne par cata
        """
         
        if cataFile == None :
           print ('No catafile')
           return
        debug=0
        if debug : print ('importCata cataFile', cataFile)
        nomCata = os.path.splitext(os.path.basename(cataFile))[0]
        repCata = os.path.abspath(os.path.dirname(cataFile))
        if debug : print ('importCata nomCata', cataFile)
        if debug : print ('importCata repCata', repCata)
        sys.path[:0] = [repCata]
        self.appliEficas.listePathAEnlever.append(repCata)

        if nomCata in list(sys.modules.keys()):
            del sys.modules[nomCata]

        for k in sys.modules:
            if k[0 : len(nomCata) + 1] == nomCata + ".":
                del sys.modules[k]

        # permettait d ajouter des scripts appelables par des fonctions supplementaires
        # dans l ihm
        # par exemple  permet d ajouter des morceaux dans le jeu de données
        # mecanisme mis en place pout MT et laisse pour pouvoir eventuellement
        # etre repris 
        # mesScriptsNomFichier = "mesScripts_" + self.code.upper()
        # try: self.appliEficas.mesScripts[self.code] = __import__(mesScriptsNomFichier)
        # except: pass

        try:
        #print ('PN --> Attention chgt Try en if')
        #if 1 :
            #import importlib.util
            #from importlib import util
            #cataSpec = util.spec_from_file_location(nomCata, cataFile)
            #leCata = util.module_from_spec(cataSpec)
            #print ('--------------1',leCata)
            #cataSpec.loader.exec_module(leCata)
            #print ('--------------2',leCata)
            # les lignes precedentes ne sont pas equivalentes a l __import__
            # le exec module execute le catalogue mais sans lui on n a pas acces a cata.JdC
            # a creuser
            leCata =__import__(nomCata)
            return leCata
        except Exception as e:
        #else :
            self.appliEficas.afficheMessage("catalog python", "unable to load catalog file")
            #import traceback
            #traceback.print_exc()
            raise EficasException(str(e))
            sys.exit(1) 

    def retrouveOrdreCata(self):
        """
        Construit une structure de donnees dans le catalogue qui permet
        a EFICAS de retrouver l'ordre des mots-cles dans le texte du catalogue.
        Pour chaque entite du catalogue on cree une liste de nom ordreMC qui
        contient le nom des mots cles dans le bon ordre
        """
        self.dicoCataOrdonne, self.appliEficas.liste_simp_reel = analyse_ordre_catalogue.analyseCatalogue(self.cata)

    def retrouveOrdreCataImpose(self):
        """
        Retrouve l'ordre des mots-cles dans le catalogue, cad :
        Attention s appuie sur les commentaires
        """
        nomCata = os.path.splitext(os.path.basename(self.cataFile))[0]
        repCata = os.path.dirname(self.cataFile)
        self.commandesOrdreCatalogue = analyse_ordre_impose.analyseCatalogue( self.cataFile)

    def traiteIcones(self):
        if self.appliEficas.maConfiguration.ficIcones == None:
            return
        try:
            ficIcones = self.appliEficas.maConfiguration.ficIcones
            fichierIcones = __import__(ficIcones, globals(), locals(), [], 0)
            self.appliEficas.maConfiguration.dicoIcones = (
                fichierIcones.dicoDesIcones.dicoIcones
            )
            self.appliEficas.maConfiguration.dicoImages = (
                fichierIcones.dicoDesIcones.dicoImages
            )
        except:
            print("Pas de fichier associe contenant des liens sur les icones ")
            self.appliEficas.maConfiguration.dicoIcones = {}

    def creeDicoInverse(self):
        self.dicoInverse = {}
        self.dicoMC = {}
        if not self.cata:
            return
        listeEtapes = self.cata.JdC.commandes
        for e in self.cata.JdC.commandes:
            self.traiteEntite(e)

    def creeDicoCasToCata(self):
        if hasattr(self.cata, "dicoCasEn"):
            _temp = __import__(
                self.cata.dicoCasEn, globals(), locals(), ["DicoCasEnToCata"], 0
            )
            if self.appliEficas.langue == "ang":
                self.dicoCasToCata = _temp.dicoCasEnToCata
            else:
                self.dicoCasToCata = _temp.dicoCasFrToCata

    def traiteEntite(self, e):
        boolIn = 0
        for nomFils, fils in list(e.entites.items()):
            self.dicoMC[nomFils] = fils
            self.traiteEntite(fils)
            boolIn = 1
        if boolIn == 0:
            liste = []
            moi = e
            while hasattr(moi, "pere"):
                liste.append((moi.nom, moi))
                moi = moi.pere
            liste.append((moi.nom, moi))
            self.dicoInverse[e.nom] = liste
            self.dicoInverse[tr(e.nom)] = liste

    def creeRubrique(self, e, dico, niveau):
        from Accas import A_BLOC

        decale = niveau * "   "
        # if niveau != 0 :
        #    if isinstance(e,A_BLOC.BLOC): print decale, e.condition
        #    else :                           print decale, e. nom
        for nom, fils in list(e.entites.items()):
            if list(fils.entites.items()) != []:
                self.creeRubrique(fils, dico, niveau + 1)
            # else : print (niveau+1)*"   ", nom

    # def dumpToXsdEficas(self):
    # Pas sur qu on ait jamais besoin de cela
    #    pass
    # from Efi2Xsd import readerEfficas
    # newSchema=   xml = open('Cata_MED_FAM.xml').read()
    # SchemaMed = efficas.CreateFromDocument(xml)
    # SchemaMed.alimenteCata(self.cata)

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

import types, sys, os, re
import subprocess
import traceback

# Modules Eficas

import Accas.IO.reader as reader
import Accas.IO.writer as writer
from uuid import uuid1
from Accas.extensions.eficas_exception import EficasException
from Accas.extensions.eficas_translation import tr
from Accas.extensions.codeErreur import dictErreurs

Dictextensions = {"MAP": ".map", "TELEMAC": ".cas"}
debug = False


# ---------- #
class Editor:
# ---------- #
    """
    Editeur de jdc
    """


    def __init__(self, appliEficas, cataFile = None, dataSetFile = None,  jdc=None, include=0, formatIn ='python', formatOut = 'python', useFor = None):
    # -------------------------------------------------------------------------------------------------------------------------------------------------#
        if debug: print("dans le init de Editor")
        if debug : print (self, appliEficas, cataFile, dataSetFile,  jdc, include)
        self.appliEficas = appliEficas

        self.dataSetFile = dataSetFile
        self.fichierComplet = dataSetFile
        if dataSetFile != None: self.extensionFichier = os.path.splitext(dataSetFile)[1]
        else: self.extensionFichier = None

        self.cataFile = cataFile
        self.first = True
        self.jdc = None
        self.jdc_item = None
        self.dicoNouveauxMC = {}
        self.dicoNouveauxFact = {}
        self.dict_reels = {}
        self.liste_simp_reel = []
        self.editorId = uuid1().hex
        self.appliEficas.editorManager.dictEditors[self.editorId]=self
        self.include = include
        self.formatFichierOut = formatOut
        self.formatFichierIn = formatIn
        self.editorManager=appliEficas.editorManager


        # ces attributs sont mis a jour par definitCode appelee par newEditor
        self.code = self.appliEficas.maConfiguration.code
        self.maConfiguration = self.appliEficas.maConfiguration

       
        if self.maConfiguration.writerModule :
            try:
                _module = __import__(self.maConfiguration.writerModule)
                info = _module.entryPoint()
                writer.plugins.addEntryPoint(info)
            except:
                print ('unable to load writerModule')
                pass

        if self.maConfiguration.readerModule :
            try:
                # print self.maConfiguration.readerModule
                _module = __import__(self.maConfiguration.readerModule)
                info = _module.entryPoint()
                reader.plugins.addEntryPoint(info)
            except:
                print ('unable to load raderModule')
                pass

        self.mesWriters = writer
        if "xml" in writer.plugins.keys(): self.XMLWriter = writer.plugins["xml"]()
        else : self.XMLWriter = None
        if "python" in writer.plugins.keys(): self.pythonWriter = writer.plugins["python"]()
        else : self.pythonWriter = None
        if self.formatFichierOut in writer.plugins.keys(): self.myWriter = writer.plugins[self.formatFichierOut]()

        self.fileInfo = None
        self.lastModified = 0

        self.modified = False
        self.isReadOnly = False

        try : 
        #if 1 :
            self.readCata()
        except Exception as e :
            print ('----------------------------------------')
            print ( 'lecture du catalogue impossible')
            print ( e)
            print ('----------------------------------------')
            if not self.appliEficas.salome :  exit (1)
            else : return
        if self.readercata  : self.construitJdC(jdc)
        if useFor == 'Web' :
           if not hasattr(self,'webExtension') : 
              from InterfaceGUI.Web.web_editor_extension import WebEditorExtension
              self.webExtension = WebEditorExtension(self)
     
    def construitJdC(self,jdc):
    #-------------------------
    # construction du jdc 
    # Est-il encore necessaire de passer en paramtre un jdc a l init ?
    # je ne vois plus quel est le cas d usage
    # je garde les 3 lignes . 11 mars 2024
        if jdc : 
           self.jdc = jdc
           return
        self.pbLectureDataSet = None
        self.messageInfo = ""
        if self.readercata.cata == None: 
           if self.dataSetFile is not None: 
              print ('dataSetFile comm mais pas de cata')
              raise EficasException("dataSet fourni mais pas de catalogue'")

        self.nouveau = 0
        if self.dataSetFile is not None:  #  fichier jdc fourni
            # print ('PNPN : chgt try en if')
            try:
            #if 1 :
                self.jdc = self.readFile(self.dataSetFile)
            except Exception as e :
            #else :
                self.pbLectureDataSet = str(e)
                self.jdc = None
                print("mauvaise lecture du dataSetFile")
                print (str(e))
            if self.appliEficas.salome:
                try:
                    self.appliEficas.addJdcInSalome(self.dataSetFile)
                except Exception as e:
                    print("mauvais enregistrement dans Salome")
                    raise EficasException(str(e))
        else:
            if not self.include: self.jdc = self._newJDC()
            else: self.jdc = self._newJDCInclude()
            self.nouveau = 1

        if self.jdc:
            self.jdc.editor = self
            self.jdc.lang = self.appliEficas.langue
            self.jdc.aReafficher = False
            txt_exception = None
            if self.extensionFichier == ".xml":
                if self.appliEficas.withXSD: self.jdc.analyseXML()
                else: 
                   # prevoir autre chose pour le web
                   print("run MDM with -x option  (MDM for XML)")
                   exit()
            else:
                self.jdc.analyse()
                if hasattr(self, "monJDCReader") and hasattr( self.monJDCReader, "traitementApresLoad"):
                    self.monJDCReader.traitementApresLoad(self.jdc)
                self.pbLectureDataSet  = self.jdc.cr.getMessException()
            if self.pbLectureDataSet :
                self.jdc = None
                self.afficheMessage("pb chargement jdc", self.pbLectureDataSet)

   
    # -----------------#
    def readCata(self) :
    # -----------------#
        # pour le TUI ou le Web appli eficas n a pas de cata
        self.readercata = None
        self.pbLectureCata = None
        if self.maConfiguration.typeDeCata == "XML":
            from Accas.catalog import reader_cata_XML as reader_cata
        else:
            from Accas.catalog import reader_cata
        try :
            self.readercata =  reader_cata.ReaderCata(self.appliEficas, self)
        except Exception as e:
            self.pbLectureCata = str(e)
        if self.readercata : 
            self.titre = self.readercata.titre

    # ---------------------#
    def readFile(self, fn):
    # ---------------------#
        # charge un JDC

        fn = str(fn)
        jdcName = os.path.basename(fn)
        debug = 0
        if debug : 
            print ('-------------------------------------------')
            print (fn)
            print ('-------------------------------------------')

        # Il faut convertir le contenu du dataSetFile en fonction du format
        formatIn = self.appliEficas.formatFichierIn
        if self.extensionFichier == ".xml" and self.appliEficas.withXSD:
            formatIn = "xml"
        if formatIn in reader.plugins:
            # Le convertisseur existe on l'utilise
            monJDCReader = reader.plugins[formatIn]()
            monJDCReader.readfile(fn)

            if monJDCReader.text == "":
                self.nouveau = 1
            # print ('PNPN --> CIST a faire')

            if formatIn != "xml":
                pareil, texteNew = self.verifieChecksum(monJDCReader.text)
                if not pareil:
                    self.afficheMessage( "fichier modifie", "Attention! fichier change hors EFICAS" )
                    self.messageInfo = "fichier modifie, Attention! fichier change hors EFICAS"
                monJDCReader.text = texteNew
                memeVersion, texteNew = self.verifieVersionCataDuJDC(monJDCReader.text)
                if memeVersion == 0:
                    texteNew = self.traduitCatalogue(texteNew)
                monJDCReader.text = texteNew
                text = monJDCReader.convert("exec", self.appliEficas)
                if not monJDCReader.cr.estvide():
                    self.afficheMessage(tr("Erreur a la conversion"),"pb lecture XML", "red")
            else:
                text = monJDCReader.text
        else:
            self.afficheMessage(
                "Type de fichier non reconnu",
                "EFICAS ne sait pas ouvrir le type de fichier "
                + self.appliEficas.formatFichierIn,
                'red'
            )
            return None

        CONTEXT.unsetCurrentStep()

        # le cata  n est pas charge ou ???
        # ligne a verifier
        if not (hasattr(self.readercata, "dicoCataOrdonne")): return

        jdc = self.readercata.cata.JdC(
            procedure=text,
            appliEficas=self.appliEficas,
            cata=self.readercata.cata,
            dicoCataOrdonne=self.readercata.dicoCataOrdonne,
            nom=jdcName,
            repMat=self.maConfiguration.repMat,
            editeur=self
        )
        self.modified = False
        self.monJDCReader = monJDCReader
        return jdc

    # ----------------------------#
    def _newJDC(self, texte = ""):
    # ----------------------------#
        """
        Initialise un nouveau JDC avec le texte passe en parametre
        """
        self.modified = 1
        CONTEXT.unsetCurrentStep()

        if hasattr(self.readercata.cata, "TEXTE_NEW_JDC"):
            texte = self.readercata.cata.TEXTE_NEW_JDC

        jdc = self.readercata.cata.JdC(
            procedure=texte,
            appliEficas=self.appliEficas,
            cata=self.readercata.cata,
            dicoCataOrdonne=self.readercata.dicoCataOrdonne,
            repMat=self.maConfiguration.repMat,
            editeur=self
        )

        jdc.lang = self.appliEficas.langue
        jdc.editor = self
        return jdc

    # ----------------------#
    def _newJDCInclude(self):
    # ----------------------#
        """
        Initialise un nouveau JDC include vierge
        Inutilise depuis Aster mais interessant
        permet de definir a part une portion du JDC en
        utilisant les concepts dans les 2 JDC
        """
        import Accas.extensions.jdc_include

        JdC_aux = Accas.extensions.jdc_include.JdC_include
        CONTEXT.unsetCurrentStep()

        # jaux=self.readercata.cata[0].JdC( procedure="",
        jaux = self.readercata.cata.JdC(
            procedure="",
            appliEficas=self.appliEficas,
            cata=self.readercata.cata,
            dicoCataOrdonne=self.readercata.dicoCataOrdonne,
            repMat=self.maConfiguration.repMat,
            editeur=self
        )
        jaux.editor = self
        jaux.analyse()

        J = JdC_aux(
            procedure="",
            appliEficas=self.appliEficas,
            cata=self.readercata.cata,
            dicoCataOrdonne=self.readercata.dicoCataOrdonne,
            jdc_pere=jaux,
            repMat=self.maConfiguration.repMat,
            editeur=self
        )
        J.editor = self
        J.analyse()
        return J

    # ---------------------------#
    def getDicoForFancy(self, obj):
    # ----------------------------#
        # Normalement appele que par le Web
        if not hasattr(self,'webExtension') : 
           return (None, 110, dictErreur[110], "")
        return (self.webExtension.getDicoForFancy(obj), 0, "","")

   
    #---------------------------
    def getListeCommandes(self):
    #---------------------------
        if self.readercata == None : 
           return (None, 3000, dictErreur[3000], "")
        if self.readercata.cata.JdC == None : 
           return (None, 3000, dictErreur[3000], "")
        return (self.readercata.cata.JdC.getListeCmd(), 0, "", "")


    # -----------------------#
    def getSource(self, file):
    # -----------------------#

        # Il faut convertir le contenu du fichier en fonction du format
        if self.formatFichierIn in reader.plugins:
            # Le convertisseur existe on l'utilise
            p = reader.plugins[self.formatFichierIn]()
            p.readfile(file)
            text = p.convert("execnoparseur")
            if not p.cr.estvide():
                self.afficheMessage("Erreur a la conversion", p.cr.report(), "red")
            return text
        else:
            # Il n'existe pas c'est une erreur
            self.afficheMessage(
                "Type de fichier non reconnu",
                "EFICAS ne sait pas ouvrir le type de fichier "
                + self.appliEficas.formatFichierIn,
            )
            return None

    # ----------------------------------------------#
    def __generateTempFilename(self, prefix, suffix):
    # ----------------------------------------------#
        import tempfile
        (fd, filename) = tempfile.mkstemp(prefix=prefix, suffix=suffix)
        os.close(fd)
        return filename

    # -----------------#
    def generDico(self):
    # -----------------#
        if "dico" in writer.plugins:
            self.myWriter = writer.plugins["dico"]()
            # print (self.myWriter)
            jdc_formate = self.myWriter.gener(self.jdc)
            # print (jdc_formate)
            dico = self.myWriter.Dico
            # print (dico)
            return dico

    # --------------------------------#
    def generDicoPourWeb(self, obj=None):
    # --------------------------------#
        if obj == None:
            obj = self.jdc
        if "dico" in writer.plugins:
            self.myWriter = writer.plugins["dico"]()
            jdc_formate = self.myWriter.gener(self.jdc)
            dico = self.myWriter.Dico
            return dico

    # -----------------------#
    def generDicoPython(self):
    # -----------------------#
        if "dico" in writer.plugins:
            self.myWriter = writer.plugins["dico"]()
            dico = self.myWriter.generDico(self.jdc)
            return dico

    # --------------------------#
    def getJdcFichierSource(self):
    # --------------------------#
        if self.dataSetFile == None: return "fichier source non defini"
        if os.path.isfile(self.dataSetFile):
            f = open(self.dataSetFile, "r")
            texteSource = f.read()
            f.close()
            return texteSource
        else:
            return "le fichier source n existe pas"
            self._viewText("file doesn't exist", "JDC_SOURCE")

    # -----------------------------#
    def getJdcFichierResultat(self):
    # -----------------------------#
        strResult = str(self.getTextJDC(self.formatFichierOut))
        return strResult

    # -----------------------#
    def getJdcRapport(self):
    # -----------------------#
        # on ajoute les regles
        strRapport = str(self.jdc.report())
        return strRapport

    # -----------------------#
    def getJdcRegles(self):
    # -----------------------#
        # on ajoute les regles
        texteGlobal, testOK = self.jdc.verifRegles()
        return texteGlobal

    # -------------------------#
    def getDataSetFileName(self):
    # --------------------------#
        return self.dataSetFile

    # -------------------------#
    def getCataFileName(self):
    # --------------------------#
        return self.cataFile

    # -------------------------#
    def getEditorId(self):
    # --------------------------#
        return self.editorId


    # -------------------#
    def initModif(self):
    # -------------------#
        """
        Met l'attribut modified a 'o' : utilise par Eficas pour savoir
        si un JDC doit etre sauvegarde avant destruction ou non
        """
        self.modified = True

    # --------------------------------------------------------#
    def writeFile(self, fn, txt=None, formatLigne="beautifie"):
    # --------------------------------------------------------#
        fn = str(fn)

        if txt == None:
            txt = self.getTextJDC(self.formatFichierOut, formatLigne=formatLigne)
            eol = "\n"
            if len(txt) >= len(eol):
                if txt[-len(eol) :] != eol:
                    txt += eol
            else:
                txt += eol
            txt = self.ajoutVersionCataDsJDC(txt)
            if self.code != "PSEN" and self.code != "PSEN_N1":
                checksum = self.getChecksum(txt)
            else:
                checksum = ""
            txt = txt + checksum
        if self.code == "TELEMAC":
            return 1
        try:
            f = open(fn, "w")
            f.write(txt)
            f.close()
            return 1
        except IOError as why:
            print(
                "Sauvegarde du Fichier",
                "Le fichier" + str(fn) + "n a pas pu etre sauvegarde :",
                str(why),
            )
            self.afficheMessage( "Sauvegarde du Fichier",
                "Le fichier" + str(fn) + "n a pas pu etre sauvegarde ", "red"
            )
            return 0

    # -------------------------------------------------------------------#
    def getTextJDC(self, format=None, pourRun=0, formatLigne="beautifie"):
    # -------------------------------------------------------------------#
        debug = 0
        if self.code == "MAP" and not (format in writer.plugins):
            format = "MAP"
        if format == None:
            format = self.formatFichierOut
        if debug : print ('writer.plugins',writer.plugins)
        if format in writer.plugins:
            # Le writer existe on l'utilise
            self.myWriter = writer.plugins[format]()
            try:
                jdc_formate = self.myWriter.gener(
                    self.jdc,
                    format=formatLigne,
                    config=self.appliEficas.maConfiguration,
                    appliEficas=self.appliEficas,
                )
                if pourRun:
                    jdc_formate = self.myWriter.textePourRun
                if self.code == "TELEMAC":
                    jdc_formate = self.myWriter.texteDico
            except ValueError as e:
                self.afficheMessage("Erreur a la generation", str(e), "red")
                return

            if not self.myWriter.cr.estvide():
                self.afficheMessage(
                    "Erreur a la generation",
                    "EFICAS ne sait pas convertir ce JDC",
                    "red",
                )
                return ""
            else:
                return jdc_formate
        else:
            # Il n'existe pas c'est une erreur
            self.afficheMessage("Format de sortie ", format + " non reconnu")
            return ""

    # ------------------------------#
    def verifieChecksum(self, text):
    # ------------------------------#
        # Attention : souci sous Windows
        #
        indexDeb = text.find("#CHECKSUM:")
        if indexDeb < 0:
            return 1, text
        indexFin = text.find(":FIN CHECKSUM")
        checkAvant = text[indexDeb : indexFin + 13]
        textJDC = text[0:indexDeb] + text[indexFin + 13 : -1]
        if self.code != "PSEN" and self.code != "PSEN_N1":
            checksum = self.getChecksum(textJDC)
            pareil = checkAvant == checksum
        else:
            pareil = 1
        return pareil, textJDC

    # ---------------------------#
    def getChecksum(self, texte):
    # ---------------------------#
        try:
            import hashlib

            newtexte = texte.replace('"', '\\"')
            hash_checksum = hashlib.md5()
            hash_checksum.update(newtexte.encode("utf-8"))
            checksum = hash_checksum.hexdigest()
            ligne = "#CHECKSUM:" + checksum + ":FIN CHECKSUM"
        except:
            try:
                newtexte = texte.replace('"', '\\"')
                commande = 'echo "' + newtexte + '"|md5sum'
                a = os.popen(commande)
                checksum = a.read()
                a.close()
            except:
                checksum = "Fichier trop long \n"
            ligne = "#CHECKSUM:" + checksum[0:-1] + ":FIN CHECKSUM"
        return ligne

    # ---------------#
    def getDico(self):
    # ---------------#
        if "dicoImbrique" in writer.plugins:
            self.myWriter = writer.plugins["dicoImbrique"]()
            # print (self.myWriter)
            jdc_formate = self.myWriter.gener(self.jdc)
            dico = self.myWriter.Dico
            return dico
        else:
            self.afficheMessage( tr("Format %s non reconnu", "Dictionnaire Imbrique"), "red"
            )
            return ""

    # ----------------------#
    def chercheGroupes(self):
    # ----------------------#
        listeMA, listeNO = self.getTextJDC("GroupMA")
        return listeMA, listeNO

    # --------------------------------------#
    def saveFileLegerAs(self, fileName=None):
    # --------------------------------------#
        if fileName != None:
            self.dataSetFile = fileName
            return self.saveFileLeger(fileName)
        return self.saveFileLeger()

    # -----------------------------------------------------------------#
    def saveFileComplet(self, fichier=None, formatLigne="beautifie"):
    # -----------------------------------------------------------------#
        fn = fichier
        self.myWriter = writer.plugins[self.format]()
        #print(self.myWriter)
        if hasattr(self.myWriter, "writeComplet"):
            self.myWriter.writeComplet(
                fichier,
                self.jdc,
                config=self.appliEficas.maConfiguration,
                appliEficas=self.appliEficas,
            )

    # --------------------------------#
    def saveUQFile(self, fichier=None):
    # --------------------------------#
        if fichier == None:
            self.afficheMessage("Sauvegarde", "nom de fichier obligatoire pour sauvegarde")
            return 0, None
        self.dataSetFile = fichier
        self.myWriter = writer.plugins["UQ"]()
        ret, comm = self.myWriter.creeNomsFichiers(fichier)
        # print (ret,comm)
        if not ret:
            self.afficheMessage("Sauvegarde UQ", self.myWriter.commentaire)
            return ret, None
        ret = self.myWriter.gener(self.jdc)
        if not ret:
            self.afficheMessage("Sauvegarde UQ", self.myWriter.commentaire)
            return ret, None
        if ret == 2:
            self.afficheMessage("Sauvegarde UQ", self.myWriter.commentaire, critique=False)
            self.modified = False
            return 1, fichier
        ret = self.myWriter.writeUQ(fichier)
        if not ret:
            self.afficheMessage("Sauvegarde UQ", self.myWriter.commentaire)
        else:
            self.afficheMessage(
                "Sauvegarde UQ",
                "Sauvegardes des fichiers .comm, _det.comm  effectuées.\n"
                "Création des fichiers _UQ.py et _@det.comm.",
                critique=False,
            )
        self.modified = False
        return ret, fichier

    # ---------------------------------------#
    def sauvePourPersalys(self, fichier=None):
    # ---------------------------------------#
        if fichier == None:
            self.afficheMessage(
                "Sauvegarde Etude Persalys",
                "nom de fichier obligatoire pour sauvegarde",
            )
            return 0, None
        self.myWriter = writer.plugins["UQ"]()
        ret, comm = self.myWriter.creeNomsFichiers(fichier)
        if not ret:
            self.afficheMessage("Sauvegarde Etude Persalys", self.myWriter.commentaire)
        fichierPersalys = self.myWriter.fichierUQExe
        ret = self.myWriter.gener(self.jdc)
        if not ret:
            self.afficheMessage("Sauvegarde Etude Persalys", self.myWriter.commentaire)
            return ret, None
        txt = self.myWriter.txtScriptPersalys.split(
            "################ CUT THE FILE HERE IF YOU WANT TO IMPORT IT IN THE SALOME PERSALYS MODULE ################"
        )[0]
        try:
            with open(fichierPersalys, "w") as f:
                f.write(txt)
                f.close()
            self.afficheMessage(
                "Sauvegarde Etude Persalys",
                "Le fichier " + str(fichierPersalys) + " a été sauvegardé",
                critique=False,
            )
            return 1, " "
        except IOError as why:
            self.afficheMessage(
                "Sauvegarde Etude Persalys",
                "Le fichier " + str(fichierPersalys) + " n a pas pu etre sauvegardé",
            )
            return 0, str(why)

    # --------------------------------------#
    def exeUQ(self, fichier=None, path=None):
    # --------------------------------------#
        self.afficheMessage("Pas prevu pour l instant")
        return ret, None

    # --------------------------------#
    def ajoutCommentaire(self):
    # --------------------------------#
        print("pas programme sans Ihm")
        print("prevenir la maintenance du besoin")

    # ------------------------------------------------#
    def afficheMessage(self, titre, txt, couleur='red'):
    # ------------------------------------------------#
        # methode differenre avec et sans ihm
        if couleur == 'red': print("!!!!!!!!!!!!!!!!!!!!!!!!!!!")
        print(titre)
        print(txt)
        if couleur == 'red': print("!!!!!!!!!!!!!!!!!!!!!!!!!!!")

    # ------------------------------------------------------------------------#
    def _viewText(self, txt, caption="FILE_VIEWER", largeur=1200, hauteur=600):
    # ------------------------------------------------------------------------#
        print("_____________________________")
        print(txt)
        print("_____________________________")

    # --------------------------------------------------#
    def saveFile(self, fichier, formatLigne="beautifie"):
    # --------------------------------------------------#
        """
        Public slot to save the text to a file.

        @param path directory to save the file in (string or QString)
        @return tuple of two values (boolean, string) giving a success indicator and
            the name of the saved file
        """
        #TODO PN : s occuper des suffixes

        if fichier != self.dataSetFile :
           return (1, 'utiliser saveFileAs pour changer le nom du fichier')
        self.fichierOut = fichier
        if not (self.writeFile(fichier, formatLigne=formatLigne)):
            return (0, None)
        if self.jdc.cata.modeleMetier and self.jdc.isValid():
            if self.myWriter != self.XMLWriter:
                self.XMLWriter.gener(self.jdc)
                self.XMLWriter.writeDefault(fichier)
                return (0, self.dataSetFile)
        if self.jdc.isValid() and hasattr(self.myWriter, "writeDefault"):
            self.myWriter.writeDefault(fichier)
        elif self.code == "TELEMAC" and hasattr(self.myWriter, "writeDefault"):
            self.myWriter.writeDefault(fichier)
        self.modified = 0
        return (0, self.dataSetFile)

    # --------------------------------------------------#
    def saveFileAs(self, fichier, formatLigne="beautifie"):
    # --------------------------------------------------#
        self.dataSetFile  = fichier
        return self.saveFile(fichier, formatLigne)

    # -----------------------#
    def sauveLigneFile(self):
    # ----------------------#
        self.modified = 1
        return self.saveFile(formatLigne="Ligne")

    # ----------------------------------------#
    def updateJdcEtape(self, itemApres, texte):
    # ----------------------------------------#
        # ajoute une etape  de JdC a partir d un texte
        # garder pour l exemple d utilisation de build_includeEtape
        monItem = itemApres
        etape = monItem.item.object
        CONTEXT.set_current_step(etape)
        try: ok = etape.build_includeEtape(texte)
        except: ok = 0
        if not ok:
            QMessageBox.information( self, tr("Import texte"), tr("Impossible d importer le texte"))
        self.tree.racine.build_children()
        return ok

    # -------------------------------------------------------#
    def dumpXsd(self, withAbstractElt, withUnitAsAttribute):
    # -------------------------------------------------------#
        if not self.readercata.cata:
            return
        texteXSD = self.readercata.cata.JdC.dumpXsd(withAbstractElt, withUnitAsAttribute)
        return texteXSD

    # ---------------------#
    def dumpStructure(self):
    # ---------------------#
        texteStructure = self.readercata.cata.JdC.dumpStructure()
        return texteStructure

    # ----------------------------#
    def dumpGitStringFormat(self):
    # ----------------------------#
        texteGitStringFormat = self.readercata.cata.JdC.dumpGitStringFormat()
        return texteGitStringFormat

    # ------------------------------------#
    def ajoutVersionCataDsJDC(self, texte):
    # ------------------------------------#
        # if not hasattr(self.readercata.cata[0],'VERSION_CATALOGUE'): return txt
        if not hasattr(self.readercata.cata, "VERSION_CATALOGUE"):
            return texte
        ligneVersion = (
            "#VERSION_CATALOGUE:"
            + self.readercata.cata.VERSION_CATALOGUE
            + ":FIN VERSION_CATALOGUE\n"
        )
        texte = texte + ligneVersion
        return texte

    # --------------------------------------#
    def verifieVersionCataDuJDC(self, texte):
    # --------------------------------------#
        memeVersion = False
        indexDeb = texte.find("#VERSION_CATALOGUE:")
        indexFin = texte.find(":FIN VERSION_CATALOGUE")
        if indexDeb < 0:
            self.versionCataDuJDC = "sans"
            textJDC = texte
        else:
            self.versionCataDuJDC = texte[indexDeb + 19 : indexFin]
            textJDC = texte[0:indexDeb] + texte[indexFin + 23 : -1]

        self.versionCata = "sans"
        if hasattr(self.readercata.cata, "VERSION_CATALOGUE"):
            self.versionCata = self.readercata.cata.VERSION_CATALOGUE

        if self.versionCata == self.versionCataDuJDC:
            memeVersion = True
        return memeVersion, textJDC

    # -------------------------------#
    def traduitCatalogue(self, texte):
    # -------------------------------#
        nomTraducteur = ( "traduit" + self.readercata.code + self.versionCataDuJDC + "To" + self.versionCata)
        sys.path.append( os.path.abspath( os.path.join( os.path.dirname(__file__), "..","Traducteur")))
        try:
            traducteur = __import__(nomTraducteur)
            monTraducteur = traducteur.MonTraducteur(texte)
            nouveauTexte = monTraducteur.traduit()
            return nouveauTexte
        except:
            return texte

    # ------------------#
    def insertInDB(self):
    # -------------------#
        debug = True
        if debug:
            print("insertInDB ", self.jdc, self.readercata.cata)
        texte = self.jdc.prepareInsertInDB()
        if debug:
            print(texte)

    # -------------------------------------------------#
    def dumpDBSchema(self, nomDataBaseACreer=None):
    # -------------------------------------------------#
        texteDBSchema = self.readercata.cata.JdC.dumpDBSchema(nomDataBaseACreer)
        return texteDBSchema

    # -----------------------------#
    def getEtapesByName(self, name):
    # -----------------------------#
        if not self.jdc : return (1, 'pas de jdc')
        return self.jdc.getEtapesByName(name)

    # --------------------------------------------------------#
    def updateSDName(self, cId, externEditorId, nodeId, sdnom) :
    # --------------------------------------------------------#
        if self.appliEficas.dictChannelType[cId] ==  'Web':
           return self.webExtension.updateSDName(cId, externEditorId, nodeId, sdnom)

    # --------------------------------------------------------#
    def changeValue(self, cId, externEditorId, nodeId, value) :
    # --------------------------------------------------------#
        if self.appliEficas.dictChannelType[cId] ==  'Web':
           return self.webExtension.changeValue(cId, externEditorId, nodeId, value)

    # --------------------------------------------------------#
    def changeValue(self, cId, externEditorId, nodeId, value) :
    # --------------------------------------------------------#
        if self.appliEficas.dictChannelType[cId] ==  'Web':
           return self.webExtension.changeValue(cId, externEditorId, nodeId, value)

    # -------------------------------------------------#
    def removeNode (self, cId, externEditorId, nodeId) :
    # -------------------------------------------------#
        if self.appliEficas.dictChannelType[cId] ==  'Web':
           return self.webExtension.removeNode(cId, externEditorId, nodeId)

    # ---------------------------------------------------------------#
    def appendChild(self,cId, externEditorId, nodeId, name, pos=None):
    #----------------------------------------------------------------#
        if self.appliEficas.dictChannelType[cId] ==  'Web':
           return self.webExtension.appendChild(cId, externEditorId, nodeId, name, pos)

    # -------------------------#
    def deleteEtape(self, etape):
    # --------------------------#
    # inutilise pour l instant
    # a ajouter dans l API
        self.jdc.suppEntite(etape)

   #-------------------------------------- Fonctions utilisees par VP ------- a Revoir
   # il faut les trier : celles qui change le cata et les autres
   # et les remettre avec les bons objets

    # ----------------------------------------------#
    def deleteMC(self, etape, MCFils, listeAvant=()):
    # ----------------------------------------------#
        # dans le JDC
        # etape est l objet et listeAvant est 
        # une liste de nom d objet (string)
        # ne fonctionne pas si il y a des MCFACTs multiples
        ouChercher = etape
        for mot in listeAvant:
            ouChercher = ouChercher.getChild(mot, restreint="oui")
        monMC = ouChercher.getChild(MCFils, restreint="oui")
        if monMC != None: ouChercher.suppentite(monMC)
        ouChercher.state = "changed"
        ouChercher.isvalid()

    # --------------------------------------------------------#
    def ajoutMC(self, etape, MCFils, valeurs, listeAvant=()):
    # --------------------------------------------------------#
        # dans le JDC
        # etape est l objet et listeAvant est 
        # une liste de nom d objet (string)
        # ne fonctionne pas si il y a des MCFACTs multiples
        debug = False
        if debug: print("ajoutMC", etape, MCFils, valeurs, listeAvant)
        ouChercher = etape
        if debug: print(ouChercher)
        for mot in listeAvant:
            ouChercher = ouChercher.getChild(mot, restreint="oui")
        monMC = ouChercher.getChild(MCFils, restreint="oui")
        if monMC == None:
            monMC = ouChercher.addEntite(MCFils)
        monMC.valeur = valeurs
        monMC.val = valeurs
        monMC.state = "changed"
        monMC.isvalid()
        return 1

    # --------------------------------------------------------------------#
    def ajoutMCinMCFactUnique(self, etape, MCFils, valeurs, listeAvant=()):
    # Attention si +sieursMCFACT
    # --------------------------------------------------------------------#
        # dans le JDC
        debug = False
        if debug: print("ajoutMC", etape, MCFils, valeurs, listeAvant)
        ouChercher = etape
        if debug: print(ouChercher)
        for mot in listeAvant:
            ouChercher = ouChercher.getChild(mot, restreint="oui")
        # Attention si +sieursMCFACT
        ouChercher = ouChercher[0]
        if debug: print(ouChercher)
        monMC = ouChercher.getChild(MCFils, restreint="oui")
        if monMC == None: monMC = ouChercher.addEntite(MCFils)
        monMC.valeur = valeurs
        monMC.val = valeurs
        monMC.state = "changed"
        monMC.isValid()
        return 1

    # -------------------------------------------------#
    def ajoutMCFact(self, etape, MCFils, listeAvant=()):
    # -------------------------------------------------#
        # dans le JDC
        ouChercher = etape
        for mot in listeAvant:
            ouChercher = ouChercher.getChild(mot, restreint="oui")
        monMC = etape.getChild(ouChercher, restreint="oui")
        if monMC == None:
            monMC = ouChercher.addEntite(MCFils)
        monMC.isvalid()

    # ---------------------------------------------------------#
    def setValeurMCSimpInEtape(self, etape, listeAvant, valeur):
    # ---------------------------------------------------------#
        # pour VP
        monObj = etape
        for mot in listeAvant:
            monObj = monObj.getChild(mot, restreint="oui")
            if monObj == None:
                return False
        if monObj == None:
            return False
        if monObj.valeur != valeur:
            # PNPN le setValeur fait des bugs --> pourquoi
            # monObj.setValeur(valeur)
            monObj.valeur = valeur
            monObj.isValid()
        return True

    # -------------------------------------------------#
    def getValeur(self, nomEtape, MCFils, listeAvant=()):
    # -------------------------------------------------#
        # dans le JDC
        debug = 0
        ouChercher = None
        for e in self.jdc.etapes:
            if e.nom == nomEtape:
                ouChercher = e
                break
        if debug: print("etape trouvee", ouChercher)
        if ouChercher == None: return None
        for mot in listeAvant:
            ouChercher = ouChercher.getChild(mot, restreint="oui")
            if debug: print(mot, ouChercher)
            if ouChercher == None: return None
        monMC = ouChercher.getChild(MCFils, restreint="oui")
        if debug: print("monMC", monMC)
        if monMC == None: return None
        return monMC.valeur

    # -------------------------------------------------#
    def getMCDsEtape(self, etape, MCFils, listeAvant=()):
    # -------------------------------------------------#
        # dans le JDC
        if etape == None: return None
        ouChercher = etape
        debug = 0
        for mot in listeAvant:
            ouChercher = ouChercher.getChild(mot, restreint="oui")
            if debug: print(mot, ouChercher)
            if ouChercher == None: return None
        monMC = ouChercher.getChild(MCFils, restreint="oui")
        if debug: print("monMC", monMC)
        return monMC

    # -----------------------------------------------------------#
    def setValeur(self, nomEtape, MCFils, valeur, listeAvant=()):
    # --------------------------------------------------------#
        # dans le JDC
        ouChercher = None
        for e in self.jdc.etapes:
            if e.nom == nomEtape:
                ouChercher = e
                break
        if ouChercher == None:
            return None
        for mot in listeAvant:
            ouChercher = ouChercher.getChild(mot, restreint="oui")
            # print (mot, ouChercher)
            if ouChercher == None:
                return None
        monMC = ouChercher.getChild(MCFils, restreint="oui")
        monMC.set_valeur(valeur)
        monMC.isvalid()

    # -----------------------------------------------------------#
    def changeIntoMC(self, etape, MCFils, valeurs, listeAvant=()):
    # -----------------------------------------------------------#
        # dans le JDC
        ouChercher = etape
        if isinstance(etape, str):
            ouChercher = None
            for e in self.jdc.etapes:
                if e.nom == etape:
                    ouChercher = e
                    break
        if ouChercher == None:
            return

        for mot in listeAvant:
            ouChercher = ouChercher.getChild(mot, restreint="oui")
            if ouChercher == None:
                return
        monMC = ouChercher.getChild(MCFils, restreint="oui")
        if monMC == None:
            monMC = ouChercher.addEntite(MCFils)

        monMC.definition.into = valeurs
        from Accas.processing.P_VALIDATOR import IntoProtocol

        monMC.definition.intoProto = IntoProtocol( "into",
            into=monMC.definition.into,
            val_min=monMC.definition.val_min,
            val_max=monMC.definition.val_max,
        )
        monMC.state = "changed"
        monMC.isvalid()

    # -------------------------------------------------------------------------#
    def reCalculeValiditeMCApresChgtInto(self, nomEtape, MCFils, listeAvant=()):
    # -------------------------------------------------------------------------#
        # dans le JDC
        for e in self.jdc.etapes:
            if e.nom == nomEtape:
                ouChercher = e
                break

        for mot in listeAvant:
            try:
                ouChercher = ouChercher.getChild(mot, restreint="oui")
            # Le mot clef n est pas la
            except: return 0
        try:
            monMC = ouChercher.getChild(MCFils, restreint="oui")
        # Le mot clef n est pas la
        except: return 0
        if monMC == None: return 0

        if hasattr(monMC.definition, "into"):
            if type(monMC.definition.into) == types.FunctionType:
                maListeDeValeur = monMC.definition.into()
            else:
                maListeDeValeur = monMC.definition.into
        else:
            return 0

        monMC.state = "changed"
        return 1


    # -----------------------------------------------------#
    def changeDefautDefMC(self, nomEtape, listeMC, valeurs):
    # -----------------------------------------------------#
        # dans le MDD

        # if isinstance (etape, str):
        #  for e in self.jdc.etapes:
        #    if e.nom == etape : etape=e; break
        # if etape == None : return
        definitionEtape = getattr(self.jdc.cata, nomEtape)
        # definitionEtape=getattr(self.jdc.cata[0],nomEtape)
        ouChercher = definitionEtape
        if len(listeMC) > 1:
            for mc in listeMC[0:-1]:
                mcfact = ouChercher.entites[mc]
                ouChercher = mcfact

        mcAccas = ouChercher.entites[listeMC[-1]]
        mcAccas.defaut = valeurs
        return 1

    # ------------------------------------------------------------------------#
    def changeIntoDefMC(self, etape, listeMC, valeurs, rechercheParNom=False):
    # ------------------------------------------------------------------------#
        # dans le MDD
        # definitionEtape=getattr(self.jdc.cata[0],nomEtape)
        # definitionEtape=getattr(self.jdc.cata,nomEtape)
        print("changeIntoDefMC ", etape, listeMC, valeurs)
        # ouChercher = getattr(self.jdc.cata, etape.nom)
        if rechercheParNom:
            ouChercher = getattr(self.jdc.cata, etape)
        else:
            ouChercher = getattr(self.jdc.cata, etape.nom)

        # if len(listeMC) > 1 :
        #   for mc in listeMC[0:-1]:
        #     mcfact=ouChercher.entites[mc]
        #     ouChercher=mcfact
        # mcAccas=ouChercher.entites[listeMC[-1]]

        for mc in listeMC:
            mcAccas = ouChercher.entites[mc]
            ouChercher = mcAccas
            if ouChercher == None:
                return 0

        if hasattr(mcAccas, "into"):
            oldValeurs = mcAccas.into
        else:
            oldValeurs = None

        if oldValeurs == valeurs:
            return 1
        mcAccas.into = valeurs
        from Accas.processing.P_VALIDATOR import IntoProtocol

        mcAccas.intoProto = IntoProtocol(
            "into", into=valeurs, val_min=mcAccas.val_min, val_max=mcAccas.val_max
        )
        return 1

    # ------------------------------------------------------#
    def deleteDefinitionMC(self, etape, listeAvant, nomDuMC):
    # ------------------------------------------------------#
        # dans le MDD
        # print 'in deleteDefinitionMC', etape,listeAvant,nomDuMC
        if isinstance(etape, str):
            for e in self.jdc.etapes:
                if e.nom == etape:
                    etape = e
                    break
        if etape == None:
            return
        # definitionEtape=getattr(self.jdc.cata[0],etape)
        definitionEtape = getattr(self.jdc.cata, etape)
        ouChercher = definitionEtape
        for k in listeAvant:
            ouChercher = ouChercher.entites[k]
        MCADetruire = ouChercher.entites[nomDuMC]
        ouChercher.ordreMC.remove(nomDuMC)
        print("remove de ", nomDuMC)
        del ouChercher.entites[nomDuMC]
        del self.dicoNouveauxMC[nomDuMC]

    # ---------------------------------------------------------------------#
    def ajoutDefinitionMC(self, nomEtape, listeAvant, nomDuMC, typ, **args):
    # ---------------------------------------------------------------------#
        # dans le MDD
        # definitionEtape=getattr(self.jdc.cata[0],nomEtape)
        definitionEtape = getattr(self.jdc.cata, nomEtape)
        ouChercher = definitionEtape
        for k in listeAvant:
            ouChercher = ouChercher.entites[k]
        from Accas import A_SIMP

        Nouveau = A_SIMP.SIMP(typ, **args)
        Nouveau.pere = ouChercher
        Nouveau.nom = nomDuMC
        # Nouveau.ordreMC=[]
        ouChercher.entites[nomDuMC] = Nouveau
        ouChercher.ordreMC.append(nomDuMC)
        # print ('ajout de ', nomDuMC)
        # traceback.print_stack()
        # ajout CIST sauvegarde
        if nomDuMC in self.dicoNouveauxMC:
            del self.dicoNouveauxMC[nomDuMC]
        self.dicoNouveauxMC[nomDuMC] = (
            "ajoutDefinitionMC", nomEtape, listeAvant, nomDuMC, typ, args,)

    # -----------------------------------------------------------------------------#
    def ajoutDefinitionMCFact(self, nomEtape, listeAvant, nomDuMC, listeMC, **args):
    # -----------------------------------------------------------------------------#
        # dans le MDD
        print("ajoutDefinitionMCFact", nomDuMC)
        # definitionEtape=getattr(self.jdc.cata[0],nomEtape)
        definitionEtape = getattr(self.jdc.cata, nomEtape)
        ouChercher = definitionEtape
        for k in listeAvant:
            ouChercher = ouChercher.entites[k]
        from Accas import A_SIMP

        for mc in listeMC:
            nomMC = mc[0]
            typMC = mc[1]
            argsMC = mc[2]
            nouveauMC = A_SIMP.SIMP(typMC, **argsMC)
            nouveauMC.nom = nomMC
            args[nomMC] = nouveauMC
        from Accas import A_FACT

        nouveauFact = A_FACT.FACT(**args)
        nouveauFact.pere = ouChercher
        nouveauFact.nom = nomDuMC
        from Accas.catalog.analyse_ordre_catalogue import traiteEntite

        traiteEntite(nouveauFact, [])
        ouChercher.entites[nomDuMC] = nouveauFact
        ouChercher.ordreMC.append(nomDuMC)
        self.dicoNouveauxFact[nomDuMC] = ( "ajoutDefinitionMC", nomEtape, listeAvant, nomDuMC, listeMC, args,)
        # print self.dicoNouveauxMC


    # ---------------------------------------------------------#
    def changeIntoMCandSet(self, etape, listeMC, into, valeurs):
    # ---------------------------------------------------------#
        # dans le MDD et le JDC

        self.changeIntoDefMC(etape, listeMC, into)

        if isinstance(etape, str):
            for e in self.jdc.etapes:
                if e.nom == etape:
                    etape = e
                    break
        if etape == None:
            return

        ouChercher = etape
        for mot in listeMC[:-1]:
            ouChercher = ouChercher.getChild(mot, restreint="oui")
            if ouChercher == None:
                return
        MCFils = listeMC[-1]
        monMC = ouChercher.getChild(MCFils, restreint="oui")
        if monMC == None:
            monMC = etape.addEntite(MCFils)

        monMC.definition.into = into
        monMC.valeur = valeurs
        monMC.val = valeurs
        monMC.state = "changed"
        monMC.isvalid()





if __name__ == "__main__":
    print("a faire")

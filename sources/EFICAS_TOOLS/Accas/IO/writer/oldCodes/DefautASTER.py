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
Ce module contient les variables
par defaut pour Aster
"""

from OpenturnsSTD import STDGenerateur
from OpenturnsXML import XMLGenerateur

#====================================================
# Preparation du fichier STD
#====================================================
# C.1. Parties du texte en dur dans le fichier STD
#-------------------------------------------------

DecalSTD     = "  "
DecalSTDsaut = "\n  "

TexteSTDFIN ="\n\nexcept : \n"
TexteSTDFIN += DecalSTD + "error_message = sys.exc_type\n"
TexteSTDFIN += "\nif error_message is not None :\n"
TexteSTDFIN += DecalSTD + "texte  = \"\\n=================================================\""
TexteSTDFIN += DecalSTD + "texte += \"\\nMessage d'erreur : \" + str(error_message)"
TexteSTDFIN += DecalSTD + "texte += \"\\n=================================================\\n\""
TexteSTDFIN += DecalSTD + "print (texte)"
TexteSTDFIN += DecalSTD + "\nsys.exit(error_message)\n"

# C.2. Definition de composants dans le fichier STD
#--------------------------------------------------

NomFunction              = "myFunction"
NomPhysicalStartingPoint = "myPhysicalStartingPoint"
NomCollection            = "myCollection"
NomCopule                = "myCopula"
NomDistribution          = "myDistribution"
NomRandomVector_in       = "myRandomVector_in"
NomRandomVector_out      = "myRandomVector_out"
NomEvent                 = "myEvent"
NomMethod                = "myMethod"
NomAlgo                  = "myAlgo"
NomRoot                  = "myRoot"
NomSampling              = "mySampling"
NomSolverSD              = "mySolver"
NomResu                  = "myResu"

class Defaut :
# Cette classe ajoute les parametres par defaut propres au Solver Aster
# Elle va d abord enrichir le dictionnaire DictMCVal avec des valeurs par defaut
# C est la methode enrichitMCVal
# Elle va ensuite enrichir les variables
# C est la methode enrichitListeVariables
  
  def __init__(self, parent) :
       self.parent=parent
       self.enrichitMCVal()
       self.enrichitListeVariables()


  def enrichitMCVal(self) :
  #=====================
      # InformationSolver : nom du wrapper, type de fichiers d'echange, etc
      #----------------------------------------------------------------------
      # Ajoute les informations sur le wrapper 
      #        nom du wrapper, type de fichiers d'echange, etc.
       dico = { "WrapperPath" : "Code_Aster.so",
                 "FunctionName" : "Code_Aster",
                 "WrapCouplingMode" : "fork",
                 "State" : "shared",
                 "InDataTransfer" : "files",
                 "OutDataTransfer" : "files",
              }

       self.parent.ajouteDictMCVal(dico)

      #InformationSolverFile : parametres par defaut pour les fichiers d'echange
      #--------------------------------------------------------------------------

       liste = []
       dicoIn = { "Id" : "file_in", "Type" : "in", "Name" : "StdIn", "Path" : "commandes_aster" }
       liste.append(dicoIn)
       dicoOut = { "Id" : "file_out", "Type" : "out", "Name" : "StdOut", "Path" : "resultats_aster", }
       liste.append(dicoOut)
       dicoFile={"exchange_file" : liste} 
       self.parent.ajouteDictMCVal(dicoFile)

# D.2. InformationSolverCommande : arguments, etc
#-------------------------------------------------------------------------
# InformationSolverCommande est un dictionnaire indexe par le nom du solveur externe appele.
# InformationSolverCommande[solveur] est lui-meme un dictionnaire qui contient les parametres
# supplementaires pour la commande.
# Des parametres sont donnes sous forme de tuple : (ok/nok, "mot-cle") ou (ok/nok, "mot-cle", valeur)
# . On ajoute seulement si ok
# . Avec (ok/nok, "mot-cle"), on ajoute en arguments les couples ("mot-cle", nom_du_parametre)
# . Avec (ok/nok, "mot-cle", valeur), on ajoute en arguments les couples ("mot-cle", valeur)


#       dico = { "file_out"    : (1, "-fic_de_aster_vers_ot"),
#                "variable_in" : (1, "-variable") }
#       self.parent.InformationSolverCommande["Code_Aster"] = dico          


  def enrichitListeVariables(self) :
       # parametres par defaut pour chaque variable
       #--------------------------------------------

       dico_in = { "Regexp" : '"^" , "Name", "(.*)= *[0-9eE.+-]+([)]?;?)$"',
                   "Format" : '"Name", "\\1=%20.13G\\2"'
                 }
       dico_out = { "Regexp" : '"(.*)"' }
       self.parent.ajouteInfoVariables(dico_in,dico_out)          

class MonSTDGenerateur(STDGenerateur) :

  def CreeResu (self) :
  #------------------
    '''
    Le resultat :
    . Donnees :
      . l'algorithme choisi.
    . Resultats :
      . Ecriture des odres d'impression.
    '''
    if self.DictMCVal.has_key("Analysis"):
       self.Analysis = str(self.DictMCVal["Analysis"])
    else :
       self.Analysis = None
    self.fic_resu_OpenTURNS = "fic_resu_OpenTURNS_glop"
    Algorithm = str (self.DictMCVal["Algorithm"])
    texte  = "\n\n# Le resultat\n"
    texte += DecalSTDsaut + NomResu + " = " + NomAlgo +  ".getResult()"
    texte += DecalSTDsaut + "###" + "print ( " + NomResu+")"
    texte += DecalSTDsaut + "text_resu  = \"Resultats\\n=======\\n\""

#   Particularites des algorithmes de fiabilite

    if self.Analysis in ( "Reliability", ) :
      texte += DecalSTDsaut + "aux = " + NomResu + ".getIsStandardPointOriginInFailureSpace()"
      texte += DecalSTDsaut + "if aux :"
      texte += DecalSTDsaut + DecalSTD + "texte_bis = \"est\""
      texte += DecalSTDsaut + "else :"
      texte += DecalSTDsaut + DecalSTD + "texte_bis = \"n\'est pas\""
      texte += DecalSTDsaut + "text_resu += \"\\nLe point initial \" + texte_bis + \" dans l\'espace de defaillance.\""
      l_aux = [ ("Probabilite de defaillance", "EventProbability") ]
      l_aux.append ( ("Indice de confiance generalise", "GeneralisedReliabilityIndex") )
      l_aux.append ( ("Indice de confiance de Hasofer", "HasoferReliabilityIndex") )
      for t_aux in l_aux :
        texte += DecalSTDsaut + "text_resu += \"\\n" + t_aux[0] + " = \" + str(" \
                              + NomResu + ".get" + t_aux[1] + "())"
      l_aux = []
      l_aux.append("StandardSpaceDesignPoint")
      l_aux.append("PhysicalSpaceDesignPoint")
      l_aux.append("ImportanceFactors")
      texte += DecalSTDsaut + "l_aux_var = []"
      for DictVariable in self.ListeVariables :
        if ( DictVariable["Type"] == "in" ) :
          texte += DecalSTDsaut + "l_aux_var.append(\"" + DictVariable["Name"] + "\")"
      texte += DecalSTDsaut + "l_aux = []"
      for type_resu in l_aux :
        texte += DecalSTDsaut + "l_aux.append(" + NomResu + ".get" + type_resu + "())"
      texte += DecalSTDsaut + "for resu in l_aux :"       
      texte += DecalSTDsaut + DecalSTD + "if not resu.isEmpty() :"       
      texte += DecalSTDsaut + DecalSTD + DecalSTD + "text_resu += \"\\n\" + resu.getName() + \" :\""       
      texte += DecalSTDsaut + DecalSTD + DecalSTD + "size = resu.getDimension()"       
      texte += DecalSTDsaut + DecalSTD + DecalSTD + "l_aux_1 = resu.getCollection()"       
      texte += DecalSTDsaut + DecalSTD + DecalSTD + "for iaux in range(size) :"       
      texte += DecalSTDsaut + DecalSTD + DecalSTD + DecalSTD + "text_resu += \"\\n. \" + l_aux_var[iaux] + \" : \" + str(l_aux_1[iaux])"       

#   Particularites des algorithmes de simulation

    if self.Analysis in ( "Simulation", ) :
      l_aux = [ ("Probabilite de defaillance", "ProbabilityEstimate") ]
      l_aux.append ( ("Variance", "VarianceEstimate") )
      l_aux.append ( ("Nombre d\'iterations", "OuterSampling") )
      for t_aux in l_aux :
        texte += DecalSTDsaut + "text_resu += \"\\n" + t_aux[0] + " = \" + str(" \
                              + NomResu + ".get" + t_aux[1] + "())"
      texte += DecalSTDsaut + "text_resu += \"\\nNombre d'evaluations de l'etat limite = \" + str(" \
                               + NomResu + ".getOuterSampling()*" + NomResu + ".getBlockSize())"
      if self.DictMCVal.has_key("ConfidenceIntervalProbability") :
        aux = self.DictMCVal["ConfidenceIntervalProbability"]
        texte += DecalSTDsaut + "proba = " + NomResu + ".getProbabilityEstimate()"
        texte += DecalSTDsaut + "t_aux = "
        if ( type(aux) is type(0.) ) :
          texte += "(" + str(aux) + ")"
          t_aux = [ str(aux) ]
        else :
          texte += str(aux)
        texte += DecalSTDsaut + "for val in t_aux :"
        texte += DecalSTDsaut + DecalSTD + "length = " + NomResu + ".getConfidenceLength(val)"
        texte += DecalSTDsaut + DecalSTD + "vinf = str( proba - 0.5*length )"
        texte += DecalSTDsaut + DecalSTD + "vsup = str( proba + 0.5*length )"
        texte += DecalSTDsaut + DecalSTD + "text_resu += \"\\nIntervalle de confiance a \" + str(val) + \" = [ \" "
        texte += "+ vinf + \" , \" + vsup + \" ]\""

#   Generalites

    texte += DecalSTDsaut + "d_aux = {}"
    texte += DecalSTDsaut + "d_aux[\"E\"] = ( \"de la fonction\", " + NomFunction + ".getEvaluationCallsNumber() )"
    texte += DecalSTDsaut + "d_aux[\"G\"] = ( \"du gradient\", " + NomFunction + ".getGradientCallsNumber() )"
    texte += DecalSTDsaut + "d_aux[\"H\"] = ( \"du hessien\", " + NomFunction + ".getHessianCallsNumber() )"
    texte += DecalSTDsaut + "for cle in d_aux.keys() :"
    texte += DecalSTDsaut + DecalSTD + "if d_aux[cle][1] > 0 :"
    texte += DecalSTDsaut + DecalSTD + DecalSTD + "text_resu += \"\\nNombre d\'appels au solveur pour le calcul \"" \
                                + " + d_aux[cle][0] + \" = \" + str(d_aux[cle][1])"

#   Impression

    texte += DecalSTDsaut + "print ( \"\\n\", text_resu, \" ) \\n\""
    texte += DecalSTDsaut + "file_resu = open(\"" + self.fic_resu_OpenTURNS + "\", \"w\")"
    texte += DecalSTDsaut + "file_resu.write(text_resu)"
    texte += DecalSTDsaut + "file_resu.close()"
    texte += DecalSTDsaut + "probability = " + NomResu + ".getEventProbability()"

    return texte


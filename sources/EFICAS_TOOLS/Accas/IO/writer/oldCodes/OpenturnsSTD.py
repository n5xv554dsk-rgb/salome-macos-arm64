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
Ce module contient le generateur Etude pour Openturns
"""

from Accas.extensions.eficas_translation import tr

__revision__ = "V1.0"

defaultSTD = """#! /usr/bin/env python

class StudyFileGenerationError:
  def __init__ (self, st):
    self.st = st
  def __str__(self):
    return "'%s'" % self.st

raise StudyFileGenerationError, "The study file was not generated. Check analysis type."
"""

headerSTD = """#! /usr/bin/env python

# Chargement du module systeme
import sys
sys.path[:0]=['%s']

# Chargement du module math
import math

# Chargement du module Open TURNS
from openturns import *

# Fonction verifiant si un echantillon contient des valeurs non valides (NaN)
def contain_nan_values(sample):
  for point in sample:
    for val in point:
      if math.isnan(val):
        return True
  return False

results = {}

"""

viewerSTD = """
from openturns.viewer import View

# Fonction de test du serveur X
import subprocess
xserver_available = None
def is_xserver_available():
  global xserver_available
  if xserver_available is None:
    xserver_available = True
    try:
      subprocess.check_call('python -c "from matplotlib import pyplot;pyplot.figure()" >/dev/null 2>&1', shell = True)
    except:
      xserver_available = False
  return xserver_available

"""

footerSTD = """

# Flush des messages en attente
Log.Flush()

# Terminaison du fichier
#sys.exit( 0 )
"""

#=============================================
#  La classe de creation du fichier STD
#=============================================

class STDGenerateur :

  '''
  Generation du fichier python
  '''
  def __init__ (self, appli, DictMCVal, ListeVariablesIn, ListeVariablesOut, DictLois ) :
    self.DictMCVal = DictMCVal
    self.ListeVariablesIn = ListeVariablesIn
    self.ListeVariablesOut = ListeVariablesOut
    self.DictLois = DictLois
    #print "DictMCVal=", DictMCVal
    print "ListeVariablesIn= %s", ListeVariablesIn

# A REPRENDRE DEPUIS ICI !!
    print "ListeVariablesOut= %s", ListeVariablesOut
    #print "DictLois=", DictLois
    self.texteSTD = defaultSTD
    self.OpenTURNS_path = appli.maConfiguration.OpenTURNS_path

    # Ce dictionnaire fait la correspondance entre le mot lu dans le dictionnaire des mots-clefs et la methode a appeler
    self.traitement = {
      "Min/Max" :
      ( "MinMax",
        { "Experiment Plane" : "ExperimentPlane",
          "Random Sampling" : "MinMaxRandomSampling",
          },
        ),
      "Central Uncertainty" :
      ( "CentralUncertainty",
        { "Taylor Variance Decomposition" : "TaylorVarianceDecomposition",
          "Random Sampling" : "CentralUncertaintyRandomSampling",
         },
        ),
      "Threshold Exceedence" :
      ( "ThresholdExceedence",
        { "Simulation" : "Simulation",
          "FORM_SORM" : "Analytical",
          "MonteCarlo" : "MonteCarlo",
          "LHS" : "LHS",
          "ImportanceSampling" : "ImportanceSampling",
          "FirstOrder" : "FORM",
          "SecondOrder" : "SORM",
          "Cobyla" : "Cobyla",
          "AbdoRackwitz" : "AbdoRackwitz",
          },
        ),
      }

    # Ce dictionnaire liste le nom des variables utilisees dans le script
    # La clef est le nom attendu par les methodes, la valeur est le nom produit dans le fichier de sortie
    # Le fait de passer par un dictionnaire permet de controler que les variables existent et sont correctement nommees
    # meme si clef == valeur
    self.variable = {
      "n" : "n",
      "p" : "p",
      "wrapper" : "wrapper",
      "wrapperdata" : "wrapperdata",
      "frameworkdata" : "frameworkdata",
      "framework" : "framework",
      "studyid" : "studyid",
      "studycase" : "studycase",
      "componentname" : "componentname",
      "model" : "model",
      "scaledVector" : "scaledVector",
      "translationVector" : "translationVector",
      "levels" : "levels",
      "myCenteredReductedGrid" : "myCenteredReductedGrid",
      "myExperimentPlane" : "myExperimentPlane",
      "inputSample" : "inputSample",
      "outputSample" : "outputSample",
      "minValue" : 'results["minValue"]',
      "maxValue" : 'results["maxValue"]',
      "flags" : "flags",
      "inSize" : "inSize",
      "distribution" : "distribution",
      "marginal" : "marginal",
      "collection" : "collection",
      "copula" : "copula",
      "correlation" : "correlation",
      "R" : "R",
      "vars" : "vars",
      "description" : "description",
      "inputRandomVector" : "inputRandomVector",
      "outputRandomVector" : "outputRandomVector",
      "myQuadraticCumul" : "myQuadraticCumul",
      "meanFirstOrder" : 'results["meanFirstOrder"]',
      "meanSecondOrder" : 'results["meanSecondOrder"]',
      "standardDeviationFirstOrder" : 'results["standardDeviationFirstOrder"]',
      "importanceFactors" : 'results["importanceFactors"]',
      "importanceFactorsGraph" : "importanceFactorsGraph",
      "importanceFactorsDrawing" : "importanceFactorsDrawing",
      "empiricalMean" : 'results["empiricalMean"]',
      "empiricalStandardDeviation" : 'results["empiricalStandardDeviation"]',
      "empiricalQuantile" : 'results["empiricalQuantile"]',
      "alpha" : "alpha",
      "beta" : "beta",
      "PCCcoefficient" : 'results["PCCcoefficient"]',
      "PRCCcoefficient" : 'results["PRCCcoefficient"]',
      "SRCcoefficient" : 'results["SRCcoefficient"]',
      "SRRCcoefficient" : 'results["SRRCcoefficient"]',
      "kernel" : "kernel",
      "kernelSmoothedDist" : "kernelSmoothedDist",
      "kernelSmoothedPDFDrawing" : "kernelSmoothedPDFDrawing",
      "kernelSmoothedGraph" : "kernelSmoothedGraph",
      "meanVector" : "meanVector",
      "importanceDensity" : "importanceDensity",
      "myEvent" : "myEvent",
      "myAlgo" : "myAlgo",
      "myResult" : "myResult",
      "probability" : 'results["probability"]',
      "standardDeviation" : 'results["standardDeviation"]',
      "level" : "level",
      "length" : "length",
      "coefficientOfVariation" : 'results["coefficientOfVariation"]',
      "convergenceGraph" : "convergenceGraph",
      "convergenceDrawing" : "convergenceDrawing",
      "simulationNumbers" : 'results["simulationNumbers"]',
      "myOptimizer" : "myOptimizer",
      "specificParameters" : "specificParameters",
      "startingPoint" : "startingPoint",
      "hasoferReliabilityIndex" : 'results["hasoferReliabilityIndex"]',
      "standardSpaceDesignPoint" : 'results["standardSpaceDesignPoint"]',
      "physicalSpaceDesignPoint" : 'results["physicalSpaceDesignPoint"]',
      "eventProbabilitySensitivity" : 'results["eventProbabilitySensitivity"]',
      "hasoferReliabilityIndexSensitivity" : 'results["hasoferReliabilityIndexSensitivity"]',
      "eventProbabilitySensitivityGraph" : "eventProbabilitySensitivityGraph",
      "eventProbabilitySensitivityDrawing" : "eventProbabilitySensitivityDrawing",
      "hasoferReliabilityIndexSensitivityGraph" : "hasoferReliabilityIndexSensitivityGraph",
      "hasoferReliabilityIndexSensitivityDrawing" : "hasoferReliabilityIndexSensitivityDrawing",
      "modelEvaluationCalls" : 'results["modelEvaluationCalls"]',
      "modelGradientCalls" : 'results["modelGradientCalls"]',
      "modelHessianCalls" : 'results["modelHessianCalls"]',
      "tvedtApproximation" : 'results["tvedtApproximation"]',
      "hohenBichlerApproximation" : 'results["hohenBichlerApproximation"]',
      "breitungApproximation" : 'results["breitungApproximation"]',
      }

    # Ce dictionnaire fait la correspondance entre le mot-clef du catalogue et le flag de la bibliotheque
    self.logFlags = {
      "DebugMessages"   : "Log.DBG",
      "WrapperMessages" : "Log.WRAPPER",
      "UserMessages"    : "Log.USER",
      "InfoMessages"    : "Log.INFO",
      "WarningMessages" : "Log.WARN",
      "ErrorMessages"   : "Log.ERROR",
      }
    
  def CreeSTD (self) :
    '''
    Pilotage de la creation du fichier python
    '''
    TypeAnalyse = None
    if ( self.DictMCVal.has_key( 'Type' ) ):
      TypeAnalyse =  self.DictMCVal[ 'Type' ]

    traitement = None
    subDict = {}
    if ( self.traitement.has_key( TypeAnalyse ) ):
      (traitement, subDict) =  self.traitement[ TypeAnalyse ]

    if ( traitement is not None ):
      self.texteSTD = apply( STDGenerateur.__dict__[ traitement ], (self, subDict) )
    
    return self.texteSTD

  def Header (self) :
    '''
    Imprime l entete commun a tous les fichiers
    '''
    txt  = headerSTD % self.OpenTURNS_path
    txt += viewerSTD
    txt += "# Definit le niveau d'affichage de la log\n"
    txt += "%s = Log.NONE\n" % self.variable["flags"]
    for flag in self.logFlags.keys():
      if ( self.DictMCVal.has_key( flag ) ):
        val =  self.DictMCVal[ flag ]
        op = "-"
        if val == 'yes' :
          op = "+"
        txt += "%s = %s %s %s\n" % (self.variable["flags"], self.variable["flags"], op, self.logFlags[ flag ])
    txt += "Log.Show( %s )\n" % self.variable["flags"]
    txt += "\n"
    return txt

  def Footer (self) :
    '''
    Imprime le pied de page commun a tous les fichiers
    '''
    return footerSTD

  def MinMax (self, subDict):
    '''
    Produit le fichier study correspondant a une analyse Min/Max
    '''
    txt  = self.Header()
    txt += self.Model()
    
    Methode = None
    if ( self.DictMCVal.has_key( 'Method' ) ):
      Methode =  self.DictMCVal[ 'Method' ]

    traitement = None
    if ( subDict.has_key( Methode ) ):
      traitement =  subDict[ Methode ]

    if ( traitement is not None ):
      txt += apply( STDGenerateur.__dict__[ traitement ], (self,) )

    txt += self.MinMaxResult()
    
    txt += self.Footer()
    return txt

  def Model (self):
    '''
    Importe le modele physique
    '''
    if ( self.DictMCVal.has_key( 'FileName' ) ):
      name =  self.DictMCVal[ 'FileName' ]
      
    txt  = "# Charge le modele physique\n"
    txt += "%s = WrapperFile( '%s' )\n" % (self.variable["wrapper"], name)
    txt += "%s = %s.getWrapperData()\n" % (self.variable["wrapperdata"], self.variable["wrapper"])

    txt += "# Ces lignes sont utiles pour le fonctionnement du script sous Salome\n"
    txt += "if globals().has_key('%s'):\n" % self.variable["framework"]
    txt += "  %s = %s.getFrameworkData()\n" % (self.variable["frameworkdata"], self.variable["wrapperdata"])
    txt += "  %s.studyid_ = %s['%s']\n"  % (self.variable["frameworkdata"], self.variable["framework"], self.variable["studyid"])
    txt += "  %s.studycase_ = %s['%s']\n"  % (self.variable["frameworkdata"], self.variable["framework"], self.variable["studycase"])
    txt += "  %s.componentname_ = %s['%s']\n"  % (self.variable["frameworkdata"], self.variable["framework"], self.variable["componentname"])
    txt += "  %s.setFrameworkData( %s )\n" % (self.variable["wrapperdata"], self.variable["frameworkdata"])
    txt += "  %s.setWrapperData( %s )\n" % (self.variable["wrapper"], self.variable["wrapperdata"])
    txt += "# Fin des lignes pour Salome\n"
    
    txt += "%s = NumericalMathFunction( %s )\n" % (self.variable["model"], self.variable["wrapper"],)
    txt += "%s = %s.getInputDimension()\n" % (self.variable["n"], self.variable["model"])
    txt += "\n"
    return txt

  def ExperimentPlane (self):
    '''
    Etude par plan d experience
    '''
    txt  = "# Etude par plan d'experience\n"
    txt += self.Levels()
    txt += self.CenteredReductedGrid()
    txt += self.ScaledVector()
    txt += self.TranslationVector()
    txt += "%s = %s\n" % (self.variable["inputSample"], self.variable["myExperimentPlane"])
    txt += "\n"
    txt += "# Etude 'Min/Max'\n"
    txt += "# Calcul\n"
    txt += "%s = %s( %s )\n" % (self.variable["outputSample"], self.variable["model"], self.variable["inputSample"])
    txt += "if contain_nan_values( %s ):\n" % (self.variable["outputSample"])
    txt += "  raise Exception('Some computations failed')\n"
    txt += "\n"
    return txt

  def MinMaxRandomSampling (self):
    '''
    Etude par echantillonage aleatoire
    '''
    size = 0
    if ( self.DictMCVal.has_key( 'SimulationsNumber' ) ):
      size =  self.DictMCVal[ 'SimulationsNumber' ]

    txt  = "# Etude par echantillonage aleatoire\n"
    txt += self.InputDistribution()
    txt += self.InputRandomVector()
    txt += "\n"
    txt += "# Etude 'Min/Max'\n"
    txt += "# Calcul\n"
    txt += "%s = %d\n" % (self.variable["inSize"], size)
    txt += "%s = RandomVector( %s, %s )\n" % (self.variable["outputRandomVector"], self.variable["model"], self.variable["inputRandomVector"])
    txt += "%s = %s.getSample( %s )\n" % (self.variable["outputSample"], self.variable["outputRandomVector"], self.variable["inSize"])
    txt += "if contain_nan_values( %s ):\n" % (self.variable["outputSample"])
    txt += "  raise Exception('Some computations failed')\n"
    return txt

  def InputDistribution (self):
    '''
    Cree la loi jointe des variables d entree
    '''
    txt  = "# Definit la loi jointe des variables d'entree\n"
    txt += "%s = DistributionCollection( %s )\n" % (self.variable["collection"], self.variable["n"])
    txt += "%s = Description( %s )\n" % (self.variable["description"], self.variable["n"])
    txt += "\n"

    dictVariables = {}
    for variable in self.ListeVariablesIn:
      nomVar = variable['ModelVariable'].getName()
      dictVariables[ nomVar ] = variable['Distribution']

    i = 0
    sortedVarNames = dictVariables.keys()
    sortedVarNames.sort()
    for variable in sortedVarNames:
      conceptloi = dictVariables[ variable ]
      loi = self.DictLois[ conceptloi ]
      if loi.has_key( 'Kind' ):
        marginale = "%s_%d" % (self.variable["marginal"], i)
        txt += "# Definit la loi marginale de la composante %d\n" % i
        txt += "%s = %s\n" % (marginale, apply( STDGenerateur.__dict__[ loi[ 'Kind' ] ], (self, loi) ))
        txt += "%s.setName( '%s' )\n" % (marginale, conceptloi.getName())
        txt += "%s[ %d ] = '%s'\n" % (self.variable["description"], i, variable)
        txt += "%s[ %d ] = Distribution( %s )\n" % (self.variable["collection"], i, marginale)
        txt += "\n"
        i += 1

    txt += self.Copula()

    txt += "# Definit la loi jointe\n"
    txt += "%s = ComposedDistribution( %s, Copula( %s ) )\n" % (self.variable["distribution"], self.variable["collection"], self.variable["copula"])
    txt += "%s.setDescription( %s )\n" % (self.variable["distribution"], self.variable["description"])
    txt += "\n"
    return txt

  def Copula (self):
    '''
    Cree la copule de la loi jointe
    '''
    txt  = "# Definit la copule de la loi jointe\n"

    if ( not self.DictMCVal.has_key( 'Copula' ) ):
      self.DictMCVal[ 'Copula' ] = 'Independent'

    if ( self.DictMCVal[ 'Copula' ] in ( 'Independent', ) ):
      txt += "%s = IndependentCopula( %s )\n" % (self.variable["copula"], self.variable["n"])
    elif ( self.DictMCVal[ 'Copula' ] in ( 'Normal', ) ):
      varList   = self.DictMCVal[ 'CorrelationMatrix' ][0]
      dimension = len(varList)
      txt += "%s = {}\n" % self.variable["correlation"]
      for i in range( dimension ):
        txt += "%s['%s'] = {}\n" % (self.variable["correlation"], varList[i])
        for j in range ( dimension ):
          txt += "%s['%s']['%s'] = %g\n" % (self.variable["correlation"], varList[i], varList[j], self.DictMCVal[ 'CorrelationMatrix' ][i+1][j])
      txt += "%s = getCorrelationMatrixFromMap( %s.getVariableList(), %s )\n" % (self.variable["R"], self.variable["wrapperdata"], self.variable["correlation"])
      txt += "%s = NormalCopula( %s )\n" % (self.variable["copula"], self.variable["R"])

    txt += "\n"
    return txt

  def InputRandomVector (self):
    '''
    Cree le vector aleatoire d entree
    '''
    txt  = "# Definit le vecteur aleatoire d'entree\n"
    txt += "%s = RandomVector( %s )\n" % (self.variable["inputRandomVector"], self.variable["distribution"])
    txt += "\n"
    return txt

  def OutputRandomVector (self):
    '''
    Cree le vector aleatoire de sortie
    '''
    nomVar = "output"
    for variable in self.ListeVariablesOut:
      nomVar = variable['ModelVariable'].getName()

    txt  = "# Definit le vecteur aleatoire de sortie\n"
    txt += "%s = RandomVector( %s, %s )\n" % (self.variable["outputRandomVector"], self.variable["model"], self.variable["inputRandomVector"])
    txt += "%s.setName( '%s' )\n" % (self.variable["outputRandomVector"], nomVar)
    txt += "\n"
    return txt

  def ScaledVector (self):
    '''
    Definit les coefficients multiplicateurs par composante du vecteur
    '''
    dimension = 0
    if ( self.DictMCVal.has_key( 'UnitsPerDimension' ) ):
      unitsPerDimension =  self.DictMCVal[ 'UnitsPerDimension' ]
      dimension = len( unitsPerDimension )
    
    txt  = "# Definit les facteurs d'echelle dans chaque direction\n"
    txt += "%s = NumericalPoint( %s )\n" % (self.variable["scaledVector"], self.variable["n"])
    for i in range(dimension):
      txt += "%s[%d] = %g\n" % (self.variable["scaledVector"], i, unitsPerDimension[i])
    txt += "%s.scale( %s )\n" % (self.variable["myExperimentPlane"], self.variable["scaledVector"])
    txt += "\n"
    return txt

  def TranslationVector (self):
    '''
    Definit le vecteur de translation
    '''
    dimension = 0
    if ( self.DictMCVal.has_key( 'Center' ) ):
      center =  self.DictMCVal[ 'Center' ]
      dimension = len( center )
    
    txt  = "# Definit le vecteur de translation\n"
    txt += "%s = NumericalPoint( %s )\n" % (self.variable["translationVector"], self.variable["n"])
    for i in range(dimension):
      txt += "%s[%d] = %g\n" % (self.variable["translationVector"], i, center[i])
    txt += "%s.translate( %s )\n" % (self.variable["myExperimentPlane"], self.variable["translationVector"])
    txt += "\n"
    return txt

  def Levels (self):
    '''
    Definit les niveaux du plan d experience
    '''
    dimension = 0
    if ( self.DictMCVal.has_key( 'Levels' ) ):
      levels =  self.DictMCVal[ 'Levels' ]
      dimension = len( levels )
    
    txt  = "# Definit les niveaux de la structure de grille\n"
    txt += "%s = NumericalPoint( %d )\n" % (self.variable["levels"], dimension)
    for i in range(dimension):
      txt += "%s[%d] = %g\n" % (self.variable["levels"], i, levels[i])
    txt += "\n"
    return txt

  def CenteredReductedGrid (self):
    '''
    Definit la grille reduite du plan d experience
    '''
    plane = None
    if ( self.DictMCVal.has_key( 'ExperimentPlane' ) ):
      plane =  self.DictMCVal[ 'ExperimentPlane' ]

    txt  = "# Cree le plan d'experience centre reduit\n"
    txt += "%s = %s(%s, %s)\n" % (self.variable["myCenteredReductedGrid"], plane, self.variable["n"], self.variable["levels"])
    txt += "%s = %s.generate()\n" % (self.variable["myExperimentPlane"], self.variable["myCenteredReductedGrid"])
    txt += "\n"
    return txt

  def MinMaxResult (self):
    '''
    Produit les resultats de l etude
    '''
    txt  = "# Resultats\n"
    txt += "%s = %s.getMin()\n" % (self.variable["minValue"], self.variable["outputSample"])
    txt += "print '%s = ', %s\n" % ("minValue", self.variable["minValue"])
    txt += "\n"
    txt += "%s = %s.getMax()\n" % (self.variable["maxValue"], self.variable["outputSample"])
    txt += "print '%s = ', %s\n" % ("maxValue", self.variable["maxValue"])
    txt += "\n"
    return txt

  def CentralUncertainty (self, subDict):
    '''
    Produit le fichier study correspondant a une analyse d incertitude en valeur centrale
    '''
    txt  = self.Header()
    txt += self.Model()
    txt += self.InputDistribution()
    txt += self.InputRandomVector()
    txt += self.OutputRandomVector()
   
    Methode = None
    if ( self.DictMCVal.has_key( 'Method' ) ):
      Methode =  self.DictMCVal[ 'Method' ]

    traitement = None
    if ( subDict.has_key( Methode ) ):
      traitement =  subDict[ Methode ]

    if ( traitement is not None ):
      txt += "# Etude 'Central Uncertainty'\n"
      txt += apply( STDGenerateur.__dict__[ traitement ], (self,) )

    txt += self.Footer()
    return txt


  def TaylorVarianceDecomposition (self):
    '''
    Etude par decomposition de Taylor
    '''
    txt  = "# Cumul quadratique (decomposition de Taylor)\n"
    txt += "%s = QuadraticCumul( %s )\n" % (self.variable["myQuadraticCumul"], self.variable["outputRandomVector"])
    txt += "\n"
    txt += "# Resultats\n"
    
    if ( self.DictMCVal.has_key( 'MeanFirstOrder' ) ):
      if ( self.DictMCVal[ 'MeanFirstOrder' ] == "yes" ):
        txt += "%s = %s.getMeanFirstOrder()\n" % (self.variable["meanFirstOrder"], self.variable["myQuadraticCumul"])
        txt += "print '%s = ', %s\n" % ("mean First Order", self.variable["meanFirstOrder"])
        txt += "\n"
       
    if ( self.DictMCVal.has_key( 'MeanSecondOrder' ) ):
      if ( self.DictMCVal[ 'MeanSecondOrder' ] == "yes" ):
        txt += "%s = %s.getMeanSecondOrder()\n" % (self.variable["meanSecondOrder"], self.variable["myQuadraticCumul"])
        txt += "print '%s = ', %s\n" % ("mean Second Order", self.variable["meanSecondOrder"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'StandardDeviationFirstOrder' ) ):
      if ( self.DictMCVal[ 'StandardDeviationFirstOrder' ] == "yes" ):
        txt += "%s = %s.getCovariance()\n" % (self.variable["standardDeviationFirstOrder"], self.variable["myQuadraticCumul"])
        txt += "dim = %s.getDimension()\n" % self.variable["standardDeviationFirstOrder"]
        txt += "for i in range( dim ):\n"
        txt += "  %s[ i, i ] = math.sqrt( %s[ i, i ] )\n" % (self.variable["standardDeviationFirstOrder"], self.variable["standardDeviationFirstOrder"])
        txt += "  print '%s = ', %s[ i, i ]\n" % ("standard Deviation First Order", self.variable["standardDeviationFirstOrder"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'ImportanceFactor' ) ):
      if ( self.DictMCVal[ 'ImportanceFactor' ] == "yes" ):
        txt += "%s = %s.getImportanceFactors()\n" % (self.variable["importanceFactors"], self.variable["myQuadraticCumul"])
        txt += "for i in range(%s.getDimension()):\n" % self.variable["importanceFactors"]
        txt += "  print %s.getDescription()[i], ':', %s[i]*100., '%%'\n" % (self.variable["distribution"], self.variable["importanceFactors"])
        txt += "\n"
        txt += "%s = %s.drawImportanceFactors()\n" % (self.variable["importanceFactorsGraph"], self.variable["myQuadraticCumul"])
        txt += "%s = '%s'\n" % (self.variable["importanceFactorsDrawing"], self.DictMCVal[ 'ImportanceFactorDrawingFilename' ])
        txt += "%s.draw( %s )\n" % (self.variable["importanceFactorsGraph"], self.variable["importanceFactorsDrawing"])
        txt += "#if is_xserver_available():\n"
        txt += "#  view = View(%s)\n" % self.variable["importanceFactorsGraph"]
        txt += "#  view.show(block=True)\n"
        txt += "#else:\n"
        txt += "#  print 'Warning: cannot display image', %s.getBitmap(), '(probably because no X server was found)'\n" % self.variable["importanceFactorsGraph"]
        txt += "print 'bitmap =', %s.getBitmap()\n"  % self.variable["importanceFactorsGraph"]
        txt += "print 'postscript =', %s.getPostscript()\n"  % self.variable["importanceFactorsGraph"]
        txt += "\n"
        
    txt += "\n"
    return txt

  def CentralUncertaintyRandomSampling (self):
    '''
    Etude par echantillonage aleatoire
    '''
    size = 0
    if ( self.DictMCVal.has_key( 'SimulationsNumber' ) ):
      size =  self.DictMCVal[ 'SimulationsNumber' ]

    txt  = "# Echantillonnage aleatoire de la variable de sortie\n"
    txt += "%s = %d\n" % (self.variable["inSize"], size)
    txt += "%s = %s.getSample( %s )\n" % (self.variable["inputSample"], self.variable["inputRandomVector"], self.variable["inSize"])
    txt += "%s = %s( %s )\n" % (self.variable["outputSample"], self.variable["model"], self.variable["inputSample"])
    txt += "if contain_nan_values( %s ):\n" % (self.variable["outputSample"])
    txt += "  raise Exception('Some computations failed')\n"
    txt += "\n"

    if ( self.DictMCVal.has_key( 'EmpiricalMean' ) ):
      if ( self.DictMCVal[ 'EmpiricalMean' ] == "yes" ):
        txt += "%s = %s.computeMean()\n" % (self.variable["empiricalMean"], self.variable["outputSample"])
        txt += "print '%s =', %s[0]\n" % ("empirical Mean", self.variable["empiricalMean"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'EmpiricalStandardDeviation' ) ):
      if ( self.DictMCVal[ 'EmpiricalStandardDeviation' ] == "yes" ):
        txt += "%s = %s.computeCovariance()\n" % (self.variable["empiricalStandardDeviation"], self.variable["outputSample"])
        txt += "dim = %s.getDimension()\n" % self.variable["empiricalStandardDeviation"]
        txt += "for i in range( dim ):\n"
        txt += "  %s[ i, i ] = math.sqrt( %s[ i, i ] )\n" % (self.variable["empiricalStandardDeviation"], self.variable["empiricalStandardDeviation"])
        txt += "  print '%s = ', %s[ i, i ]\n" % ("empirical Standard Deviation", self.variable["empiricalStandardDeviation"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'EmpiricalQuantile_Order' ) ):
      ordre = self.DictMCVal[ 'EmpiricalQuantile_Order' ]
      txt += "%s = %s.computeQuantile( %s )\n" % (self.variable["empiricalQuantile"], self.variable["outputSample"], ordre)
      txt += "print '%s ( %s ) =', %s\n" % ("empirical Quantile", ordre, self.variable["empiricalQuantile"])
      txt += "\n"
   
    if ( self.DictMCVal.has_key( 'CorrelationAnalysis' ) ):
      if ( self.DictMCVal[ 'CorrelationAnalysis' ] == "yes" ):
        txt += "if ( %s.getDimension() == 1 ):\n" % self.variable["outputSample"]
        txt += "  %s = CorrelationAnalysis.PCC( %s, %s )\n" % (self.variable["PCCcoefficient"], self.variable["inputSample"], self.variable["outputSample"])
        txt += "  print 'PCC Coefficients:'\n"
        txt += "  for i in range( %s ):\n" % self.variable["n"]
        txt += "    print %s.getDescription()[i], ':', %s[i]\n" % (self.variable["distribution"], self.variable["PCCcoefficient"])
        txt += "\n"
        txt += "  %s = CorrelationAnalysis.PRCC( %s, %s )\n" % (self.variable["PRCCcoefficient"], self.variable["inputSample"], self.variable["outputSample"])
        txt += "  print 'PRCC Coefficients:'\n"
        txt += "  for i in range( %s ):\n" % self.variable["n"]
        txt += "    print %s.getDescription()[i], ':', %s[i]\n" % (self.variable["distribution"], self.variable["PRCCcoefficient"])
        txt += "\n"
        txt += "  %s = CorrelationAnalysis.SRC( %s, %s )\n" % (self.variable["SRCcoefficient"], self.variable["inputSample"], self.variable["outputSample"])
        txt += "  print 'SRC Coefficients:'\n"
        txt += "  for i in range( %s ):\n" % self.variable["n"]
        txt += "    print %s.getDescription()[i], ':', %s[i]\n" % (self.variable["distribution"], self.variable["SRCcoefficient"])
        txt += "\n"
        txt += "  %s = CorrelationAnalysis.SRRC( %s, %s )\n" % (self.variable["SRRCcoefficient"], self.variable["inputSample"], self.variable["outputSample"])
        txt += "  print 'SRRC Coefficients:'\n"
        txt += "  for i in range( %s ):\n" % self.variable["n"]
        txt += "    print %s.getDescription()[i], ':', %s[i]\n" % (self.variable["distribution"], self.variable["SRRCcoefficient"])
        txt += "\n"
   
    if ( self.DictMCVal.has_key( 'KernelSmoothing' ) ):
      if ( self.DictMCVal[ 'KernelSmoothing' ] == "yes" ):
        txt += "# Kernel Smoohing\n"
        txt += "%s = KernelSmoothing()\n" % self.variable["kernel"]
        txt += "if ( %s.getDimension() == 1 ):\n" % self.variable["outputSample"]
        txt += "  %s.setName( 'Output' )\n" % self.variable["outputSample"]
        txt += "  %s = %s.build( %s, 'TRUE')\n" % (self.variable["kernelSmoothedDist"], self.variable["kernel"], self.variable["outputSample"])
        txt += "  %s = %s.drawPDF()\n" % (self.variable["kernelSmoothedGraph"], self.variable["kernelSmoothedDist"])
        txt += "  %s = '%s'\n" % (self.variable["kernelSmoothedPDFDrawing"], self.DictMCVal[ 'KernelSmoothingDrawingFilename' ])
        txt += "  %s.draw( %s )\n" % (self.variable["kernelSmoothedGraph"], self.variable["kernelSmoothedPDFDrawing"])
        txt += "  #if is_xserver_available():\n"
        txt += "  #  view = View(%s)\n" % self.variable["kernelSmoothedGraph"]
        txt += "  #  view.show(block=True)\n"
        txt += "  #else:\n"
        txt += "  #  print 'Warning: cannot display image', %s.getBitmap(), '(probably because no X server was found)'\n" % self.variable["kernelSmoothedGraph"]
        txt += "  print 'bitmap =', %s.getBitmap()\n"  % self.variable["kernelSmoothedGraph"]
        txt += "  print 'postscript =', %s.getPostscript()\n"  % self.variable["kernelSmoothedGraph"]
        txt += "\n"
   
    return txt

  def ThresholdExceedence (self, subDict):
    '''
    Produit le fichier study correspondant a une analyse de depassement de seuil
    '''
    txt  = self.Header()
    txt += "# Etude 'Threshold Exceedence'\n"

    txt += self.RandomGenerator()
    txt += self.Model()
    txt += self.InputDistribution()
    txt += self.InputRandomVector()
    txt += self.OutputRandomVector()
    txt += self.Event()
   
    Methode = None
    if ( self.DictMCVal.has_key( 'Method' ) ):
      Methode =  self.DictMCVal[ 'Method' ]

    traitement = None
    if ( subDict.has_key( Methode ) ):
      traitement =  subDict[ Methode ]

    if ( traitement is not None ):
      txt += apply( STDGenerateur.__dict__[ traitement ], (self, subDict) )

    txt += self.Footer()
    return txt

  def Simulation (self, subDict):
    '''
    Methodes de simulation
    '''
    Algorithme = None
    if ( self.DictMCVal.has_key( 'Algorithm' ) ):
      Algorithme =  self.DictMCVal[ 'Algorithm' ]

    traitement = None
    if ( subDict.has_key( Algorithme ) ):
      traitement =  subDict[ Algorithme ]

    if ( traitement is not None ):
      txt = apply( STDGenerateur.__dict__[ traitement ], (self,) )

    maxOuterSampling = None
    if ( self.DictMCVal.has_key( 'MaximumOuterSampling' ) ):
      maxOuterSampling = self.DictMCVal[ 'MaximumOuterSampling' ]
      txt += "%s.setMaximumOuterSampling( %s )\n" % (self.variable["myAlgo"], maxOuterSampling)

    blockSize = None
    if ( self.DictMCVal.has_key( 'BlockSize' ) ):
      blockSize = self.DictMCVal[ 'BlockSize' ]
      txt += "%s.setBlockSize( %s )\n" % (self.variable["myAlgo"], blockSize)

    maxCoefficientOfVariation = None
    if ( self.DictMCVal.has_key( 'MaximumCoefficientOfVariation' ) ):
      maxCoefficientOfVariation = self.DictMCVal[ 'MaximumCoefficientOfVariation' ]
      txt += "%s.setMaximumCoefficientOfVariation( %s )\n" % (self.variable["myAlgo"], maxCoefficientOfVariation)

    txt += "%s.run()\n"  % self.variable["myAlgo"]
    txt += "\n"
    txt += "# Resultats de la simulation\n"
    txt += "%s = %s.getResult()\n"  % (self.variable["myResult"], self.variable["myAlgo"])
    txt += "\n"

    if ( self.DictMCVal.has_key( 'Probability' ) ):
      if ( self.DictMCVal[ 'Probability' ] == "yes" ):
        txt += "%s = %s.getProbabilityEstimate()\n" % (self.variable["probability"], self.variable["myResult"])
        txt += "print '%s =', %s\n" % ("probability", self.variable["probability"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'StandardDeviation' ) ):
      if ( self.DictMCVal[ 'StandardDeviation' ] == "yes" ):
        txt += "%s = math.sqrt( %s.getProbabilityEstimate() )\n" % (self.variable["standardDeviation"], self.variable["myResult"])
        txt += "print '%s =', %s\n" % ("standard Deviation", self.variable["standardDeviation"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'ConfidenceInterval' ) and self.DictMCVal.has_key( 'Probability' ) ):
      if ( ( self.DictMCVal[ 'ConfidenceInterval' ] == "yes" ) and ( self.DictMCVal[ 'Probability' ] == "yes" ) ):
        level = self.DictMCVal[ 'Level' ]
        txt += "%s = %s.getConfidenceLength( %s )\n" % (self.variable["length"], self.variable["myResult"], level)
        txt += "print 'confidence interval at %s = [', %s-0.5*%s, ',', %s+0.5*%s, ']'\n" % (level, self.variable["probability"], self.variable["length"], self.variable["probability"], self.variable["length"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'VariationCoefficient' ) ):
      if ( self.DictMCVal[ 'VariationCoefficient' ] == "yes" ):
        txt += "%s = %s.getCoefficientOfVariation()\n" % (self.variable["coefficientOfVariation"], self.variable["myResult"])
        txt += "print '%s =', %s\n" % ("coefficient of Variation", self.variable["coefficientOfVariation"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'SimulationsNumber' ) ):
      if ( self.DictMCVal[ 'SimulationsNumber' ] == "yes" ):
        txt += "%s = %s.getOuterSampling()\n" % (self.variable["simulationNumbers"], self.variable["myResult"])
        txt += "print '%s =', %s\n" % ("simulation Numbers", self.variable["simulationNumbers"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'ConvergenceGraph' ) and self.DictMCVal.has_key( 'ConfidenceInterval' ) ):
      if ( ( self.DictMCVal[ 'ConvergenceGraph' ] == "yes" ) and ( self.DictMCVal[ 'ConfidenceInterval' ] == "yes" ) ):
        txt += "%s = %s\n" % (self.variable["alpha"], self.DictMCVal[ 'Level' ])
        txt += "%s = %s.drawProbabilityConvergence( %s )\n" % (self.variable["convergenceGraph"], self.variable["myAlgo"], self.variable["alpha"])
        txt += "%s = '%s'\n" % (self.variable["convergenceDrawing"], self.DictMCVal[ 'ConvergenceDrawingFilename' ])
        txt += "%s.draw( %s )\n" % (self.variable["convergenceGraph"], self.variable["convergenceDrawing"])
        txt += "#if is_xserver_available():\n"
        txt += "#  view = View(%s)\n" % self.variable["convergenceGraph"]
        txt += "#  view.show(block=True)\n"
        txt += "#else:\n"
        txt += "#  print 'Warning: cannot display image', %s.getBitmap(), '(probably because no X server was found)'\n" % self.variable["convergenceGraph"]
        txt += "\n"

    return txt

  def Analytical (self, subDict):
    '''
    Methodes analytiques
    '''
    txt = ""
    
    OptimizationAlgo = None
    if ( self.DictMCVal.has_key( 'OptimizationAlgorithm' ) ):
      OptimizationAlgo =  self.DictMCVal[ 'OptimizationAlgorithm' ]

    traitement = None
    if ( subDict.has_key( OptimizationAlgo ) ):
      traitement =  subDict[ OptimizationAlgo ]

    if ( traitement is not None ):
      txt += apply( STDGenerateur.__dict__[ traitement ], (self,) )

    txt += self.OptimizerSettings()
    txt += self.PhysicalStartingPoint()

    Approximation = None
    if ( self.DictMCVal.has_key( 'Approximation' ) ):
      Approximation =  self.DictMCVal[ 'Approximation' ]

    traitement = None
    if ( subDict.has_key( Approximation ) ):
      traitement =  subDict[ Approximation ]

    if ( traitement is not None ):
      txt += apply( STDGenerateur.__dict__[ traitement ], (self,) )

    txt += self.RunAlgorithm()
    txt += self.AnalyticalResult()

    return txt

  def OptimizerSettings (self):
    '''
    Parametrage de l optimiseur
    '''
    txt = ""
    
    simulationNumbers = None
    if ( self.DictMCVal.has_key( 'MaximumIterationsNumber' ) ):
      simulationNumbers = self.DictMCVal[ 'MaximumIterationsNumber' ]
      txt += "%s.setMaximumIterationsNumber( %s )\n" % (self.variable["myOptimizer"], simulationNumbers)

    absoluteError = None
    if ( self.DictMCVal.has_key( 'MaximumAbsoluteError' ) ):
      absoluteError = self.DictMCVal[ 'MaximumAbsoluteError' ]
      txt += "%s.setMaximumAbsoluteError( %s )\n" % (self.variable["myOptimizer"], absoluteError)

    relativeError = None
    if ( self.DictMCVal.has_key( 'MaximumRelativeError' ) ):
      relativeError = self.DictMCVal[ 'MaximumRelativeError' ]
      txt += "%s.setMaximumRelativeError( %s )\n" % (self.variable["myOptimizer"], relativeError)

    residualError = None
    if ( self.DictMCVal.has_key( 'MaximumResidualError' ) ):
      residualError = self.DictMCVal[ 'MaximumResidualError' ]
      txt += "%s.setMaximumResidualError( %s )\n" % (self.variable["myOptimizer"], residualError)

    constraintError = None
    if ( self.DictMCVal.has_key( 'MaximumConstraintError' ) ):
      constraintError = self.DictMCVal[ 'MaximumConstraintError' ]
      txt += "%s.setMaximumConstraintError( %s )\n" % (self.variable["myOptimizer"], constraintError)

    txt += "\n"

    return txt

  def PhysicalStartingPoint (self):
    '''
    Point physique de depart
    '''
    txt  = "# Point physique de depart\n"

    if ( self.DictMCVal.has_key( 'PhysicalStartingPoint' ) ):
      point = self.DictMCVal[ 'PhysicalStartingPoint' ]
      dimension = len( point )
      txt += "%s = NumericalPoint( %d )\n" % (self.variable["startingPoint"], dimension)
      for i in range( dimension ):
        txt += "%s[ %d ] = %g\n" % (self.variable["startingPoint"], i, point[i])
    else:
      txt += "%s = %s.getMean()\n" % (self.variable["startingPoint"], self.variable["inputRandomVector"])
      
    txt += "\n"

    return txt

  def AnalyticalResult (self):
    '''
    Resultat des methodes analytiques
    '''
    txt  = "# Resultat des methodes analytiques\n"
    txt += "%s = %s.getResult()\n" % (self.variable["myResult"], self.variable["myAlgo"])
    
    if ( self.DictMCVal.has_key( 'Probability' ) ):
      if ( self.DictMCVal[ 'Probability' ] == "yes" ):
        txt += "%s = %s.getEventProbability()\n" % (self.variable["probability"], self.variable["myResult"])
        txt += "print '%s =', %s\n" % (self.variable["probability"], self.variable["probability"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'HasoferReliabilityIndex' ) ):
      if ( self.DictMCVal[ 'HasoferReliabilityIndex' ] == "yes" ):
        txt += "%s = %s.getHasoferReliabilityIndex()\n" % (self.variable["hasoferReliabilityIndex"], self.variable["myResult"])
        txt += "print '%s =', %s\n" % ("hasofer Reliability Index", self.variable["hasoferReliabilityIndex"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'DesignPoint' ) ):
      if ( self.DictMCVal[ 'DesignPoint' ] == "yes" ):
        txt += "%s = %s.getStandardSpaceDesignPoint()\n" % (self.variable["standardSpaceDesignPoint"], self.variable["myResult"])
        txt += "print '%s =', %s\n" % ("standard Space Design Point", self.variable["standardSpaceDesignPoint"])
        txt += "%s = %s.getPhysicalSpaceDesignPoint()\n" % (self.variable["physicalSpaceDesignPoint"], self.variable["myResult"])
        txt += "print '%s =', %s\n" % ("physical Space Design Point", self.variable["physicalSpaceDesignPoint"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'ImportanceFactor' ) ):
      if ( self.DictMCVal[ 'ImportanceFactor' ] == "yes" ):
        txt += "print 'Importance Factors:'\n"
        txt += "%s = %s.getImportanceFactors()\n" % (self.variable["importanceFactors"], self.variable["myResult"])
        txt += "for i in range(%s.getDimension()):\n" % self.variable["importanceFactors"]
        txt += "  print %s.getDescription()[i], ':', %s[i]*100., '%%'\n" % (self.variable["distribution"], self.variable["importanceFactors"])
        txt += "\n"
        txt += "%s = %s.drawImportanceFactors()\n" % (self.variable["importanceFactorsGraph"], self.variable["myResult"])
        txt += "%s = '%s'\n" % (self.variable["importanceFactorsDrawing"], self.DictMCVal[ 'ImportanceFactorDrawingFilename' ])
        txt += "%s.draw( %s )\n" % (self.variable["importanceFactorsGraph"], self.variable["importanceFactorsDrawing"])
        txt += "#if is_xserver_available():\n"
        txt += "#  view = View(%s)\n" % self.variable["importanceFactorsGraph"]
        txt += "#  view.show(block=True)\n"
        txt += "#else:\n"
        txt += "#  print 'Warning: cannot display image', %s.getBitmap(), '(probably because no X server was found)'\n" % self.variable["importanceFactorsGraph"]
        txt += "print 'bitmap =', %s.getBitmap()\n"  % self.variable["importanceFactorsGraph"]
        txt += "print 'postscript =', %s.getPostscript()\n"  % self.variable["importanceFactorsGraph"]
        txt += "\n"

    if ( self.DictMCVal.has_key( 'FORMEventProbabilitySensitivity' ) ):
      if ( self.DictMCVal[ 'FORMEventProbabilitySensitivity' ] == "yes" ):
        txt += "%s = %s.getEventProbabilitySensitivity()\n" % (self.variable["eventProbabilitySensitivity"], self.variable["myResult"])
        txt += "print 'FORM Event Probability Sensitivity:'\n"
        txt += "for i in range( %s ):\n" % self.variable["n"]
        txt += "  print %s.getDescription()[i], ':'\n" % self.variable["distribution"]
        txt += "  for j in range( %s[i].getDimension() ):\n" % self.variable["eventProbabilitySensitivity"]
        txt += "    print '  ', %s[i].getDescription()[j], ':', %s[i][j]\n" % (self.variable["eventProbabilitySensitivity"], self.variable["eventProbabilitySensitivity"])
        txt += "\n"
        txt += "%s = %s.drawEventProbabilitySensitivity()[0]\n" % (self.variable["eventProbabilitySensitivityGraph"], self.variable["myResult"])
        txt += "%s = '%s'\n" % (self.variable["eventProbabilitySensitivityDrawing"], self.DictMCVal[ 'FORMEventProbabilitySensitivityDrawingFilename' ])
        txt += "%s.draw( %s )\n" % (self.variable["eventProbabilitySensitivityGraph"], self.variable["eventProbabilitySensitivityDrawing"])
        txt += "#if is_xserver_available():\n"
        txt += "#  view = View(%s)\n" % self.variable["eventProbabilitySensitivityGraph"]
        txt += "#  view.show(block=True)\n"
        txt += "#else:\n"
        txt += "#  print 'Warning: cannot display image', %s.getBitmap(), '(probably because no X server was found)'\n" % self.variable["eventProbabilitySensitivityGraph"]
        txt += "print 'bitmap =', %s.getBitmap()\n"  % self.variable["eventProbabilitySensitivityGraph"]
        txt += "print 'postscript =', %s.getPostscript()\n"  % self.variable["eventProbabilitySensitivityGraph"]
        txt += "\n"

    if ( self.DictMCVal.has_key( 'HasoferReliabilityIndexSensitivity' ) ):
      if ( self.DictMCVal[ 'HasoferReliabilityIndexSensitivity' ] == "yes" ):
        txt += "%s = %s.getHasoferReliabilityIndexSensitivity()\n" % (self.variable["hasoferReliabilityIndexSensitivity"], self.variable["myResult"])
        txt += "print 'Hasofer Reliability Index Sensitivity:'\n"
        txt += "for i in range( %s ):\n" % self.variable["n"]
        txt += "  print %s.getDescription()[i], ':'\n" % self.variable["distribution"]
        txt += "  for j in range( %s[i].getDimension() ):\n" % self.variable["hasoferReliabilityIndexSensitivity"]
        txt += "    print '  ', %s[i].getDescription()[j], ':', %s[i][j]\n" % (self.variable["hasoferReliabilityIndexSensitivity"], self.variable["hasoferReliabilityIndexSensitivity"])
        txt += "\n"
        txt += "%s = %s.drawHasoferReliabilityIndexSensitivity()[0]\n" % (self.variable["hasoferReliabilityIndexSensitivityGraph"], self.variable["myResult"])
        txt += "%s = '%s'\n" % (self.variable["hasoferReliabilityIndexSensitivityDrawing"], self.DictMCVal[ 'HasoferReliabilityIndexSensitivityDrawingFilename' ])
        txt += "%s.draw( %s )\n" % (self.variable["hasoferReliabilityIndexSensitivityGraph"], self.variable["hasoferReliabilityIndexSensitivityDrawing"])
        txt += "#if is_xserver_available():\n"
        txt += "#  view = View(%s)\n" % self.variable["hasoferReliabilityIndexSensitivityGraph"]
        txt += "#  view.show(block=True)\n"
        txt += "#else:\n"
        txt += "#  print 'Warning: cannot display image', %s.getBitmap(), '(probably because no X server was found)'\n" % self.variable["hasoferReliabilityIndexSensitivityGraph"]
        txt += "print 'bitmap =', %s.getBitmap()\n"  % self.variable["hasoferReliabilityIndexSensitivityGraph"]
        txt += "print 'postscript =', %s.getPostscript()\n"  % self.variable["hasoferReliabilityIndexSensitivityGraph"]
        txt += "\n"

    if ( self.DictMCVal.has_key( 'TvedtApproximation' ) ):
      if ( self.DictMCVal[ 'TvedtApproximation' ] == "yes" ):
        txt += "%s = %s.getEventProbabilityTvedt()\n" % (self.variable["tvedtApproximation"], self.variable["myResult"])
        txt += "print '%s =', %s\n" % ("Tvedt Approximation", self.variable["tvedtApproximation"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'HohenBichlerApproximation' ) ):
      if ( self.DictMCVal[ 'HohenBichlerApproximation' ] == "yes" ):
        txt += "%s = %s.getEventProbabilityHohenBichler()\n" % (self.variable["hohenBichlerApproximation"], self.variable["myResult"])
        txt += "print '%s =', %s\n" % ("HohenBichler Approximation", self.variable["tvedtApproximation"])
        txt += "\n"

    if ( self.DictMCVal.has_key( 'BreitungApproximation' ) ):
      if ( self.DictMCVal[ 'BreitungApproximation' ] == "yes" ):
        txt += "%s = %s.getEventProbabilityBreitung()\n" % (self.variable["breitungApproximation"], self.variable["myResult"])
        txt += "print '%s =', %s\n" % ("Breitung Approximation", self.variable["breitungApproximation"])
        txt += "\n"


    return txt

  def RandomGenerator (self):
    '''
    Generateur Aleatoire
    '''
    txt = ""
    
    seed = None
    if ( self.DictMCVal.has_key( 'RandomGeneratorSeed' ) ):
      seed = self.DictMCVal[ 'RandomGeneratorSeed' ]
      txt += "# Initialise le generateur aleatoire\n"
      txt += "RandomGenerator.SetSeed( %s )\n" % seed
      txt += "\n"
    
    return txt

  def Event (self):
    '''
    Definition de l evenement de defaillance
    '''
    operator = None
    if ( self.DictMCVal.has_key( 'ComparisonOperator' ) ):
      operator = self.DictMCVal[ 'ComparisonOperator' ]

    threshold = None
    if ( self.DictMCVal.has_key( 'Threshold' ) ):
      threshold = self.DictMCVal[ 'Threshold' ]
    
    txt  = "# Evenement de defaillance\n"
    txt += "%s = Event( %s, ComparisonOperator( %s() ), %s )\n" % (self.variable["myEvent"], self.variable["outputRandomVector"], operator, threshold)
    txt += "%s.setName( '%s' )\n" % (self.variable["myEvent"], "myEvent")
    txt += "\n"
    return txt
    
  def MonteCarlo (self):
    '''
    Methode de MonteCarlo
    '''
    txt  = "# Simulation par MonteCarlo\n"
    txt += "%s = MonteCarlo( %s )\n"  % (self.variable["myAlgo"], self.variable["myEvent"])
    txt += "\n"
   
    return txt

  def LHS (self):
    '''
    Methode LHS
    '''
    txt  = "# Simulation par LHS\n"
    txt += "%s = LHS( %s )\n"  % (self.variable["myAlgo"], self.variable["myEvent"])
    txt += "\n"
   
    return txt

  def ImportanceSampling (self):
    '''
    Methode de tirage d importance
    '''
    dimension = 0
    if ( self.DictMCVal.has_key( 'MeanVector' ) ):
      meanVector =  self.DictMCVal[ 'MeanVector' ]
      dimension = len( meanVector )
        
    txt  = "# Simulation par Tirage d'importance\n"
    txt += "# Densite d'importance\n"
    txt += "%s = NumericalPoint( %s )\n" % (self.variable["meanVector"], self.variable["n"])
    for i in range(dimension):
      txt += "%s[%d] = %g\n" % (self.variable["meanVector"], i, meanVector[i])
      
    txt += "%s = Normal( %s, CovarianceMatrix( IdentityMatrix( %s ) ) )\n" % (self.variable["importanceDensity"], self.variable["meanVector"], self.variable["n"])
    txt += "%s = ImportanceSampling( %s, Distribution( %s ) )\n"  % (self.variable["myAlgo"], self.variable["myEvent"], self.variable["importanceDensity"])
    txt += "\n"

    return txt

  def FORM (self):
    '''
    Methode FORM
    '''
    txt  = "# Algorithme FORM\n"
    txt += "%s = FORM ( NearestPointAlgorithm( %s ), %s, %s )\n"  % (self.variable["myAlgo"], self.variable["myOptimizer"], self.variable["myEvent"], self.variable["startingPoint"])
    txt += "\n"

    return txt

  def SORM (self):
    '''
    Methode SORM
    '''
    txt  = "# Algorithme SORM\n"
    txt += "%s = SORM ( NearestPointAlgorithm( %s ), %s, %s )\n"  % (self.variable["myAlgo"], self.variable["myOptimizer"], self.variable["myEvent"], self.variable["startingPoint"])
    txt += "\n"

    return txt

  def RunAlgorithm (self):
    '''
    Do the computation
    '''
    txt = ""
    if ( self.DictMCVal.has_key( 'FunctionCallsNumber' ) ):
      if ( self.DictMCVal[ 'FunctionCallsNumber' ] == "yes" ):
        txt += "%s = %s.getEvaluationCallsNumber()\n" % (self.variable["modelEvaluationCalls"], self.variable["model"])
        txt += "%s = %s.getGradientCallsNumber()\n" % (self.variable["modelGradientCalls"], self.variable["model"])
        txt += "%s = %s.getHessianCallsNumber()\n" % (self.variable["modelHessianCalls"], self.variable["model"])
        txt += "\n"

    txt += "# Perform the computation\n"
    txt += "%s.run()\n" % self.variable["myAlgo"]
    txt += "\n"
    

    if ( self.DictMCVal.has_key( 'FunctionCallsNumber' ) ):
      if ( self.DictMCVal[ 'FunctionCallsNumber' ] == "yes" ):
        txt += "%s = %s.getEvaluationCallsNumber() - %s\n" % (self.variable["modelEvaluationCalls"], self.variable["model"], self.variable["modelEvaluationCalls"])
        txt += "%s = %s.getGradientCallsNumber() - %s\n" % (self.variable["modelGradientCalls"], self.variable["model"], self.variable["modelGradientCalls"])
        txt += "%s = %s.getHessianCallsNumber() - %s\n" % (self.variable["modelHessianCalls"], self.variable["model"], self.variable["modelHessianCalls"])
        txt += "\n"
        txt += "print '%s =', %s\n" % ("model Evaluation Calls", self.variable["modelEvaluationCalls"])
        txt += "print '%s =', %s\n" % ("model Gradient Calls", self.variable["modelGradientCalls"])
        txt += "print '%s =', %s\n" % ("model Hessian Calls", self.variable["modelHessianCalls"])
        txt += "\n"

    return txt

  def Cobyla (self):
    '''
    Methode Cobyla
    '''
    txt  = "# Optimisation par Cobyla\n"
    txt += "%s = Cobyla()\n" % self.variable["myOptimizer"]
    txt += "#%s = CobylaSpecificParameters()\n" % self.variable["specificParameters"]
    txt += "#%s.setSpecificParameters( %s )\n" % (self.variable["myOptimizer"], self.variable["specificParameters"])
    txt += "\n"
        
    return txt

  def AbdoRackwitz (self):
    '''
    Methode AbdoRackwitz
    '''
    txt  = "# Optimisation par AbdoRackwitz\n"
    txt += "%s = AbdoRackwitz()\n" % self.variable["myOptimizer"]
    txt += "#%s = AbdoRackwitzSpecificParameters()\n" % self.variable["specificParameters"]
    txt += "#%s.setSpecificParameters( %s )\n" % (self.variable["myOptimizer"], self.variable["specificParameters"])
    txt += "\n"
    return txt

  def Beta (self, loi):
    '''
    Definition de la loi Beta
    '''
    settings = {
      "RT" : "Beta.RT",
      "MuSigma" : "Beta.MUSIGMA",
      }
    if loi[ 'Settings' ] == 'RT' :
      arg1 = loi[ 'R' ]
      arg2 = loi[ 'T' ]
    else :
      arg1 = loi[ 'Mu'    ]
      arg2 = loi[ 'Sigma' ]
      
    arg3 = loi[ 'A' ]
    arg4 = loi[ 'B' ]
    txt = "Beta( %g, %g, %g, %g, %s )" % (arg1, arg2, arg3, arg4, settings[ loi[ 'Settings' ] ])
    return txt
  
  def Exponential (self, loi):
    '''
    Definition de la loi Exponential
    '''
    arg1 = loi[ 'Lambda' ]
    arg2 = loi[ 'Gamma'  ]
    txt = "Exponential( %g, %g )" % (arg1, arg2)
    return txt
  
  def Gamma (self, loi):
    '''
    Definition de la loi Gamma
    '''
    settings = {
      "KLambda" : "Gamma.KLAMBDA",
      "MuSigma" : "Gamma.MUSIGMA",
    }
    if loi[ 'Settings' ] == 'KLambda' :
      arg1 = loi[ 'K'      ]
      arg2 = loi[ 'Lambda' ]
    else :
      arg1 = loi[ 'Mu'    ]
      arg2 = loi[ 'Sigma' ]
      
    arg3 = loi[ 'Gamma' ]
    txt = "Gamma( %g, %g, %g, %s )" % (arg1, arg2, arg3, settings[ loi[ 'Settings' ] ])
    return txt

  def Geometric (self, loi):
    '''
    Definition de la loi Geometric
    '''
    txt = "Geometric( %g )" % loi[ 'P' ]
    return txt

  def Gumbel (self, loi):
    '''
    Definition de la loi Gumbel
    '''
    settings = {
      "AlphaBeta" : "Gumbel.ALPHABETA",
      "MuSigma" : "Gumbel.MUSIGMA",
    }
    if loi[ 'Settings' ] == 'AlphaBeta' :
      arg1 = loi[ 'Alpha' ]
      arg2 = loi[ 'Beta'  ]
    else :
      arg1 = loi[ 'Mu'    ]
      arg2 = loi[ 'Sigma' ]
      
    txt = "Gumbel( %g, %g, %s )" % (arg1, arg2, settings[ loi[ 'Settings' ] ])
    return txt

  def Histogram (self, loi):
    '''
    Definition de la loi Histogram
    '''
    arg1 = loi[ 'First' ]
    arg2 = loi[ 'Values'  ]
    txt = "Histogram( %g, %s )" % (arg1, arg2)
    return txt

  def Laplace (self, loi):
    '''
    Definition de la loi Laplace
    '''
    arg1 = loi[ 'Lambda' ]
    arg2 = loi[ 'Mu'     ]
    txt = "Laplace( %g, %g )" % (arg1, arg2)
    return txt

  def Logistic (self, loi):
    '''
    Definition de la loi Logistic
    '''
    arg1 = loi[ 'Alpha' ]
    arg2 = loi[ 'Beta'  ]
    txt = "Logistic( %g, %g )" % (arg1, arg2)
    return txt

  def LogNormal (self, loi):
    '''
    Definition de la loi LogNormal
    '''
    settings = {
      "MuSigmaLog" : "LogNormal.MUSIGMA_LOG",
      "MuSigma" : "LogNormal.MUSIGMA",
      "MuSigmaOverMu" : "LogNormal.MU_SIGMAOVERMU",
    }
    if loi[ 'Settings' ] == 'MuSigmaLog' :
      arg1 = loi[ 'MuLog' ]
      arg2 = loi[ 'SigmaLog' ]
    elif loi[ 'Settings' ] == 'MuSigmaOverMu' :
      arg1 = loi[ 'Mu' ]
      arg2 = loi[ 'SigmaOverMu' ]
    else :
      arg1 = loi[ 'Mu'    ]
      arg2 = loi[ 'Sigma' ]
      
    arg3 = loi[ 'Gamma' ]
    txt = "LogNormal( %g, %g, %g, %s )" % (arg1, arg2, arg3, settings[ loi[ 'Settings' ] ])
    return txt

  def MultiNomial (self, loi):
    '''
    Definition de la loi MultiNomial
    '''
    arg1 = loi[ 'Values' ]
    arg2 = loi[ 'N' ]
    txt = "MultiNomial( NumericalPoint( %s ) , %d)" % (arg1, arg2)
    return txt

  def NonCentralStudent (self, loi):
    '''
    Definition de la loi NonCentralStudent
    '''
    arg1 = loi[ 'Nu'    ]
    arg2 = loi[ 'Delta' ]
    arg3 = loi[ 'Gamma' ]
    txt = "NonCentralStudent( %g, %g )" % (arg1, arg2, arg3)
    return txt

  def Normal (self, loi):
    '''
    Definition de la loi Normal
    '''
    arg1 = loi[ 'Mu'    ]
    arg2 = loi[ 'Sigma' ]
    txt = "Normal( %g, %g )" % (arg1, arg2)
    return txt

  def TruncatedNormal (self, loi):
    '''
    Definition de la loi TruncatedNormal
    '''
    arg1 = loi[ 'MuN' ]
    arg2 = loi[ 'SigmaN' ]
    arg3 = loi[ 'A' ]
    arg4 = loi[ 'B' ]
    txt = "TruncatedNormal( %g, %g, %g, %g )" % (arg1, arg2, arg3, arg4)
    return txt

  def Poisson (self, loi):
    '''
    Definition de la loi Poisson
    '''
    txt = "Poisson( %g )" % loi[ 'Lambda' ]
    return txt

  def Rayleigh (self, loi):
    '''
    Definition de la loi Rayleigh
    '''
    arg1 = loi[ 'Sigma' ]
    arg2 = loi[ 'Gamma' ]
    txt = "Rayleigh( %g, %g )" % (arg1, arg2)
    return txt

  def Student (self, loi):
    '''
    Definition de la loi Student
    '''
    arg1 = loi[ 'Mu' ]
    arg2 = loi[ 'Nu' ]
    arg3 = loi[ 'Sigma' ]
    txt = "Student( %g, %g, %g )" % (arg1, arg2, arg3)
    return txt

  def Triangular (self, loi):
    '''
    Definition de la loi Triangular
    '''
    arg1 = loi[ 'A' ]
    arg2 = loi[ 'M' ]
    arg3 = loi[ 'B' ]
    txt = "Triangular( %g, %g, %g )" % (arg1, arg2, arg3)
    return txt

  def Uniform (self, loi):
    '''
    Definition de la loi Uniform
    '''
    arg1 = loi[ 'A' ]
    arg2 = loi[ 'B' ]
    txt = "Uniform( %g, %g )" % (arg1, arg2)
    return txt

  def UserDefined (self, loi):
    '''
    Definition de la loi UserDefined
    '''
    txt = "** UserDefined not defined yet **"
    return txt

  def Weibull (self, loi):
    '''
    Definition de la loi Weibull
    '''
    settings = {
      "AlphaBeta" : "Weibull.ALPHABETA",
      "MuSigma" : "Weibull.MUSIGMA",
    }
    if loi[ 'Settings' ] == 'AlphaBeta' :
      arg1 = loi[ 'Alpha' ]
      arg2 = loi[ 'Beta'  ]
    else :
      arg1 = loi[ 'Mu'    ]
      arg2 = loi[ 'Sigma' ]
      
    arg3 = loi[ 'Gamma' ]
    txt = "Weibull( %g, %g, %g, %s )" % (arg1, arg2, arg3, settings[ loi[ 'Settings' ] ])
    return txt



  def GraphiquePDF (self, loi, chemin, fichier):
    '''
    Produit une image PNG representant la PDF de la loi
    '''
    txt  = headerSTD % self.OpenTURNS_path
    txt += "dist = %s\n" % apply( STDGenerateur.__dict__[ loi[ 'Kind' ] ], (self, loi) )
    txt += "graph = dist.drawPDF()\n"
    txt += "graph.draw( '%s/%s' , 640, 480, GraphImplementation.PNG)\n" % (chemin, fichier)
    txt += footerSTD
    return txt
  

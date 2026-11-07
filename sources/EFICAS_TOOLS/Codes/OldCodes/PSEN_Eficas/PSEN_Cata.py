# -*- coding: iso-8859-1 -*-
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

# --------------------------------------------------
# debut entete
# --------------------------------------------------

#from Accas import ASSD, JDC_CATA, AU_MOINS_UN, PROC, SIMP, FACT, OPER, MACRO, BLOC, A_VALIDATOR
from Accas import *
import opsPSEN

class loi      ( ASSD ) : pass
class variable ( ASSD ) : pass
class sd_charge     ( ASSD ) : pass
class sd_generateur ( ASSD ) : pass
class sd_ligne     ( ASSD ) : pass
class sd_transfo ( ASSD ) : pass
class sd_moteur (ASSD) : pass
#class sd_busbar ( sd_generateur,sd_charge ) : pass

import types
class Tuple:
  def __init__(self,ntuple):
    self.ntuple=ntuple

  def __convert__(self,valeur):
    if type(valeur) == types.StringType:
      return None
    if len(valeur) != self.ntuple:
      return None
    return valeur

  def info(self):
    return "Tuple de %s elements" % self.ntuple

  __repr__=info
  __str__=info

class Matrice:
  def __init__(self,nbLigs=None,nbCols=None,methodeCalculTaille=None,formatSortie="ligne",valSup=None,valMin=None,structure=None):
      self.nbLigs=nbLigs
      self.nbCols=nbCols
      self.methodeCalculTaille=methodeCalculTaille
      self.formatSortie=formatSortie
      self.valSup=valSup
      self.valMin=valMin
      self.structure=structure

  def __convert__(self,valeur):
    # Attention ne verifie pas grand chose
    if type(valeur) != types.ListType :
      return None
    return valeur

  def info(self):
      return "Matrice %s x %s" % (self.nbLigs, self.nbCols)

      __repr__=info
      __str__=info


#CONTEXT.debug = 1
JdC = JDC_CATA ( code = 'PSEN',
                 execmodul = None,
                 regles = ( AU_MOINS_UN ( 'PSSE_PARAMETERS' ),
                            AU_MOINS_UN ( 'DIRECTORY' ),
                            AU_MOINS_UN ( 'DISTRIBUTION' ),
                            AU_MOINS_UN ( 'SIMULATION' ),
                            AU_PLUS_UN ( 'PSSE_PARAMETERS' ),
                            AU_PLUS_UN ( 'DIRECTORY' ),
                            AU_PLUS_UN ( 'SIMULATION' ),
                            AU_PLUS_UN ( 'CORRELATION' ),
                            AU_PLUS_UN ( 'N_1_GENERATORS' ),
                            AU_PLUS_UN ( 'N_1_LINES' ),
                            AU_PLUS_UN ( 'N_1_LOADS' ),
                            AU_PLUS_UN ( 'N_1_MOTORS' ),
                            AU_PLUS_UN ( 'N_1_TRANSFORMERS' ),

                            ),
                 ) # Fin JDC_CATA


# --------------------------------------------------
# fin entete
# --------------------------------------------------

MONGENER =  OPER ( nom = "MONGENER",
            sd_prod = sd_generateur,
            UIinfo = {"groupes": ("CACHE")},
            op = None,
            fr = "Generateur",
            ang = "Generator",

  ID = SIMP ( statut = 'o', typ = "TXM", fr = "num bus", ang = "num bus",),
)
MONMOTEUR =  OPER ( nom = "MONMOTEUR",
            sd_prod = sd_moteur,
            UIinfo = {"groupes": ("CACHE")},
            op = None,
            fr = "Moteur",
            ang = "Motor",

  ID = SIMP ( statut = 'o', typ = "TXM", fr = "num bus", ang = "num bus",),
)
MACHARGE =  OPER ( nom = "MACHARGE",
            sd_prod = sd_charge,
            UIinfo = {"groupes": ("CACHE")},
            op = None,
            fr = "Charge",
            ang = "Load",

  ID = SIMP ( statut = 'o', typ = "TXM", fr = "nom charge", ang = "load name",),
)
MALIGNE =  OPER ( nom = "MALIGNE",
            sd_prod = sd_ligne,
            UIinfo = {"groupes": ("CACHE")},
            op = None,
            fr = "Ligne",
            ang = "Line",

  ID = SIMP ( statut = 'o', typ = "TXM", fr = "nom ligne", ang = "line name",),
)
MONTRANSFO =  OPER ( nom = "MONTRANSFO",
            sd_prod = sd_transfo,
            UIinfo = {"groupes": ("CACHE")},
            op = None,
            fr = "Transformateur",
            ang = "Transformer",

  ID = SIMP ( statut = 'o', typ = "TXM", fr = "nom transformateur", ang = "transformer name",),
)



PSSE_PARAMETERS = PROC ( nom = "PSSE_PARAMETERS",
             op=None,
             docu = "",
  ALGORITHM = SIMP ( statut = "o",
                     typ='TXM',
                     into=["Optimum Power Flow","Economic Dispatch and Power Flow"],
                     defaut="Optimum Power Flow",
                    ),
  I_MAX = SIMP ( statut = "o",
                     typ='TXM',
                     into=['RateA','RateB','RateC'],
                     defaut='RateA',
                    ),
  LOCK_TAPS = SIMP ( statut = "o",
                     typ=bool,
                     defaut=True,
                     ),

  b_OPF = BLOC (condition = "ALGORITHM == 'Optimum Power Flow'",
  FUEL_COST = SIMP ( statut = "o",
                     typ=bool,
                     defaut=True,
                     ),
  LOADSHEDDING_COST = SIMP ( statut = "o",
                     typ=bool,
                     defaut=False,
                     ),
  MVAR_COST = SIMP ( statut = "o",
                     typ=bool,
                     defaut=False,
                    ),
  ITERATION_LIMIT = SIMP ( statut = "o",
                 typ = "I",
                 val_min=1,
                 defaut=20,
                 ),
  QGEP_CONTROL = SIMP ( statut = "o",
                        typ = bool,
                        defaut = True,
                        ),
  b_QgenControl = BLOC (condition = "QGEP_CONTROL == True",
  SAVE_CASE_BEFORE_QCONTROL = SIMP ( statut = "o",
                        typ = bool,
                        defaut = False,
                        fr = "Sauvegarder des fichiers de cas avant d'avoir deconnecte les groupes ne produisant pas de la puissance active",
                        ang = "Save network case files before having disconnected groups that dont generate active power.",
                        ),
  ),
  ),

  b_ECD = BLOC (condition = "ALGORITHM == 'Economic Dispatch and Power Flow'",
  ecd_file=SIMP(statut="o", typ = ('Fichier', 'Economic Dispatch Files (*.ecd);;All Files (*)',),),
  ),

##  P_MIN= SIMP ( statut = "o",
##                     typ=bool,
##                     defaut=True,
##                     ),
)

SIMULATION = PROC ( nom = "SIMULATION",
             op = None,
             docu = "",
  regles             =(EXCLUS('NUMBER_PACKAGE','CONVERGENCE'), UN_PARMI('NUMBER_PACKAGE','CONVERGENCE'),),

  SIZE_PACKAGE = SIMP ( statut = "o",
                 typ = "I",
                 val_min=10,
                 defaut=100,
                 ),
  NUMBER_PACKAGE = SIMP ( statut = "f",
                 typ = "I",
                 val_min=1,
                 ),
  CONVERGENCE = SIMP ( statut = "f",
                 typ="I",
                 into=[1],
                ),

##  STUDY = SIMP ( statut = "o",
##                 typ = "TXM",
##                 into = ( 'N-1', 'Load', 'Wind-1', 'Wind-2', 'PV' ),
##                 max=5,
##                 fr = "Affichage du niveau de wrapper de la bibliotheque Open TURNS",
##                 ang = "Open TURNS library debug level print",
##                 ),
)


#================================
# Definition du modele physique
#================================



CORRELATION = PROC ( nom = 'CORRELATION',
                     op = None,
                     docu = "",
                     fr = "Correlation entre variables",
                     ang = "Variable correlation",

####  Copula = SIMP ( statut = "o",
####                  typ = 'TXM',
####                  into = ( "Independent", "Normal" ),
####                  defaut = "Independent",
####                  fr = "Type de la copule",
####                  ang = "Copula kind",
####                  ),
##
## # Matrix = BLOC ( condition = "Copula in ( 'Normal', )",
##
    CorrelationMatrix = SIMP ( statut = "o",
                               typ = Matrice(nbLigs=None,
                                             nbCols=None,
                                             methodeCalculTaille='NbDeDistributions',
                                             structure="symetrique"),
                               fr = "Matrice de correlation entre les variables d'entree",
                               ang = "Correlation matrix for input variables",
                               #val_max=1.0,
                               #val_min=-1.0
                               ),
##  #), # Fin BLOC Matrix
##
##
)

DIRECTORY = MACRO ( nom = 'DIRECTORY',
        op=None,
        fr = "Chargement des directoires et fichiers",
        ang = "Load directories and files necessary to run PSEN",
                sd_prod = opsPSEN.INCLUDE,
                op_init = opsPSEN.INCLUDE_context,
                #sd_prod=None,
                fichier_ini = 1,

        PSSE_path=SIMP(statut="o",typ='Repertoire',defaut='C:\Program Files\PTI\PSSE33\PSSBIN'),
        sav_file=SIMP(statut="o", typ = ('Fichier', 'Network Case Files (*.sav);;All Files (*)',),),
        results_folder=SIMP(statut="o",typ='Repertoire'),
        #lines_file=SIMP(statut="o" ,typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),),
        #groups_file=SIMP(statut="o", typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),),
        #generationsystem_file=SIMP(statut="o" ,typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),),

)



#================================
# Importation des fichiers csv N-1
#================================

N_1_LINES = PROC( nom="N_1_LINES",
                     op = None,
                     docu = "",
                     fr = "N-1 lignes",
                     ang = "N-1 lines",
  Activated = SIMP ( statut='o', typ=bool, defaut=True),
##  FileName = SIMP ( statut = "o",
##                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
##                    fr = "chemin du fichier csv des probabilites des defauts lignes",
##                    ang = "csv file path with probabilities of line outages",
##                    ),
  Probability = SIMP ( statut = 'o',
                       typ = Tuple(2),
                       max = '**',
                       fr = "Probabilite d'indisponibilite de la ligne",
                       ang = "Probability that the line is not available",
                       validators=VerifTypeTuple((sd_ligne,'R')),),
              )

N_1_TRANSFORMERS = PROC( nom="N_1_TRANSFORMERS",
                     op = None,
                     docu = "",
                     fr = "N-1 transformateurs",
                     ang = "N-1 transformers",
  Activated = SIMP ( statut='o', typ=bool, defaut=True),
##  FileName = SIMP ( statut = "o",
##                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
##                    fr = "chemin du fichier csv des probabilites des defauts transformateur",
##                    ang = "csv file path with probabilities of transformer outages",
##                    ),
  Probability = SIMP ( statut = 'o',
                       typ = Tuple(2),
                       max = '**',
                       fr = "Probabilite d'indisponibilite de la ligne",
                       ang = "Probability that the line is not available",
                       validators=VerifTypeTuple((sd_transfo,'R')),),
              )
N_1_GENERATORS = PROC( nom="N_1_GENERATORS",
                     op = None,
                     docu = "",
                     fr = "N-1 generateurs",
                     ang = "N-1 generators",
  Activated = SIMP ( statut='o', typ=bool, defaut=True),
##  FileName = SIMP ( statut = "o",
##                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
##                    fr = "chemin du fichier csv des probabilites des defauts generateurs",
##                    ang = "csv file path with probabilities of generator outages",
##                    ),
  Probability = SIMP ( statut = 'o',
                       typ = Tuple(2),
                       max = '**',
                       fr = "Probabilite d'indisponibilite du generateur",
                       ang = "Probability that the generator is not available",
                       validators=VerifTypeTuple((sd_generateur,'R')),),
              )
N_1_MOTORS = PROC( nom="N_1_MOTORS",
                     op = None,
                     docu = "",
                     fr = "N-1 moteurs",
                     ang = "N-1 motors",
  Activated = SIMP ( statut='o', typ=bool, defaut=True),
##  FileName = SIMP ( statut = "o",
##                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
##                    fr = "chemin du fichier csv des probabilites des defauts generateurs",
##                    ang = "csv file path with probabilities of generator outages",
##                    ),
  Probability = SIMP ( statut = 'o',
                       typ = Tuple(2),
                       max = '**',
                       fr = "Probabilite d'indisponibilite du moteur",
                       ang = "Probability that the motor is not available",
                       validators=VerifTypeTuple((sd_moteur,'R')),),
              )
N_1_LOADS = PROC( nom="N_1_LOADS",
                     op = None,
                     docu = "",
                     fr = "N-1 charges",
                     ang = "N-1 loads",
  Activated = SIMP ( statut='o', typ=bool, defaut=True),
##  FileName = SIMP ( statut = "o",
##                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
##                    fr = "chemin du fichier csv des probabilites des defauts charges",
##                    ang = "csv file path with probabilities of load outages",
##                    ),
  Probability = SIMP ( statut = 'o',
                       typ = Tuple(2),
                       max = '**',
                       fr = "Probabilite d'indisponibilite du generateur",
                       ang = "Probability that the generator is not available",
                       validators=VerifTypeTuple((sd_charge,'R')),),
              )




#================================
# Definition des LOIS
#================================

# Nota : les variables de type OPER doivent etre en majuscules !
# Nota : les variables de type OPER doivent etre de premier niveau (pas imbriquees dans un autre type)
DISTRIBUTION = OPER ( nom = "DISTRIBUTION",
                      sd_prod = loi,
                      op = 68,
                      fr = "Definitions des lois marginales utilisees par les variables d'entree",

#====
# Choisir generateur ou charge
#====

##  TypeMachine = SIMP ( statut='o', typ='TXM',
##                      into = ('charge','vent1','vent2','pv','N-1',),
##                      ),
  Activated = SIMP ( statut='o', typ=bool, defaut=True),
  ComponentType = SIMP (statut='o', typ='TXM',
                      into = ('Generator','Load','Motor','Line','Transformer'),),
  b_gener = BLOC (condition = "ComponentType == 'Generator'",

  Type = SIMP (statut= "o", typ = "TXM",
               into = ("Generator Power Level", "Generator Availability"),
               fr = "Choisir si c'est le niveau de puissance ou la disponibilit� du generateur qui sera tiree",
               ang= "Choose whether the power level or the availability of the generator will be set by the law",
               defaut = "Generator Power Level",
               ),

  Sampling = SIMP (statut= "o", typ = "TXM",
               into = ("Same sample for all generators", "One sample per generator"),
               fr = "Choisir si une seule tirage sera fait pour tous les generateurs ou si des tirages differents seront faits pour chaque generateur",
               ang= "Choose whether one drawing/sample will be performed for all of the generators or whether a different drawing/sample will be performed for each generator.",
               defaut = "Same sample for all generators",
               ),

  Generator   = SIMP(statut='o',typ=sd_generateur,max="**", homo="SansOrdreNiDoublon",docu="sd_generateur"),

#====
# Type de distribution
#====

  b_gener_level = BLOC (condition= "Type == 'Generator Power Level'",

  Law = SIMP ( statut = "o", typ = "TXM",
                into = ( "Exponential",
                         "Histogram",
                         "Normal",
                         #"Rayleigh",
                         "PDF_from_file",
                         "TruncatedNormal",
                         "TimeSeries_from_file",
                         "Uniform",
                         "UserDefined",
                         "Weibull",
                         ),
                fr = "Choix du type de la loi marginale",
                ang = "1D marginal distribution",
                ),


#====
# Definition des parametres selon le type de la loi
#====


  EXPONENTIAL = BLOC ( condition = " Law in ( 'Exponential', ) ",

                         Lambda = SIMP ( statut = "o",
                                         typ = "R",
                                         max = 1,
                                         val_min = 0.,
                                         fr = "Parametre Lambda | Lambda > 0",
                                         ang = "Lambda parameter | Lambda > 0",
                                         ),

                         Gamma = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne inferieure du support de la loi",
                                        ang = "Support lower bound",
                                        ),

  ), # Fin BLOC EXPONENTIAL


  HISTOGRAM = BLOC ( condition = " Law in ( 'Histogram', ) ",

                       First = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du supoport de la loi",
                                    ang = "Support lower bound",
                                    ),

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : largeur de classe, hauteur de classe",
                                       ang = "Class bandwidth, class height couple list",
                                       validators=VerifTypeTuple(('R','R')),
                                       ),

  ), # Fin BLOC HISTOGRAM


   NORMAL = BLOC ( condition = " Law in ( 'Normal', ) ",

                    Mu = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Moyenne de la loi",
                                ang = "Mean value",
                                ),

                   Sigma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  val_min = 0.,
                                  fr = "Ecart type de la loi",
                                  ang = "Standard deviation",
                                  ),

   ), # Fin BLOC NORMAL


  RAYLEIGH = BLOC ( condition = " Law in ( 'Rayleigh', ) ",

                   Sigma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Parametre Sigma de la loi | Sigma > 0",
                                  ang = "Sigma parameter | Sigma > 0",
                                  ),

                   Gamma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Borne inferieure du support de la loi",
                                  ang = "Support lower bound",
                                  ),
 ), # Fin BLOC RAYLEIGH

  PDF = BLOC ( condition = " Law in ( 'PDF_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Nom du fichier .csv",
                    ang = ".csv file name",
                    ),
              ),



   TRUNCATEDNORMAL = BLOC ( condition = " Law in ( 'TruncatedNormal', ) ",

                             MuN = SIMP ( statut = "o",
                                          typ = "R",
                                          max = 1,
                                          fr = "Moyenne de la loi Normale non tronqu�e",
                                          ang = "Mean value of the associated non truncated normal distribution",
                                          ),

                             SigmaN = SIMP ( statut = "o",
                                             typ = "R",
                                             max = 1,
                                             val_min = 0.,
                                             fr = "Ecart-type de la loi Normale non tronqu�e",
                                             ang = "Standard deviation of the associated non truncated normal distribution",
                                             ),

                             A = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne inferieure de la loi | A < B",
                                        ang = "Lower bound | A < B",
                                        ),

                             B = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne superieure de la loi | A < B",
                                        ang = "Upper bound | A < B",
                                        ),

   ), # Fin BLOC TRUNCATEDNORMAL


  TimeSeries = BLOC ( condition = " Law in ( 'TimeSeries_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Fichier CSV d'une serie temporelle",
                    ang = "CSV file of a time series",
                    ),
              ),


   UNIFORM = BLOC ( condition = " Law in ( 'Uniform', ) ",

                     A = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne inferieure du support de la loi | A < B",
                                ang = "Support lower bound | A < B",
                                ),

                     B = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne superieure du support de la loi | A < B",
                                ang = "Support upper bound | A < B",
                                ),

   ), # Fin BLOC UNIFORM


   USERDEFINED = BLOC ( condition = " Law in ( 'UserDefined', ) ",

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : (valeur, prob.)",
                                       ang = "List of pairs : (value, prob.)",
                                       validators=VerifTypeTuple(('R','R')),
                                       ),

  ), # Fin BLOC USERDEFINED


   WEIBULL = BLOC ( condition = " Law in ( 'Weibull', ) ",

                     Settings = SIMP ( statut = "o",
                                          typ = "TXM",
                                          max = 1,
                                          into = ( "AlphaBeta", "MuSigma" ),
                                          defaut = "AlphaBeta",
                                          fr = "Parametrage de la loi weibull",
                                          ang = "Weibull distribution parameter set",
                                          ),

                     AlphaBeta_Parameters = BLOC ( condition = " Settings in ( 'AlphaBeta', ) ",

                                         Alpha = SIMP ( statut = "o",
                                                        typ = "R",
                                                        max = 1,
                                                        val_min = 0.,
                                                        fr = "Parametre Alpha de la loi | Alpha > 0",
                                                        ang = "Alpha parameter | Alpha > 0",
                                                        ),

                                         Beta = SIMP ( statut = "o",
                                                       typ = "R",
                                                       max = 1,
                                                       val_min = 0.,
                                                       fr = "Parametre Beta de la loi | Beta > 0",
                                                       ang = "Beta parameter | Beta > 0",
                                                       ),

                                         ), # Fin BLOC AlphaBeta_Parameters


                     MuSigma_Parameters = BLOC ( condition = " Settings in ( 'MuSigma', ) ",

                                         Mu = SIMP ( statut = "o",
                                                     typ = "R",
                                                     max = 1,
                                                     fr = "Moyenne de la loi",
                                                     ang = "Mean value",
                                                     ),

                                         Sigma = SIMP ( statut = "o",
                                                        typ = "R",
                                                        max = 1,
                                                        val_min = 0.,
                                                        fr = "Ecart type de la loi",
                                                        ang = "Standard deviation",
                                                        ),

                                         ), # Fin BLOC MuSigma_Parameters

                     Gamma = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du support de la loi",
                                    ang = "Support lower bound",
                                    ),

    ), # Fin BLOC WEIBULL


    Transfer_Function = FACT(statut='f',

        TF_Input = SIMP ( statut='o',
                       typ = 'TXM',
                       fr = 'Entrer une fonction de transfert � partir d''un fichier .pow (vitesse de vent - puissance eolienne)\n \
                             ou entrer une liste de tuples (valeur tiree - puissance normalisee)',
                       ang = 'Enter wind speed - turbine production transfer function as a .pow file, \n \
                              or enter a generic list of (law output value, normalized power output) tuples',
                       into = ('.pow file', 'tuples list'),
                             ),
        b_file = BLOC(condition = "TF_Input == '.pow file'",
                      File_Name = SIMP ( statut = "o",
                                        typ = ('Fichier', 'Pow files (*.pow);;All Files (*)',),
                                        fr = "Nom du fichier de transfer .pow",
                                        ang = ".pow file name",
                                        ),
                      Wind_Speed_Measurement_Height = SIMP ( statut = 'o',
                                        typ = "R",
                                        max = 1,
                                        fr = 'Hauteur (en metres) a laquelle les mesures de vitesse du vent ont ete prises',
                                        ang = 'Height of wind speed measurements (m)',
                                        sug = 10,
                                        val_min = 0,
                                        ),
                      Hub_Height = SIMP (statut = 'o',
                                         typ = "R",
                                         fr = 'hauteur de moyeu de l''eolienne',
                                         ang = 'wind turbine hub height',
                                         sug = 80,
                                         val_min = 0,),
                      AlphaWS = SIMP (statut = 'o',
                                         typ = "R",
                                         fr = 'l''alpha pour extrapoler les mesures de vitesse du vent a la hauteur du moyeu ',
                                         ang = 'alpha used to extrapolate wind speed measurements to hub height',
                                         defaut = 1./7,
                                         val_min = 0,
                                         val_max = 1,
                                            ),
                      Percent_Losses = SIMP (statut = 'o',
                                         typ = "R",
                                         fr = 'pourcentage de pertes entre la sortie theorique d''une turbine et la sortie de la centrale',
                                         ang = 'percent losses between theoretical power output of a single turbine and the output of the farm',
                                         defaut = 5,
                                         val_min = 0,
                                         val_max = 100,
                                             ),
                      ), #fin du bloc FileName

        b_tuples = BLOC(condition = "TF_Input == 'tuples list'",

                       TF_Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       min = 2,
                                       fr = "Liste de couples : valeur tiree, puissance normalisee sortie",
                                       ang = "List of couples : value set by law, normalized power output",
                                       validators=VerifTypeTuple(('R','R')),
                                       ),
                      ), #fin du block Tuples List

        ), #fin du FACT Transfer Function

  ), #fin du bloc generator level


  b_gener_avail = BLOC (condition= "Type == 'Generator Availability'",

  Law = SIMP ( statut = "o", typ = "TXM",
                into = ( #"Exponential",
                         #"Histogram",
                         #"Normal",
                         #"Rayleigh",
                         #"PDF_from_file",
                         #"TruncatedNormal",
                         "TimeSeries_from_file",
                         #"Uniform",
                         "UserDefined",
                         #"Weibull",
                         ),
                fr = "Choix du type de la loi marginale",
                ang = "1D marginal distribution",
                defaut="UserDefined",
                ),


#====
# Definition des parametres selon le type de la loi
#====


  TimeSeries = BLOC ( condition = " Law in ( 'TimeSeries_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Fichier CSV d'une serie temporelle",
                    ang = "CSV file of a time series",
                    ),
              ),


   USERDEFINED = BLOC ( condition = " Law in ( 'UserDefined', ) ",

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : (valeur, prob.)",
                                       ang = "List of pairs : (value, prob.)",
                                       validators=VerifTypeTuple(('R','R')),
                                       defaut=((0,0.0),(1,1.0)),
                                       ),

  ), # Fin BLOC USERDEFINED


  ), #fin du bloc generator avail


  ), #fin du bloc generateur

#Bloc Charge
  b_charge = BLOC (condition = "ComponentType == 'Load'",


#====
# Type de distribution
#====

  Type = SIMP (statut= "o", typ = "TXM",
               into = ("Load Level", "Load Availability"),
               fr = "Choisir si c'est le niveau de charge ou la disponibilit� de la charge qui sera tiree",
               ang= "Choose whether the power level or the availability of the load will be set by the law",
               defaut = "Load Level",
               ),

  Sampling = SIMP (statut= "o", typ = "TXM",
               into = ("Same sample for all loads", "One sample per load"),
               fr = "Choisir si une seule tirage sera fait pour tous les charges ou si des tirages differents seront faits pour chaque charge",
               ang= "Choose whether one drawing/sample will be performed for all of the loads or whether a different drawing/sample will be performed for each load.",
               defaut = "Same sample for all loads",
               ),

  Load       = SIMP(statut='o',typ=sd_charge,max="**", homo="SansOrdreNiDoublon",),


  b_charge_level = BLOC (condition = "Type == 'Load Level'",

  Law = SIMP ( statut = "o", typ = "TXM",
                into = ( "Exponential",
                         "Histogram",
                         "Normal",
                         #"Rayleigh",
                         "PDF_from_file",
                         "TruncatedNormal",
                         "TimeSeries_from_file",
                         "Uniform",
                         "UserDefined",
                         "Weibull",
                         ),
                fr = "Choix du type de la loi marginale",
                ang = "1D marginal distribution",
                ),


#====
# Definition des parametres selon le type de la loi
#====


  EXPONENTIAL = BLOC ( condition = " Law in ( 'Exponential', ) ",

                         Lambda = SIMP ( statut = "o",
                                         typ = "R",
                                         max = 1,
                                         val_min = 0.,
                                         fr = "Parametre Lambda | Lambda > 0",
                                         ang = "Lambda parameter | Lambda > 0",
                                         ),

                         Gamma = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne inferieure du support de la loi",
                                        ang = "Support lower bound",
                                        ),

  ), # Fin BLOC EXPONENTIAL


  HISTOGRAM = BLOC ( condition = " Law in ( 'Histogram', ) ",

                       First = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du supoport de la loi",
                                    ang = "Support lower bound",
                                    ),

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : largeur de classe, hauteur de classe",
                                       ang = "Class bandwidth, class height couple list",
                                       validators=VerifTypeTuple(('R','R')),
                                       ),

  ), # Fin BLOC HISTOGRAM


   NORMAL = BLOC ( condition = " Law in ( 'Normal', ) ",

                    Mu = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Moyenne de la loi",
                                ang = "Mean value",
                                ),

                   Sigma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  val_min = 0.,
                                  fr = "Ecart type de la loi",
                                  ang = "Standard deviation",
                                  ),

   ), # Fin BLOC NORMAL


  RAYLEIGH = BLOC ( condition = " Law in ( 'Rayleigh', ) ",

                   Sigma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Parametre Sigma de la loi | Sigma > 0",
                                  ang = "Sigma parameter | Sigma > 0",
                                  ),

                   Gamma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Borne inferieure du support de la loi",
                                  ang = "Support lower bound",
                                  ),
 ), # Fin BLOC RAYLEIGH

  PDF = BLOC ( condition = " Law in ( 'PDF_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Nom du fichier .csv",
                    ang = ".csv file name",
                    ),
              ),



   TRUNCATEDNORMAL = BLOC ( condition = " Law in ( 'TruncatedNormal', ) ",

                             MuN = SIMP ( statut = "o",
                                          typ = "R",
                                          max = 1,
                                          fr = "Moyenne de la loi Normale non tronqu�e",
                                          ang = "Mean value of the associated non truncated normal distribution",
                                          ),

                             SigmaN = SIMP ( statut = "o",
                                             typ = "R",
                                             max = 1,
                                             val_min = 0.,
                                             fr = "Ecart-type de la loi Normale non tronqu�e",
                                             ang = "Standard deviation of the associated non truncated normal distribution",
                                             ),

                             A = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne inferieure de la loi | A < B",
                                        ang = "Lower bound | A < B",
                                        ),

                             B = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne superieure de la loi | A < B",
                                        ang = "Upper bound | A < B",
                                        ),

   ), # Fin BLOC TRUNCATEDNORMAL


  TimeSeries = BLOC ( condition = " Law in ( 'TimeSeries_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Fichier CSV d'une serie temporelle",
                    ang = "CSV file of a time series",
                    ),
              ),


   UNIFORM = BLOC ( condition = " Law in ( 'Uniform', ) ",

                     A = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne inferieure du support de la loi | A < B",
                                ang = "Support lower bound | A < B",
                                ),

                     B = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne superieure du support de la loi | A < B",
                                ang = "Support upper bound | A < B",
                                ),

   ), # Fin BLOC UNIFORM


   USERDEFINED = BLOC ( condition = " Law in ( 'UserDefined', ) ",

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : (valeur, probabilite)",
                                       ang = "List of pairs : (value, probability)",
                                       validators=VerifTypeTuple(('R','R')),
                                       ),

  ), # Fin BLOC USERDEFINED


   WEIBULL = BLOC ( condition = " Law in ( 'Weibull', ) ",

                     Settings = SIMP ( statut = "o",
                                          typ = "TXM",
                                          max = 1,
                                          into = ( "AlphaBeta", "MuSigma" ),
                                          defaut = "AlphaBeta",
                                          fr = "Parametrage de la loi weibull",
                                          ang = "Weibull distribution parameter set",
                                          ),

                     AlphaBeta_Parameters = BLOC ( condition = " Settings in ( 'AlphaBeta', ) ",

                                         Alpha = SIMP ( statut = "o",
                                                        typ = "R",
                                                        max = 1,
                                                        val_min = 0.,
                                                        fr = "Parametre Alpha de la loi | Alpha > 0",
                                                        ang = "Alpha parameter | Alpha > 0",
                                                        ),

                                         Beta = SIMP ( statut = "o",
                                                       typ = "R",
                                                       max = 1,
                                                       val_min = 0.,
                                                       fr = "Parametre Beta de la loi | Beta > 0",
                                                       ang = "Beta parameter | Beta > 0",
                                                       ),

                                         ), # Fin BLOC AlphaBeta_Parameters


                     MuSigma_Parameters = BLOC ( condition = " Settings in ( 'MuSigma', ) ",

                                         Mu = SIMP ( statut = "o",
                                                     typ = "R",
                                                     max = 1,
                                                     fr = "Moyenne de la loi",
                                                     ang = "Mean value",
                                                     ),

                                         Sigma = SIMP ( statut = "o",
                                                        typ = "R",
                                                        max = 1,
                                                        val_min = 0.,
                                                        fr = "Ecart type de la loi",
                                                        ang = "Standard deviation",
                                                        ),

                                         ), # Fin BLOC MuSigma_Parameters

                     Gamma = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du support de la loi",
                                    ang = "Support lower bound",
                                    ),

    ), # Fin BLOC WEIBULL

  ), #fin du block Load Level


  b_charge_avail = BLOC (condition = "Type == 'Load Availability'",

  Law = SIMP ( statut = "o", typ = "TXM",
                into = ( #"Exponential",
                         #"Histogram",
                         #"Normal",
                         #"Rayleigh",
                         #"PDF_from_file",
                         #"TruncatedNormal",
                         "TimeSeries_from_file",
                         #"Uniform",
                         "UserDefined",
                         #"Weibull",
                         ),
                fr = "Choix du type de la loi marginale",
                ang = "1D marginal distribution",
                defaut = "UserDefined",
                ),


#====
# Definition des parametres selon le type de la loi
#====

  TimeSeries = BLOC ( condition = " Law in ( 'TimeSeries_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Fichier CSV d'une serie temporelle",
                    ang = "CSV file of a time series",
                    ),
              ),



   USERDEFINED = BLOC ( condition = " Law in ( 'UserDefined', ) ",

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : (valeur, probabilite)",
                                       ang = "List of pairs : (value, probability)",
                                       validators=VerifTypeTuple(('R','R')),
                                       defaut=((0,0.0),(1,1.0)),
                                       ),

  ), # Fin BLOC USERDEFINED


  ), #fin du block Load Avail


  ), #fin du bloc charge



#Bloc Moteur
  b_moteur = BLOC (condition = "ComponentType == 'Motor'",


#====
# Type de distribution
#====

  Type = SIMP (statut= "o", typ = "TXM",
               into = ("Motor Level", "Motor Availability"),
               fr = "Choisir si c'est le niveau de charge du moteur ou la disponibilit� du moteur qui sera tiree",
               ang= "Choose whether the power level or the availability of the motor will be set by the law",
               defaut = "Motor Level",
               ),

  Sampling = SIMP (statut= "o", typ = "TXM",
               into = ("Same sample for all motors", "One sample per motor"),
               fr = "Choisir si une seule tirage sera fait pour tous les moteurs ou si des tirages differents seront faits pour chaque moteur",
               ang= "Choose whether one drawing/sample will be performed for all of the motors or whether a different drawing/sample will be performed for each motor.",
               defaut = "Same sample for all motors",
               ),

  Motor       = SIMP(statut='o',typ=sd_moteur,max="**", homo="SansOrdreNiDoublon",),


  b_moteur_level = BLOC (condition = "Type == 'Motor Level'",

  Law = SIMP ( statut = "o", typ = "TXM",
                into = ( "Exponential",
                         "Histogram",
                         "Normal",
                         #"Rayleigh",
                         "PDF_from_file",
                         "TruncatedNormal",
                         "TimeSeries_from_file",
                         "Uniform",
                         "UserDefined",
                         "Weibull",
                         ),
                fr = "Choix du type de la loi marginale",
                ang = "1D marginal distribution",
                ),


#====
# Definition des parametres selon le type de la loi
#====


  EXPONENTIAL = BLOC ( condition = " Law in ( 'Exponential', ) ",

                         Lambda = SIMP ( statut = "o",
                                         typ = "R",
                                         max = 1,
                                         val_min = 0.,
                                         fr = "Parametre Lambda | Lambda > 0",
                                         ang = "Lambda parameter | Lambda > 0",
                                         ),

                         Gamma = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne inferieure du support de la loi",
                                        ang = "Support lower bound",
                                        ),

  ), # Fin BLOC EXPONENTIAL


  HISTOGRAM = BLOC ( condition = " Law in ( 'Histogram', ) ",

                       First = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du supoport de la loi",
                                    ang = "Support lower bound",
                                    ),

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : largeur de classe, hauteur de classe",
                                       ang = "Class bandwidth, class height couple list",
                                       validators=VerifTypeTuple(('R','R')),
                                       ),

  ), # Fin BLOC HISTOGRAM


   NORMAL = BLOC ( condition = " Law in ( 'Normal', ) ",

                    Mu = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Moyenne de la loi",
                                ang = "Mean value",
                                ),

                   Sigma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  val_min = 0.,
                                  fr = "Ecart type de la loi",
                                  ang = "Standard deviation",
                                  ),

   ), # Fin BLOC NORMAL


  RAYLEIGH = BLOC ( condition = " Law in ( 'Rayleigh', ) ",

                   Sigma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Parametre Sigma de la loi | Sigma > 0",
                                  ang = "Sigma parameter | Sigma > 0",
                                  ),

                   Gamma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Borne inferieure du support de la loi",
                                  ang = "Support lower bound",
                                  ),
 ), # Fin BLOC RAYLEIGH

  PDF = BLOC ( condition = " Law in ( 'PDF_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Nom du fichier .csv",
                    ang = ".csv file name",
                    ),
              ),



   TRUNCATEDNORMAL = BLOC ( condition = " Law in ( 'TruncatedNormal', ) ",

                             MuN = SIMP ( statut = "o",
                                          typ = "R",
                                          max = 1,
                                          fr = "Moyenne de la loi Normale non tronqu�e",
                                          ang = "Mean value of the associated non truncated normal distribution",
                                          ),

                             SigmaN = SIMP ( statut = "o",
                                             typ = "R",
                                             max = 1,
                                             val_min = 0.,
                                             fr = "Ecart-type de la loi Normale non tronqu�e",
                                             ang = "Standard deviation of the associated non truncated normal distribution",
                                             ),

                             A = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne inferieure de la loi | A < B",
                                        ang = "Lower bound | A < B",
                                        ),

                             B = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne superieure de la loi | A < B",
                                        ang = "Upper bound | A < B",
                                        ),

   ), # Fin BLOC TRUNCATEDNORMAL


  TimeSeries = BLOC ( condition = " Law in ( 'TimeSeries_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Fichier CSV d'une serie temporelle",
                    ang = "CSV file of a time series",
                    ),
              ),


   UNIFORM = BLOC ( condition = " Law in ( 'Uniform', ) ",

                     A = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne inferieure du support de la loi | A < B",
                                ang = "Support lower bound | A < B",
                                ),

                     B = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne superieure du support de la loi | A < B",
                                ang = "Support upper bound | A < B",
                                ),

   ), # Fin BLOC UNIFORM


   USERDEFINED = BLOC ( condition = " Law in ( 'UserDefined', ) ",

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : (valeur, probabilite)",
                                       ang = "List of pairs : (value, probability)",
                                       validators=VerifTypeTuple(('R','R')),
                                       ),

  ), # Fin BLOC USERDEFINED


   WEIBULL = BLOC ( condition = " Law in ( 'Weibull', ) ",

                     Settings = SIMP ( statut = "o",
                                          typ = "TXM",
                                          max = 1,
                                          into = ( "AlphaBeta", "MuSigma" ),
                                          defaut = "AlphaBeta",
                                          fr = "Parametrage de la loi weibull",
                                          ang = "Weibull distribution parameter set",
                                          ),

                     AlphaBeta_Parameters = BLOC ( condition = " Settings in ( 'AlphaBeta', ) ",

                                         Alpha = SIMP ( statut = "o",
                                                        typ = "R",
                                                        max = 1,
                                                        val_min = 0.,
                                                        fr = "Parametre Alpha de la loi | Alpha > 0",
                                                        ang = "Alpha parameter | Alpha > 0",
                                                        ),

                                         Beta = SIMP ( statut = "o",
                                                       typ = "R",
                                                       max = 1,
                                                       val_min = 0.,
                                                       fr = "Parametre Beta de la loi | Beta > 0",
                                                       ang = "Beta parameter | Beta > 0",
                                                       ),

                                         ), # Fin BLOC AlphaBeta_Parameters


                     MuSigma_Parameters = BLOC ( condition = " Settings in ( 'MuSigma', ) ",

                                         Mu = SIMP ( statut = "o",
                                                     typ = "R",
                                                     max = 1,
                                                     fr = "Moyenne de la loi",
                                                     ang = "Mean value",
                                                     ),

                                         Sigma = SIMP ( statut = "o",
                                                        typ = "R",
                                                        max = 1,
                                                        val_min = 0.,
                                                        fr = "Ecart type de la loi",
                                                        ang = "Standard deviation",
                                                        ),

                                         ), # Fin BLOC MuSigma_Parameters

                     Gamma = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du support de la loi",
                                    ang = "Support lower bound",
                                    ),

    ), # Fin BLOC WEIBULL

  ), #fin du block Load Level


  b_moteur_avail = BLOC (condition = "Type == 'Motor Availability'",

  Law = SIMP ( statut = "o", typ = "TXM",
                into = ( #"Exponential",
                         #"Histogram",
                         #"Normal",
                         #"Rayleigh",
                         #"PDF_from_file",
                         #"TruncatedNormal",
                         "TimeSeries_from_file",
                         #"Uniform",
                         "UserDefined",
                         #"Weibull",
                         ),
                fr = "Choix du type de la loi marginale",
                ang = "1D marginal distribution",
                defaut = "UserDefined",
                ),


#====
# Definition des parametres selon le type de la loi
#====

  TimeSeries = BLOC ( condition = " Law in ( 'TimeSeries_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Fichier CSV d'une serie temporelle",
                    ang = "CSV file of a time series",
                    ),
              ),



   USERDEFINED = BLOC ( condition = " Law in ( 'UserDefined', ) ",

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : (valeur, probabilite)",
                                       ang = "List of pairs : (value, probability)",
                                       validators=VerifTypeTuple(('R','R')),
                                       defaut=((0,0.0),(1,1.0)),
                                       ),

  ), # Fin BLOC USERDEFINED


  ), #fin du block Load Avail


  ), #fin du bloc moteur


  b_ligne = BLOC (condition = "ComponentType == 'Line'",


#====
# Type de distribution
#====

  Type = SIMP (statut= "o", typ = "TXM",
               into = ("Line Availability",),
               fr = "La disponibilite de la ligne sera tiree",
               ang= "Line availability will be set by the law",
               defaut = "Line Availability",
               ),

  Sampling = SIMP (statut= "o", typ = "TXM",
               into = ("Same sample for all lines", "One sample per line"),
               fr = "Choisir si une seule tirage sera fait pour tous les lignes ou si des tirages differents seront faits pour chaque ligne",
               ang= "Choose whether one drawing/sample will be performed for all of the lines or whether a different drawing/sample will be performed for each line.",
               defaut = "Same sample for all lines",
               ),

  Line   = SIMP(statut='o',typ=sd_ligne,max="**", homo="SansOrdreNiDoublon"),

  Law = SIMP ( statut = "o", typ = "TXM",
                into = ( #"Exponential",
                         #"Histogram",
                         #"Normal",
                         #"Rayleigh",
                         #"PDF_from_file",
                         #"TruncatedNormal",
                         "TimeSeries_from_file",
                         #"Uniform",
                         "UserDefined",
                         #"Weibull",
                         ),
                defaut = "UserDefined",
                fr = "Choix du type de la loi marginale",
                ang = "1D marginal distribution",
                ),


#====
# Definition des parametres selon le type de la loi
#====


  EXPONENTIAL = BLOC ( condition = " Law in ( 'Exponential', ) ",

                         Lambda = SIMP ( statut = "o",
                                         typ = "R",
                                         max = 1,
                                         val_min = 0.,
                                         fr = "Parametre Lambda | Lambda > 0",
                                         ang = "Lambda parameter | Lambda > 0",
                                         ),

                         Gamma = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne inferieure du support de la loi",
                                        ang = "Support lower bound",
                                        ),

  ), # Fin BLOC EXPONENTIAL


  HISTOGRAM = BLOC ( condition = " Law in ( 'Histogram', ) ",

                       First = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du supoport de la loi",
                                    ang = "Support lower bound",
                                    ),

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : largeur de classe, hauteur de classe",
                                       ang = "Class bandwidth, class height couple list",
                                       validators=VerifTypeTuple(('R','R')),
                                       ),

  ), # Fin BLOC HISTOGRAM


   NORMAL = BLOC ( condition = " Law in ( 'Normal', ) ",

                    Mu = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Moyenne de la loi",
                                ang = "Mean value",
                                ),

                   Sigma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  val_min = 0.,
                                  fr = "Ecart type de la loi",
                                  ang = "Standard deviation",
                                  ),

   ), # Fin BLOC NORMAL


  RAYLEIGH = BLOC ( condition = " Law in ( 'Rayleigh', ) ",

                   Sigma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Parametre Sigma de la loi | Sigma > 0",
                                  ang = "Sigma parameter | Sigma > 0",
                                  ),

                   Gamma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Borne inferieure du support de la loi",
                                  ang = "Support lower bound",
                                  ),
 ), # Fin BLOC RAYLEIGH

  PDF = BLOC ( condition = " Law in ( 'PDF_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Nom du fichier .csv",
                    ang = ".csv file name",
                    ),
              ),



   TRUNCATEDNORMAL = BLOC ( condition = " Law in ( 'TruncatedNormal', ) ",

                             MuN = SIMP ( statut = "o",
                                          typ = "R",
                                          max = 1,
                                          fr = "Moyenne de la loi Normale non tronqu�e",
                                          ang = "Mean value of the associated non truncated normal distribution",
                                          ),

                             SigmaN = SIMP ( statut = "o",
                                             typ = "R",
                                             max = 1,
                                             val_min = 0.,
                                             fr = "Ecart-type de la loi Normale non tronqu�e",
                                             ang = "Standard deviation of the associated non truncated normal distribution",
                                             ),

                             A = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne inferieure de la loi | A < B",
                                        ang = "Lower bound | A < B",
                                        ),

                             B = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne superieure de la loi | A < B",
                                        ang = "Upper bound | A < B",
                                        ),

   ), # Fin BLOC TRUNCATEDNORMAL


  TimeSeries = BLOC ( condition = " Law in ( 'TimeSeries_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Fichier CSV d'une serie temporelle",
                    ang = "CSV file of a time series",
                    ),
              ),


   UNIFORM = BLOC ( condition = " Law in ( 'Uniform', ) ",

                     A = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne inferieure du support de la loi | A < B",
                                ang = "Support lower bound | A < B",
                                ),

                     B = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne superieure du support de la loi | A < B",
                                ang = "Support upper bound | A < B",
                                ),

   ), # Fin BLOC UNIFORM


   USERDEFINED = BLOC ( condition = " Law in ( 'UserDefined', ) ",

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : (valeur, probabilite)",
                                       ang = "List of pairs : (value, probability)",
                                       validators=VerifTypeTuple(('R','R')),
                                       defaut=((0,0.0),(1,1.0)),
                                       ),

  ), # Fin BLOC USERDEFINED


   WEIBULL = BLOC ( condition = " Law in ( 'Weibull', ) ",

                     Settings = SIMP ( statut = "o",
                                          typ = "TXM",
                                          max = 1,
                                          into = ( "AlphaBeta", "MuSigma" ),
                                          defaut = "AlphaBeta",
                                          fr = "Parametrage de la loi weibull",
                                          ang = "Weibull distribution parameter set",
                                          ),

                     AlphaBeta_Parameters = BLOC ( condition = " Settings in ( 'AlphaBeta', ) ",

                                         Alpha = SIMP ( statut = "o",
                                                        typ = "R",
                                                        max = 1,
                                                        val_min = 0.,
                                                        fr = "Parametre Alpha de la loi | Alpha > 0",
                                                        ang = "Alpha parameter | Alpha > 0",
                                                        ),

                                         Beta = SIMP ( statut = "o",
                                                       typ = "R",
                                                       max = 1,
                                                       val_min = 0.,
                                                       fr = "Parametre Beta de la loi | Beta > 0",
                                                       ang = "Beta parameter | Beta > 0",
                                                       ),

                                         ), # Fin BLOC AlphaBeta_Parameters


                     MuSigma_Parameters = BLOC ( condition = " Settings in ( 'MuSigma', ) ",

                                         Mu = SIMP ( statut = "o",
                                                     typ = "R",
                                                     max = 1,
                                                     fr = "Moyenne de la loi",
                                                     ang = "Mean value",
                                                     ),

                                         Sigma = SIMP ( statut = "o",
                                                        typ = "R",
                                                        max = 1,
                                                        val_min = 0.,
                                                        fr = "Ecart type de la loi",
                                                        ang = "Standard deviation",
                                                        ),

                                         ), # Fin BLOC MuSigma_Parameters

                     Gamma = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du support de la loi",
                                    ang = "Support lower bound",
                                    ),

    ), # Fin BLOC WEIBULL

  ), #fin du bloc ligne

  b_transfo = BLOC (condition = "ComponentType == 'Transformer'",


#====
# Type de distribution
#====

  Type = SIMP (statut= "o", typ = "TXM",
               into = ("Transformer Availability",),
               fr = "La disponibilite du transformateur sera tiree",
               ang= "Transformer availability will be set by the law",
               defaut = "Transformer Availability"
               ),

  Sampling = SIMP (statut= "o", typ = "TXM",
               into = ("Same sample for all transformers", "One sample per transformer"),
               fr = "Choisir si une seule tirage sera fait pour tous les transforamteurs ou si des tirages differents seront faits pour chaque transformateur",
               ang= "Choose whether one drawing/sample will be performed for all of the tranformers or whether a different drawing/sample will be performed for each transformer.",
               defaut = "Same sample for all transformers",
               ),

  Transformer = SIMP(statut='o',typ=sd_transfo,max="**", homo="SansOrdreNiDoublon"),

  Law = SIMP ( statut = "o", typ = "TXM",
                into = ( #"Beta",
                         #"Exponential",
                         #"Gamma",
                         #"Geometric",
                         #"Gumbel",
                         #"Histogram",
                         #"Laplace",
                         #"Logistic",
                         #"LogNormal",
                         #"MultiNomial",
                         #"NonCentralStudent",
                         #"Normal",
                         #"Poisson",
                         #"Rayleigh",
                         #"Student",
                         #"PDF_from_file",
                         #"Triangular",
                         #"TruncatedNormal",
                         "TimeSeries_from_file",
                         #"Uniform",
                         "UserDefined",
                         #"Weibull",
                         ),
                defaut="UserDefined",
                fr = "Choix du type de la loi marginale",
                ang = "1D marginal distribution",
                ),


#====
# Definition des parametres selon le type de la loi
#====

##  NONPARAM = BLOC ( condition = " Law in ( 'NonParametrique', ) ",
##
##  FileName = SIMP ( statut = "o",
##                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
##                    fr = "Nom du modele physique",
##                    ang = "Physical model identifier",
##                    ),
##              ),

#  BETA = BLOC ( condition = " Law in ( 'Beta', ) ",
#
#                  Settings = SIMP ( statut = "o",
#                                       typ = "TXM",
#                                       max = 1,
#                                       into = ( "RT", "MuSigma" ),
#                                       defaut = "RT",
#                                       fr = "Parametrage de la loi beta",
#                                       ang = "Beta distribution parameter set",
#                                       ),
#
#                  RT_Parameters = BLOC ( condition = " Settings in ( 'RT', ) ",
#
#                                      R = SIMP ( statut = "o",
#                                                 typ = "R",
#                                                 max = 1,
#                                                 val_min = 0.,
#                                                 fr = "Parametre R de la loi | R > 0",
#                                                 ang = "R parameter | R > 0",
#                                                 ),
#
#                                      # T > R
#                                      T = SIMP ( statut = "o",
#                                                 typ = "R",
#                                                 max = 1,
#                                                 val_min = 0.,
#                                                 fr = "Parametre T de la loi | T > R",
#                                                 ang = "T parameter | T > R",
#                                                 ),
#
#                                      ), # Fin BLOC RT_Parameters
#
#
#                  MuSigma_Parameters = BLOC ( condition = " Settings in ( 'MuSigma', ) ",
#
#                                      Mu = SIMP ( statut = "o",
#                                                  typ = "R",
#                                                  max = 1,
#                                                  fr = "Moyenne de la loi",
#                                                  ang = "Mean value",
#                                                  ),
#
#                                      Sigma = SIMP ( statut = "o",
#                                                     typ = "R",
#                                                     max = 1,
#                                                     val_min = 0.,
#                                                     fr = "Ecart type de la loi",
#                                                     ang = "Standard deviation",
#                                                     ),
#
#                                      ), # Fin BLOC MuSigma_Parameters
#
#
#                  A = SIMP ( statut = "o",
#                             typ = "R",
#                             max = 1,
#                             fr = "Borne inferieure du support de la loi",
#                             ang = "Support lower bound",
#                             ),
#
#                  # B > A
#                  B = SIMP ( statut = "o",
#                             typ = "R",
#                             max = 1,
#                             fr = "Borne superieure du support de la loi",
#                             ang = "Support upper bound",
#                             ),
#
#  ), # Fin BLOC BETA



  EXPONENTIAL = BLOC ( condition = " Law in ( 'Exponential', ) ",

                         Lambda = SIMP ( statut = "o",
                                         typ = "R",
                                         max = 1,
                                         val_min = 0.,
                                         fr = "Parametre Lambda | Lambda > 0",
                                         ang = "Lambda parameter | Lambda > 0",
                                         ),

                         Gamma = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne inferieure du support de la loi",
                                        ang = "Support lower bound",
                                        ),

  ), # Fin BLOC EXPONENTIAL



#  GAMMA = BLOC ( condition = " Law in ( 'Gamma', ) ",
#
#                   Settings = SIMP ( statut = "o",
#                                        typ = "TXM",
#                                        max = 1,
#                                        into = ( "KLambda", "MuSigma" ),
#                                        defaut = "KLambda",
#                                        fr = "Parametrage de la loi gamma",
#                                        ang = "Gamma distribution parameter set",
#                                        ),
#
#                   KLambda_Parameters = BLOC ( condition = " Settings in ( 'KLambda', ) ",
#
#                                       K = SIMP ( statut = "o",
#                                                  typ = "R",
#                                                  max = 1,
#                                                  val_min = 0.,
#                                                  fr = "Parametre K de la loi | K > 0",
#                                                  ang = "K parameter | K > 0",
#                                                  ),
#
#                                       Lambda = SIMP ( statut = "o",
#                                                       typ = "R",
#                                                       max = 1,
#                                                       val_min = 0.,
#                                                       fr = "Parametre Lambda de la loi | Lambda > 0",
#                                                       ang = "Lambda parameter | Lambda > 0",
#                                                       ),
#
#                                       ), # Fin BLOC KLambda_Parameters
#
#
#                   MuSigma_Parameters = BLOC ( condition = " Settings in ( 'MuSigma', ) ",
#
#                                       Mu = SIMP ( statut = "o",
#                                                   typ = "R",
#                                                   max = 1,
#                                                   fr = "Moyenne de la loi",
#                                                   ang = "Mean value",
#                                                   ),
#
#                                       Sigma = SIMP ( statut = "o",
#                                                      typ = "R",
#                                                      max = 1,
#                                                      val_min = 0.,
#                                                      fr = "Ecart type de la loi",
#                                                      ang = "Standard deviation",
#                                                      ),
#
#                                       ), # Fin BLOC MuSigma_Parameters
#
#                   Gamma = SIMP ( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  fr = "Borne inferieure du supoport de la loi",
#                                  ang = "Support lower bound",
#                                  ),
#
#
#  ), # Fin BLOC GAMMA


#
#  GEOMETRIC = BLOC ( condition = " Law in ( 'Geometric', ) ",
#
#                       P = SIMP ( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  val_min = 0.,
#                                  val_max = 1.,
#                                  fr = "Parametre P | 0 < P < 1",
#                                  ang = "P parameter | 0 < P < 1",
#                                  ),
#
#  ), # Fin BLOC GEOMETRIC
#
#
#
#  GUMBEL = BLOC ( condition = " Law in ( 'Gumbel', ) ",
#
#                    Settings = SIMP ( statut = "o",
#                                         typ = "TXM",
#                                         max = 1,
#                                         into = ( "AlphaBeta", "MuSigma" ),
#                                         defaut = "AlphaBeta",
#                                         fr = "Parametrage de la loi gumbel",
#                                         ang = "Gumbel distribution parameter set",
#                                         ),
#
#                    AlphaBeta_Parameters = BLOC ( condition = " Settings in ( 'AlphaBeta', ) ",
#
#                                        Alpha = SIMP ( statut = "o",
#                                                       typ = "R",
#                                                       max = 1,
#                                                       val_min = 0.,
#                                                       fr = "Parametre Alpha de la loi | Alpha > 0",
#                                                       ang = "Alpha parameter | Alpha > 0",
#                                                       ),
#
#                                        Beta = SIMP ( statut = "o",
#                                                      typ = "R",
#                                                      max = 1,
#                                                      fr = "Parametre Beta de la loi",
#                                                      ang = "Beta parameter",
#                                                      ),
#
#                                        ), # Fin BLOC AlphaBeta_Parameters
#
#
#                    MuSigma_Parameters = BLOC ( condition = " Settings in ( 'MuSigma', ) ",
#
#                                        Mu = SIMP ( statut = "o",
#                                                    typ = "R",
#                                                    max = 1,
#                                                    fr = "Moyenne de la loi",
#                                                    ang = "Mean value",
#                                                    ),
#
#                                        Sigma = SIMP ( statut = "o",
#                                                       typ = "R",
#                                                       max = 1,
#                                                       val_min = 0.,
#                                                       fr = "Ecart type de la loi",
#                                                       ang = "Standard deviation",
#                                                       ),
#
#                                        ), # Fin BLOC MuSigma_Parameters
#
#  ), # Fin BLOC GUMBEL



  HISTOGRAM = BLOC ( condition = " Law in ( 'Histogram', ) ",

                       First = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du supoport de la loi",
                                    ang = "Support lower bound",
                                    ),

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : largeur de classe, hauteur de classe",
                                       ang = "Class bandwidth, class height couple list",
                                       validators=VerifTypeTuple(('R','R')),
                                       ),

  ), # Fin BLOC HISTOGRAM



#  LAPLACE = BLOC ( condition = " Law in ( 'Laplace', ) ",
#
#                   Lambda = SIMP ( statut = "o",
#                                   typ = "R",
#                                   max = 1,
#                                   val_min = 0.,
#                                   fr = "Parametre Lambda | Lambda > 0",
#                                   ang = "Lambda parameter | Lambda > 0",
#                                   ),
#
#                   Mu = SIMP ( statut = "o",
#                               typ = "R",
#                               max = 1,
#                               fr = "Moyenne de la loi",
#                               ang = "Mean value",
#                              ),
#
#  ), # Fin BLOC LAPLACE
#
#  LOGNORMAL = BLOC ( condition = " Law in ( 'LogNormal', ) ",
#
#                     Settings = SIMP ( statut = "o",
#                                       typ = "TXM",
#                                       max = 1,
#                                       into = ( "MuSigmaLog", "MuSigma", "MuSigmaOverMu" ),
#                                       defaut = "MuSigmaLog",
#                                       fr = "Parametrage de la loi lognormale",
#                                       ang = "Lognormal distribution parameter set",
#                                       ),
#
#                     MuSigma_Parameters = BLOC ( condition = " Settings in ( 'MuSigma', ) ",
#
#                                                 Mu = SIMP ( statut = "o",
#                                                             typ = "R",
#                                                             max = 1,
#                                                             fr = "Moyenne de la loi",
#                                                             ang = "Mean value",
#                                                             ),
#
#                                                 Sigma = SIMP ( statut = "o",
#                                                                typ = "R",
#                                                                max = 1,
#                                                                val_min = 0.,
#                                                                fr = "Ecart type de la loi",
#                                                                ang = "Standard deviation",
#                                                                ),
#
#                                                 ), # Fin BLOC MuSigma_Parameters
#
#                     MuSigmaOverMu_Parameters = BLOC ( condition = " Settings in ( 'MuSigmaOverMu', ) ",
#
#                                                 Mu = SIMP ( statut = "o",
#                                                             typ = "R",
#                                                             max = 1,
#                                                             fr = "Moyenne de la loi",
#                                                             ang = "Mean value",
#                                                             ),
#
#                                                 SigmaOverMu = SIMP ( statut = "o",
#                                                                typ = "R",
#                                                                max = 1,
#                                                                val_min = 0.,
#                                                                fr = "Rapport ecart type / moyenne de la loi",
#                                                                ang = "Standard deviation / mean value ratio",
#                                                                ),
#
#                                                 ), # Fin BLOC MuSigmaOverMu_Parameters
#
#                     MuSigmaLog_Parameters = BLOC ( condition = " Settings in ( 'MuSigmaLog', ) ",
#
#                                                    MuLog = SIMP ( statut = "o",
#                                                                   typ = "R",
#                                                                   max = 1,
#                                                                   fr = "Moyenne du log",
#                                                                   ang = "Log mean value",
#                                                                   ),
#
#                                                    SigmaLog = SIMP ( statut = "o",
#                                                                      typ = "R",
#                                                                      max = 1,
#                                                                      val_min = 0.,
#                                                                      fr = "Ecart type du log",
#                                                                      ang = "Log standard deviation",
#                                                                      ),
#
#                                                    ), # Fin BLOC MuSigmaLog_Parameters
#
#                     Gamma = SIMP ( statut = "o",
#                                    typ = "R",
#                                    max = 1,
#                                    fr = "Borne inferieure du support de la loi",
#                                    ang = "Support lower bound",
#                                    ),
#
#   ), # Fin BLOC LOGNORMAL
#
#
#
#   LOGISTIC = BLOC ( condition = " Law in ( 'Logistic', ) ",
#
#                       Alpha = SIMP ( statut = "o",
#                                      typ = "R",
#                                      max = 1,
#                                      fr = "Borne inferieure du supoport de la loi",
#                                      ang = "Support lower bound",
#                                      ),
#
#                       Beta = SIMP ( statut = "o",
#                                     typ = "R",
#                                     max = 1,
#                                     val_min = 0.,
#                                     fr = "Parametre Beta de la loi | Beta > 0",
#                                     ang = "Beta parameter | Beta > 0",
#                                     ),
#
#   ), # Fin BLOC LOGISTIC
#
#
#
#   MULTINOMIAL = BLOC ( condition = " Law in ( 'MultiNomial', ) ",
#
#                         N = SIMP ( statut = "o",
#                                    typ = "I",
#                                    max = 1,
#                                    fr = "Parametre N de la loi | N > 0",
#                                    ang = "N parameter | N > 0",
#                                    ),
#
#                       # Il faut definir une collection de couples ( x,p )
#                       Values = SIMP ( statut = 'o',
#                                       typ = "R",
#                                       max = '**',
#                                       fr = "Liste de probabilit�s",
#                                       ang = "Probability list",
#                                       validators=VerifTypeTuple(('R','R')),
#                                       ),
#
#   ), # Fin BLOC MULTINOMIAL
#
#
#  NONCENTRALSTUDENT = BLOC ( condition = " Law in ( 'NonCentralStudent', ) ",
#
#                   Nu = SIMP ( statut = "o",
#                               typ = "R",
#                               max = 1,
#                               fr = "Parametre Nu de la loi | Nu > 0",
#                               ang = "Nu parameter | Nu > 0",
#                              ),
#
#                   Delta = SIMP ( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  fr = "Parametre Delta de la loi | Delta > 0",
#                                  ang = "Delta parameter | Delta > 0",
#                                  ),
#
#                   Gamma = SIMP ( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  fr = "Parametre Gamma de centrage de la loi",
#                                  ang = "Gamma parameter",
#                                  ),
#
#  ), # Fin BLOC NONCENTRALSTUDENT


   NORMAL = BLOC ( condition = " Law in ( 'Normal', ) ",

                    Mu = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Moyenne de la loi",
                                ang = "Mean value",
                                ),

                   Sigma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  val_min = 0.,
                                  fr = "Ecart type de la loi",
                                  ang = "Standard deviation",
                                  ),

   ), # Fin BLOC NORMAL


#
#   POISSON = BLOC ( condition = " Law in ( 'Poisson', ) ",
#
#                     Lambda = SIMP ( statut = "o",
#                                     typ = "R",
#                                     max = 1,
#                                     val_min = 0.,
#                                     fr = "Parametre Lambda de la loi | Lambda > 0",
#                                     ang = "Lambda parameter | Lambda > 0",
#                                     ),
#
#   ), # Fin BLOC POISSON
#
#
#
#  RAYLEIGH = BLOC ( condition = " Law in ( 'Rayleigh', ) ",
#
#                   Sigma = SIMP ( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  fr = "Parametre Sigma de la loi | Sigma > 0",
#                                  ang = "Sigma parameter | Sigma > 0",
#                                  ),
#
#                   Gamma = SIMP ( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  fr = "Borne inferieure du support de la loi",
#                                  ang = "Support lower bound",
#                                  ),
# ), # Fin BLOC RAYLEIGH

  PDF = BLOC ( condition = " Law in ( 'PDF_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Nom du fichier .csv",
                    ang = ".csv file name",
                    ),
              ),

#   STUDENT = BLOC ( condition = " Law in ( 'Student', ) ",
#
#                     Mu = SIMP ( statut = "o",
#                                 typ = "R",
#                                 max = 1,
#                                 fr = "Parametre Mu de la loi",
#                                 ang = "Mu parameter",
#                                 ),
#
#                     Nu = SIMP ( statut = "o",
#                                 typ = "R",
#                                 max = 1,
#                                 val_min = 2.,
#                                 fr = "Parametre Nu de la loi | Nu > 2",
#                                 ang = "Nu parameter | Nu > 2",
#                                 ),
#
#                   Sigma = SIMP ( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  fr = "Parametre Sigma de la loi",
#                                  ang = "Sigma parameter",
#                                  ),
#
#   ), # Fin BLOC STUDENT
#
#
#
#   TRIANGULAR = BLOC ( condition = " Law in ( 'Triangular', ) ",
#
#                         A = SIMP ( statut = "o",
#                                    typ = "R",
#                                    max = 1,
#                                    fr = "Borne inferieure du support de la loi | A < M < B",
#                                    ang = "Support lower bound | A < M < B",
#                                    ),
#
#                         M = SIMP ( statut = "o",
#                                    typ = "R",
#                                    max = 1,
#                                    fr = "Mode de la loi | A < M < B",
#                                    ang = "Mode | A < M < B",
#                                    ),
#
#                         B = SIMP ( statut = "o",
#                                    typ = "R",
#                                    max = 1,
#                                    fr = "Borne superieure du support de la loi | A < M < B",
#                                    ang = "Support upper bound | A < M < B",
#                                    ),
#
#   ), # Fin BLOC TRIANGULAR
#
#

   TRUNCATEDNORMAL = BLOC ( condition = " Law in ( 'TruncatedNormal', ) ",

                             MuN = SIMP ( statut = "o",
                                          typ = "R",
                                          max = 1,
                                          fr = "Moyenne de la loi Normale non tronqu�e",
                                          ang = "Mean value of the associated non truncated normal distribution",
                                          ),

                             SigmaN = SIMP ( statut = "o",
                                             typ = "R",
                                             max = 1,
                                             val_min = 0.,
                                             fr = "Ecart-type de la loi Normale non tronqu�e",
                                             ang = "Standard deviation of the associated non truncated normal distribution",
                                             ),

                             A = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne inferieure de la loi | A < B",
                                        ang = "Lower bound | A < B",
                                        ),

                             B = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne superieure de la loi | A < B",
                                        ang = "Upper bound | A < B",
                                        ),

   ), # Fin BLOC TRUNCATEDNORMAL


  TimeSeries = BLOC ( condition = " Law in ( 'TimeSeries_from_file', ) ",

  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Fichier CSV d'une serie temporelle",
                    ang = "CSV file of a time series",
                    ),
              ),


   UNIFORM = BLOC ( condition = " Law in ( 'Uniform', ) ",

                     A = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne inferieure du support de la loi | A < B",
                                ang = "Support lower bound | A < B",
                                ),

                     B = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne superieure du support de la loi | A < B",
                                ang = "Support upper bound | A < B",
                                ),

   ), # Fin BLOC UNIFORM


   USERDEFINED = BLOC ( condition = " Law in ( 'UserDefined', ) ",

                       # Il faut definir une collection de couples ( x,p )
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       max = '**',
                                       fr = "Liste de couples : (valeur, probabilite)",
                                       ang = "List of pairs : (value, probability)",
                                       validators=VerifTypeTuple(('R','R')),
                                       defaut=((0,0.0),(1,1.0)),
                                       ),

  ), # Fin BLOC USERDEFINED


   WEIBULL = BLOC ( condition = " Law in ( 'Weibull', ) ",

                     Settings = SIMP ( statut = "o",
                                          typ = "TXM",
                                          max = 1,
                                          into = ( "AlphaBeta", "MuSigma" ),
                                          defaut = "AlphaBeta",
                                          fr = "Parametrage de la loi weibull",
                                          ang = "Weibull distribution parameter set",
                                          ),

                     AlphaBeta_Parameters = BLOC ( condition = " Settings in ( 'AlphaBeta', ) ",

                                         Alpha = SIMP ( statut = "o",
                                                        typ = "R",
                                                        max = 1,
                                                        val_min = 0.,
                                                        fr = "Parametre Alpha de la loi | Alpha > 0",
                                                        ang = "Alpha parameter | Alpha > 0",
                                                        ),

                                         Beta = SIMP ( statut = "o",
                                                       typ = "R",
                                                       max = 1,
                                                       val_min = 0.,
                                                       fr = "Parametre Beta de la loi | Beta > 0",
                                                       ang = "Beta parameter | Beta > 0",
                                                       ),

                                         ), # Fin BLOC AlphaBeta_Parameters


                     MuSigma_Parameters = BLOC ( condition = " Settings in ( 'MuSigma', ) ",

                                         Mu = SIMP ( statut = "o",
                                                     typ = "R",
                                                     max = 1,
                                                     fr = "Moyenne de la loi",
                                                     ang = "Mean value",
                                                     ),

                                         Sigma = SIMP ( statut = "o",
                                                        typ = "R",
                                                        max = 1,
                                                        val_min = 0.,
                                                        fr = "Ecart type de la loi",
                                                        ang = "Standard deviation",
                                                        ),

                                         ), # Fin BLOC MuSigma_Parameters

                     Gamma = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du support de la loi",
                                    ang = "Support lower bound",
                                    ),

    ), # Fin BLOC WEIBULL



  ), #fin du bloc transformer


)

Classement_Commandes_Ds_Arbre=('DIRECTORY', 'DISTRIBUTION', 'CORRELATION',)

Ordre_Des_Commandes = ( 'DIRECTORY', 'PSSE_PARAMETERS', 'SIMULATION', 'DISTRIBUTION', 'CORRELATION',
                        'N_1_GENERATORS', 'N_1_LINES', 'N_1_TRANSFORMERS', 'N_1_LOADS',)

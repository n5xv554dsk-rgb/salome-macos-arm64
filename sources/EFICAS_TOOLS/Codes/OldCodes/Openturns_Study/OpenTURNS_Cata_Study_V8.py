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

class loi      ( ASSD ) : pass
class variable ( ASSD ) : pass

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
JdC = JDC_CATA ( code = 'OPENTURNS_STUDY',
                 execmodul = None,
                 regles = ( AU_MOINS_UN ( 'CRITERIA' ),
                            AU_MOINS_UN ( 'MODEL' ),
#                            AVANT ( ('DISTRIBUTION', 'MODEL'), 'VARIABLE' ),
#                            A_CLASSER ( 'VARIABLE',                'CORRELATION' ),
#                            A_CLASSER ( 'VARIABLE',                'CRITERIA' ),
#                            A_CLASSER ( 'CORRELATION',             'CRITERIA' ),
                            ),
                 ) # Fin JDC_CATA


# --------------------------------------------------
# fin entete
# --------------------------------------------------

SIMULATION = PROC ( nom = "SIMULATION",
             op = None,
             docu = "",
               
  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.csv);;All Files (*)',),
                    fr = "Nom du modele physique",
 ),
  SAMPLE = SIMP ( statut = "o",
                 typ = "R",
                 ),
               
  WrapperMessages = SIMP ( statut = "o",
                 typ = "TXM",
                 into = ( 'yes', 'no' ),
                 defaut = 'no',
                 fr = "Affichage du niveau de wrapper de la bibliotheque Open TURNS",
                 ang = "Open TURNS library debug level print",
                 ),
               
  UserMessages = SIMP ( statut = "o",
                 typ = "TXM",
                 into = ( 'yes', 'no' ),
                 defaut = 'no',
                 fr = "Affichage du niveau de user de la bibliotheque Open TURNS",
                 ang = "Open TURNS library user level print",
                 ),
               
  InfoMessages = SIMP ( statut = "o",
                 typ = "TXM",
                 into = ( 'yes', 'no' ),
                 defaut = 'yes',
                 fr = "Affichage du niveau de info de la bibliotheque Open TURNS",
                 ang = "Open TURNS library info level print",
                 ),
               
  WarningMessages = SIMP ( statut = "o",
                 typ = "TXM",
                 into = ( 'yes', 'no' ),
                 defaut = 'yes',
                 fr = "Affichage du niveau de warning de la bibliotheque Open TURNS",
                 ang = "Open TURNS library warning level print",
                 ),
               
  ErrorMessages = SIMP ( statut = "o",
                 typ = "TXM",
                 into = ( 'yes', 'no' ),
                 defaut = 'yes',
                 fr = "Affichage du niveau de error de la bibliotheque Open TURNS",
                 ang = "Open TURNS library error level print",
                 ),
               
) # Fin PROC SIMULATION
# Ordre Catalogue SIMULATION





#================================
# Definition des LOIS
#================================

# Nota : les variables de type OPER doivent etre en majuscules !
# Nota : les variables de type OPER doivent etre de premier niveau (pas imbriquees dans un autre type)
#VARIABLE2=OPER( nom= "VARIABLE2",
             
#DISTRIBUTION = OPER ( nom = "DISTRIBUTION",
VARIABLE2=OPER(nom="VARIABLE2",
                      sd_prod = variable,
                      #sd_prod = None,
                      op = None,
                      fr = "Definitions des lois marginales utilisees par les variables d'entree", 
                      
 #VARIABLE = FACT (statut='f',max='**',
 #             NOM=SIMP(statut = "o", typ = "TXM",),
                      
#DISTRIBUTION= FACT(statut = "o",
#====
# Type de distribution
#====

  Kind = SIMP ( statut = "o", typ = "TXM",
                into = ( "Beta",
                         "Exponential",
                         "Gamma",
                         "Geometric",
                         "Gumbel",
                         "Histogram",
                         "Laplace",
                         "Logistic",
                         "LogNormal",
                         "MultiNomial",
                         "NonCentralStudent",
                         "Normal",
                         "Poisson",
                         "Rayleigh",
                         "Student",
                         "Triangular",
                         "TruncatedNormal",
                         "Uniform",
                         #"UserDefined",
                         "Weibull",
                         ),
                fr = "Choix du type de la loi marginale",
                ang = "1D marginal distribution",
                defaut="Beta",
                ),

#====
# Definition des parametres selon le type de la loi
#====

  BETA = BLOC ( condition = " Kind in ( 'Beta', ) ",

                  Settings = SIMP ( statut = "o",
                                       typ = "TXM",
                                       max = 1,
                                       into = ( "RT", "MuSigma" ),
                                       defaut = "RT",
                                       fr = "Parametrage de la loi beta",
                                       ang = "Beta distribution parameter set",
                                       ),

                  RT_Parameters = BLOC ( condition = " Settings in ( 'RT', ) ",

                                      R = SIMP ( statut = "o",
                                                 typ = "R",
                                                 max = 1,
                                                 val_min = 0.,
                                                 fr = "Parametre R de la loi | R > 0",
                                                 ang = "R parameter | R > 0",
                                                 defaut=1,
                                                 ),

                                      # T > R
                                      T = SIMP ( statut = "o",
                                                 typ = "R",
                                                 max = 1,
                                                 val_min = 0.,
                                                 fr = "Parametre T de la loi | T > R",
                                                 ang = "T parameter | T > R",
                                                 defaut=2,
                                                 ),

                                      ), # Fin BLOC RT_Parameters


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


                  A = SIMP ( statut = "o",
                             typ = "R",
                             max = 1,
                             fr = "Borne inferieure du support de la loi",
                             ang = "Support lower bound",
                             ),

                  # B > A
                  B = SIMP ( statut = "o",
                             typ = "R",
                             max = 1,
                             fr = "Borne superieure du support de la loi",
                             ang = "Support upper bound",
                             ),

  ), # Fin BLOC BETA



  EXPONENTIAL = BLOC ( condition = " Kind in ( 'Exponential', ) ",

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



  GAMMA = BLOC ( condition = " Kind in ( 'Gamma', ) ",

                   Settings = SIMP ( statut = "o",
                                        typ = "TXM",
                                        max = 1,
                                        into = ( "KLambda", "MuSigma" ),
                                        defaut = "KLambda",
                                        fr = "Parametrage de la loi gamma",
                                        ang = "Gamma distribution parameter set",
                                        ),

                   KLambda_Parameters = BLOC ( condition = " Settings in ( 'KLambda', ) ",

                                       K = SIMP ( statut = "o",
                                                  typ = "R",
                                                  max = 1,
                                                  val_min = 0.,
                                                  fr = "Parametre K de la loi | K > 0",
                                                  ang = "K parameter | K > 0",
                                                  ),

                                       Lambda = SIMP ( statut = "o",
                                                       typ = "R",
                                                       max = 1,
                                                       val_min = 0.,
                                                       fr = "Parametre Lambda de la loi | Lambda > 0",
                                                       ang = "Lambda parameter | Lambda > 0",
                                                       ),

                                       ), # Fin BLOC KLambda_Parameters


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
                                  fr = "Borne inferieure du supoport de la loi",
                                  ang = "Support lower bound",
                                  ),


  ), # Fin BLOC GAMMA



  GEOMETRIC = BLOC ( condition = " Kind in ( 'Geometric', ) ",

                       P = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  val_min = 0.,
                                  val_max = 1.,
                                  fr = "Parametre P | 0 < P < 1",
                                  ang = "P parameter | 0 < P < 1",
                                  ),

  ), # Fin BLOC GEOMETRIC



  GUMBEL = BLOC ( condition = " Kind in ( 'Gumbel', ) ",

                    Settings = SIMP ( statut = "o",
                                         typ = "TXM",
                                         max = 1,
                                         into = ( "AlphaBeta", "MuSigma" ),
                                         defaut = "AlphaBeta",
                                         fr = "Parametrage de la loi gumbel",
                                         ang = "Gumbel distribution parameter set",
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
                                                      fr = "Parametre Beta de la loi",
                                                      ang = "Beta parameter",
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

  ), # Fin BLOC GUMBEL



  HISTOGRAM = BLOC ( condition = " Kind in ( 'Histogram', ) ",

                       First = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du supoport de la loi",
                                    ang = "Support lower bound",
                                    ),

                       # Il faut definir une collection de couples ( x,p ) 
                       Values = SIMP ( statut = 'o',
                                       typ = Tuple(2),
                                       #max = '**', 
                                       fr = "Liste de couples : largeur de classe, hauteur de classe",
                                       ang = "Class bandwidth, class height couple list",
                                       validators=VerifTypeTuple(('R','R')),
                                       ),

  ), # Fin BLOC HISTOGRAM



  LAPLACE = BLOC ( condition = " Kind in ( 'Laplace', ) ",

                   Lambda = SIMP ( statut = "o",
                                   typ = "R",
                                   max = 1,
                                   val_min = 0.,
                                   fr = "Parametre Lambda | Lambda > 0",
                                   ang = "Lambda parameter | Lambda > 0",
                                   ),
                   
                   Mu = SIMP ( statut = "o",
                               typ = "R",
                               max = 1,
                               fr = "Moyenne de la loi",
                               ang = "Mean value",
                              ),

  ), # Fin BLOC LAPLACE

  LOGNORMAL = BLOC ( condition = " Kind in ( 'LogNormal', ) ",

                     Settings = SIMP ( statut = "o",
                                       typ = "TXM",
                                       max = 1,
                                       into = ( "MuSigmaLog", "MuSigma", "MuSigmaOverMu" ),
                                       defaut = "MuSigmaLog",
                                       fr = "Parametrage de la loi lognormale",
                                       ang = "Lognormal distribution parameter set",
                                       ),

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

                     MuSigmaOverMu_Parameters = BLOC ( condition = " Settings in ( 'MuSigmaOverMu', ) ",

                                                 Mu = SIMP ( statut = "o",
                                                             typ = "R",
                                                             max = 1,
                                                             fr = "Moyenne de la loi",
                                                             ang = "Mean value",
                                                             ),

                                                 SigmaOverMu = SIMP ( statut = "o",
                                                                typ = "R",
                                                                max = 1,
                                                                val_min = 0.,
                                                                fr = "Rapport ecart type / moyenne de la loi",
                                                                ang = "Standard deviation / mean value ratio",
                                                                ),

                                                 ), # Fin BLOC MuSigmaOverMu_Parameters

                     MuSigmaLog_Parameters = BLOC ( condition = " Settings in ( 'MuSigmaLog', ) ",

                                                    MuLog = SIMP ( statut = "o",
                                                                   typ = "R",
                                                                   max = 1,
                                                                   fr = "Moyenne du log",
                                                                   ang = "Log mean value",
                                                                   ),

                                                    SigmaLog = SIMP ( statut = "o",
                                                                      typ = "R",
                                                                      max = 1,
                                                                      val_min = 0.,
                                                                      fr = "Ecart type du log",
                                                                      ang = "Log standard deviation",
                                                                      ),
                                            
                                                    ), # Fin BLOC MuSigmaLog_Parameters

                     Gamma = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du support de la loi",
                                    ang = "Support lower bound",
                                    ),

   ), # Fin BLOC LOGNORMAL



   LOGISTIC = BLOC ( condition = " Kind in ( 'Logistic', ) ",

                       Alpha = SIMP ( statut = "o",
                                      typ = "R",
                                      max = 1,
                                      fr = "Borne inferieure du supoport de la loi",
                                      ang = "Support lower bound",
                                      ),

                       Beta = SIMP ( statut = "o",
                                     typ = "R",
                                     max = 1,
                                     val_min = 0.,
                                     fr = "Parametre Beta de la loi | Beta > 0",
                                     ang = "Beta parameter | Beta > 0",
                                     ),

   ), # Fin BLOC LOGISTIC



   MULTINOMIAL = BLOC ( condition = " Kind in ( 'MultiNomial', ) ",
                         
                         N = SIMP ( statut = "o",
                                    typ = "I",
                                    max = 1,
                                    fr = "Parametre N de la loi | N > 0",
                                    ang = "N parameter | N > 0",
                                    ),

                       # Il faut definir une collection de couples ( x,p ) 
                       Values = SIMP ( statut = 'o',
                                       typ = "R",
                                       max = '**',
                                       fr = "Liste de probabilités",
                                       ang = "Probability list",
                                       validators=VerifTypeTuple(('R','R')),
                                       ),

   ), # Fin BLOC MULTINOMIAL


  NONCENTRALSTUDENT = BLOC ( condition = " Kind in ( 'NonCentralStudent', ) ",

                   Nu = SIMP ( statut = "o",
                               typ = "R",
                               max = 1,
                               fr = "Parametre Nu de la loi | Nu > 0",
                               ang = "Nu parameter | Nu > 0",
                              ),

                   Delta = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Parametre Delta de la loi | Delta > 0",
                                  ang = "Delta parameter | Delta > 0",
                                  ),
                   
                   Gamma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Parametre Gamma de centrage de la loi",
                                  ang = "Gamma parameter",
                                  ),

  ), # Fin BLOC NONCENTRALSTUDENT


   NORMAL = BLOC ( condition = " Kind in ( 'Normal', ) ",

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



   POISSON = BLOC ( condition = " Kind in ( 'Poisson', ) ",

                     Lambda = SIMP ( statut = "o",
                                     typ = "R",
                                     max = 1,
                                     val_min = 0.,
                                     fr = "Parametre Lambda de la loi | Lambda > 0",
                                     ang = "Lambda parameter | Lambda > 0",
                                     ),

   ), # Fin BLOC POISSON



  RAYLEIGH = BLOC ( condition = " Kind in ( 'Rayleigh', ) ",

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


   STUDENT = BLOC ( condition = " Kind in ( 'Student', ) ",

                     Mu = SIMP ( statut = "o",
                                 typ = "R",
                                 max = 1,
                                 fr = "Parametre Mu de la loi",
                                 ang = "Mu parameter",
                                 ),

                     Nu = SIMP ( statut = "o",
                                 typ = "R",
                                 max = 1,
                                 val_min = 2.,
                                 fr = "Parametre Nu de la loi | Nu > 2",
                                 ang = "Nu parameter | Nu > 2",
                                 ),

                   Sigma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Parametre Sigma de la loi",
                                  ang = "Sigma parameter",
                                  ),

   ), # Fin BLOC STUDENT



   TRIANGULAR = BLOC ( condition = " Kind in ( 'Triangular', ) ",

                         A = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure du support de la loi | A < M < B",
                                    ang = "Support lower bound | A < M < B",
                                    ),

                         M = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Mode de la loi | A < M < B",
                                    ang = "Mode | A < M < B",
                                    ),

                         B = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne superieure du support de la loi | A < M < B",
                                    ang = "Support upper bound | A < M < B",
                                    ),

   ), # Fin BLOC TRIANGULAR



   TRUNCATEDNORMAL = BLOC ( condition = " Kind in ( 'TruncatedNormal', ) ",

                             MuN = SIMP ( statut = "o",
                                          typ = "R",
                                          max = 1,
                                          fr = "Moyenne de la loi Normale non tronquée",
                                          ang = "Mean value of the associated non truncated normal distribution",
                                          ),

                             SigmaN = SIMP ( statut = "o",
                                             typ = "R",
                                             max = 1,
                                             val_min = 0.,
                                             fr = "Ecart-type de la loi Normale non tronquée",
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



   UNIFORM = BLOC ( condition = " Kind in ( 'Uniform', ) ",

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



   USERDEFINED = BLOC ( condition = " Kind in ( 'UserDefined', ) ",

                           # Il faut definir une collection de couples ( x,p ) 
                         Values = SIMP ( statut = 'o',
                                         typ = 'R',
                                         max = '**',
                                         ),

   ), # Fin BLOC USERDEFINED



   WEIBULL = BLOC ( condition = " Kind in ( 'Weibull', ) ",

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

#), # Fin OPER DISTRIBUTION
#), # Fin OPER DISTRIBUTION
) # Fin OPER DISTRIBUTION



#================================
# Definition du modele physique
#================================


DETERMINISTICVARIABLE = OPER ( nom = "DETERMINISTICVARIABLE",
            sd_prod = variable,
            op = None,
            fr = "Variable deterministe",
            ang = "Deterministic variable",
            UIinfo = {"groupes": ("CACHE")},
            
  N = SIMP ( statut = 'o',
             typ = "TXM",
             fr = "Nom",
             ang = "Name",
             ),
            
  T = SIMP ( statut = 'o',
             defaut = "in",
             into = ( "in" , "out", ),
             typ = "TXM",
             fr = "Type",
             ang = "Type",
             ),
            
  R = SIMP ( statut = 'o',
             defaut = 0,
             typ = "I",
             fr = "Rang",
             ang = "Rank",
             ),
            
) # Fin OPER DETERMINISTICVARIABLE
# Ordre Catalogue DETERMINISTICVARIABLE



import opsOT
MODEL = MACRO ( nom = "MODEL",
                op = None,
                UIinfo = { "groupes" : ( "Gestion du travail", ) },
                fr = "Chargement du wrapper du modele physique",
                ang = "Physical model wrapper load",
                sd_prod = opsOT.INCLUDE,
                op_init = opsOT.INCLUDE_context,
                fichier_ini = 1,
               
  FileName = SIMP ( statut = "o",
                    typ = ('Fichier', 'Wrapper Files (*.xml);;All Files (*)',),
                    fr = "Nom du modele physique",
                    ang = "Physical model identifier",
                    ),
               
) # Fin PROC MODEL
# Ordre Catalogue MODEL




VARIABLE = PROC ( nom = "VARIABLE",
                  op = None,
                  docu = "",
                  fr = "Variable probabiliste",
                  ang = "Probabilistic variable",

  ModelVariable = SIMP ( statut = "o",
                         typ = ( variable, ),
                         fr = "Variable d'entrée du modèle",
                         ang = "Input variable of the model",
                         ),

  Distribution = SIMP ( statut = "o",
                        typ = ( loi, ),
                        fr = "Modélisation probabiliste",
                        ang = "Probabilistic modelisation",
                        ),
                  
) # Fin PROC VARIABLE
# Ordre Catalogue VARIABLE


CORRELATION = PROC ( nom = 'CORRELATION',
                     op = None,
                     docu = "",
                     fr = "Correlation entre variables",
                     ang = "Variable correlation",

  Copula = SIMP ( statut = "o",
                  typ = 'TXM',
                  into = ( "Independent", "Normal" ),
                  defaut = "Independent",
                  fr = "Type de la copule",
                  ang = "Copula kind",
                  ),

  Matrix = BLOC ( condition = "Copula in ( 'Normal', )",
                  
    CorrelationMatrix = SIMP ( statut = "o",
                               typ = Matrice(nbLigs=None,
                                             nbCols=None,
                                             methodeCalculTaille='NbDeVariables',
                                             valSup=1,
                                             valMin=-1,
                                             structure="symetrique"),
                               fr = "Matrice de correlation entre les variables d'entree",
                               ang = "Correlation matrix for input variables",
                               ),
  ), # Fin BLOC Matrix


) # Fin PROC CORRELATION
# Ordre Catalogue CORRELATION





#================================
# Definition de l'etude
#================================

# Nota : les variables de type PROC doivent etre en majuscules !
CRITERIA = PROC ( nom = "CRITERIA",
                  op = None,
                  docu = "",
                  fr = "Critère de l'étude d'incertitudes",
                  ang = "Uncertainty study criteria",



  Type = SIMP ( statut = "o",
                typ = "TXM",
                into = ( "Min/Max", "Central Uncertainty", "Threshold Exceedence" ),
                fr = "Type du critère",
                ang = "Criteria type",
                ),







  MinMax = BLOC ( condition = " Type in ( 'Min/Max', ) ",

                  Method = SIMP ( statut = "o",
                                  typ = "TXM",
                                  into = ( "Experiment Plane", "Random Sampling" ),
                                  fr = "Methode",
                                  ang = "Method",
                                  ),
                  # UC 3.1.1
                  ExperimentPlaneSettings = BLOC ( condition = " Method in ( 'Experiment Plane', ) ",

                          ExperimentPlane = SIMP ( statut = "o",
                                                   typ = "TXM",
                                                   into = ( "Axial", "Factorial", "Composite", ),
                                                   fr = "Type du plan d'expérience",
                                                   ang = "Experiment plane type",
                                                   ),

                          Levels = SIMP ( statut = "o",
                                          typ = "R",
                                          val_min = 0.0,
                                          max = '**',    
                                          fr = "Liste de niveaux dans chaque direction",
                                          ang = "Levels in each direction",
                                          ),

                          # Scaled Vector
                          UnitPerDimension = SIMP ( statut = "o",
                                          typ = "R",
                                          max = '**',    
                                          fr = "Unité par dimension (autant que de variables declarées)",
                                          ang = "Units per dimension (as much as declared variables)",
                                          ),

                          # Translation Vector
                          Center = SIMP ( statut = "o",
                                          typ = "R",
                                          max = '**',    
                                          fr = "Centre du plan d'expérience",
                                          ang = "Experiment plan center",
                                          ),

                    ), # Fin BLOC ExperimentPlaneSettings



                  RandomSamplingSettings = BLOC ( condition = " Method in ( 'Random Sampling', ) ",

                          SimulationsNumber = SIMP ( statut = "o",
                                                typ = "I",
                                                val_min = 1,
                                                fr = "Nombre de points",
                                                ang = "Points number",
                                                ),

                    ), # Fin BLOC RandomSamplingSettings

                  Result = SIMP (  statut = "o",
                                   typ = "TXM",
                                   into = ( "Min/Max", ),
                                   defaut = "Min/Max",
                                   fr = "Le minimum et le maximum de la variable d'intérêt",
                                   ang = "The min and max values",
                                   ),


  ), # Fin BLOC MinMax




  CentralUncertainty = BLOC ( condition = " Type in ( 'Central Uncertainty', ) ",

                  Method = SIMP ( statut = "o",
                                  typ = "TXM",
                                  into = ( "Taylor Variance Decomposition", "Random Sampling" ),
                                  fr = "Methode",
                                  ang = "Method",
                                  ),
                              
                  # UC 3.2.
                  TaylorVarianceDecompositionSettings = BLOC ( condition = " Method in ( 'Taylor Variance Decomposition', ) ",

                      Result = FACT ( statut = "o",
                                      min = 1,
                                      max = "**",

                              MeanFirstOrder = SIMP ( statut = "o",
                                                typ = 'TXM',
                                                into = ( 'yes', 'no' ),
                                                defaut = 'yes',
                                                max = 1,
                                                fr = "Moyenne au premier ordre",
                                                ang = "MeanFirstOrder",
                                                ),

                              StandardDeviationFirstOrder = SIMP ( statut = "o",
                                                                   typ = 'TXM',
                                                                   into = ( 'yes', 'no' ),
                                                                   defaut = 'yes',
                                                                   max = 1,
                                                                   fr = "Ecart-type au premier ordre",
                                                                   ang = "StandardDeviationFirstOrder",
                                                                   ),

                              MeanSecondOrder = SIMP ( statut = "o",
                                                       typ = 'TXM',
                                                       into = ( 'yes', 'no' ),
                                                       defaut = 'no',
                                                       max = 1,
                                                       fr = "Moyenne au second ordre",
                                                       ang = "MeanSecondOrder",
                                                       ),

                              ImportanceFactor = SIMP ( statut = "o",
                                                        typ = 'TXM',
                                                        into = ( 'yes', 'no' ),
                                                        defaut = 'yes',
                                                        max = 1,
                                                        fr = "Facteur d'importance pour variable de sortie scalaire",
                                                        ang = "ImportanceFactor",
                                                        ),
                              ImportanceFactorSettings = BLOC ( condition = " ImportanceFactor in ( 'yes', ) ",

                                     ImportanceFactorDrawingFilename = SIMP ( statut = "o",
                                                                              typ = "TXM",
                                                                              max = 1,
                                                                              fr = "Nom du fichier graphique des facteurs d'importance",
                                                                              ang = "Importance Factor Drawing Filename",
                                                                              ),
                                                                             

                              ), # Fin BLOC ImportanceFactorSettings
                                      
                      ), # Fin FACT Result
                                                               
                  ), # Fin BLOC TaylorVarianceDecompositionSettings



                  RandomSamplingSettings = BLOC ( condition = " Method in ( 'Random Sampling', ) ",

                          SimulationsNumber = SIMP ( statut = "o",
                                                typ = "I",
                                                val_min = 1,
                                                fr = "Nombre de points",
                                                ang = "Points number",
                                                ),

                       Result = FACT ( statut = "o",
                                      min = 1,
                                      max = "**",

                              EmpiricalMean = SIMP ( statut = "o",
                                                     typ = 'TXM',
                                                     into = ( 'yes', 'no' ),
                                                     defaut = 'yes',
                                                     max = 1,
                                                     fr = "Moyenne empirique",
                                                     ang = "Empirical mean",
                                                     ),

                              EmpiricalStandardDeviation = SIMP ( statut = "o",
                                                                  typ = 'TXM',
                                                                  into = ( 'yes', 'no' ),
                                                                  defaut = 'yes',
                                                                  max = 1,
                                                                  fr = "Ecart-type empirique",
                                                                  ang = "Empirical standard deviation",
                                                                  ),

                              EmpiricalQuantile = SIMP ( statut = "o",
                                                         typ = 'TXM',
                                                         into = ( 'yes', 'no' ),
                                                         defaut = 'yes',
                                                         max = 1,
                                                         fr = "Quantile empirique",
                                                         ang = "Empirical quantile",
                                                         ),

                              EmpiricalQuantileSettings = BLOC ( condition = " EmpiricalQuantile in ( 'yes', ) ",

                                  EmpiricalQuantile_Order = SIMP ( statut = "o",
                                                                   typ = 'R',
                                                                   defaut = 0.95,
                                                                   max = 1,
                                                                   val_min = 0.0,
                                                                   val_max = 1.0,
                                                                   fr = "Ordre du quantile empirique",
                                                                   ang = "Empirical quantile order",
                                                                   ),

                              ), # Fin BLOC EmpiricalQuantileSettings

                              CorrelationAnalysis = SIMP ( statut = "o",
                                                            typ = 'TXM',
                                                            into = ( 'yes', 'no' ),
                                                            defaut = 'yes',
                                                            max = 1,
                                                            fr = "Correlations analysees",
                                                            ang = "Analysed correlations",
                                                            ),

                              KernelSmoothing = SIMP ( statut = "o",
                                                       typ = 'TXM',
                                                       into = ( 'yes', 'no' ),
                                                       defaut = 'yes',
                                                       max = 1,
                                                       fr = "Kernel smoothing de l'echantillon",
                                                       ang = "Kernel smoothing of the sample",
                                                       ),

                              KernelSmoothingSettings = BLOC ( condition = " KernelSmoothing in ( 'yes', ) ",

                                     KernelSmoothingDrawingFilename = SIMP ( statut = "o",
                                                                              typ = "TXM",
                                                                              max = 1,
                                                                              fr = "Nom du fichier graphique de la reconstruction a processing",
                                                                              ang = "Kernel Smoothing Drawing Filename",
                                                                              ),
                                                                             

                              ), # Fin BLOC KernelSmoothingSettings
                                      
                      ), # Fin FACT Result
                                                               
                  ), # Fin BLOC RandomSamplingSettings

  ), # Fin BLOC CentralUncertainty




  ThresholdExceedence = BLOC ( condition = " Type in ( 'Threshold Exceedence', ) ",

         Event =  FACT ( statut = "o",
                         min = 1,
                         max = 1,

                         Threshold = SIMP ( statut = "o",
                                            typ = "R",
                                            max = 1,
                                            fr = "Le seuil de defaillance",
                                            ang = "Failure threshold",
                                            ),

                         ComparisonOperator = SIMP ( statut = "o",
                                                     typ = "TXM",
                                                     max = 1,
                                                     into = ( "Less", "LessOrEqual", "Equal", "GreaterOrEqual", "Greater" ),
                                                     fr = "Que faut-il ne pas depasser : un maximum ou un minimum",
                                                     ang = "What is the failure threshold : maximum or minimum",
                                                     ),
         ), # Fin FACT Event
                         

         Method = SIMP ( statut = "o",
                         typ = "TXM",
                         into = ( "Simulation", "FORM_SORM" ),
                         fr = "Methode",
                         ang = "Method",
                         ),

         SimulationSettings = BLOC ( condition = " Method in ( 'Simulation', ) ",

               Algorithm = SIMP ( statut = "o",
                                  typ = "TXM",
                                  into = ( "MonteCarlo", "LHS", "ImportanceSampling" ),
                                  fr = "Algorithme de simulation",
                                  ang = "Simulation algorithm",
                                  ),

                                 
               RandomGenerator = FACT ( statut = "o",
                                        min = 1,
                                        max = 1,

                           SeedToBeSet = SIMP ( statut = "o",
                                                typ = 'TXM',
                                                into = ( 'yes', 'no' ),
                                                defaut = 'no',
                                                max = 1,
                                                fr = "La racine du generateur aleatoire doit-elle etre positionnee ?",
                                                ang = "Does the random generator seed need to be set ?",
                                                ),

                           SeedSettings = BLOC ( condition = " SeedToBeSet in ( 'yes', ) ",

                                                 RandomGeneratorSeed = SIMP ( statut = "o",
                                                                              typ = "I",
                                                                              max = 1,
                                                                              fr = "Racine du generateur aleatoire",
                                                                              ang = "Random generator seed",
                                                                              ),

                                               ), # Fin BLOC SeedSettings

               ), # Fin FACT RandomGenerator


               BlockSize = SIMP ( statut = "o",
                                  typ = "I",
                                  max = 1,
                                  val_min = 1,
                                  defaut = 1,
                                  fr = "Nombre de calculs realises en bloc",
                                  ang = "Number of computations as a block",
                                  ),

               MaximumOuterSampling = SIMP ( statut = "o",
                                             typ = "I",
                                             max = 1,
                                             val_min = 1,
                                             fr = "Maximum d'iterations externes",
                                             ang = "Maximum outer Sampling value",
                                             ),

               MaximumCoefficientOfVariation = SIMP ( statut = "o",
                                                      typ = "R",
                                                      max = 1,
                                                      defaut = 0.1,
                                                      val_min = 0.0,
                                                      val_max = 1.0,
                                                      fr = "Coefficient de variation maximum",
                                                      ang = "Maximum coefficient of variation"
                                                      ),

               ImportanceSamplingSettings = BLOC ( condition = " Algorithm in ( 'ImportanceSampling', ) ",

                            MeanVector = SIMP ( statut = "o",
                                                typ = "R",
                                                max = "**",
                                                fr = "Moyenne",
                                                ang = "Mean vector",
                                                ),


               ), # Fin BLOC ImportanceSamplingSettings

               Result = FACT ( statut = "o",
                                      min = 1,
                                      max = "**",

                    Probability = SIMP ( statut = "o",
                                         typ = 'TXM',
                                         into = ( 'yes', ),
                                         defaut = 'yes',
                                         max = 1,
                                         fr = "Probabiblite",
                                         ang = "Probability",
                                         ),

                    StandardDeviation = SIMP ( statut = "o",
                                         typ = 'TXM',
                                         into = ( 'yes', ),
                                         defaut = 'yes',
                                         max = 1,
                                         fr = "Ecart type",
                                         ang = "Standard deviation",
                                         ),

                    ConfidenceInterval = SIMP ( statut = "o",
                                                typ = 'TXM',
                                                into = ( 'yes', 'no' ),
                                                defaut = 'yes',
                                                max = 1,
                                                fr = "Intervale de confiance",
                                                ang = "Confidence interval",
                                                ),

                    ConfidenceIntervalSettings = BLOC ( condition = " ConfidenceInterval in ( 'yes', ) ",

                          Level = SIMP ( statut = "o",
                                         typ = 'R',
                                         defaut = 0.9,
                                         max = 1,
                                         val_min = 0.0,
                                         val_max = 1.0,
                                         fr = "Niveau de confiance",
                                         ang = "Confidence level",
                                         ),
                                                     
                    ), # Fin BLOC ConfidenceIntervalSettings
                               
                    VariationCoefficient = SIMP ( statut = "o",
                                                  typ = 'TXM',
                                                  into = ( 'yes', 'no' ),
                                                  defaut = 'yes',
                                                  max = 1,
                                                  fr = "Coefficient de variation",
                                                  ang = "Coefficient of variation",
                                                  ),

                    SimulationsNumber = SIMP ( statut = "o",
                                             typ = 'TXM',
                                             into = ( 'yes', 'no' ),
                                             defaut = 'yes',
                                             max = 1,
                                             fr = "Nombre d'iterations",
                                             ang = "Iteration number",
                                             ),

                    ConvergenceGraph = SIMP ( statut = "o",
                                             typ = 'TXM',
                                             into = ( 'yes', 'no' ),
                                             defaut = 'yes',
                                             max = 1,
                                             fr = "Graphe de convergence",
                                             ang = "Convergence graph",
                                             ),
                               
                    ConvergenceGraphSettings = BLOC ( condition = " ConvergenceGraph in ( 'yes', ) ",

                                     ConvergenceDrawingFilename = SIMP ( statut = "o",
                                                                         typ = "TXM",
                                                                         max = 1,
                                                                         fr = "Nom du fichier graphique de la convergence",
                                                                         ang = "Convergence Drawing Filename",
                                                                         ),
                                                                             

                              ), # Fin BLOC ConvergenceGraphSettings
                                      
             ), # Fin FACT Result
                                                               


         ), # Fin BLOC SimulationSettings


                               
         FORM_SORMSettings = BLOC ( condition = " Method in ( 'FORM_SORM', ) ",

                Approximation = SIMP ( statut = "o",
                                       typ = "TXM",
                                       defaut = "FirstOrder",
                                       into = ( "FirstOrder", "SecondOrder" ),
                                       max = 1,
                                       fr = "Approximation",
                                       ang = "Approximation",
                                       ),

                OptimizationAlgorithm = SIMP ( statut = "o",
                                               typ = "TXM",
                                               defaut = "Cobyla",
                                               into = ( "Cobyla", "AbdoRackwitz" ),
                                               max = 1,
                                               fr = "Methode d'optimisation",
                                               ang = "Optimization method",
                                               ),

                                     
                PhysicalStartingPoint = SIMP ( statut = "f",
                                               typ = "R",
                                               max = "**",
                                               fr = "Point de demarrage de l'algorithme iteratif",
                                               ang = "Initial point for iterative process",
                                               ),

                MaximumIterationsNumber = SIMP ( statut = "f",
                                                 typ = "I",
                                                 max = 1,
                                                 val_min = 1,
                                                 fr = "Nombre maximum d'iterations",
                                                 ang = "Maximum number of iterations",
                                                 ),

                                     
                MaximumAbsoluteError = SIMP ( statut = "o",
                                              typ = "R",
                                              max = 1,
                                              defaut = 1E-4,
                                              val_min = 0.0,
                                              fr = "Distance maximum absolue entre 2 iterations successives",
                                              ang = "Absolute maximum distance between 2 successive iterates",
                                              ),

                MaximumRelativeError = SIMP ( statut = "o",
                                               typ = "R",
                                               max = 1,
                                               defaut = 1E-4,
                                               val_min = 0.0,
                                               fr = "Distance maximum relative entre 2 iterations successives",
                                               ang = "Relative maximum distance between 2 successive iterates",
                                               ),
                                     
                MaximumConstraintError = SIMP ( statut = "o",
                                                typ = "R",
                                                max = 1,
                                                defaut = 1E-4,
                                                val_min = 0.0,
                                                fr = "Valeur maximum absolue de la fonction moins la valeur du niveau",
                                                ang = "Maximum absolute value of the constraint function minus the level value",
                                                ),

                ImportanceSampling = SIMP ( statut = "o",
                                            typ = 'TXM',
                                            into = ( 'yes', 'no' ),
                                            defaut = 'no',
                                            max = 1,
                                            fr = "Tirage d'importance au point de conception",
                                            ang = "Importance sampling at design point",
                                            ),

                FORMResult = BLOC ( condition = " Approximation in ( 'FirstOrder', ) ",

                    Probability = SIMP ( statut = "o",
                                         typ = 'TXM',
                                         into = ( 'yes', ),
                                         defaut = 'yes',
                                         max = 1,
                                         fr = "Probabiblite",
                                         ang = "Probability",
                                         ),

                    DesignPoint = SIMP ( statut = "o",
                                         typ = 'TXM',
                                         into = ( 'yes', 'no' ),
                                         defaut = 'yes',
                                         max = 1,
                                         fr = "Point de conception",
                                         ang = "Design point",
                                         ),

                    HasoferReliabilityIndex = SIMP ( statut = "o",
                                                 typ = 'TXM',
                                                 into = ( 'yes', 'no' ),
                                                 defaut = 'yes',
                                                 max = 1,
                                                 fr = "Indice de fiabilite",
                                                 ang = "Reliability index",
                                                 ),

                    ImportanceFactor = SIMP ( statut = "o",
                                              typ = 'TXM',
                                              into = ( 'yes', 'no' ),
                                              defaut = 'yes',
                                              max = 1,
                                              fr = "Facteur d'importance pour variable de sortie scalaire",
                                              ang = "Importance factor",
                                              ),

                    ImportanceFactorSettings = BLOC ( condition = " ImportanceFactor in ( 'yes', ) ",

                                     ImportanceFactorDrawingFilename = SIMP ( statut = "o",
                                                                              typ = "TXM",
                                                                              max = 1,
                                                                              fr = "Nom du fichier graphique des facteurs d'importance",
                                                                              ang = "Importance Factor Drawing Filename",
                                                                              ),
                                                                             

                              ), # Fin BLOC ImportanceFactorSettings
                                      
                    SensitivityAnalysis = SIMP ( statut = "o",
                                                 typ = 'TXM',
                                                 into = ( 'yes', 'no' ),
                                                 defaut = 'yes',
                                                 max = 1,
                                                 fr = "Analyse de sensibilite",
                                                 ang = "Sensitivity analysis",
                                                 ),

                    SensitivityAnalysisSettings = BLOC ( condition = " SensitivityAnalysis in ( 'yes', ) ",

                            FORMEventProbabilitySensitivity = SIMP ( statut = "o",
                                                             typ = 'TXM',
                                                             into = ( 'yes', 'no' ),
                                                             defaut = 'yes',
                                                             max = 1,
                                                             fr = "Indice de fiabilite de Hasofer",
                                                             ang = "Hasofer reliability index",
                                                             ),
        
                            FORMEventProbabilitySensitivitySettings = BLOC ( condition = " FORMEventProbabilitySensitivity in ( 'yes', ) ",

                                     FORMEventProbabilitySensitivityDrawingFilename = SIMP ( statut = "o",
                                                                         typ = "TXM",
                                                                         max = 1,
                                                                         fr = "Nom du fichier graphique des sensibilites",
                                                                         ang = "Sensitivity Drawing Filename",
                                                                         ),
                                                                             

                              ), # Fin BLOC FORMEventProbabilitySensitivitySettings
                                      
                            HasoferReliabilityIndexSensitivity = SIMP ( statut = "o",
                                                             typ = 'TXM',
                                                             into = ( 'yes', 'no' ),
                                                             defaut = 'yes',
                                                             max = 1,
                                                             fr = "Indice de fiabilite de Hasofer",
                                                             ang = "Hasofer reliability index",
                                                             ),
        
                            HasoferReliabilityIndexSensitivitySettings = BLOC ( condition = " HasoferReliabilityIndexSensitivity in ( 'yes', ) ",

                                     HasoferReliabilityIndexSensitivityDrawingFilename = SIMP ( statut = "o",
                                                                         typ = "TXM",
                                                                         max = 1,
                                                                         fr = "Nom du fichier graphique des sensibilites",
                                                                         ang = "Sensitivity Drawing Filename",
                                                                         ),
                                                                             

                              ), # Fin BLOC FHasoferReliabilityIndexSensitivitySettings
                                      
                    ), # Fin BLOC SensitivityAnalysisSettings

                    FunctionCallsNumber = SIMP ( statut = "o",
                                                 typ = 'TXM',
                                                 into = ( 'yes', 'no' ),
                                                 defaut = 'yes',
                                                 max = 1,
                                                 fr = "Nombre d'appels a la fonction",
                                                 ang = "Function calls number",
                                                 ),


                ), # Fin BLOC FORMResult


                SORMResult = BLOC ( condition = " Approximation in ( 'SecondOrder', ) ",


                    TvedtApproximation = SIMP ( statut = "o",
                                                typ = 'TXM',
                                                into = ( 'yes', 'no' ),
                                                defaut = 'yes',
                                                max = 1,
                                                fr = "Approximation de Tvedt",
                                                ang = "Tvedt approximation",
                                                ),

                    HohenBichlerApproximation = SIMP ( statut = "o",
                                                       typ = 'TXM',
                                                       into = ( 'yes', 'no' ),
                                                       defaut = 'yes',
                                                       max = 1,
                                                       fr = "Approximation de HohenBichler",
                                                       ang = "HohenBichler approximation",
                                                       ),

                    BreitungApproximation = SIMP ( statut = "o",
                                                   typ = 'TXM',
                                                   into = ( 'yes', 'no' ),
                                                   defaut = 'yes',
                                                   max = 1,
                                                   fr = "Approximation de Breitung",
                                                   ang = "Breitung approximation",
                                                   ),

                    DesignPoint = SIMP ( statut = "o",
                                         typ = 'TXM',
                                         into = ( 'yes', 'no' ),
                                         defaut = 'yes',
                                         max = 1,
                                         fr = "Point de conception",
                                         ang = "Design point",
                                         ),

                    ImportanceFactor = SIMP ( statut = "o",
                                              typ = 'TXM',
                                              into = ( 'yes', 'no' ),
                                              defaut = 'yes',
                                              max = 1,
                                              fr = "Facteur d'importance pour variable de sortie scalaire",
                                              ang = "Importance factor",
                                              ),

                    ImportanceFactorSettings = BLOC ( condition = " ImportanceFactor in ( 'yes', ) ",

                                     ImportanceFactorDrawingFilename = SIMP ( statut = "o",
                                                                              typ = "TXM",
                                                                              max = 1,
                                                                              fr = "Nom du fichier graphique des facteurs d'importance",
                                                                              ang = "Importance Factor Drawing Filename",
                                                                              ),
                                                                             

                              ), # Fin BLOC ImportanceFactorSettings
                                      
                    SensitivityAnalysis = SIMP ( statut = "o",
                                                 typ = 'TXM',
                                                 into = ( 'yes', 'no' ),
                                                 defaut = 'yes',
                                                 max = 1,
                                                 fr = "Analyse de sensibilite",
                                                 ang = "Sensitivity analysis",
                                                 ),

                    SensitivityAnalysisSettings = BLOC ( condition = " SensitivityAnalysis in ( 'yes', ) ",

                            HasoferReliabilityIndexSensitivity = SIMP ( statut = "o",
                                                             typ = 'TXM',
                                                             into = ( 'yes', 'no' ),
                                                             defaut = 'yes',
                                                             max = 1,
                                                             fr = "Indice de fiabilite de Hasofer",
                                                             ang = "Hasofer reliability index",
                                                             ),
                                                                 
                            HasoferReliabilityIndexSensitivitySettings = BLOC ( condition = " HasoferReliabilityIndexSensitivity in ( 'yes', ) ",

                                     HasoferReliabilityIndexSensitivityDrawingFilename = SIMP ( statut = "o",
                                                                         typ = "TXM",
                                                                         max = 1,
                                                                         fr = "Nom du fichier graphique des sensibilites",
                                                                         ang = "Sensitivity Drawing Filename",
                                                                         ),
                                                                             

                              ), # Fin BLOC FHasoferReliabilityIndexSensitivitySettings
                                      
                    ), # Fin BLOC SensitivityAnalysisSettings

                    FunctionCallsNumber = SIMP ( statut = "o",
                                                 typ = 'TXM',
                                                 into = ( 'yes', 'no' ),
                                                 defaut = 'yes',
                                                 max = 1,
                                                 fr = "Nombre d'appels a la fonction",
                                                 ang = "Function calls number",
                                                 ),


                ), # Fin BLOC SecondOrder


                                     
        ), # Fin BLOC FORM_SORMSettings


                               
  ), # Fin BLOC ThresholdExceedence



) # Fin PROC CRITERIA
# Ordre Catalogue CRITERIA








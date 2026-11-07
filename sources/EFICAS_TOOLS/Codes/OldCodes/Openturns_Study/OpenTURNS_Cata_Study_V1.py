# -*- coding: utf-8 -*-

# --------------------------------------------------
# debut entete
# --------------------------------------------------

import Accas
from Accas import *

class loi ( ASSD ) : pass
class variable ( ASSD ) : pass


#CONTEXT.debug = 1
JdC = JDC_CATA ( code = 'OPENTURNS_STUDY',
                 execmodul = None,
                 regles = ( AU_MOINS_UN ( 'CRITERIA' ), ),
                 ) # Fin JDC_CATA

# --------------------------------------------------
# fin entete
# --------------------------------------------------






#================================
# 1. Definition des LOIS
#================================

# Nota : les variables de type OPER doivent etre en majuscules !
# Nota : les variables de type OPER doivent etre de premier niveau (pas imbriquees dans un autre type)
DISTRIBUTION = OPER ( nom = "DISTRIBUTION",
                      sd_prod = loi,
                      op = 68,
                      fr = "Definitions des lois marginales utilisees par les variables d'entree", 
                      
                      
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
                         "Logistic",
                         "LogNormal",
                         "MultiNomial",
                         "Normal",
                         "TruncatedNormal",
                         "Poisson",
                         "Student",
                         "Triangular",
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
                                                 fr = "Parametre R de la loi",
                                                 ang = "R parameter",
                                                 ),

                                      # T > R
                                      T = SIMP ( statut = "o",
                                                 typ = "R",
                                                 max = 1,
                                                 val_min = 0.,
                                                 fr = "Parametre T de la loi | T > R",
                                                 ang = "T parameter | T > R",
                                                 ),

                                      ), # Fin BLOC RT_Parameters


                  MuSigma_Parameters = BLOC ( condition = " Settings in ( 'MuSigma', ) ",

                                      Mu = SIMP ( statut = "o",
                                                  typ = "R",
                                                  max = 1,
                                                  fr = "Parametre Mu de la loi",
                                                  ang = "Mu parameter",
                                                  ),

                                      Sigma = SIMP ( statut = "o",
                                                     typ = "R",
                                                     max = 1,
                                                     val_min = 0.,
                                                     fr = "Parametre Sigma de la loi | Sigma > 0",
                                                     ang = "Sigma parameter | Sigma > 0",
                                                     ),

                                      ), # Fin BLOC MuSigma_Parameters


                  A = SIMP ( statut = "o",
                             typ = "R",
                             max = 1,
                             fr = "Parametre A de la loi",
                             ang = "A parameter",
                             ),

                  # B > A
                  B = SIMP ( statut = "o",
                             typ = "R",
                             max = 1,
                             fr = "Parametre B de la loi | B > A",
                             ang = "B parameter | B > A",
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
                                        fr = "Parametre Gamma",
                                        ang = "Gamma parameter",
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
                                                   defaut = 0.0,
                                                   fr = "Parametre Mu de la loi",
                                                   ang = "Mu parameter",
                                                   ),

                                       Sigma = SIMP ( statut = "o",
                                                      typ = "R",
                                                      max = 1,
                                                      defaut = 1.0,
                                                      val_min = 0.,
                                                      fr = "Parametre Sigma de la loi | Sigma > 0",
                                                      ang = "Sigma parameter | Sigma > 0",
                                                      ),

                                       ), # Fin BLOC MuSigma_Parameters

                   Gamma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  fr = "Parametre Gamma",
                                  ang = "Gamma parameter",
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
                                                    fr = "Parametre Mu de la loi",
                                                    ang = "Mu parameter",
                                                    ),

                                        Sigma = SIMP ( statut = "o",
                                                       typ = "R",
                                                       max = 1,
                                                       val_min = 0.,
                                                       fr = "Parametre Sigma de la loi | Sigma > 0",
                                                       ang = "Sigma parameter | Sigma > 0",
                                                       ),

                                        ), # Fin BLOC MuSigma_Parameters

  ), # Fin BLOC GUMBEL



  HISTOGRAM = BLOC ( condition = " Kind in ( 'Histogram', ) ",

                       Sup = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne superieure de la distribution",
                                    ang = "Upper bound",
                                    ),

                       # Il faut definir une collection de couples ( x,p ) 
                       Values = SIMP ( statut = 'o',
                                       typ = 'R',
                                       max = '**',
                                       ),

  ), # Fin BLOC HISTOGRAM



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
                                                             fr = "Parametre Mu de la loi | Mu > Gamma",
                                                             ang = "Mu parameter | Mu > Gamma",
                                                             ),

                                                 Sigma = SIMP ( statut = "o",
                                                                typ = "R",
                                                                max = 1,
                                                                val_min = 0.,
                                                                fr = "Parametre Sigma de la loi | Sigma > 0",
                                                                ang = "Sigma parameter | Sigma > 0",
                                                                ),

                                                 ), # Fin BLOC MuSigma_Parameters

                     MuSigmaOverMu_Parameters = BLOC ( condition = " Settings in ( 'MuSigmaOverMu', ) ",

                                                 Mu = SIMP ( statut = "o",
                                                             typ = "R",
                                                             max = 1,
                                                             fr = "Parametre Mu de la loi | Mu > Gamma",
                                                             ang = "Mu parameter | Mu > Gamma",
                                                             ),

                                                 SigmaOverMu = SIMP ( statut = "o",
                                                                typ = "R",
                                                                max = 1,
                                                                val_min = 0.,
                                                                fr = "Parametre SigmaOverMu de la loi | SigmaOverMu > 0",
                                                                ang = "SigmaOverMu parameter | SigmaOverMu > 0",
                                                                ),

                                                 ), # Fin BLOC MuSigmaOverMu_Parameters

                     MuSigmaLog_Parameters = BLOC ( condition = " Settings in ( 'MuSigmaLog', ) ",

                                                    MuLog = SIMP ( statut = "o",
                                                                   typ = "R",
                                                                   max = 1,
                                                                   fr = "Parametre Mu log de la loi",
                                                                   ang = "Mu log parameter",
                                                                   ),

                                                    SigmaLog = SIMP ( statut = "o",
                                                                      typ = "R",
                                                                      max = 1,
                                                                      val_min = 0.,
                                                                      fr = "Parametre Sigma log de la loi | SigmaLog > 0",
                                                                      ang = "Sigma log parameter | SigmaLog > 0",
                                                                      ),
                                            
                                                    ), # Fin BLOC MuSigmaLog_Parameters

                     Gamma = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Parametre Gamma",
                                    ang = "Gamma parameter",
                                    ),

   ), # Fin BLOC LOGNORMAL



   LOGISTIC = BLOC ( condition = " Kind in ( 'Logistic', ) ",

                       Alpha = SIMP ( statut = "o",
                                      typ = "R",
                                      max = 1,
                                      fr = "Parametre Alpha de la loi",
                                      ang = "Alpha parameter",
                                      ),

                       Beta = SIMP ( statut = "o",
                                     typ = "R",
                                     max = 1,
                                     val_min = 0.,
                                     fr = "Parametre Beta de la loi | Beta > = 0",
                                     ang = "Beta parameter | Beta > = 0",
                                     ),

   ), # Fin BLOC LOGISTIC



   MULTINOMIAL = BLOC ( condition = " Kind in ( 'MultiNomial', ) ",
                         
                         N = SIMP ( statut = "o",
                                    typ = "I",
                                    max = 1,
                                    fr = "Dimension de la loi",
                                    ang = "Distribution dimension",
                                    ),

                         # Il faut un vecteur P de taille N
                         Values = SIMP ( statut = 'o',
                                         typ = 'R',
                                         max = '**',
                                         ),

   ), # Fin BLOC MULTINOMIAL



   NORMAL = BLOC ( condition = " Kind in ( 'Normal', ) ",

                    Mu = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Parametre Mu de la loi",
                                ang = "Mu parameter",
                                ),

                   Sigma = SIMP ( statut = "o",
                                  typ = "R",
                                  max = 1,
                                  val_min = 0.,
                                  fr = "Parametre Sigma de la loi | Sigma > 0",
                                  ang = "Sigma parameter | Sigma > 0",
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
                                 fr = "Parametre Nu de la loi | V > = 2",
                                 ang = "Nu parameter | V > = 2",
                                 ),

   ), # Fin BLOC STUDENT



   TRIANGULAR = BLOC ( condition = " Kind in ( 'Triangular', ) ",

                         A = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne inferieure de la loi | A < = M < = B",
                                    ang = "Lower bound | A < = M < = B",
                                    ),

                         M = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Mode de la loi | A < = M < = B",
                                    ang = "Mode | A < = M < = B",
                                    ),

                         B = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Borne superieure de la loi | A < = M < = B",
                                    ang = "Upper bound | A < = M < = B",
                                    ),

   ), # Fin BLOC TRIANGULAR



   TRUNCATEDNORMAL = BLOC ( condition = " Kind in ( 'TruncatedNormal', ) ",

                             MuN = SIMP ( statut = "o",
                                          typ = "R",
                                          max = 1,
                                          fr = "Parametre Mu de la loi",
                                          ang = "Mu parameter",
                                          ),

                             SigmaN = SIMP ( statut = "o",
                                             typ = "R",
                                             max = 1,
                                             val_min = 0.,
                                             fr = "Parametre SigmaN de la loi | SigmaN > 0",
                                             ang = "SigmaN parameter | SigmaN> 0",
                                             ),

                             A = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne inferieure de la loi | A < = B",
                                        ang = "Lower bound | A < = B",
                                        ),

                             B = SIMP ( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        fr = "Borne superieure de la loi | A < = B",
                                        ang = "Upper bound | A < = B",
                                        ),

   ), # Fin BLOC TRUNCATEDNORMAL



   UNIFORM = BLOC ( condition = " Kind in ( 'Uniform', ) ",

                     A = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne inferieure de la loi | A < = B",
                                ang = "Lower bound | A < = B",
                                ),

                     B = SIMP ( statut = "o",
                                typ = "R",
                                max = 1,
                                fr = "Borne superieure de la loi | A < = B",
                                ang = "Upper bound | A < = B",
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
                                                     fr = "Parametre Mu de la loi",
                                                     ang = "Mu parameter",
                                                     ),

                                         Sigma = SIMP ( statut = "o",
                                                        typ = "R",
                                                        max = 1,
                                                        val_min = 0.,
                                                        fr = "Parametre Sigma de la loi | Sigma > 0",
                                                        ang = "Sigma parameter | Sigma > 0",
                                                        ),

                                         ), # Fin BLOC MuSigma_Parameters

                     Gamma = SIMP ( statut = "o",
                                    typ = "R",
                                    max = 1,
                                    fr = "Parametre Gamma",
                                    ang = "Gamma parameter",
                                    ),

    ), # Fin BLOC WEIBULL

) # Fin OPER DISTRIBUTION






#================================
# 3. Definition de l'etude
#================================

# Nota : les variables de type PROC doivent etre en majuscules !
CRITERIA = PROC ( nom = "CRITERIA",
                  op = None,
                  docu = "",
                  fr = "Mise en donnee pour le fichier de configuration de OPENTURNS.",
                  ang = "Writes the configuration file for OPENTURNS.",



  Type = SIMP ( statut = "o",
                typ = "TXM",
                into = ( "Min/Max", "Central Uncertainty", "Threshold Exceedence" ),
                fr = "Type d'Analyse",
                ang = "Analysis",
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
                                                   fr = "Methode",
                                                   ang = "Method",
                                                   ),

                          Levels = SIMP ( statut = "o",
                                          typ = "R",
                                          val_min = 0.0,
                                          max = '**',    
                                          fr = "Nombre de niveaux dans chaque direction",
                                          ang = "Levels in each direction",
                                          ),

                          # Scaled Vector
                          UnitsPerDimension = SIMP ( statut = "o",
                                          typ = "R",
                                          max = '**',    
                                          fr = "Unite par dimension (autant que de variables declarees)",
                                          ang = "Units per dimension (as much as declared variables)",
                                          ),

                          # Translation Vector
                          Center = SIMP ( statut = "o",
                                          typ = "R",
                                          max = '**',    
                                          fr = "Unite par dimension",
                                          ang = "Units per dimension",
                                          ),

                    ), # Fin BLOC ExperimentPlaneSettings



                  RandomSamplingSettings = BLOC ( condition = " Method in ( 'Random Sampling', ) ",

                          PointsNumber = SIMP ( statut = "o",
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
                                   fr = "Le minimum et le maximum",
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
                                                       defaut = 'yes',
                                                       max = 1,
                                                       fr = "Moyenne au second ordre",
                                                       ang = "MeanSecondOrder",
                                                       ),

                              ImportanceFactor = SIMP ( statut = "o",
                                                        typ = 'TXM',
                                                        into = ( 'yes', 'no' ),
                                                        defaut = 'no',
                                                        max = 1,
                                                        fr = "Facteur d'importance pour variable de sortie scalaire",
                                                        ang = "ImportanceFactor",
                                                        ),

                             ImportanceFactorSettings = BLOC ( condition = " ImportanceFactor in ( 'yes', ) ",

                                    NumericalResults  = SIMP ( statut = "o",
                                                               typ = 'TXM',
                                                               into = ( 'yes', 'no' ),
                                                               defaut = 'yes',
                                                               max = 1,
                                                               fr = "Resultats numeriques",
                                                               ang = "NumericalResults",
                                                               ),

                                     GraphicalResults  = SIMP ( statut = "o",
                                                                typ = 'TXM',
                                                                into = ( 'yes', 'no' ),
                                                                defaut = 'no',
                                                                max = 1,
                                                                fr = "Resultats graphiques",
                                                                ang = "GraphicalResults",
                                                                ),

                            ), # Fin BLOC ImportanceFactorSettings

                      ), # Fin FACT Result
                                                               
                  ), # Fin BLOC TaylorVarianceDecompositionSettings



                  RandomSamplingSettings = BLOC ( condition = " Method in ( 'Random Sampling', ) ",

                          PointsNumber = SIMP ( statut = "o",
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
                                                         typ = 'R',
                                                         defaut = 0.0,
                                                         max = 1,
                                                         val_min = 0.0,
                                                         val_max = 1.0,
                                                         fr = "Quantile empirique",
                                                         ang = "Empirical quantile",
                                                         ),

                              AnalysedCorrelations = SIMP ( statut = "o",
                                                            typ = 'TXM',
                                                            into = ( 'yes', 'no' ),
                                                            defaut = 'no',
                                                            max = 1,
                                                            fr = "Correlations analysees",
                                                            ang = "Analysed correlations",
                                                            ),

                              KernelSmoothing = SIMP ( statut = "o",
                                                       typ = 'TXM',
                                                       into = ( 'yes', 'no' ),
                                                       defaut = 'no',
                                                       max = 1,
                                                       fr = "Kernel smoothing de l'echantillon",
                                                       ang = "Kernel smoothing of the sample",
                                                       ),

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
                         into = ( "Simulation", "Analytical" ),
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


               BlockSize = SIMP ( statut = "f",
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

               MaximumCoefficientOfVariation = SIMP ( statut = "f",
                                                      typ = "R",
                                                      max = 1,
                                                      defaut = 0.1,
                                                      val_min = 0.0,
                                                      fr = " maximum ...",
                                                      ang = "Absolute maximum ...."
                                                      ),

               ImportanceSamplingSettings = BLOC ( condition = " Algorithm in ( 'ImportanceSampling', ) ",

                            MeanVector = SIMP ( statut = "o",
                                                typ = "R",
                                                max = "**",
                                                fr = "Moyenne",
                                                ang = "Mean vector",
                                                ),

                            Correlation = SIMP ( statut = "o",
                                                 typ = 'TXM',
                                                 into = ( 'Independent', 'Linear' ),
                                                 defaut = 'Linear',
                                                 max = 1,
                                                 fr = "Le type de correlation entre les variables",
                                                 ang = "Correlation between variables",
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

                    ConfidenceInterval = SIMP ( statut = "o",
                                                typ = 'TXM',
                                                into = ( 'yes', 'no' ),
                                                defaut = 'yes',
                                                max = 1,
                                                fr = "Ecart-type empirique",
                                                ang = "Empirical standard deviation",
                                                ),

                    ConfidenceIntervalSettings = BLOC ( condition = " ConfidenceInterval in ( 'yes', ) ",

                          Level = SIMP ( statut = "o",
                                         typ = 'R',
                                         defaut = 0.0,
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
                                                  ang = "VariationCoefficient",
                                                  ),

                    IterationNumber = SIMP ( statut = "o",
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

               ), # Fin FACT Result
                                                               


         ), # Fin BLOC SimulationSettings


                               
         AnalyticalSettings = BLOC ( condition = " Method in ( 'Analytical', ) ",

                Approximation = SIMP ( statut = "o",
                                       typ = "TXM",
                                       into = ( "FORM", "SORM" ),
                                       fr = "Approximation",
                                       ang = "Approximation",
                                       ),

                OptimizationAlgorithm = SIMP ( statut = "o",
                                               typ = "TXM",
                                               into = ( "Cobyla", "AbdoRackwitz" ),
                                               fr = "Methode d'optimisation",
                                               ang = "Optimisation method",
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
                                                 fr = "Nombre maximum d iterations",
                                                 ang = "Maximum number of iterations",
                                                 ),

                regles = ( EXCLUS ( "MaximumAbsoluteError", "RelativeAbsoluteError" ),  ),
                                     
                MaximumAbsoluteError = SIMP ( statut = "f",
                                              typ = "R",
                                              max = 1,
                                              defaut = 1E-6,
                                              val_min = 0.0,
                                              fr = "Distance maximum absolue entre 2 iterations successifs",
                                              ang = "Absolute maximum distance between 2 successive iterates",
                                              ),

                RelativeAbsoluteError = SIMP ( statut = "f",
                                               typ = "R",
                                               max = 1,
                                               defaut = 1E-6,
                                               val_min = 0.0,
                                               fr = "Distance maximum relative entre 2 iterations successives",
                                               ang = "Relative maximum distance between 2 successive iterates",
                                               ),
                                     
                MaximumConstraintError = SIMP ( statut = "f",
                                                typ = "R",
                                                max = 1,
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

                FORM = BLOC ( condition = " Approximation in ( 'FORM', ) ",

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

                    HasReliabilityIndex = SIMP ( statut = "o",
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
                                              defaut = 'no',
                                              max = 1,
                                              fr = "Facteur d'importance pour variable de sortie scalaire",
                                              ang = "ImportanceFactor",
                                              ),

                    ImportanceFactorSettings = BLOC ( condition = " ImportanceFactor in ( 'yes', ) ",

                            NumericalResults  = SIMP ( statut = "o",
                                                       typ = 'TXM',
                                                       into = ( 'yes', 'no' ),
                                                       defaut = 'yes',
                                                       max = 1,
                                                       fr = "Resultats numeriques",
                                                       ang = "NumericalResults",
                                                       ),

                             GraphicalResults  = SIMP ( statut = "o",
                                                        typ = 'TXM',
                                                        into = ( 'yes', 'no' ),
                                                        defaut = 'no',
                                                        max = 1,
                                                        fr = "Resultats graphiques",
                                                        ang = "GraphicalResults",
                                                        ),

                    ), # Fin BLOC ImportanceFactorSettings


                    SensitivityAnalysis = SIMP ( statut = "o",
                                                 typ = 'TXM',
                                                 into = ( 'yes', 'no' ),
                                                 defaut = 'no',
                                                 max = 1,
                                                 fr = "Analyse de sensibilite",
                                                 ang = "Sensitivity analysis",
                                                 ),

                    SensitivityAnalysisSettings = BLOC ( condition = " SensitivityAnalysis in ( 'yes', ) ",

                            HasoferReliabilityIndex = SIMP ( statut = "o",
                                                             typ = 'TXM',
                                                             into = ( 'yes', 'no' ),
                                                             defaut = 'no',
                                                             max = 1,
                                                             fr = "Indice de fiabilite de Hasofer",
                                                             ang = "Hasofer reliability index",
                                                             ),
        
                            HasoferReliabilityIndexSettings = BLOC ( condition = " HasoferReliabilityIndex in ( 'yes', ) ",
        
                                    NumericalResults  = SIMP ( statut = "o",
                                                               typ = 'TXM',
                                                               into = ( 'yes', 'no' ),
                                                               defaut = 'yes',
                                                               max = 1,
                                                               fr = "Resultats numeriques",
                                                               ang = "NumericalResults",
                                                               ),
        
                                     GraphicalResults  = SIMP ( statut = "o",
                                                                typ = 'TXM',
                                                                into = ( 'yes', 'no' ),
                                                                defaut = 'no',
                                                                max = 1,
                                                                fr = "Resultats graphiques",
                                                                ang = "GraphicalResults",
                                                                ),

                            ), # Fin BLOC HasoferReliabilityIndexSettings
                                                         
                    ), # Fin BLOC SensitivityAnalysisSettings

                    FunctionCallsNumber = SIMP ( statut = "o",
                                                 typ = 'TXM',
                                                 into = ( 'yes', 'no' ),
                                                 defaut = 'no',
                                                 max = 1,
                                                 fr = "Nombre d'appels a la fonction",
                                                 ang = "Function calls number",
                                                 ),


                ), # Fin BLOC FORM


                SORM = BLOC ( condition = " Approximation in ( 'SORM', ) ",


                    TvedtApproximation = SIMP ( statut = "o",
                                                typ = 'TXM',
                                                into = ( 'yes', 'no' ),
                                                defaut = 'no',
                                                max = 1,
                                                fr = "Approximation de Tvedt",
                                                ang = "Tvedt approximation",
                                                ),

                    HohenBichlerApproximation = SIMP ( statut = "o",
                                                       typ = 'TXM',
                                                       into = ( 'yes', 'no' ),
                                                       defaut = 'no',
                                                       max = 1,
                                                       fr = "Approximation de HohenBichler",
                                                       ang = "HohenBichler approximation",
                                                       ),

                    BreitungApproximation = SIMP ( statut = "o",
                                                   typ = 'TXM',
                                                   into = ( 'yes', 'no' ),
                                                   defaut = 'no',
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
                                              defaut = 'no',
                                              max = 1,
                                              fr = "Facteur d'importance pour variable de sortie scalaire",
                                              ang = "ImportanceFactor",
                                              ),

                    ImportanceFactorSettings = BLOC ( condition = " ImportanceFactor in ( 'yes', ) ",

                            NumericalResults  = SIMP ( statut = "o",
                                                       typ = 'TXM',
                                                       into = ( 'yes', 'no' ),
                                                       defaut = 'yes',
                                                       max = 1,
                                                       fr = "Resultats numeriques",
                                                       ang = "NumericalResults",
                                                       ),

                             GraphicalResults  = SIMP ( statut = "o",
                                                        typ = 'TXM',
                                                        into = ( 'yes', 'no' ),
                                                        defaut = 'no',
                                                        max = 1,
                                                        fr = "Resultats graphiques",
                                                        ang = "GraphicalResults",
                                                        ),

                    ), # Fin BLOC ImportanceFactorSettings


                    SensitivityAnalysis = SIMP ( statut = "o",
                                                 typ = 'TXM',
                                                 into = ( 'yes', 'no' ),
                                                 defaut = 'no',
                                                 max = 1,
                                                 fr = "Analyse de sensibilite",
                                                 ang = "Sensitivity analysis",
                                                 ),

                    SensitivityAnalysisSettings = BLOC ( condition = " SensitivityAnalysis in ( 'yes', ) ",

                            HasoferReliabilityIndex = SIMP ( statut = "o",
                                                             typ = 'TXM',
                                                             into = ( 'yes', 'no' ),
                                                             defaut = 'no',
                                                             max = 1,
                                                             fr = "Indice de fiabilite de Hasofer",
                                                             ang = "Hasofer reliability index",
                                                             ),
        
                            HasoferReliabilityIndexSettings = BLOC ( condition = " HasoferReliabilityIndex in ( 'yes', ) ",
        
                                    NumericalResults  = SIMP ( statut = "o",
                                                               typ = 'TXM',
                                                               into = ( 'yes', 'no' ),
                                                               defaut = 'yes',
                                                               max = 1,
                                                               fr = "Resultats numeriques",
                                                               ang = "NumericalResults",
                                                               ),
        
                                     GraphicalResults  = SIMP ( statut = "o",
                                                                typ = 'TXM',
                                                                into = ( 'yes', 'no' ),
                                                                defaut = 'no',
                                                                max = 1,
                                                                fr = "Resultats graphiques",
                                                                ang = "GraphicalResults",
                                                                ),

                            ), # Fin BLOC HasoferReliabilityIndexSettings
                                                         
                    ), # Fin BLOC SensitivityAnalysisSettings

                    FunctionCallsNumber = SIMP ( statut = "o",
                                                 typ = 'TXM',
                                                 into = ( 'yes', 'no' ),
                                                 defaut = 'no',
                                                 max = 1,
                                                 fr = "Nombre d'appels a la fonction",
                                                 ang = "Function calls number",
                                                 ),


                ), # Fin BLOC SORM


                                     
        ), # Fin BLOC AnalyticalSettings


                               
  ), # Fin BLOC ThresholdExceedence



) # Fin PROC CRITERIA


#===============================
# 5. Definition des parametres
#===============================
VARI = OPER ( nom = "VARI",
                      sd_prod = variable,
                      op = None,
                      fr = "Definitions des lois marginales utilisees par les variables d'entree", 
                      type=SIMP(statut='f',defaut="IN",into=("IN","OUT"), typ = "TXM",)
              )

AAA=PROC(nom="AAA",
       op=None,
       fr="Essai",
       ang = "Test",
       
       MALOI       = SIMP(statut='o',typ=(loi,),),
       MAVARIABLE  = SIMP(statut='o',typ=(variable,),),
) ;

                     

import ops
FICXML=MACRO(nom="FICXML",
            op=None,
            UIinfo={"groupes":("Gestion du travail",)},
            fr="Débranchement vers un fichier de commandes secondaires",
            sd_prod=ops.INCLUDE,op_init=ops.INCLUDE_context,fichier_ini=1,
            FICHIER  = SIMP(statut='o',typ='TXM',),
);


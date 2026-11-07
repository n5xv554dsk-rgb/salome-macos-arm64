import os, sys
repInitial = os.path.dirname(os.path.abspath(__file__))
repEficas = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if os.path.dirname(repInitial) not in sys.path :
   sys.path.insert(0,repInitial)
if os.path.dirname(repEficas) not in sys.path :
   sys.path.insert(0,repEficas)
import types

from Accas import OPER, BLOC, FACT, SIMP, ASSD, JDC_CATA, VerifTypeTuple, Matrice, Tuple, AU_MOINS_UN,  PROC 
from Accas.processing.P_VALIDATOR import Valid

#TODO --> si UserDefined et Uranie alors UserDefined


class CataError(Exception):
    pass


class compareAutreMC(Valid) :
#----------------------------
    def __init__(self,frere=None):
        Valid.__init__(self, frere=frere)
        self.nomFrere=frere
        
    def set_MCSimp (self, MCSimp):
        self.MCSimp=MCSimp

class supValeurProbabiliste(compareAutreMC):
#-------------------------------------------
    def convert(self, valeur):
        try : VP=self.MCSimp.parent.parent.parent.variableDeterministe.valeur
        except : return valeur
        if VP == None : return valeur
        if VP > valeur : 
           raise CataError('la valeur de la variable Probabiliste  est superieure a la valeur entree ')
        return valeur

    def verifItem(self, valeur):
        try : VP=self.MCSimp.parent.parent.parent.variableDeterministe.valeur
        except : return valeur
        if VP == None : return valeur
        if VP > valeur :
           raise CataError(' la valeur de la variable Probabiliste est superieure a la valeur entree et doit etre inferieure')
           return 0
        return valeur

    def infoErreurItem(self, valeur):
        return 'la valeur de la variable Probabiliste est superieure a la valeur entree et doit etre inferieure'


class infValeurProbabiliste(compareAutreMC):
#-------------------------------------------
    def convert(self, valeur):
        valeur=valeur
        try : VP=self.MCSimp.parent.parent.parent.variableDeterministe.valeur
        except : return valeur
        VP=self.MCSimp.parent.parent.parent.variableDeterministe.valeur
        if VP < valeur : 
           raise CataError('la valeur de la variable Probabiliste  est inferieure a la valeur entree ')
        return valeur

    def verifItem(self, valeur):
        try : VP=self.MCSimp.parent.parent.parent.variableDeterministe.valeur
        except : return valeur
        if VP == None : return valeur
        if VP  < valeur :
           raise CataError(' la valeur de la variable Probabiliste est inferieure a la valeur entree et doit etre superieure')
           return 0
        return valeur

    def infoErreurItem(self, valeur):
        return 'la valeur de la variable Probabiliste est inferieure a la valeur entree et doit etre superieure'

class infFrereMC(compareAutreMC):
#-------------------------------
    def convert(self, valeur):
        # on sort de cardProto on a une liste
        valeur=valeur[0]
        try: MCFrere=self.MCSimp.parent.getChildOrChildInBloc(self.nomFrere)
        except : return valeur
        if not MCFrere    : return valeur
        if MCFrere== None : return valeur
        if MCFrere.valeur  == None : return valeur
        if MCFrere.valeur  < valeur : 
           raise CataError('la valeur de '+self.nomFrere + ' est inferieure a la valeur entree ')
        return valeur

    def verifItem(self, valeur):
        try: MCFrere=self.MCSimp.parent.getChildOrChildInBloc(self.nomFrere)
        except : return valeur
        if not MCFrere    : return valeur
        if MCFrere== None : return valeur
        if MCFrere.valeur  == None : return valeur
        if MCFrere.valeur  < valeur :
           raise CataError('la valeur de '+self.nomFrere + ' est inferieure a la valeur entree et doit etre superieure')
           return 0
        return 1

    def infoErreurItem(self, valeur):
        return 'la valeur de '+self.nomFrere + ' est inferieure a la valeur entree et doit etre superieure'

    def info(self):
        return 'la valeur de '+self.nomFrere + ' est inferieure a la valeur entree et doit etre superieure'

class supFrereMC(compareAutreMC):
#--------------------------------
    def convert(self, valeur):
        # on sort de cardProto on a une liste
        valeur=valeur[0]
        MCFrere=self.MCSimp.parent.getChildOrChildInBloc(self.nomFrere)
        if not MCFrere    : return valeur
        if MCFrere== None : return valeur
        if MCFrere.valeur  > valeur : 
           raise CataError('la valeur de '+self.nomFrere + ' est superieure a la valeur entree et doit etre inferieure')
        return valeur

    def verifItem(self, valeur):
        MCFrere=self.MCSimp.parent.getChildOrChildInBloc(self.nomFrere)
        if not MCFrere    : return 1
        if MCFrere== None : return 1
        if MCFrere.valeur  > valeur :
           raise CataError('la valeur de '+self.nomFrere + ' est superieure a la valeur entree et doit etre inferieure')
           return 0
        return 1

    def infoErreurItem(self, valeur):
        return 'la valeur de '+self.nomFrere + ' est superieure a la valeur entree et doit etre inferieure'

    def info(self):
        return 'la valeur de '+self.nomFrere + ' est superieure a la valeur entree '
# 
#listeLoiDistribution= (  #"Beta", #"Exponential", #"Gamma", #"Geometric", #"Gumbel", #"Histogram", #"Laplace", #"Logistic", #"LogNormal", #"MultiNomial",
                         #"NonCentralStudent", #"Normal", #"Poisson", #"Rayleigh", #"Student", #"Triangular", "TruncatedNormal", "Uniform", "UserDefined",
                         #"Weibull",),

##====
## Definition des parametres selon le type de la loi
##====

def creeBeta ( MuMax=1 ):
    MuSimp = SIMP( statut = "o", typ = "R", max = 1, val_max=MuMax,
                   fr = "Moyenne de la loi",
                   ang = "Mean value",
                  )
    BETA = BLOC( condition = "Distribution == 'Beta'",
         Settings = SIMP( statut = "o", typ = "TXM", max = 1,
                          into = ( "RT", "MuSigma" ),
                          defaut = "RT",
                          fr = "Parametrage de la loi beta",
                          ang = "Beta distribution parameter set",
                        ),

         RT_Parameters = BLOC( condition = " Settings in ( 'RT', ) ",
                R = SIMP( statut = "o", typ = "R", max = 1, val_min = 0.,
                          fr = "Parametre R de la loi | R > 0",
                          ang = "R parameter | R > 0",
                        ),

                # T > R
                T = SIMP( statut = "o", typ = "R", max = 1, val_min = 0.,
                          fr = "Parametre T de la loi | T > R",
                          ang = "T parameter | T > R",
                         ),
          ), # Fin BLOC RT_Parameters

         MuSigma_Parameters = BLOC( condition = " Settings in ( 'MuSigma', ) ",
                 Mu=MuSimp,
                 Sigma = SIMP( statut = "o", typ = "R", max = 1, val_min = 0.,
                               fr = "Ecart type de la loi",
                               ang = "Standard deviation",
                             ),
         ), # Fin BLOC MuSigma_Parameters

         A = SIMP( statut = "o", typ = "R", max = 1,
                   fr = "Borne inferieure du support de la loi",
                   ang = "Support lower bound",
                  ),

         # B > A
         B = SIMP( statut = "o", typ = "R", max = 1,
                   fr = "Borne superieure du support de la loi",
                   ang = "Support upper bound",
                   ),

        ) # Fin BLOC BETA
    return BETA

def creeExponential ():
  EXPONENTIAL = BLOC( condition = " Distribution in ( 'Exponential', ) ",

         Lambda = SIMP( statut = "o", typ = "R", max = 1, val_min = 0.,
                    fr = "Parametre Lambda | Lambda > 0",
                    ang = "Lambda parameter | Lambda > 0",
                    ),

         Gamma = SIMP( statut = "o", typ = "R", max = 1,
                    fr = "Borne inferieure du support de la loi",
                    ang = "Support lower bound",
                    ),
  ) # Fin BLOC EXPONENTIAL
  return EXPONENTIAL

#def creeGamma ():
#  GAMMA = BLOC( condition = " Distribution in ( 'Gamma', ) ",
#
#          Settings = SIMP( statut = "o", typ = "TXM", max = 1, into = ( "KLambda", "MuSigma" ), defaut = "KLambda",
#                    fr = "Parametrage de la loi gamma",
#                    ang = "Gamma distribution parameter set",
#                    ),
#
#          KLambda_Parameters = BLOC( condition = " Settings in ( 'KLambda', ) ",
#
#                 K = SIMP( statut = "o", typ = "R", max = 1, val_min = 0.,
#                    fr = "Parametre K de la loi | K > 0",
#                    ang = "K parameter | K > 0",
#                    ),
#
#                 Lambda = SIMP( statut = "o", typ = "R", max = 1, val_min = 0.,
#                    fr = "Parametre Lambda de la loi | Lambda > 0",
#                    ang = "Lambda parameter | Lambda > 0",
#                 ),
#
#          ), # Fin BLOC KLambda_Parameters
#
#
#         MuSigma_Parameters = BLOC( condition = " Settings in ( 'MuSigma', ) ",
#
#                                       Mu = SIMP( statut = "o",
#                                                   typ = "R",
#                                                   max = 1,
#                                                   fr = "Moyenne de la loi",
#                                                   ang = "Mean value",
#                                                   ),
#
#                                       Sigma = SIMP( statut = "o",
#                                                      typ = "R",
#                                                      max = 1,
#                                                      val_min = 0.,
#                                                      fr = "Ecart type de la loi",
#                                                      ang = "Standard deviation",
#                                                      ),
#
#                                       ), # Fin BLOC MuSigma_Parameters
#
#                   Gamma = SIMP( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  fr = "Borne inferieure du supoport de la loi",
#                                  ang = "Support lower bound",
#                                  ),
#
#
#  ) # Fin BLOC GAMMA

#
#
#  GEOMETRIC = BLOC( condition = " Distribution in ( 'Geometric', ) ",
#
#                       P = SIMP( statut = "o",
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
#  GUMBEL = BLOC( condition = " Distribution in ( 'Gumbel', ) ",
#
#                    Settings = SIMP( statut = "o",
#                                         typ = "TXM",
#                                         max = 1,
#                                         into = ( "AlphaBeta", "MuSigma" ),
#                                         defaut = "AlphaBeta",
#                                         fr = "Parametrage de la loi gumbel",
#                                         ang = "Gumbel distribution parameter set",
#                                         ),
#
#                    AlphaBeta_Parameters = BLOC( condition = " Settings in ( 'AlphaBeta', ) ",
#
#                                        Alpha = SIMP( statut = "o",
#                                                       typ = "R",
#                                                       max = 1,
#                                                       val_min = 0.,
#                                                       fr = "Parametre Alpha de la loi | Alpha > 0",
#                                                       ang = "Alpha parameter | Alpha > 0",
#                                                       ),
#
#                                        Beta = SIMP( statut = "o",
#                                                      typ = "R",
#                                                      max = 1,
#                                                      fr = "Parametre Beta de la loi",
#                                                      ang = "Beta parameter",
#                                                      ),
#
#                                        ), # Fin BLOC AlphaBeta_Parameters
#
#
#                    MuSigma_Parameters = BLOC( condition = " Settings in ( 'MuSigma', ) ",
#
#                                        Mu = SIMP( statut = "o",
#                                                    typ = "R",
#                                                    max = 1,
#                                                    fr = "Moyenne de la loi",
#                                                    ang = "Mean value",
#                                                    ),
#
#                                        Sigma = SIMP( statut = "o",
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
#
#
#
#  HISTOGRAM = BLOC( condition = " Distribution in ( 'Histogram', ) ",
#
#                       First = SIMP( statut = "o",
#                                    typ = "R",
#                                    max = 1,
#                                    fr = "Borne inferieure du supoport de la loi",
#                                    ang = "Support lower bound",
#                                    ),
#
#                       # Il faut definir une collection de couples ( x,p ) 
#                       Values = SIMP( statut = 'o',
#                                       typ = Tuple(2),
#                                       max = '**',
#                                       fr = "Liste de couples : largeur de classe, hauteur de classe",
#                                       ang = "Class bandwidth, class height couple list",
#                                       validators=VerifTypeTuple(('R','R')),
#                                       ),
#
#  ), # Fin BLOC HISTOGRAM
#
#
#
#  LAPLACE = BLOC( condition = " Distribution in ( 'Laplace', ) ",
#
#                   Lambda = SIMP( statut = "o",
#                                   typ = "R",
#                                   max = 1,
#                                   val_min = 0.,
#                                   fr = "Parametre Lambda | Lambda > 0",
#                                   ang = "Lambda parameter | Lambda > 0",
#                                   ),
#                   
#                   Mu = SIMP( statut = "o",
#                               typ = "R",
#                               max = 1,
#                               fr = "Moyenne de la loi",
#                               ang = "Mean value",
#                              ),
#
#  ), # Fin BLOC LAPLACE
#
#  LOGNORMAL = BLOC( condition = " Distribution in ( 'LogNormal', ) ",
#
#                     Settings = SIMP( statut = "o",
#                                       typ = "TXM",
#                                       max = 1,
#                                       into = ( "MuSigmaLog", "MuSigma", "MuSigmaOverMu" ),
#                                       defaut = "MuSigmaLog",
#                                       fr = "Parametrage de la loi lognormale",
#                                       ang = "Lognormal distribution parameter set",
#                                       ),
#
#                     MuSigma_Parameters = BLOC( condition = " Settings in ( 'MuSigma', ) ",
#
#                                                 Mu = SIMP( statut = "o",
#                                                             typ = "R",
#                                                             max = 1,
#                                                             fr = "Moyenne de la loi",
#                                                             ang = "Mean value",
#                                                             ),
#
#                                                 Sigma = SIMP( statut = "o",
#                                                                typ = "R",
#                                                                max = 1,
#                                                                val_min = 0.,
#                                                                fr = "Ecart type de la loi",
#                                                                ang = "Standard deviation",
#                                                                ),
#
#                                                 ), # Fin BLOC MuSigma_Parameters
#
#                     MuSigmaOverMu_Parameters = BLOC( condition = " Settings in ( 'MuSigmaOverMu', ) ",
#
#                                                 Mu = SIMP( statut = "o",
#                                                             typ = "R",
#                                                             max = 1,
#                                                             fr = "Moyenne de la loi",
#                                                             ang = "Mean value",
#                                                             ),
#
#                                                 SigmaOverMu = SIMP( statut = "o",
#                                                                typ = "R",
#                                                                max = 1,
#                                                                val_min = 0.,
#                                                                fr = "Rapport ecart type / moyenne de la loi",
#                                                                ang = "Standard deviation / mean value ratio",
#                                                                ),
#
#                                                 ), # Fin BLOC MuSigmaOverMu_Parameters
#
#                     MuSigmaLog_Parameters = BLOC( condition = " Settings in ( 'MuSigmaLog', ) ",
#
#                                                    MuLog = SIMP( statut = "o",
#                                                                   typ = "R",
#                                                                   max = 1,
#                                                                   fr = "Moyenne du log",
#                                                                   ang = "Log mean value",
#                                                                   ),
#
#                                                    SigmaLog = SIMP( statut = "o",
#                                                                      typ = "R",
#                                                                      max = 1,
#                                                                      val_min = 0.,
#                                                                      fr = "Ecart type du log",
#                                                                      ang = "Log standard deviation",
#                                                                      ),
#                                            
#                                                    ), # Fin BLOC MuSigmaLog_Parameters
#
#                     Gamma = SIMP( statut = "o",
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
#   LOGISTIC = BLOC( condition = " Distribution in ( 'Logistic', ) ",
#
#                       Alpha = SIMP( statut = "o",
#                                      typ = "R",
#                                      max = 1,
#                                      fr = "Borne inferieure du supoport de la loi",
#                                      ang = "Support lower bound",
#                                      ),
#
#                       Beta = SIMP( statut = "o",
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
#   MULTINOMIAL = BLOC( condition = " Distribution in ( 'MultiNomial', ) ",
#                         
#                         N = SIMP( statut = "o",
#                                    typ = "I",
#                                    max = 1,
#                                    fr = "Parametre N de la loi | N > 0",
#                                    ang = "N parameter | N > 0",
#                                    ),
#
#                       # Il faut definir une collection de couples ( x,p ) 
#                       Values = SIMP( statut = 'o',
#                                       typ = "R",
#                                       max = '**',
#                                       fr = "Liste de probabilités",
#                                       ang = "Probability list",
#                                       validators=VerifTypeTuple(('R','R')),
#                                       ),
#
#   ), # Fin BLOC MULTINOMIAL
#
#
#  NONCENTRALSTUDENT = BLOC( condition = " Distribution in ( 'NonCentralStudent', ) ",
#
#                   Nu = SIMP( statut = "o",
#                               typ = "R",
#                               max = 1,
#                               fr = "Parametre Nu de la loi | Nu > 0",
#                               ang = "Nu parameter | Nu > 0",
#                              ),
#
#                   Delta = SIMP( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  fr = "Parametre Delta de la loi | Delta > 0",
#                                  ang = "Delta parameter | Delta > 0",
#                                  ),
#                   
#                   Gamma = SIMP( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  fr = "Parametre Gamma de centrage de la loi",
#                                  ang = "Gamma parameter",
#                                  ),
#
#  ), # Fin BLOC NONCENTRALSTUDENT
#
#
#   NORMAL = BLOC( condition = " Distribution in ( 'Normal', ) ",
#
#                    Mu = SIMP( statut = "o",
#                                typ = "R",
#                                max = 1,
#                                fr = "Moyenne de la loi",
#                                ang = "Mean value",
#                                ),
#
#                   Sigma = SIMP( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  val_min = 0.,
#                                  fr = "Ecart type de la loi",
#                                  ang = "Standard deviation",
#                                  ),
#
#   ) # Fin BLOC NORMAL
#
#
#
#   POISSON = BLOC( condition = " Distribution in ( 'Poisson', ) ",
#
#                     Lambda = SIMP( statut = "o",
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
#  RAYLEIGH = BLOC( condition = " Distribution in ( 'Rayleigh', ) ",
#
#                   Sigma = SIMP( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  fr = "Parametre Sigma de la loi | Sigma > 0",
#                                  ang = "Sigma parameter | Sigma > 0",
#                                  ),
#
#                   Gamma = SIMP( statut = "o",
#                                  typ = "R",
#                                  max = 1,
#                                  fr = "Borne inferieure du support de la loi",
#                                  ang = "Support lower bound",
#                                  ),
# ), # Fin BLOC RAYLEIGH
#
#
#   STUDENT = BLOC( condition = " Distribution in ( 'Student', ) ",
#
#                     Mu = SIMP( statut = "o",
#                                 typ = "R",
#                                 max = 1,
#                                 fr = "Parametre Mu de la loi",
#                                 ang = "Mu parameter",
#                                 ),
#
#                     Nu = SIMP( statut = "o",
#                                 typ = "R",
#                                 max = 1,
#                                 val_min = 2.,
#                                 fr = "Parametre Nu de la loi | Nu > 2",
#                                 ang = "Nu parameter | Nu > 2",
#                                 ),
#
#                   Sigma = SIMP( statut = "o",
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
#   TRIANGULAR = BLOC( condition = " Distribution in ( 'Triangular', ) ",
#
#                         A = SIMP( statut = "o",
#                                    typ = "R",
#                                    max = 1,
#                                    fr = "Borne inferieure du support de la loi | A < M < B",
#                                    ang = "Support lower bound | A < M < B",
#                                    ),
#
#                         M = SIMP( statut = "o",
#                                    typ = "R",
#                                    max = 1,
#                                    fr = "Mode de la loi | A < M < B",
#                                    ang = "Mode | A < M < B",
#                                    ),
#
#                         B = SIMP( statut = "o",
#                                    typ = "R",
#                                    max = 1,
#                                    fr = "Borne superieure du support de la loi | A < M < B",
#                                    ang = "Support upper bound | A < M < B",
#                                    ),
#
#   ), # Fin BLOC TRIANGULAR
#
#
#
def creeTruncatedNormal():
   TRUNCATEDNORMAL = BLOC( condition = " Distribution in ( 'TruncatedNormal', ) ",

                             MuN = SIMP( statut = "o",
                                          typ = "R",
                                          max = 1,
                                          fr = "Moyenne de la loi Normale non tronquée",
                                          ang = "Mean value of the associated non truncated normal distribution",
                                          ),

                             SigmaN = SIMP( statut = "o",
                                             typ = "R",
                                             max = 1,
                                             val_min = 0.,
                                             fr = "Ecart-type de la loi Normale non tronquée",
                                             ang = "Standard deviation of the associated non truncated normal distribution",
                                             ),

                             A = SIMP( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        #fr = "Borne inferieure de la loi | A < B",
                                        #ang = "Lower bound | A < B",
                                        ),

                             B = SIMP( statut = "o",
                                        typ = "R",
                                        max = 1,
                                        #fr = "Borne superieure de la loi | A < B",
                                        #ang = "Upper bound | A < B",
                                        ),

   ) # Fin BLOC TRUNCATEDNORMAL
   return TRUNCATEDNORMAL


def verifieBorneInUniforme(self):
     if self.valeur < self.parent.getChild('A').valeur : return ( "il faut A < B") 

def creeUniform():
   UNIFORM = BLOC( condition = " Distribution in ( 'Uniform', ) ",

                     A = SIMP( statut = "o",
                                typ = "R",
                                max = 1,
                                #fr = "Borne inferieure du support de la loi | A < B",
                                #ang = "Support lower bound | A < B",
                                validators=[infFrereMC(frere='B'),infValeurProbabiliste()],
                                #validators=infFrereMC(frere='B')
                                ),

                     B = SIMP( statut = "o",
                                typ = "R",
                                max = 1,
                                #fr = "Borne superieure du support de la loi | A < B",
                                #ang = "Support upper bound | A < B",
                                validators=[supFrereMC(frere='A'),supValeurProbabiliste()],
                                ),
   ) # Fin BLOC UNIFORM
   return UNIFORM

#
#
def creeUserDefined ():
   USERDEFINED = BLOC( condition = " Distribution in ( 'UserDefined', ) ",

                           # Il faut definir une collection de couples ( x,p ) 
                         Values = SIMP( statut = 'o',
                                         typ = 'R',
                                         max = '**',
                                         ),

   ) # Fin BLOC USERDEFINED
   return USERDEFINED
#
#
#   WEIBULL = BLOC( condition = " Distribution in ( 'Weibull', ) ",
#
#                     Settings = SIMP( statut = "o",
#                                          typ = "TXM",
#                                          max = 1,
#                                          into = ( "AlphaBeta", "MuSigma" ),
#                                          defaut = "AlphaBeta",
#                                          fr = "Parametrage de la loi weibull",
#                                          ang = "Weibull distribution parameter set",
#                                          ),
#
#                     AlphaBeta_Parameters = BLOC( condition = " Settings in ( 'AlphaBeta', ) ",
#
#                                         Alpha = SIMP( statut = "o",
#                                                        typ = "R",
#                                                        max = 1,
#                                                        val_min = 0.,
#                                                        fr = "Parametre Alpha de la loi | Alpha > 0",
#                                                        ang = "Alpha parameter | Alpha > 0",
#                                                        ),
#
#                                         Beta = SIMP( statut = "o",
#                                                       typ = "R",
#                                                       max = 1,
#                                                       val_min = 0.,
#                                                       fr = "Parametre Beta de la loi | Beta > 0",
#                                                       ang = "Beta parameter | Beta > 0",
#                                                       ),
#
#                                         ), # Fin BLOC AlphaBeta_Parameters
#
#
#                     MuSigma_Parameters = BLOC( condition = " Settings in ( 'MuSigma', ) ",
#
#                                         Mu = SIMP( statut = "o",
#                                                     typ = "R",
#                                                     max = 1,
#                                                     fr = "Moyenne de la loi",
#                                                     ang = "Mean value",
#                                                     ),
#
#                                         Sigma = SIMP( statut = "o",
#                                                        typ = "R",
#                                                        max = 1,
#                                                        val_min = 0.,
#                                                        fr = "Ecart type de la loi",
#                                                        ang = "Standard deviation",
#                                                        ),
#
#                                         ), # Fin BLOC MuSigma_Parameters
#
#                     Gamma = SIMP( statut = "o",
#                                    typ = "R",
#                                    max = 1,
#                                    fr = "Borne inferieure du support de la loi",
#                                    ang = "Support lower bound",
#                                    ),
#
#    ), # Fin BLOC WEIBULL
#
#) # Fin OPER DISTRIBUTION
#
#
#
#Correlation = PROC ( nom = 'Correlation',
#                     op = None,
#                     docu = "",
#                     fr = "Correlation entre variables",
#                     ang = "Variable correlation",
#                     UIinfo={"groupes":("UQ",)},
#
#  Copula = SIMP( statut = "o",
#                  typ = 'TXM',
#                  into = ( "Independent", "Normal" ),
#                  defaut = "Independent",
#                  fr = "Type de la copule",
#                  ang = "Copula kind",
#                  ),
#
#  Matrix = BLOC( condition = "Copula in ( 'Normal', )",
#                  
#    CorrelationMatrix = SIMP( statut = "o",
#                               typ = Matrice(nbLigs=None,
#                                             nbCols=None,
#                                             methodeCalculTaille='NbDeVariables',
#                                             valSup=1,
#                                             valMin=-1,),
#                                             #structure="symetrique"),
#                               fr = "Matrice de correlation entre les variables d'entree",
#                               ang = "Correlation matrix for input variables",
#                               ),
#  ), # Fin BLOC Matrix
#
#
#) # Fin PROC CORRELATION
#
#
#
#
#
#
#  ThresholdExceedence = BLOC( condition = " Type in ( 'Threshold Exceedence', ) ",
#
#         Event =  FACT ( statut = "o",
#                         min = 1,
#                         max = 1,
#
#                         Threshold = SIMP( statut = "o",
#                                            typ = "R",
#                                            max = 1,
#                                            fr = "Le seuil de defaillance",
#                                            ang = "Failure threshold",
#                                            ),
#
#                         ComparisonOperator = SIMP( statut = "o",
#                                                     typ = "TXM",
#                                                     max = 1,
#                                                     into = ( "Less", "LessOrEqual", "Equal", "GreaterOrEqual", "Greater" ),
#                                                     fr = "Que faut-il ne pas depasser : un maximum ou un minimum",
#                                                     ang = "What is the failure threshold : maximum or minimum",
#                                                     ),
#         ), # Fin FACT Event
#                         
#
#         Method = SIMP( statut = "o",
#                         typ = "TXM",
#                         into = ( "Simulation", "FORM_SORM" ),
#                         fr = "Methode",
#                         ang = "Method",
#                         ),
#
#         SimulationSettings = BLOC( condition = " Method in ( 'Simulation', ) ",
#
#               Algorithm = SIMP( statut = "o",
#                                  typ = "TXM",
#                                  into = ( "MonteCarlo", "LHS", "ImportanceSampling" ),
#                                  fr = "Algorithme de simulation",
#                                  ang = "Simulation algorithm",
#                                  ),
#
#                                 
#               RandomGenerator = FACT ( statut = "o",
#                                        min = 1,
#                                        max = 1,
#
#                           SeedToBeSet = SIMP( statut = "o",
#                                                typ = 'TXM',
#                                                into = ( 'yes', 'no' ),
#                                                defaut = 'no',
#                                                max = 1,
#                                                fr = "La racine du generateur aleatoire doit-elle etre positionnee ?",
#                                                ang = "Does the random generator seed need to be set ?",
#                                                ),
#
#                           SeedSettings = BLOC( condition = " SeedToBeSet in ( 'yes', ) ",
#
#                                                 RandomGeneratorSeed = SIMP( statut = "o",
#                                                                              typ = "I",
#                                                                              max = 1,
#                                                                              fr = "Racine du generateur aleatoire",
#                                                                              ang = "Random generator seed",
#                                                                              ),
#
#                                               ), # Fin BLOC SeedSettings
#
#               ), # Fin FACT RandomGenerator
#
#
#               BlockSize = SIMP( statut = "o",
#                                  typ = "I",
#                                  max = 1,
#                                  val_min = 1,
#                                  defaut = 1,
#                                  fr = "Nombre de calculs realises en bloc",
#                                  ang = "Number of computations as a block",
#                                  ),
#
#               MaximumOuterSampling = SIMP( statut = "o",
#                                             typ = "I",
#                                             max = 1,
#                                             val_min = 1,
#                                             fr = "Maximum d'iterations externes",
#                                             ang = "Maximum outer Sampling value",
#                                             ),
#
#               MaximumCoefficientOfVariation = SIMP( statut = "o",
#                                                      typ = "R",
#                                                      max = 1,
#                                                      defaut = 0.1,
#                                                      val_min = 0.0,
#                                                      val_max = 1.0,
#                                                      fr = "Coefficient de variation maximum",
#                                                      ang = "Maximum coefficient of variation"
#                                                      ),
#
#               ImportanceSamplingSettings = BLOC( condition = " Algorithm in ( 'ImportanceSampling', ) ",
#
#                            MeanVector = SIMP( statut = "o",
#                                                typ = "R",
#                                                max = "**",
#                                                fr = "Moyenne",
#                                                ang = "Mean vector",
#                                                ),
#
#
#               ), # Fin BLOC ImportanceSamplingSettings
#
#               Result = FACT ( statut = "o",
#                                      min = 1,
#                                      max = "**",
#
#                    Probability = SIMP( statut = "o",
#                                         typ = 'TXM',
#                                         into = ( 'yes', ),
#                                         defaut = 'yes',
#                                         max = 1,
#                                         fr = "Probabiblite",
#                                         ang = "Probability",
#                                         ),
#
#                    StandardDeviation = SIMP( statut = "o",
#                                         typ = 'TXM',
#                                         into = ( 'yes', ),
#                                         defaut = 'yes',
#                                         max = 1,
#                                         fr = "Ecart type",
#                                         ang = "Standard deviation",
#                                         ),
#
#                    ConfidenceInterval = SIMP( statut = "o",
#                                                typ = 'TXM',
#                                                into = ( 'yes', 'no' ),
#                                                defaut = 'yes',
#                                                max = 1,
#                                                fr = "Intervale de confiance",
#                                                ang = "Confidence interval",
#                                                ),
#
#                    ConfidenceIntervalSettings = BLOC( condition = " ConfidenceInterval in ( 'yes', ) ",
#
#                          Level = SIMP( statut = "o",
#                                         typ = 'R',
#                                         defaut = 0.9,
#                                         max = 1,
#                                         val_min = 0.0,
#                                         val_max = 1.0,
#                                         fr = "Niveau de confiance",
#                                         ang = "Confidence level",
#                                         ),
#                                                     
#                    ), # Fin BLOC ConfidenceIntervalSettings
#                               
#                    VariationCoefficient = SIMP( statut = "o",
#                                                  typ = 'TXM',
#                                                  into = ( 'yes', 'no' ),
#                                                  defaut = 'yes',
#                                                  max = 1,
#                                                  fr = "Coefficient de variation",
#                                                  ang = "Coefficient of variation",
#                                                  ),
#
#                    SimulationsNumber = SIMP( statut = "o",
#                                             typ = 'TXM',
#                                             into = ( 'yes', 'no' ),
#                                             defaut = 'yes',
#                                             max = 1,
#                                             fr = "Nombre d'iterations",
#                                             ang = "Iteration number",
#                                             ),
#
#                    ConvergenceGraph = SIMP( statut = "o",
#                                             typ = 'TXM',
#                                             into = ( 'yes', 'no' ),
#                                             defaut = 'yes',
#                                             max = 1,
#                                             fr = "Graphe de convergence",
#                                             ang = "Convergence graph",
#                                             ),
#                               
#                    ConvergenceGraphSettings = BLOC( condition = " ConvergenceGraph in ( 'yes', ) ",
#
#                                     ConvergenceDrawingFilename = SIMP( statut = "o",
#                                                                         typ = "TXM",
#                                                                         max = 1,
#                                                                         fr = "Nom du fichier graphique de la convergence",
#                                                                         ang = "Convergence Drawing Filename",
#                                                                         ),
#                                                                             
#
#                              ), # Fin BLOC ConvergenceGraphSettings
#                                      
#             ), # Fin FACT Result
#                                                               
#
#
#         ), # Fin BLOC SimulationSettings
#
#
#                               
#         FORM_SORMSettings = BLOC( condition = " Method in ( 'FORM_SORM', ) ",
#
#                Approximation = SIMP( statut = "o",
#                                       typ = "TXM",
#                                       defaut = "FirstOrder",
#                                       into = ( "FirstOrder", "SecondOrder" ),
#                                       max = 1,
#                                       fr = "Approximation",
#                                       ang = "Approximation",
#                                       ),
#
#                OptimizationAlgorithm = SIMP( statut = "o",
#                                               typ = "TXM",
#                                               defaut = "Cobyla",
#                                               into = ( "Cobyla", "AbdoRackwitz" ),
#                                               max = 1,
#                                               fr = "Methode d'optimisation",
#                                               ang = "Optimization method",
#                                               ),
#
#                                     
#                PhysicalStartingPoint = SIMP( statut = "f",
#                                               typ = "R",
#                                               max = "**",
#                                               fr = "Point de demarrage de l'algorithme iteratif",
#                                               ang = "Initial point for iterative process",
#                                               ),
#
#                MaximumIterationsNumber = SIMP( statut = "f",
#                                                 typ = "I",
#                                                 max = 1,
#                                                 val_min = 1,
#                                                 fr = "Nombre maximum d'iterations",
#                                                 ang = "Maximum number of iterations",
#                                                 ),
#
#                                     
#                MaximumAbsoluteError = SIMP( statut = "o",
#                                              typ = "R",
#                                              max = 1,
#                                              defaut = 1E-4,
#                                              val_min = 0.0,
#                                              fr = "Distance maximum absolue entre 2 iterations successives",
#                                              ang = "Absolute maximum distance between 2 successive iterates",
#                                              ),
#
#                MaximumRelativeError = SIMP( statut = "o",
#                                               typ = "R",
#                                               max = 1,
#                                               defaut = 1E-4,
#                                               val_min = 0.0,
#                                               fr = "Distance maximum relative entre 2 iterations successives",
#                                               ang = "Relative maximum distance between 2 successive iterates",
#                                               ),
#                                     
#                MaximumConstraintError = SIMP( statut = "o",
#                                                typ = "R",
#                                                max = 1,
#                                                defaut = 1E-4,
#                                                val_min = 0.0,
#                                                fr = "Valeur maximum absolue de la fonction moins la valeur du niveau",
#                                                ang = "Maximum absolute value of the constraint function minus the level value",
#                                                ),
#
#                ImportanceSampling = SIMP( statut = "o",
#                                            typ = 'TXM',
#                                            into = ( 'yes', 'no' ),
#                                            defaut = 'no',
#                                            max = 1,
#                                            fr = "Tirage d'importance au point de conception",
#                                            ang = "Importance sampling at design point",
#                                            ),
#
#                FORMResult = BLOC( condition = " Approximation in ( 'FirstOrder', ) ",
#
#                    Probability = SIMP( statut = "o",
#                                         typ = 'TXM',
#                                         into = ( 'yes', ),
#                                         defaut = 'yes',
#                                         max = 1,
#                                         fr = "Probabiblite",
#                                         ang = "Probability",
#                                         ),
#
#                    DesignPoint = SIMP( statut = "o",
#                                         typ = 'TXM',
#                                         into = ( 'yes', 'no' ),
#                                         defaut = 'yes',
#                                         max = 1,
#                                         fr = "Point de conception",
#                                         ang = "Design point",
#                                         ),
#
#                    HasoferReliabilityIndex = SIMP( statut = "o",
#                                                 typ = 'TXM',
#                                                 into = ( 'yes', 'no' ),
#                                                 defaut = 'yes',
#                                                 max = 1,
#                                                 fr = "Indice de fiabilite",
#                                                 ang = "Reliability index",
#                                                 ),
#
#                    ImportanceFactor = SIMP( statut = "o",
#                                              typ = 'TXM',
#                                              into = ( 'yes', 'no' ),
#                                              defaut = 'yes',
#                                              max = 1,
#                                              fr = "Facteur d'importance pour variable de sortie scalaire",
#                                              ang = "Importance factor",
#                                              ),
#
#                    ImportanceFactorSettings = BLOC( condition = " ImportanceFactor in ( 'yes', ) ",
#
#                                     ImportanceFactorDrawingFilename = SIMP( statut = "o",
#                                                                              typ = "TXM",
#                                                                              max = 1,
#                                                                              fr = "Nom du fichier graphique des facteurs d'importance",
#                                                                              ang = "Importance Factor Drawing Filename",
#                                                                              ),
#                                                                             
#
#                              ), # Fin BLOC ImportanceFactorSettings
#                                      
#                    SensitivityAnalysis = SIMP( statut = "o",
#                                                 typ = 'TXM',
#                                                 into = ( 'yes', 'no' ),
#                                                 defaut = 'yes',
#                                                 max = 1,
#                                                 fr = "Analyse de sensibilite",
#                                                 ang = "Sensitivity analysis",
#                                                 ),
#
#                    SensitivityAnalysisSettings = BLOC( condition = " SensitivityAnalysis in ( 'yes', ) ",
#
#                            FORMEventProbabilitySensitivity = SIMP( statut = "o",
#                                                             typ = 'TXM',
#                                                             into = ( 'yes', 'no' ),
#                                                             defaut = 'yes',
#                                                             max = 1,
#                                                             fr = "Indice de fiabilite de Hasofer",
#                                                             ang = "Hasofer reliability index",
#                                                             ),
#        
#                            FORMEventProbabilitySensitivitySettings = BLOC( condition = " FORMEventProbabilitySensitivity in ( 'yes', ) ",
#
#                                     FORMEventProbabilitySensitivityDrawingFilename = SIMP( statut = "o",
#                                                                         typ = "TXM",
#                                                                         max = 1,
#                                                                         fr = "Nom du fichier graphique des sensibilites",
#                                                                         ang = "Sensitivity Drawing Filename",
#                                                                         ),
#                                                                             
#
#                              ), # Fin BLOC FORMEventProbabilitySensitivitySettings
#                                      
#                            HasoferReliabilityIndexSensitivity = SIMP( statut = "o",
#                                                             typ = 'TXM',
#                                                             into = ( 'yes', 'no' ),
#                                                             defaut = 'yes',
#                                                             max = 1,
#                                                             fr = "Indice de fiabilite de Hasofer",
#                                                             ang = "Hasofer reliability index",
#                                                             ),
#        
#                            HasoferReliabilityIndexSensitivitySettings = BLOC( condition = " HasoferReliabilityIndexSensitivity in ( 'yes', ) ",
#
#                                     HasoferReliabilityIndexSensitivityDrawingFilename = SIMP( statut = "o",
#                                                                         typ = "TXM",
#                                                                         max = 1,
#                                                                         fr = "Nom du fichier graphique des sensibilites",
#                                                                         ang = "Sensitivity Drawing Filename",
#                                                                         ),
#                                                                             
#
#                              ), # Fin BLOC FHasoferReliabilityIndexSensitivitySettings
#                                      
#                    ), # Fin BLOC SensitivityAnalysisSettings
#
#                    FunctionCallsNumber = SIMP( statut = "o",
#                                                 typ = 'TXM',
#                                                 into = ( 'yes', 'no' ),
#                                                 defaut = 'yes',
#                                                 max = 1,
#                                                 fr = "Nombre d'appels a la fonction",
#                                                 ang = "Function calls number",
#                                                 ),
#
#
#                ), # Fin BLOC FORMResult
#
#
#                SORMResult = BLOC( condition = " Approximation in ( 'SecondOrder', ) ",
#
#
#                    TvedtApproximation = SIMP( statut = "o",
#                                                typ = 'TXM',
#                                                into = ( 'yes', 'no' ),
#                                                defaut = 'yes',
#                                                max = 1,
#                                                fr = "Approximation de Tvedt",
#                                                ang = "Tvedt approximation",
#                                                ),
#
#                    HohenBichlerApproximation = SIMP( statut = "o",
#                                                       typ = 'TXM',
#                                                       into = ( 'yes', 'no' ),
#                                                       defaut = 'yes',
#                                                       max = 1,
#                                                       fr = "Approximation de HohenBichler",
#                                                       ang = "HohenBichler approximation",
#                                                       ),
#
#                    BreitungApproximation = SIMP( statut = "o",
#                                                   typ = 'TXM',
#                                                   into = ( 'yes', 'no' ),
#                                                   defaut = 'yes',
#                                                   max = 1,
#                                                   fr = "Approximation de Breitung",
#                                                   ang = "Breitung approximation",
#                                                   ),
#
#                    DesignPoint = SIMP( statut = "o",
#                                         typ = 'TXM',
#                                         into = ( 'yes', 'no' ),
#                                         defaut = 'yes',
#                                         max = 1,
#                                         fr = "Point de conception",
#                                         ang = "Design point",
#                                         ),
#
#                    ImportanceFactor = SIMP( statut = "o",
#                                              typ = 'TXM',
#                                              into = ( 'yes', 'no' ),
#                                              defaut = 'yes',
#                                              max = 1,
#                                              fr = "Facteur d'importance pour variable de sortie scalaire",
#                                              ang = "Importance factor",
#                                              ),
#
#                    ImportanceFactorSettings = BLOC( condition = " ImportanceFactor in ( 'yes', ) ",
#
#                                     ImportanceFactorDrawingFilename = SIMP( statut = "o",
#                                                                              typ = "TXM",
#                                                                              max = 1,
#                                                                              fr = "Nom du fichier graphique des facteurs d'importance",
#                                                                              ang = "Importance Factor Drawing Filename",
#                                                                              ),
#                                                                             
#
#                              ), # Fin BLOC ImportanceFactorSettings
#                                      
#                    SensitivityAnalysis = SIMP( statut = "o",
#                                                 typ = 'TXM',
#                                                 into = ( 'yes', 'no' ),
#                                                 defaut = 'yes',
#                                                 max = 1,
#                                                 fr = "Analyse de sensibilite",
#                                                 ang = "Sensitivity analysis",
#                                                 ),
#
#                    SensitivityAnalysisSettings = BLOC( condition = " SensitivityAnalysis in ( 'yes', ) ",
#
#                            HasoferReliabilityIndexSensitivity = SIMP( statut = "o",
#                                                             typ = 'TXM',
#                                                             into = ( 'yes', 'no' ),
#                                                             defaut = 'yes',
#                                                             max = 1,
#                                                             fr = "Indice de fiabilite de Hasofer",
#                                                             ang = "Hasofer reliability index",
#                                                             ),
#                                                                 
#                            HasoferReliabilityIndexSensitivitySettings = BLOC( condition = " HasoferReliabilityIndexSensitivity in ( 'yes', ) ",
#
#                                     HasoferReliabilityIndexSensitivityDrawingFilename = SIMP( statut = "o",
#                                                                         typ = "TXM",
#                                                                         max = 1,
#                                                                         fr = "Nom du fichier graphique des sensibilites",
#                                                                         ang = "Sensitivity Drawing Filename",
#                                                                         ),
#                                                                             
#
#                              ), # Fin BLOC FHasoferReliabilityIndexSensitivitySettings
#                                      
#                    ), # Fin BLOC SensitivityAnalysisSettings
#
#                    FunctionCallsNumber = SIMP( statut = "o",
#                                                 typ = 'TXM',
#                                                 into = ( 'yes', 'no' ),
#                                                 defaut = 'yes',
#                                                 max = 1,
#                                                 fr = "Nombre d'appels a la fonction",
#                                                 ang = "Function calls number",
#                                                 ),
#
#
#                ), # Fin BLOC SecondOrder
#
#
#                                     
#        ), # Fin BLOC FORM_SORMSettings
#
#
#                               
#  ), # Fin BLOC ThresholdExceedence
#) # Fin PROC CRITERIA
#
#

def affineDistribution(monDicoVarDeter,var,loi):
     nomLoi=list(monDicoVarDeter[var].keys())[0]
     argsLoi=loi[nomLoi]
     nomFonction='cree'+nomLoi
     maFonction=globals()[nomFonction]
     bloc=maFonction(**argsLoi)
     

def creeDistributionsSelonVariable(monDicoVarDeter):
    lesBlocs={}
    for var in monDicoVarDeter : 
        listeLoisComplete=monDicoVarDeter[var]
        listeChoix=[]
        for loi in listeLoisComplete:
            nomLoi=list(loi.keys())[0]
            listeChoix.append(nomLoi)
        nomBlocVar  = 'b_Model_Variable_' + var
        laCondition ="ModelVariable == '" + var + "'"
        distribution = SIMP(statut='o', typ='TXM', into=listeChoix)
        dicoDistribution={}
        for loi in listeLoisComplete: 
            nomLoi      = list(loi.keys())[0]
            argsLoi     = loi[nomLoi]
            nomFonction = 'cree'+nomLoi
            maFonction  = globals()[nomFonction]
            bloc        = maFonction(**argsLoi)
            nomBloc     = 'b_Model_Variable_' + var+'_'+nomLoi
            dicoDistribution[nomBloc]=bloc
        lesBlocs[nomBlocVar]= BLOC(condition=laCondition, Distribution = distribution, **dicoDistribution)
    return lesBlocs


def definitIntoOuput(objExpression, contexte):
    # protege par un gros try -)
    debug=0
    if debug : print ('dans definitIntoOutput', objExpression)
    jdc=objExpression.jdc
    if not jdc : return
    if debug : print (jdc)
    monScenario=jdc.getEtapesByName('Scenario_data')[0]
    if debug : print (monScenario)
    mesPostPro=monScenario.getChildOrChildInBloc('post_processing')
    if debug : print (mesPostPro)
    if not mesPostPro : return
    mesPostPro.definition.changeSiValide(changeIntoOuput)
    changeIntoOuput(mesPostPro)


def changeIntoOuput(objPostPro):
    mesPostProVal=objPostPro.valeur
    contexte=objPostPro.etape.parent.g_context
    # on essaye d assurer la compatibilite du catalogue UQ pour les 2 versions du catalogue RN_EDG
    if len(mesPostProVal[0]) == 2 :
        for (variable,fonct) in mesPostProVal :
            if fonct == 'MED' : continue
            nomVar=variable.split('@')[0]
            phys=variable.split('@')[1]
            nomAProposer= variable+'@'+fonct
            nomBloc    = 'b_physique_' + phys 
            nomBlocVar = ('b_var_'+nomVar).replace( ' ','__')
            maDef=contexte['ExpressionIncertitude'].entites['Output'].entites['VariableDeSortie'].entites[nomBloc].entites[nomBlocVar].entites['VariablePosttraiteeAssociee']
            maDef.addInto(nomAProposer)
    if len(mesPostProVal[0]) == 3 :
        for (nomVar,phys,fonct) in mesPostProVal :
            if '@' in nomVar : continue # Les noms des grandeurs et les associations à leurs définitions doivent être revues dans une nvlle version du cata_RN.py
            if fonct == 'MED' : continue
            nomAProposer= nomVar+'@'+phys+'@'+fonct
            nomBloc    = 'b_physique_' + phys 
            nomBlocVar = ('b_var_'+nomVar).replace( ' ','__')
            # Les variables ne sont pas dans le catalogue catalog_uq.py donc pas proposees
            try : 
                maDef=contexte['ExpressionIncertitude'].entites['Output'].entites['VariableDeSortie'].entites[nomBloc].entites[nomBlocVar].entites['VariablePosttraiteeAssociee']
                maDef.addInto(nomAProposer)
            except : pass

def creeOutput(monDicoVarSortie,scriptPosttraitement):
    intoVariable=list(monDicoVarSortie.keys())
    lesBlocs={}
    Physique = SIMP (statut = "o", typ = "TXM",into = intoVariable,defaut=intoVariable[0])
    for phys in intoVariable : 
        laCondition          = "Physique == '" + phys + "'"
        VariablePhysique     =  SIMP(statut = "o", typ = "TXM", into = monDicoVarSortie[phys], )
        Unit     = SIMP ( statut = "f", typ = "TXM", fr = "Unite", ang = "Unit",) 
        Format   = SIMP ( statut = "f", typ = "TXM", fr = "Format de sortie", ang = "format", into =['med', 'csv']) 
        lesBlocsVar={}
        for v in monDicoVarSortie[phys] :
            VariablePosttraiteeAssociee = SIMP ( statut = "o", typ = "TXM", into=[])
            Consigne =  SIMP(statut="o", homo="information", typ="TXM", defaut="la Variable Post Traitée associée doit être présente dans la variable post_processing de Scenario_Data")
            laConditionVar ="VariablePhysique == '" + v + "'"
            nomBlocVar=('b_var_'+v).replace( ' ','__')
            lesBlocsVar[nomBlocVar]= BLOC (condition=laConditionVar, VariablePosttraiteeAssociee=VariablePosttraiteeAssociee, Consigne=Consigne)
        nomBloc     = 'b_physique_' + phys 
        lesBlocs[nomBloc] = BLOC (condition=laCondition, VariablePhysique = VariablePhysique, **lesBlocsVar)
    FonctionDAggregation = SIMP(statut = 'o', typ= 'TXM', into = ('valeur à t=O', 'valeur à mi-temps', 'valeur à t final',  'valeur moyenne', 'valeur cumulée', 'valeur minimale', 'valeur maximale' ),
                                defaut=('Max'), max='**', homo='SansOrdreNiDoublon', avecBlancs=True)
    ScriptPosttraitement=SIMP(
       fr="Nom du fichier Script de Postraitement",
       ang="Postprocessing Script File",
       statut="o",
       typ=("FichierNoAbs", "All Files ()"),  defaut=scriptPosttraitement)
    VariableDeSortie = FACT ( max='**', statut ='o', Physique=Physique, **lesBlocs, FonctionDAggregation=FonctionDAggregation, Unit=Unit,Format=Format)
    output = FACT (max=1, statut ='o', VariableDeSortie=VariableDeSortie, ScriptPosttraitement=ScriptPosttraitement)
    return output

def creeOperExpressionIncertitude(monDicoVarDeter, monDicoVarSortie,scriptPosttraitement, scriptDeLancement ):
    listeDesVariablesPossibles = list(monDicoVarDeter.keys())
    #monOutput = creeOutput(monDicoVarSortie)
    objectName =  SIMP ( statut = "f", typ =  'TXM', into=[],  fenetreIhm='menuDeroulant', homo='constant' ) # on ne met pas [] pour la projection XSD, intoXML=?
    modelVariable = SIMP ( statut = "o",
            typ = ( 'TXM'),
            fr = "Variable d'entrée du modèle",
            ang = "Input variable of the model",
            into = listeDesVariablesPossibles,
            fenetreIhm='menuDeroulant',
            homo='constant',
    )
    Consigne =  SIMP(statut="o", homo="information", typ="TXM", defaut=' ')
    MCPath = SIMP(statut='d', typ='TXM', defaut=(), max='**', min=0, avecBlancs = True)
    blocs=creeDistributionsSelonVariable(monDicoVarDeter)
    # Attention
    # l ordre des motclefs en 3.7 a l air de dépendre de l ordre de creation des objets
    # et non d un dict ordonné. on retombe toujours sur ce pb
    return  PROC ( nom = "ExpressionIncertitude",  UIinfo={"groupes":("CACHE",)}, op_init=definitIntoOuput,
        UncertaintyTool =  SIMP ( statut = "o", typ = "TXM", into = ['Uranie', 'OpenTurns'], defaut='OpenTurns',position='global'),
        Input = FACT( max=1, statut ='o',
            VariableProbabiliste = FACT ( max='**', statut ='cache',
                fr  = "Variable probabiliste",
                ang = "Probabilistic variable",
                ObjectName = objectName,
                ModelVariable = modelVariable,
                Consigne = Consigne,
                MCPath = MCPath,
                **blocs
            ),
        ),
        Propagation = FACT( max=1, statut ='o',
        #UncertaintyTool =  SIMP ( statut = "o", typ = "TXM", into = ['Uranie', 'OpenTurns'], defaut='Uranie',position='global'),
          Propagation_OT = BLOC( condition = "UncertaintyTool == 'OpenTurns'",
            Methode = SIMP( statut = "o", typ = "TXM", max=1, into = ('Taylor', 'MonteCarlo'), defaut='Taylor'),
            BlocMonteCarlo1 = BLOC ( condition = "Methode == 'MonteCarlo'", 
                CritereArret = FACT ( statut = "o", max = 1,
                                      regles = (AU_MOINS_UN('SimulationsNumber','MaximumElapsedTime'),),
                                      # TODO : regles = (AU_MOINS_UN('Accuracy', 'SimulationsNumber','MaximumElapsedTime'),),
                    Accuracy = SIMP ( statut = "o", typ = "R", #TODO: statut = "f"
                                      val_min = 0.0, val_max = 1.0, sug = 0.01, #TODO: val_min > 0
                        fr = "Coefficient de variation maximum à atteindre pour la moyenne",
                        ang = "Accuracy - the maximum coefficient of variation (CV) for the mean",),
                    SimulationsNumber = SIMP ( statut = "o", typ = "I",
                                               val_min = 1, defaut =10000,
                        fr = "Nombre maximum de réalisations",
                        ang = "maximum sampling size ",),
                    MaximumElapsedTime = SIMP ( statut = "o", typ = "I", # Incohérence Doc Persalys : 60s par défaut
                                                val_min = 1, defaut = 3600, #TODO: statut = "f"
                                                unite = "secondes",
                        fr = "Temps elapse maximum pour l'exécution globale",
                        ang = "Maximum elapse time for the whole simulation",),
                ), # FIN FACT CritereArret
                EvaluationParameter = FACT ( statut = "o", max = 1, #TODO:  BlockSize < SimulationsNumber
                    BlockSize = SIMP ( statut = "o", typ = "I", val_min = 1, defaut = 1,
                        fr = "Nombre d'évaluations en parallèle",
                        ang = "The number of runs launched simultaneously",),
                ), # FIN FACT EvaluationParameter
                AdvancedParameter = FACT ( statut = "f", max = 1, #TODO:  BlockSize < SimulationsNumber
                    ComputeConfidenceIntervalAt = SIMP ( statut = "o", typ = "R",
                                                         val_min = 0, val_max = 0.9999, defaut = 0.95,
                                                         #TODO: avec statut = "f" && defaut = 0.95,
                        fr = "Demande le calcul de l'interval de confiance au niveau donné",
                        ang = "Require the computation of the confidence interval at a given level",),
                    Seed = SIMP ( statut = "o", typ = "I", val_min = 0, defaut = 0,
                        fr = "La graine d'initialisation du générateur aléatoire",
                        ang = "The seed of the random generator ",),
                ), # FIN FACT AdvancedParameter
            ),
            BlocTaylor = BLOC( condition = "Methode == 'Taylor'", 
                Result  = FACT( statut = "o", min = 1, 
                    MeanFirstOrder = SIMP ( statut = "o", typ = 'TXM', into = ( 'yes', 'no' ), defaut = 'yes',
                        fr = "Moyenne au premier ordre",
                        ang = "MeanFirstOrder",),
                    StandardDeviationFirstOrder = SIMP ( statut = "o", typ = 'TXM', into = ( 'yes', 'no' ), defaut = 'yes',
                        fr = "Ecart-type au premier ordre",
                        ang = "StandardDeviationFirstOrder",),
                    MeanSecondOrder = SIMP ( statut = "o", typ = 'TXM', into = ( 'yes', 'no' ), defaut = 'no',
                        fr = "Moyenne au second ordre",
                        ang = "MeanSecondOrder",),
                ),# fin Result
            ), # fin BlocTaylor
            BlocMonteCarlo2 = BLOC ( condition = "Methode == 'MonteCarlo'", 
                Result  = FACT( statut = "o", min = 1, 
                    EmpiricalMean = SIMP ( statut = "o", typ = 'TXM', into = ( 'yes', 'no' ), defaut = 'yes',
                        fr = "Moyenne empirique",
                        ang = "Empirical mean",),
                    EmpiricalStandardDeviation = SIMP ( statut = "o", typ = 'TXM', into = ( 'yes', 'no' ), defaut = 'yes',
                        fr = "Ecart-type empirique",
                        ang = "Empirical standard deviation",),
                    EmpiricalQuantile = SIMP ( statut = "o", typ = 'TXM', into = ( 'no', ), defaut = 'no', #into = ( 'yes', 'no' ), 
                                               fr = "Quantile empirique (Non encore implémenté)",
                        ang = "Empirical quantile (Not Yet Implemented)",),
                    BlocEmpiricalQuantileSettings = BLOC ( condition = " EmpiricalQuantile in ( 'yes', ) ",
                        EmpiricalQuantile_Order = SIMP ( statut = "o", typ = 'R', defaut = 0.95,
                            val_min = 0.0, val_max = 1.0,
                            fr = "Ordre du quantile empirique",
                            ang = "Empirical quantile order",),
                    ), # Fin BlocEmpiricalQuantileSettings
                ),# fin Result
            ),# fin BlocMonteCarlo2
          ),# fin BlocOTPropagation
        Propagation_Uranie = BLOC( condition = "UncertaintyTool == 'Uranie'",
            Methode = SIMP( statut = "o", typ = "TXM", max=1, into = ('SRS', 'Sobol'), defaut='Sobol'),
          ), # fin UraniePropagation
        ), # fin Propagation
        Output=creeOutput(monDicoVarSortie,scriptPosttraitement),
        Execution = FACT (max=1, statut ='o',
             bloc_OT = BLOC (condition = 'UncertaintyTool == "OpenTurns"',
                ExecutionMode = SIMP ( statut = "o", typ = "TXM", into = ['desktop', 'cluster']),
                NbDeBranches  = SIMP ( statut = "o", typ = "I", val_min = 0, fr='nb d evaluations Persalys simultanees'),
                bloc_OT_local = BLOC (condition = 'ExecutionMode == "desktop"',
                    JobName        = SIMP ( statut = 'o', typ ="TXM", defaut='idefix_rn_job'),
                    ResourceName   = SIMP ( statut = 'o', typ ="TXM", defaut ='localhost'),
                    Login   = SIMP ( statut = 'o', typ ="TXM", defaut = os.getlogin() ),
#                    WorkDirectory = SIMP ( statut = 'o', typ='Repertoire' , defaut='/tmp/'+os.getlogin()+'_workingdir_uncertainty'), #TODO: Login + NonExistent
                    WorkDirectory = SIMP ( statut = 'o', typ='TXM' , defaut='/tmp/'+os.getlogin()+'_workingdir_uncertainty'), #TODO:  NonExistent
#                    ResultDirectory = SIMP ( statut = 'o', typ='Repertoire' , defaut='/tmp/idefix_rn_job'), #TODO: JobName
                    ResultDirectory = SIMP ( statut = 'o', typ='TXM' , defaut='/tmp/idefix_rn_job'), #TODO: JobName
                    UncertaintyScript=SIMP( statut="o",  typ=('Fichier' ,'py Files (*.py);;All Files (*)'), defaut=scriptDeLancement,
                       fr="Nom du fichier script de lancement",  ang="script File to launch",),
                ),
                bloc_OT_cluster = BLOC (condition = 'ExecutionMode == "cluster"',
                    MultiJobStudy  = SIMP ( statut = "o", typ = bool, defaut=False,fr='Si True, un job est soumis pour chaque évaluation de branche'),
                    NbOfProcs      = SIMP ( statut = 'o', typ ="I" ,  defaut = 1, val_min = 1, fr='Equivaut au nombre de tasks SLURM affectées à chaque job'),
                    JobName        = SIMP ( statut = 'o', typ ="TXM", defaut='idefix_rn_job'),
                    ResourceName   = SIMP ( statut = 'o', typ ="TXM", defaut ='gaia'),
                    Login   = SIMP( statut = 'o', typ ="TXM", defaut = os.getlogin()),
                    WorkDirectory = SIMP ( statut = 'o', typ='TXM' , defaut='/scratch/'+os.getlogin()+'/workingdir/persalys_light'), #TODO: Login
#                    WorkDirectory = SIMP ( statut = 'o', typ='Repertoire' , defaut='/scratch/'+os.getlogin()+'/workingdir/persalys_light'), #TODO: Login
                    ResultDirectory = SIMP ( statut = 'o', typ='TXM' , defaut='/tmp/idefix_rn_job'), #TODO: JobName
#                    ResultDirectory = SIMP ( statut = 'o', typ='Repertoire' , defaut='/tmp/idefix_rn_job'), #TODO: JobName
                    Consigne =  SIMP(statut="o", homo="information", typ="TXM",
                       defaut="Le chemin d'accès au script de lancement est celui utilisé par les machines du cluster."),
                    UncertaintyScript = SIMP( statut="o",  typ=("Fichier", "All Files ()"), defaut=scriptDeLancement,
                       fr="Nom du fichier script de lancement",  ang="script File to launch",),
                ),
             ),
             bloc_Uranie = BLOC (condition = 'UncertaintyTool == "Uranie"',
                DOEDimensions = SIMP ( statut = "o", typ = "I"),
                NbDeBranches  = SIMP ( statut = "o", typ = "I", val_min = 0, fr='nb d evaluations simultanees'),
             ),
        ),
    )
    return ExpressionIncertitude


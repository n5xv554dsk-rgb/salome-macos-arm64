# coding: utf-8
from Accas import *

class loi      ( ASSD ) : pass
class variable ( ASSD ) : pass

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



class myModel(ASSD): pass

JdC = JDC_CATA(code='PATTERNS',
               execmodul=None,
               regles=(AU_MOINS_UN ( 'CORRELATION' ),
                )
)

DETERMINISTICVARIABLE = OPER ( nom = "DETERMINISTICVARIABLE",
                               sd_prod = variable,
                               op = None,
                               fr = "Variable deterministe",
                               ang = "Deterministic variable",
            
  N = SIMP ( statut = 'o', typ = "TXM", fr = "Nom", ang = "Name", defaut = "Var1" ),
  T = SIMP ( statut = 'o', defaut = "in", into = ( "in" , "out", ), typ = "TXM", fr = "Type", ang = "Type" ),
  R = SIMP ( statut = 'o', defaut = 0, typ = "I", fr = "Rang", ang = "Rank" ),
)

DISTRIBUTION = OPER ( nom = "DISTRIBUTION",
                      sd_prod = loi,
                      op = 68,
                      fr = "Definitions des lois marginales utilisees par les variables d'entree", 
                      
  R = SIMP ( statut = "o", typ = "R", max = 1, val_min = 0., fr = "Parametre R de la loi | R > 0", ang = "R parameter | R > 0", defaut = 0.5 ),
  # T > R
  T = SIMP ( statut = "o", typ = "R", max = 1, val_min = 0., fr = "Parametre T de la loi | T > R", ang = "T parameter | T > R", defaut = 0.7 ),
  A = SIMP ( statut = "o", typ = "R", max = 1, fr = "Borne inferieure du support de la loi", ang = "Support lower bound", defaut = 0.1 ),
  # B > A
  B = SIMP ( statut = "o", typ = "R", max = 1, fr = "Borne superieure du support de la loi", ang = "Support upper bound", defaut = 0.3 ),
)

VARIABLE = PROC ( nom = "VARIABLE",
                  op = None,
                  docu = "",
                  fr = "Variable probabiliste",
                  ang = "Probabilistic variable",

  ModelVariable = SIMP ( statut = "o", typ = ( variable, ), fr = "Variable d'entrée du modèle", ang = "Input variable of the model" ),
  Distribution = SIMP ( statut = "o", typ = ( loi, ), fr = "Modélisation probabiliste", ang = "Probabilistic modelisation" ),
)

CORRELATION = PROC ( nom = 'CORRELATION',
                     op = None,
                     docu = "",
                     fr = "Correlation entre variables",
                     ang = "Variable correlation",

  CorrelationMatrix = SIMP ( statut = "o", typ = Matrice(nbLigs=None,
                                                         nbCols=None,
                                                         methodeCalculTaille='NbDeVariables',
                                                         valSup=1,
                                                         valMin=-1,
                                                         structure="symetrique"),
                             fr = "Matrice de correlation entre les variables d'entree",
                             ang = "Correlation matrix for input variables" ),
)

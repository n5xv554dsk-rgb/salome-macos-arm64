# coding: utf-8

from Accas import *
class Tuple:
   def __init__(self,ntuple):
     self.ntuple=ntuple

   def __convert__(self,valeur):
     import types
     if type(valeur) == types.StringType:
       return None
     if len(valeur) != self.ntuple:
       return None
     return valeur

   def info(self):
     return "Tuple de %s elements" % self.ntuple

   __repr__=info
   __str__=info



class forme ( ASSD ) : pass

JdC = JDC_CATA (code = 'MED',
                execmodul = None,
                )

FORME_GEOMETRIQUE=OPER(nom='FORME_GEOMETRIQUE',sd_prod =forme ,op=None,
           Forme=SIMP(statut="o",typ='TXM',into=[ 'carre', 'cercle', 'triangle' ],defaut='carre'),
           bloc_pour_Carre =  BLOC (condition = "Forme=='carre'",
              Cote=SIMP(statut="o",typ='I'), ) , # fin bloc_pour_carre
           bloc_pour_cercle =  BLOC (condition ="Forme=='cercle'",
              rayon=SIMP(statut="o",typ='I'), ) , # fin bloc_pour_cercle

           DE_NOMBREUSES_WIDGETS= FACT(statut="o",
                Stop_Criteria = SIMP(statut = 'o',typ = Tuple(3),validators = VerifTypeTuple(('R','R','R'))),
                Fichier_Med = SIMP( statut = 'o', typ = ('Fichier', 'Med Files (*.med);;All Files (*)',),),
                ListeDeChoixPlusGrande=SIMP(statut="o",typ='TXM',into=['a','b,','c','d','e','f','g','h'],
                homo="SansOrdreNiDoublon",),
                Un_Parametre_Facultatif=SIMP(statut="f",typ='TXM')
                
           ),
          Couleur=SIMP(statut = 'f',typ='TXM'),
          Matiere=SIMP(statut = 'f',typ='TXM'),
);


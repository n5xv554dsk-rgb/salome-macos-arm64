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
#===============================
# 5. Definition des parametres
#===============================
VARI = OPER ( nom = "VARI",
                      sd_prod = variable,
                      op = None,
                      fr = "Definitions des lois marginales utilisees par les variables d'entree", 
                      type=SIMP(statut='f',defaut="IN",into=("IN","OUT"), typ = "TXM",)
              )

VARI1 = OPER ( nom = "VARI1",
                      sd_prod = variable,
                      op = None,
                      fr = "Definitions des lois marginales utilisees par les variables d'entree", 

                       POUTRE               = FACT(statut= 'f',max= '**',
                          MAILLE   = SIMP(statut= 'f',typ= 'TXM' ,validators= NoRepeat(),max= '**'),
                          GROUP_MA = SIMP(statut= 'f',typ= 'TXM' ,validators= NoRepeat(),max= '**'),
                       ),
                       POUTRE2               = FACT(statut= 'f',max= '**',
                          MAILLE2   = SIMP(statut= 'f',typ= 'TXM' ,validators= NoRepeat(),max= '**'),
                          GROUP_MA2 = SIMP(statut= 'f',typ= 'TXM' ,validators= NoRepeat(),max= '**'),
                       ),
                       FINAL =FACT(statut= 'f',max= '**',
                         type=SIMP(statut='f',min=1,max= '**', into=("POUTRE","POUTRE2"), 
                                   validators=[VerifExiste(2),NoRepeat()], typ="TXM",),
                       ),
              )


FICXML=MACRO(nom="FICXML",
            op=None,
            UIinfo={"groupes":("Gestion du travail",)},
            fr="Débranchement vers un fichier de commandes secondaires",
            sd_prod=loi,
            FICHIER  = SIMP(statut='o',typ='TXM',),
);


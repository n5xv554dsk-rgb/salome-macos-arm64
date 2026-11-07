# coding: utf-8

from Accas import *

JdC = JDC_CATA (code = 'PATTERNS',
                execmodul = None,
                )
def several(suffix,num):
    out=list()
    for i in range(1,num+1):
        out.append(suffix+str(i).zfill(2))
    return out

NUMERICAL_PARAMETERS=PROC(nom = "NUMERICAL_PARAMETERS", op=None, ang="Help for NUMERICAL_PARAMETERS, English version",
    #Equations=SIMP(statut = 'o',typ = 'TXM',into=("EF","VF","BS"),defaut="EF"),
    Solver_definition=FACT(statut = 'o',
        Solver = SIMP(statut = 'o',typ = 'TXM', into=several("Solver_",12), defaut="Solver_06"),
    )
)
PASCALE=PROC(nom = "PASCALE", op=None, ang="Help for NUMERICAL_PARAMETERS, English version",
    Equations=SIMP(statut = 'o',typ = 'TXM',into=("EF","VF","BS"),defaut="EF"),
    Solver_definition=FACT(statut = 'o',
        Solver = SIMP(statut = 'o',typ = 'TXM', into=several("Solver_",12), defaut="Solver_06"),
    )
)

Classement_Commandes_Ds_Arbre=('NUMERICAL_PARAMETERS',)

Ordre_Des_Commandes = ('NUMERICAL_PARAMETERS',)

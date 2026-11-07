# coding: utf-8

from Accas import *

JdC = JDC_CATA (code = 'PATTERNS',
                execmodul = None,
                )

PROC_01 = PROC(nom = "PROC_01",op = None, ang="Help for PROC_01 EN",
    MAX_ROWS=SIMP(statut='o',typ='I',val_min=1,val_max=8, defaut=8),
    PROCGROUP1=SIMP(statut='o',typ='TXM',into=("1","2","add new row",)),
    wideblock1=BLOC(condition='PROCGROUP1 in "add new row"',
        PROCGROUP2=SIMP(statut='o',typ='TXM',into=("1","add new row","3",)),
    )
)

Classement_Commandes_Ds_Arbre=('PROC_01',)

Ordre_Des_Commandes = ('PROC_01',)

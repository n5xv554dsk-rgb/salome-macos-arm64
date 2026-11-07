# coding: utf-8

from Accas import *

class loi(): pass

JdC = JDC_CATA (code = 'PATTERNS',
                execmodul = None,
                )
use_and=False #switch off second condition about MAX_ROWS while it does not work for blocks greater than 2
def cond2(myMax=False):
    if use_and:
        if myMax:
            out= " and MAX_ROWS>="+str(myMax)
        else:
            out=""
    else: 
        out=""
    #print out
    return out

PROC_01 = PROC(nom = "PROC_01",op = None, ang="Help for PROC_01 EN",
    MAX_ROWS=SIMP(statut='o',typ='I',val_min=1,val_max=8, defaut=8),
    PROCGROUP1=SIMP(statut='o',typ='TXM',into=("1","2","add new row",)),
    wideblock1=BLOC(condition='PROCGROUP1=="add new row"'+cond2(1),
        PROCGROUP2=SIMP(statut='o',typ='TXM',into=("1","add new row","3",)),
        wideblock2=BLOC(condition='PROCGROUP2=="add new row"'+cond2(2),
            PROCGROUP3=SIMP(statut='o',typ='TXM',into=("1","2","add new row",)),
            wideblock3=BLOC(condition='PROCGROUP3=="add new row"'+cond2(3),
                PROCGROUP4=SIMP(statut='o',typ='TXM',into=("1","add new row","3",)),
                wideblock4=BLOC(condition='PROCGROUP4=="add new row"'+cond2(4),
                    PROCGROUP5=SIMP(statut='o',typ='TXM',into=("add new row","2","3",)),
                    wideblock5=BLOC(condition='PROCGROUP5=="add new row"'+cond2(5), 
                        PROCGROUP6=SIMP(statut='o',typ='TXM',into=("1","2","add new row",)),
                        wideblock6=BLOC(condition='PROCGROUP6=="add new row"'+cond2(6), 
                            PROCGROUP7=SIMP(statut='o',typ='TXM',into=("1","add new row","3",)),
                            wideblock7=BLOC(condition='PROCGROUP7=="add new row"'+cond2(7), 
                                PROCGROUP8=SIMP(statut='o',typ='TXM',into=("add new row","2","3",)),
                                wideblock8=BLOC(condition='PROCGROUP8=="add new row"'+cond2(8),
                                )
                            )
                        )
                    )
                )
            )
        )
    )
)

#LEV1 = OPER( nom = "LEV1",
#    sd_prod=loi,
#    op=68,
#    fr='LEV1 FR',
#    Boolean01=SIMP( statut = 'o',typ = bool, defaut=True, fr = 'Bool mandatory FR', ang = 'Bool mandatory EN'),
#    SelectedItem=SIMP(statut = 'o',typ = 'TXM', into=["01_01","01_02","01_03","01_04"], fr="FR"),
#)

Classement_Commandes_Ds_Arbre=('PROC_01',)

Ordre_Des_Commandes = ('PROC_01',)

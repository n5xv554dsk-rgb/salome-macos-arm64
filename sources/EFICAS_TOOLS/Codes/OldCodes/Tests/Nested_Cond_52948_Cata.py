# coding: utf-8

from Accas import *

class loi(ASSD): pass

JdC = JDC_CATA (code = 'PATTERNS',
                execmodul = None,
                )

PER_01 = OPER( nom = "PER_01",
    sd_prod=loi,
    op=68,
    fr='LEV1 FR',
    Boolean01=SIMP( statut = 'o',typ = bool, defaut=True, fr = 'Bool mandatory FR', ang = 'Bool mandatory EN'),
    SelectedItem=SIMP(statut = 'o',typ = 'TXM', into=["01_01","01_02","01_03","01_04"], fr="FR"),
)

#Classement_Commandes_Ds_Arbre=('OPER_01',)

#Ordre_Des_Commandes = ('OPER_01',)

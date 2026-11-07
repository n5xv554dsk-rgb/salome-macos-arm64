#  coding: utf-8 -*-
#

from Accas import *
class MYOPER(ASSD) : pass

JdC   = JDC_CATA(code='Test1',)
MonOper=OPER(nom="MonOper", sd_prod=MYOPER,
    param1 = SIMP(statut='o',typ='R'),
)
MonProc = PROC(nom='MonProc',
    param1 = SIMP(statut='o',typ='R'),
)
MonProc2 = PROC(nom='MonProc2',
    param1 = SIMP(statut='o',typ='R'),
    param11 = SIMP(statut='f',typ='R'),
    param12= SIMP(statut='o',typ='R',into=[1.0,2.0,3.0,4.0,9.0],),
    b1     = BLOC (condition = 'param1 == 2',
        param1_inBloc = SIMP(statut='o',typ='R', defaut = 2),
        B11 = BLOC (condition = 'param1_inBloc == 2',
              param1_inBlocDeBloc = SIMP(statut='o',typ='R', defaut=3),
                B111 = BLOC (condition = 'param1_inBlocDeBloc == 2',
                    paramDernier = SIMP(statut='o',typ='R', defaut=2),
                    paramFacultatifDsB111 = SIMP(typ='R',statut='f'),
                    paramFacultatifDefaut = SIMP(typ='R',statut='f',defaut=3)
                ),
        ),
        param2_inBloc = SIMP(statut='o',typ='R'),
    ),
    Fact1  = FACT (statut ='o', max=4, 
        paramInFact1 = SIMP(statut='o',typ='R',max=1),
    ),
    Fact2  = FACT (statut ='f',
        param3InFact2 = SIMP(statut='o',typ='R'),
        paramFacultatif = SIMP(statut='f',typ='R'),
    ),
    Fact3  = FACT (statut ='f',
        param1InFact3 = SIMP(statut='f',typ='R'),
        paramFacultatif = SIMP(statut='f',typ='R'),
    ),
)


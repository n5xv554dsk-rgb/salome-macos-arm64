# coding: utf-8

from Accas import *

JdC = JDC_CATA (code = 'MED',
                execmodul = None,
                )
FAS=PROC(nom='FAS',op=None,
    FAMILY_MESH_NAME_REF = FACT(statut='o', max='**',

                NAME=SIMP(statut="o",typ='TXM'),
                ELEM=FACT(statut="f", max="**",
                        NUM=SIMP(statut="o",typ='TXM',),
                        NAME=SIMP(statut="o",typ='TXM',),
                        ATT=FACT(statut="f",
                                NBR=SIMP(statut="o", max=1   , typ = 'I'),
                                DES=SIMP(statut="o", max="**", typ = 'TXM'),
                                IDE=SIMP(statut="o", max="**", typ = 'I'),
                                VAL=SIMP(statut="o", max="**", typ = 'I'),
                                ),
                        GRO=FACT(statut="f",
                                NBR=SIMP(statut="o", max=1   , typ = 'I'),
                                NOM=SIMP(statut="o", max="**", typ='TXM'),
                                ),
                ),
        ),
);



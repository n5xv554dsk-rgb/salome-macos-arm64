# coding: utf-8
from Accas import *
#class myModel(ASSD): pass

JdC = JDC_CATA(code='GLOB_COND',
               execmodul=None,
               regles=(AU_PLUS_UN('TYPES',),
                       AU_PLUS_UN('INITS',),
					   AU_PLUS_UN('DATAS',),
                       #A_CLASSER('TYPES','INITS','DATAS')
                       )
);

TYPES=PROC(nom='TYPES',op=None,UIinfo={"groupes":("Global_Workflow",)}, #sd_prod=myModel,
    MODE=SIMP(
		typ='TXM',
		statut='o',
                position='global_jdc',
		into=("MANUAL","AUTOMATIC","MIXED"),
		defaut="AUTOMATIC",
		),
);

liste_condition=('INITS', 'DATAS')  

INITS=PROC(nom='INITS',op=None,UIinfo={"groupes":("INI_param",)},
	ini_manual=BLOC(condition="MODE == 'MANUAL'",
		Informer=SIMP(statut='o',typ='TXM', defaut="INITS MANUAL"),
	),
	ini_auto=BLOC(condition="MODE == 'AUTOMATIC'",
		Informer=SIMP(statut='o', typ='TXM', defaut="INITS AUTOMATIC",),
	),
	ini_mixed=BLOC(condition="MODE == 'MIXED'",
		Informer=SIMP(statut='o',typ='TXM', defaut="INITS MIXED",),
	),
);
DATAS=PROC(nom='DATAS',op=None,UIinfo={"groupes":("DATAS",)},
    data_manual=BLOC(condition="MODE == 'MANUAL'",
		Informer=SIMP(statut='o',typ='TXM', defaut="DATAS MANUAL",
			),
	),
	data_auto=BLOC(condition="MODE == 'AUTOMATIC'",
		Informer=SIMP(statut='o', typ='TXM', defaut="DATAS AUTOMATIC",
			),
	),
	data_mixed=BLOC(condition="MODE == 'MIXED'",
		Informer=SIMP(statut='o',typ='TXM', defaut="DATAS MIXED",
			),
	),
);

Classement_Commandes_Ds_Arbre=('TYPES','INITS','DATAS')
Ordre_Des_Commandes = ('TYPES','INITS','DATAS')

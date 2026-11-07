# coding: utf-8
from Accas import *

#class myMesh(ASSD): pass
class myModel(ASSD): pass

JdC = JDC_CATA(code='PATTERNS',
               execmodul=None,
               regles=(#AU_PLUS_UN('DEBUT', 'POURSUITE'),
                       AU_PLUS_UN('ALL_LISTS'),
                       #AU_PLUS_UN('FIN'),
                       A_CLASSER(('DEBUT', 'POURSUITE'), 'FIN')
                )
)


ALL_LISTS=OPER(nom="ALL_LISTS",op=18,sd_prod=myModel,
    UIinfo={"groupes":("Group1",)},
    ang="Model mesh definition EN",
    reentrant='n',
    LIST_O_NOREPEAT_CHECKTEXT_ADD_DEFAUT=SIMP(statut='o',typ="TXM",validators=NoRepeat(), 
          into=("item01","text01","item02","text02","item03","text03","item04","text04","item05","text05",), 
          defaut=('item01','item02','item03'),
          homo="SansOrdreNiDoublon",
          min=3, max='**'),

    #regles=(AU_MOINS_UN('LIST_O_CHECKTEXT','LIST_F_CHECKTEXT','LIST_O_ANY','LIST_F_ANY')),

	#LIST_O_NOREPEAT_CHECKTEXT=SIMP(statut='o',typ=grma,validators=NoRepeat(),min=3, max='**'),
    #LIST_F_NOREPEAT_CHECKTEXT=SIMP(statut='f',typ=grma,validators=NoRepeat(),min=3, max='**'),
    #LIST_F_REPEAT_CHECKTEXT=SIMP(statut='f',typ=grma,min=3, max='**'),
	#LIST_O_REPEAT_CHECKTEXT=SIMP(statut='o',typ=grma,min=3, max='**'),

    #LIST_F_NOREPEAT_ANYTEXT=SIMP(statut='f',typ='TXM',validators=NoRepeat(),min=3, max='**'),
	#LIST_O_NOREPEAT_ANYTEXT=SIMP(statut='o',typ='TXM',min=3,validators=NoRepeat(), max='**'),
	#LIST_O_REPEAT_ANYTEXT=SIMP(statut='o',typ='TXM',min=3, max='**'),
	#LIST_F_REPEAT_ANYTEXT=SIMP(statut='f',typ='TXM',min=3, max='**'),

	#LIST_O_NOREPEAT_CHECKTEXT_ADD=SIMP(statut='o',typ=grma,validators=NoRepeat(), into=("item01","text01","item02","text02","item03","text03",), min=3, max='**'),
	#LIST_F_REPEAT_ANYTEXT_ADD=SIMP(statut='f',typ=grma,validators=NoRepeat(), into=("item01","text01","item02","text02","item03","text03",), min=3, max='**'),

	#LIST_O_NOREPEAT_CHECKTEXT_ADD_NODEFAUT=SIMP(statut='o',typ=grma,validators=NoRepeat(), into=("item01","text01","item02","text02","item03","text03","item04","text04",), min=3, max='**'),


	#LIST_O_SANSORDRENODOUBLON_CHECKTEXT_DEFAUT=SIMP(statut='o',typ=grma,homo="SansOrdreNiDoublon", into=("item01","text01","item02","text02","item03","text03",), defaut=('item01','item02','item03'), min=3, max='**'),
)



Classement_Commandes_Ds_Arbre=('DEBUT','MESH_TYPES','ALL_LISTS','FIN')

Ordre_Des_Commandes = ('DEBUT','MESH_TYPES','ALL_LISTS','FIN')

# coding: utf-8
from Accas import *

class myModel(ASSD): pass

JdC = JDC_CATA(code='PATTERNS',
               execmodul=None,
               regles=(#AU_PLUS_UN('DEBUT', 'POURSUITE'),
                       AU_PLUS_UN('ALL_LISTS'),
                       #AU_PLUS_UN('FIN'),
                       A_CLASSER(('DEBUT', 'POURSUITE'), 'FIN')
                )
)

class grma():
    def __convert__(cls,valeur):
        if isinstance(valeur, (str,unicode)) and len(valeur.strip()) <= 12 and ("item" in (valeur.strip()).lower()): #
            return valeur.strip()
        raise ValueError("Name length does not contain \"test\" and is longer than allowed, 12")
    __convert__ = classmethod(__convert__)

def mySeveral(suffix,num):
    out=list()
    for i in range(1,num+1):
        out.append(suffix+str(i).zfill(2))
    return out

ALL_LISTS=OPER(nom="ALL_LISTS",op=18,sd_prod=myModel,
    UIinfo={"groupes":("Group1",)},
    fr="All lists definition FR",
    ang="All lists definition EN",
    reentrant='n',
    #regles=(AU_MOINS_UN('LIST_O_CHECKTEXT','LIST_F_CHECKTEXT','LIST_O_ANY','LIST_F_ANY')),

	L1_LIST_O_NOREPEAT_CHECKTEXT=SIMP(statut='o',typ=grma,validators=NoRepeat(),min=3, max='**', ang='Obligatory, No Repetitions, checked text, EN'),
    L2_LIST_F_NOREPEAT_CHECKTEXT=SIMP(statut='f',typ=grma,validators=NoRepeat(),min=3, max='**', ang='Optional, No Repetitions, checked text, EN'),
    L3_LIST_F_REPEAT_CHECKTEXT=SIMP(statut='f',typ=grma,min=3, max='**',ang='Optional, Allowed Repetitions, checked text, EN'),
	L4_LIST_O_REPEAT_CHECKTEXT=SIMP(statut='o',typ=grma,min=3, max='**',ang='Obligatory, Allowed Repetitions, checked text, EN'),

    L5_LIST_F_NOREPEAT_ANYTEXT=SIMP(statut='f',typ='TXM',validators=NoRepeat(),min=3, max='**',ang='Optional, No Repetitions, any text, EN'),
	L6_LIST_O_NOREPEAT_ANYTEXT=SIMP(statut='o',typ='TXM',min=3,validators=NoRepeat(), max='**',ang='Obligatory, No Repetitions, any text, EN'),
	L7_LIST_O_REPEAT_ANYTEXT=SIMP(statut='o',typ='TXM',min=3, max='**',ang='Obligatory, Allowed Repetitions, any text, EN'),
	L8_LIST_F_REPEAT_ANYTEXT=SIMP(statut='f',typ='TXM',min=3, max='**',ang='Optional, Allowed Repetitions, any text, EN'),

	L9_LIST_O_NOREPEAT_CHECKTEXT_ADD=SIMP(statut='o',typ=grma,validators=NoRepeat(), into=("item01","text01","item02","text02","item03","text03",), min=3, max='**',ang='With spare list, Obligatory, No Repetitions, checked text, EN',),
	L10_LIST_F_REPEAT_ANYTEXT_ADD=SIMP(statut='f',typ='TXM', into=("item01","text01","item02","text02","item03","text03",), min=3, max='**',ang='With spare list, Optional, Allowed Repetitions, any text, EN'),
	L11_LIST_O_REPEAT_CHECKTEXT_ADD_NODEFAUT=SIMP(statut='o',typ=grma, into=("item01","text01","item02","text02","item03","text03","item04","text04"),ang='With spare list, obligatory, No Repetitions, checked text, no default values, EN', min=3, max='**'),
	L12_LIST_O_NOREPEAT_CHECKTEXT_ADD_DEFAUT=SIMP(statut='o',typ=grma,validators=NoRepeat(), into=("item01","text01","item02","text02","item03","text03","item04","text04","item05","text05",), defaut=('item01','item02','item03'), min=3, max='**',ang='With spare list, Obligatory, No Repetitions, checked text, with default values EN'),

    L13_LIST_F_SANSORDRENODOUBLON_ANYTEXT_NODEFAUT=SIMP(statut='f',typ='TXM',homo="SansOrdreNiDoublon", into=("item01","text01","item02","text02","item03","text03",), min=3, max='**',ang='With check boxes, Optional, any text, no defaults, EN'),
    L14_LIST_O_SANSORDRENODOUBLON_CHECKTEXT_NODEFAUT=SIMP(statut='o',typ=grma,homo="SansOrdreNiDoublon", into=("item01","text01","item02","text02","item03","text03",), min=3, max='**',ang='With check boxes, Obligatory, checked text, EN'),
	L15_LIST_O_SANSORDRENODOUBLON_CHECKTEXT_DEFAUT=SIMP(statut='o',typ=grma,homo="SansOrdreNiDoublon", into=("item01","text01","item02","text02","item03","text03","item02","text02","item01","text01",), defaut=('item01','item02','item03'), min=3, max='**', ang='With check boxes, Obligatory, checked text, with default values, EN'),
)



Classement_Commandes_Ds_Arbre=('DEBUT','MESH_TYPES','ALL_LISTS','FIN')

Ordre_Des_Commandes = ('DEBUT','MESH_TYPES','ALL_LISTS','FIN')

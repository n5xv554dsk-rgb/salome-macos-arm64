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

class grma():
    def __convert__(cls,valeur):
        if isinstance(valeur, (str,unicode)) and len(valeur.strip()) <= 24 : #and ("item" in (valeur.strip()))
            return valeur.strip()
        raise ValueError("Name length does not contain \"test\" and is longer than allowed, 24")
    __convert__ = classmethod(__convert__)

def mySeveral(suffix,num):
    out=list()
    for i in range(1,num+1):
        out.append(suffix+str(i).zfill(2))
    return out

switch_facultatif=True #change 'o' to 'f' of some widgets in the loop
#empty_defauts=True

def myBloc(num):
    myNum=str(num).zfill(2)
    list_item_body="Item_"+myNum+"_"
    defauts0=["","",True,"'phenomena_"+myNum+"'",mySeveral(list_item_body,2)] #presence of default values
    defauts_mask=[False,False,True,True,True] #switch off defaults of some types
    defauts=list()
    for id0 in range(len(defauts0)):
        if defauts_mask[id0]:
            item=", defaut="+str(defauts0[id0])
        else:
            item=""
        defauts.append(item)
    #print defauts

    opt=['o','o','o','o','o'] #initial default obligation of items in FACT groups
    #make different widgets optional, one by one:
    myLen=len(opt)
    if switch_facultatif:
        make_f=(num)%myLen
        opt[make_f]='f'
    #print opt
    #if empty_defauts:
    #    clean_defaut=num%myLen

    myString="BLOC(condition=\"MESH==\'mesh_"+myNum+"'\""+defauts[0]+", AFFE=FACT(statut='"+opt[1]+"'"+defauts[1]+", ALL=SIMP(statut='"+opt[2]+"', typ=bool,ang='ALL "+myNum+" help EN'"+defauts[2]+"),PHENOMENA=SIMP(statut='"+opt[3]+"',typ='TXM',into=mySeveral('phenomena_',"+str(num)+")"+defauts[3]+"), MODELISATION=SIMP(statut='"+opt[4]+"',typ='TXM', min=2,max='**',into=mySeveral('"+list_item_body+"',"+str(num*4)+")"+defauts[4]+", ang='Input "+myNum+" list EN', fr='Input "+myNum+" list FR'),),)"
    print myString
    return eval(myString)

ALL_LISTS=OPER(nom="ALL_LISTS",op=18,sd_prod=myModel,
    UIinfo={"groupes":("Group1",)},
    ang="Model mesh definition EN",
    reentrant='n',
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

	LIST_O_NOREPEAT_CHECKTEXT_ADD_NODEFAUT=SIMP(statut='o',typ=grma,validators=NoRepeat(), into=("item01","text01","item02","text02","item03","text03","item04","text04",), min=3, max='**'),
	#LIST_O_NOREPEAT_CHECKTEXT_ADD_DEFAUT=SIMP(statut='o',typ=grma,validators=NoRepeat(), into=("item01","text01","item02","text02","item03","text03",), defaut=('item01','item02','item03'), min=3, max='**'),
)

Classement_Commandes_Ds_Arbre=('DEBUT','MESH_TYPES','ALL_LISTS','FIN')

Ordre_Des_Commandes = ('DEBUT','MESH_TYPES','ALL_LISTS','FIN')

# coding: utf-8

from Accas import *

class myMesh(ASSD): pass
class myModel(ASSD): pass

JdC = JDC_CATA(code='PATTERNS',
               execmodul=None,
               regles=(AU_PLUS_UN('DEBUT', 'POURSUITE'),
                       AU_PLUS_UN('AFFE_MODELE'),
                       AU_PLUS_UN('FIN'),
                       A_CLASSER(('DEBUT', 'POURSUITE'), 'FIN')))

def mySeveral(suffix,num):
    out=list()
    for i in range(1,num+1):
        out.append(suffix+str(i).zfill(2))
    return out

switch_facultatif=True #change 'o' to 'f' of some widgets in the loop
empty_defauts=True

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
    #make some widgets optional:
    myLen=len(opt)
    if switch_facultatif:
        make_f=(num)%myLen
        opt[make_f]='f'
    #print opt
    if empty_defauts:
        clean_defaut=num%myLen

    myString="BLOC(condition=\"MESH==\'mesh_"+myNum+"'\""+defauts[0]+", AFFE=FACT(statut='"+opt[1]+"'"+defauts[1]+", ALL=SIMP(statut='"+opt[2]+"', typ=bool,ang='ALL "+myNum+" help EN'"+defauts[2]+"),PHENOMENA=SIMP(statut='"+opt[3]+"',typ='TXM',into=mySeveral('phenomena_',"+str(num)+")"+defauts[3]+"), MODELISATION=SIMP(statut='"+opt[4]+"',typ='TXM', min=2,max='**',into=mySeveral('"+list_item_body+"',"+str(num*4)+")"+defauts[4]+", ang='Input "+myNum+" list EN', fr='Input "+myNum+" list FR'),),)"
    print myString
    return eval(myString)

DEBUT=PROC(nom="DEBUT", op=10, repetable='n', UIinfo={"groupes":("Group1",)}, ang="Debut Eng help",
        PAR_LOT=SIMP(ang="Debut Par Lot help En",statut='o',typ=bool, defaut=True),
);

AFFE_MODELE=OPER(nom="AFFE_MODELE",op=18,sd_prod=myModel,
    UIinfo={"groupes":("Group1",)},
    ang="Model mesh definition EN",
    reentrant='n',
    regles=(AU_MOINS_UN('APPROVED')),
    MESH=SIMP(statut='o',typ='TXM',into=mySeveral("mesh_",4) ,defaut="mesh_01"),
	APPROVED=SIMP(statut="o", typ=bool),
    block_mesh_01=myBloc(1),
    block_mesh_02=myBloc(2),
    block_mesh_03=myBloc(3),
    block_mesh_04=myBloc(4),
)


FIN=PROC(nom="FIN",op=9999,repetable='n',ang="Finish help EN",UIinfo={"groupes":("Group1",)},
    FORMAT_HDF =SIMP(ang="Save HDF EN",statut='f',typ='TXM',defaut="NON",into=("OUI","NON",) ), 
);

Classement_Commandes_Ds_Arbre=('DEBUT','MESH_TYPES','AFFE_MODELE','FIN')

Ordre_Des_Commandes = ('DEBUT','MESH_TYPES','AFFE_MODELE','FIN')

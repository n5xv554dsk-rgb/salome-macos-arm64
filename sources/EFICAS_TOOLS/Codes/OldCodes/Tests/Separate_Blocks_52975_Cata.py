# coding: utf-8

from Accas import *

JdC = JDC_CATA (code = 'PATTERNS',
                execmodul = None,
                )
def mySeveral(suffix,num):
    out=list()
    for i in range(1,num+1):
        out.append(suffix+str(i).zfill(2))
    return out

switch_facultatif=True #change 'o' to 'f' of some widgets in the loop
empty_defauts=True

def myFact(num):
    myNum=str(num).zfill(2)
    list_item_body="Item_"+myNum+"_"

    defauts0=["","'"+list_item_body+myNum+"'", str(num/100.), str(100+num), "'Text_"+myNum+"'" ] #presence of default values
    defauts_mask=[False,True,True,False,True] #switch off defaults of some types
    defauts=list()
    for id0 in range(len(defauts0)):
        if defauts_mask[id0]:
            item=", defaut="+defauts0[id0]
        else:
            item=""
        defauts.append(item)
    print defauts

    opt=['o','o','o','o','o'] #initial default obligation of items in FACT groups
    #make some widgets optional:
    myLen=len(opt)
    if switch_facultatif:
        make_f=(num)%myLen
        opt[make_f]='f'
    #print opt
    if empty_defauts:
        clean_defaut=num%myLen


    myString="FACT(statut = '"+opt[0]+"', List_"+myNum+" = SIMP(statut = '"+opt[1]+"',typ = 'TXM', into=mySeveral('"+list_item_body+"',12)"+defauts[1]+"),Real_"+myNum+" = SIMP(statut = '"+opt[2]+"',typ = 'R'"+defauts[2]+", ang='Real "+myNum+" help EN'),Integer_"+myNum+" = SIMP(statut = '"+opt[3]+"',typ = 'I'"+defauts[3]+",ang='Integer "+myNum+" help EN'),Text_"+myNum+" = SIMP(statut = '"+opt[4]+"',typ = 'TXM'"+defauts[4]+",ang='Text "+myNum+" help EN'))"
    print myString
    return eval(myString)


PROC_01=PROC(nom = "PROC_01", op=None, ang="Help for PROC_01, English version",fr="Help for PROC_01, French version", docu="",
    Radio_01=SIMP(statut = 'o',typ = 'TXM',into=("EF","VF","BS"),defaut="EF"),
    FACT_01=myFact(1),
    FACT_02=myFact(2),
    FACT_03=myFact(3),
    FACT_04=myFact(4),
    FACT_05=myFact(5),
    #FACT_06=myFact(6),
    #FACT_07=myFact(7),
    #FACT_08=myFact(8),
    #FACT_09=myFact(9),
    #FACT_10=myFact(10),
    #FACT_11=myFact(11),
    #FACT_12=myFact(12),
)

Classement_Commandes_Ds_Arbre=('PROC_01',)

Ordre_Des_Commandes = ('PROC_01',)

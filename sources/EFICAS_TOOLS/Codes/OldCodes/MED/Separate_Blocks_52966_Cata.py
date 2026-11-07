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

switch_facultatif=False #change 'o' to 'f' of some widgets in the loop

def myFact(num):
    opt=['o','f','o','o']
    if switch_facultatif:
        myLen=len(opt)
        make_f=(num-1)%myLen
        opt[make_f]='f'
    #print opt
    myNum=str(num).zfill(2)
    list_item_body="Item_"+myNum+"_"
    myString="FACT(statut = '"+opt[0]+"', List_"+myNum+" = SIMP(statut = '"+opt[1]+"',typ = 'TXM', into=mySeveral('"+list_item_body+"',12), defaut='"+list_item_body+myNum+"'),Real_"+myNum+" = SIMP(statut = '"+opt[2]+"',typ = 'R', defaut = "+str(num/100.)+", ang='Real "+myNum+" help EN'),Integer_"+myNum+" = SIMP(statut = '"+opt[3]+"',typ = 'I', defaut = "+str(100+num)+",ang='Max_Iter "+myNum+" help EN'))"
    print myString
    return eval(myString)


PROC_01=PROC(nom = "PROC_01", op=None, ang="Help for PROC_01, English version",fr="Help for PROC_01, French version", docu="",
    Radio_01=SIMP(statut = 'o',typ = 'TXM',into=("EF","VF","BS"),defaut="EF"),
    FACT_01=myFact(1),
    FACT_02=myFact(2),
    FACT_03=myFact(3),
    FACT_04=myFact(4),
    FACT_05=myFact(5),
    FACT_06=myFact(6),
    FACT_07=myFact(7),
    FACT_08=myFact(8),
    FACT_09=myFact(9),
    FACT_10=myFact(10),
    FACT_11=myFact(11),
    FACT_12=myFact(12),
)

Classement_Commandes_Ds_Arbre=('PROC_01',)

Ordre_Des_Commandes = ('PROC_01',)

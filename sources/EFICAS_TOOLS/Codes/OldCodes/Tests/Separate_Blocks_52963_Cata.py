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

def myFact(num):
    myNum=str(num).zfill(2)
    list_item_body="Item_"+myNum+"_"
    myString="FACT(statut = 'f', List_"+myNum+" = SIMP(statut = 'o',typ = 'TXM', into=mySeveral('"+list_item_body+"',12), defaut='"+list_item_body+myNum+"'),Real_"+myNum+" = SIMP(statut = 'o',typ = 'R', defaut = "+str(num/100.)+", ang='Real "+myNum+" help EN'),Integer_"+myNum+" = SIMP(statut = 'o',typ = 'I', defaut = "+str(100+num)+",ang='Max_Iter "+myNum+" help EN'))"
    print myString
    return eval(myString)


PROC_01=PROC(nom = "PROC_01", op=None, ang="Help for PROC_01, English version",fr="Help for PROC_01, French version", docu="",
    Radio_01=SIMP(statut = 'f',typ = 'TXM',into=("EF","VF","BS"),defaut="EF"),
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

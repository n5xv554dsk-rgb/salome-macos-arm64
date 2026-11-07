from Accas import SIMP,FACT,OPER,ASSD,AsException,AsType
import Noyau

class CATA:
   def __init__(self):
      CONTEXT.unset_current_cata()
      CONTEXT.set_current_cata(self)
   def enregistre(self,cmd):
      pass

cata=CATA()

class concept(ASSD,Noyau.AsBase):pass

OP1 = OPER(nom='OP1',op=1,sd_prod=concept,
           a=SIMP(typ='I'),
           c=SIMP(typ='I',position='global'),
          )

class concept2(ASSD,Noyau.AsBase):pass
class concept3(ASSD,Noyau.AsBase):pass

def op2_prod(TYPE_RESU,**args):
   if TYPE_RESU == "TRANS" : return concept2
   if TYPE_RESU == "HARMO" : return concept3
   raise AsException("type de concept resultat non prevu")

OP2=OPER(nom='OP2',op=2,sd_prod=op2_prod,
          TYPE_RESU       =SIMP(statut='f',typ='TXM',defaut="TRANS",into=("TRANS","HARMO") ),
        )

def op3_prod(MATR,**args):
   if AsType(MATR) == concept : return concept2
   raise AsException("type de concept resultat non prevu")

OP3=OPER(nom='OP3',op=3,sd_prod=op3_prod,
           MATR    =SIMP(statut='o',typ=concept),
        )

def op4_prod(MESURE,**args):
   vale=MESURE['NOM_PARA']
   if  vale == 'INST'   : return concept
   raise AsException("type de concept resultat non prevu")

OP4=OPER(nom='OP4',op=4,sd_prod=op4_prod,
            MESURE  =FACT(statut='o',min=01,max=01,
                          NOM_PARA  =SIMP(statut='f',typ='TXM',defaut="INST",into=("INST",) ),
                         )
        )

def op5_prod(FFT,**args):
   if (FFT != None)        :
      vale=FFT.get_child('FONCTION').get_valeur()
      if (AsType(vale) == concept )  : return concept
      if (AsType(vale) == concept2) : return concept2
   raise AsException("type de concept resultat non prevu")


OP5=OPER(nom='OP5',op=5,sd_prod=op5_prod,
         FFT =FACT(statut='f',min=1,max=1,
                    FONCTION =SIMP(statut='o',typ=(concept,concept2) )
                   ),
         )

def op6_prod(FILTRE,**args):
   vale=FILTRE[0]['MODE']
   if  AsType(vale) == concept : return concept
   if  AsType(vale) == concept2 : return concept2
   raise AsException("type de concept resultat non prevu")

OP6=OPER(nom='OP6',op=6,sd_prod=op6_prod,
            FILTRE  =FACT(statut='o',min=01,max='**',
                          MODE  =SIMP(statut='o',typ=(concept,concept2) ),
                         )
        )

OP7=OPER(nom='OP7',op=7,sd_prod=concept,
            FILTRE  =FACT(statut='o',min=01,max='**',
                          MODE  =SIMP(statut='o',typ=(concept,concept2) ),
                         )
        )


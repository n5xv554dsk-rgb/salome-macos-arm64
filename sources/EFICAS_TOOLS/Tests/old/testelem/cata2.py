from Accas import SIMP,FACT,OPER,ASSD,AsException,AsType,CO,MACRO
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

def op2_prod(self,MATR,**args):
   self.type_sdprod(MATR,concept2)
   return concept

OP2=MACRO(nom='OP2',op=-2,sd_prod=op2_prod,
          MATR=SIMP(statut='o',typ=(CO,concept2)),
        )

def op3_prod(self,MATR,**args):
   for m in MATR:
      t=m['CHAM']
      if t == 'R':self.type_sdprod(m['MM'],concept)
   return concept

OP3=MACRO(nom='OP3',op=-3,sd_prod=op3_prod,
          MATR=FACT(statut='f',min=1,max='**',
                    CHAM=SIMP(statut='o',typ='TXM',into=("R","I"),),
                    MM=SIMP(statut='o',typ=(CO,concept)),
                   ),
          )


def op4_prod(self,MATR,**args):
   if MATR == None :raise AsException("impossible recuperer mot cle facteur par defaut")
   return concept

OP4=MACRO(nom='OP4',op=-4,sd_prod=op4_prod,
          MATR=FACT(statut='d',min=1,max='**',
                    CHAM=SIMP(statut='f',typ='TXM',defaut="R"),
                   ),
          )
OP5=MACRO(nom='OP5',op=-2,sd_prod=op2_prod, MATR=SIMP(statut='o',typ=CO),)

def OP6_ops(self,MATR,**args):
  """
  """
  ier=0
  self.set_icmd(1)
  self.DeclareOut('cc',self.sd)
  cc=OP2(MATR=MATR)
  return ier

OP6=MACRO(nom='OP6',op=OP6_ops,sd_prod=op2_prod, MATR=SIMP(statut='o',typ=CO),)


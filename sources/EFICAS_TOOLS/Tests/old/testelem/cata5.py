# -*- coding: iso-8859-15 -*-
from Accas import SIMP,FACT,OPER,ASSD,AsException,AsType,CO,MACRO,JDC_CATA
import Noyau
JdC=JDC_CATA(code="ASTER")

class concept(ASSD,Noyau.AsBase):pass
class concept2(ASSD,Noyau.AsBase):pass
class concept3(ASSD,Noyau.AsBase):pass
class concept4(concept2):pass

def OP_ops(self,MATR,**args):
  ier=0
  self.set_icmd(1)
  return ier

def op2_prod(self,MATR,**args):
   self.type_sdprod(MATR,concept2)
   return concept
OP1=MACRO(nom='OP1',op=OP_ops,sd_prod=op2_prod, MATR=SIMP(statut='o',typ=CO),)
OP2=MACRO(nom='OP2',op=OP_ops,sd_prod=op2_prod, MATR=SIMP(statut='o',typ=(CO,concept2)),)
OP10=MACRO(nom='OP10',op=OP_ops,sd_prod=op2_prod, MATR=SIMP(statut='o',typ=concept2),)
OP11=MACRO(nom='OP11',op=OP_ops,sd_prod=concept, MATR=SIMP(statut='o',typ=concept2),)
OP12=MACRO(nom='OP12',op=OP_ops,sd_prod=concept, MATR=SIMP(statut='o',typ=CO),)
OP13=MACRO(nom='OP13',op=OP_ops,sd_prod=concept, MATR=SIMP(statut='o',typ=(CO,concept2)),)

def op3_prod(self,MATR,**args):
   for m in MATR:
      t=m['CHAM']
      if t == 'R':self.type_sdprod(m['MM'],concept)
   return concept
OP3=MACRO(nom='OP3',op=OP_ops,sd_prod=op3_prod,
          MATR=FACT(statut='f',min=1,max='**',
                    CHAM=SIMP(statut='o',typ='TXM',into=("R","I"),),
                    MM=SIMP(statut='o',typ=(CO,concept)),),)

def op4_prod(self,MATR,**args):
   if MATR == None :raise AsException("impossible recuperer mot cle facteur par defaut")
   return concept
OP4=MACRO(nom='OP4',op=OP_ops,sd_prod=op4_prod,
          MATR=FACT(statut='d',min=1,max='**',
                    CHAM=SIMP(statut='f',typ='TXM',defaut="R"),),)

OP5=MACRO(nom='OP5',op=OP_ops,sd_prod=op2_prod, MATR=SIMP(statut='o',typ=CO),)

def op6_prod(self,MATR,**args):
   self.type_sdprod(MATR,concept4)
   return concept
def OP6_ops(self,MATR,**args):
  ier=0
  self.set_icmd(1)
  self.DeclareOut('cc',self.sd)
  cc=OP2(MATR=MATR)
  return ier
OP6=MACRO(nom='OP6',op=OP6_ops,sd_prod=op6_prod, MATR=SIMP(statut='o',typ=CO),)

def OP7_ops(self,MATR,**args):
  ier=0
  self.set_icmd(1)
  self.DeclareOut('cc',self.sd)
  cc=OP8(MATR=MATR)
  return ier
OP7=MACRO(nom='OP7',op=OP7_ops,sd_prod=op2_prod, MATR=SIMP(statut='o',typ=CO),)

OP8=MACRO(nom='OP8',op=OP_ops,sd_prod=op6_prod, MATR=SIMP(statut='o',typ=(CO,concept4)),)

def OP9_ops(self,MATR,**args):
  ier=0
  self.set_icmd(1)
  self.DeclareOut('cc',self.sd)
  cc=OP10(MATR=MATR)
  return ier
OP9=MACRO(nom='OP9',op=OP9_ops,sd_prod=op6_prod, MATR=SIMP(statut='o',typ=CO),)
def OP14_ops(self,MATR,**args):
  ier=0
  self.set_icmd(1)
  self.DeclareOut('cc',self.sd)
  cc=OP1(MATR=MATR)
  return ier
OP14=MACRO(nom='OP14',op=OP14_ops,sd_prod=op6_prod, MATR=SIMP(statut='o',typ=CO),)
def OP15_ops(self,MATR,**args):
  ier=0
  self.set_icmd(1)
  self.DeclareOut('cc',self.sd)
  cc=OP11(MATR=MATR)
  return ier
OP15=MACRO(nom='OP15',op=OP15_ops,sd_prod=op6_prod, MATR=SIMP(statut='o',typ=CO),)
def OP16_ops(self,MATR,**args):
  ier=0
  self.set_icmd(1)
  self.DeclareOut('cc',self.sd)
  cc=OP12(MATR=MATR)
  return ier
OP16=MACRO(nom='OP16',op=OP16_ops,sd_prod=op6_prod, MATR=SIMP(statut='o',typ=CO),)
def OP17_ops(self,MATR,**args):
  ier=0
  self.set_icmd(1)
  self.DeclareOut('cc',self.sd)
  cc=OP13(MATR=MATR)
  return ier
OP17=MACRO(nom='OP17',op=OP17_ops,sd_prod=op6_prod, MATR=SIMP(statut='o',typ=CO),)

def OP18_ops(self,MATR,**args):
  ier=0
  self.set_icmd(1)
  self.DeclareOut('cc',self.sd)
  cc=OP6(MATR=MATR)
  dd=OP2(MATR=MATR)
  ee=OP11(MATR=MATR)
  return ier
OP18=MACRO(nom='OP18',op=OP18_ops,sd_prod=op6_prod, MATR=SIMP(statut='o',typ=CO),)
OP20=MACRO(nom='OP20',op=OP_ops,sd_prod=op6_prod, MATR=SIMP(statut='o',typ=CO),
                                               MATRB=SIMP(statut='o',typ=CO),)
def OP19_ops(self,MATR,**args):
  ier=0
  self.set_icmd(1)
  self.DeclareOut('cc',self.sd)
  cc=OP20(MATR=MATR,MATRB=MATR)
  return ier
OP19=MACRO(nom='OP19',op=OP19_ops,sd_prod=op6_prod, MATR=SIMP(statut='o',typ=CO),)

OP21=OPER(nom='OP21',op=1,sd_prod=concept)
def OP22_ops(self,MATR,**args):
  ier=0
  self.set_icmd(1)
  self.DeclareOut('cc',self.sd)
  cc=OP21()
  return ier
OP22=MACRO(nom='OP22',op=OP22_ops,sd_prod=op6_prod, MATR=SIMP(statut='o',typ=CO),)

import pickle
import Accas

def poursuite_sdprod(self,PAR_LOT):
  j=self.jdc
  #j.UserError=j.codex.error
  j.actif_status=1
  j.fico=None
  j.set_par_lot(PAR_LOT)
  if hasattr(self,'already_init'):return
  self.already_init=None
  context={}
  try:
       file=open("pick.1",'r')
       # Le contexte sauvegardé a été picklé en une seule fois. Il est seulement
       # possible de le récupérer en bloc. Si cette opération echoue, on ne récupère
       # aucun objet.
       context=pickle.load(file)
       file.close()
  except:
       # En cas d'erreur on ignore le contenu du fichier
       import traceback
       traceback.print_exc()
       pass
  for k,v in context.items():
    if isinstance(v,Accas.ASSD):
       self.parent.NommerSdprod(v,k)
  self.g_context.update(context)
  return None

def poursuite(self,PAR_LOT):
  ier=0
  self.set_icmd(1)
  return ier

POURSUITE=MACRO(nom='POURSUITE',op=poursuite,sd_prod=poursuite_sdprod,PAR_LOT=SIMP(typ='TXM',defaut='OUI'))

def fin(self):
  self.set_icmd(1)
  raise EOFError
FIN=MACRO(nom='FIN',op=fin,sd_prod=None)

def debut_sdprod(self,PAR_LOT):
  j=self.jdc
  #j.UserError=j.codex.error
  j.actif_status=1
  j.fico=None
  j.set_par_lot(PAR_LOT)
  return None

def debut(self,PAR_LOT):
  ier=0
  self.set_icmd(1)
  return ier

DEBUT=MACRO(nom='DEBUT',op=debut,sd_prod=debut_sdprod,PAR_LOT=SIMP(typ='TXM',defaut='OUI'))

class entier   (ASSD):
   def __init__(self,valeur=None,**args):
      ASSD.__init__(self,**args)
      self.valeur=valeur

   def __adapt__(self,validator):
      if validator.name == "list":
          #validateur liste,cardinalité
          return (self,)
      elif validator.name == "type":
          #validateur type
          return validator.adapt(self.valeur or 0)
      else:
          #validateur into et valid
          return self

   def __repr__(self):
      return "<concept entier>"


from Accas import SIMP,FACT,OPER,ASSD,AsException,AsType,CO,MACRO,JDC_CATA

class concept(ASSD):pass

JdC=JDC_CATA(code="ASTER")

OP1 = OPER(nom='OP1',op=1,sd_prod=concept,
           a=SIMP(typ='I'),
           c=SIMP(typ='I',position='global'),
          )

class concept2(ASSD):pass
class concept3(ASSD):pass

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

def INCLUDE_prod(self,UNITE,**args):
  """ Fonction sd_prod pour la macro include
  """
  # Si unite a change on reevalue le fichier associe
  if not hasattr(self,'unite') or self.unite != UNITE:
    f,text=self.get_file(unite=UNITE)
    self.unite=UNITE
    self.fichier_init = f
    # on execute le texte fourni dans le contexte forme par
    # le contexte de l etape pere (global au sens Python)
    # et le contexte de l etape (local au sens Python)
    code=compile(text,f,'exec')
    if self.jdc and self.jdc.par_lot == 'NON':
      # On est en mode commande par commande
      # On teste la validite de la commande avec interruption eventuelle
      cr=self.report()
      self.parent.cr.add(cr)
      if not cr.estvide():
        raise EOFError
    d={}
    self.g_context = d
    self.contexte_fichier_init = d
    exec code in self.parent.g_context,d

def INCLUDE_context(self,d):
  """ Fonction op_init pour macro INCLUDE
  """
  for k,v in self.g_context.items():
    d[k]=v

INCLUDE=MACRO(nom="INCLUDE",op=-1,
             sd_prod=INCLUDE_prod,
             op_init=INCLUDE_context,
             #fichier_ini=1,
              UNITE = SIMP(statut='o',typ='I'),
);


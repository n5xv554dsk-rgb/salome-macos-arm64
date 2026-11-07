# -*- coding: utf-8 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991-2026  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
#
#
# ======================================================================

import sys,string
try :
    import TextTools
except : 
    ""
try :
    from tables import ERRORS
except : 
    ""

#
__version__="$Name: V7_main $"
__Id__="$Id: conv.py,v 1.6.52.1 2013-01-24 14:25:23 pnoyret Exp $"
#

Keywords=('MAILLE_1','MAILLE_2','MAILLE_ESCL','MAILLE_FOND','MAILLE_MAIT','MAILLE_ORIG','MAILLE',
          'NOEUD', 'NOEUD_1','NOEUD_2','NOEUD_INIT','NOEUD_FIN', 'NOEUD_ORIG','NOEUD_REFE','NOEUD_EXTR',
          'NOEUD_I', 'NOEUD_J','NOEUD_CHOC','NOEUD_ANCRAGE','NOEUD_CENTRE','NOEUD_CMP','NOEUD_DOUBLE',
          'NOEUD_ESCL','NOEUD_FOND','NOEUD_PARA','NOEUD_POIN_TANG',
          'GROUP_MA', 'GROUP_MA_1','GROUP_MA_2','GROUP_MA_INT','GROUP_MA_EXT', 'GROUP_MA_ORIG',
          'GROUP_MA_BORD','GROUP_MA_INTE','GROUP_MA_FLUIDE', 'GROUP_MA_INTERF','GROUP_MA_BETON',
          'GROUP_MA_ESCL','GROUP_MA_FINAL','GROUP_MA_FLU_SOL','GROUP_MA_FLU_STR','GROUP_MA_FOND',
          'GROUP_MA_MAIT','GROUP_MA_RADIER','GROUP_MA_SOL_SOL','GROUP_MA_INIT',
          'GROUP_NO', 'GROUP_NO_1','GROUP_NO_2','GROUP_NO_EXT', 'GROUP_NO_ORIG','GROUP_NO_CHOC',
          'GROUP_NO_ANCRAGE','GROUP_NO_CENTRE','GROUP_NO_ESCL','GROUP_NO_EXTR','GROUP_NO_FIN',
          'GROUP_NO_FOND','GROUP_NO_INIT','GROUP_NO_POIN_TG','GROUP_NO_RADIER',
          'NOM','NOM_GROUP_MA',
          'SANS_NOEUD', 'SANS_GROUP_NO',
          'INTERSEC', 'UNION','DIFFE',
          'VECT_GRNO_ORIG','VECT_GRNO_EXTR',
          'VALE_CO'
         )

liste_macros=('MACRO_MATR_ASSE','MACRO_ELAS_MULT','MACR_ASCOUF_MAIL','MACR_ASCOUF_CALC','MACR_ASPIC_MAIL',
              'MACR_ASPIC_CALC','MACRO_MATR_AJOU','MACRO_ELAS_MULT','MACRO_MODE_MECA','MACRO_PROJ_BASE',
              'MACR_ADAP_MAIL',
              )
liste_concepts_produits=[]
commande_courante=''

def text_nom_ope(text,tags,left,right):
  global commande_courante
  if len(tags) :
    tag,l,r,subtags=tags[0]
    commande_courante=text[left:l]
    return text[left:l]+'('+text[l:r]
  else :
    commande_courante=text[left:right]
    return text[left:right]+'('
    
def text_reuse(text,tags):
  s=''
  for tag,l,r,subtags in tags:
    if tag == 'ident' :
      sd=text[l:r]
      s=s+ sd
    elif tag == 'nom_ope' : s=s+ '='+text_nom_ope(text,subtags,l,r)
    elif tag == 'affe' : 
      s=s+ '='+text_affe(text,subtags)
    elif tag == 'comm' :
      if commande_courante in liste_macros:
        s=s+'reuse='+sd+','+text_macro(text,subtags)+')'
      else:
        s=s+'reuse='+sd+','+text_com(text,subtags)+')'
    else:pass
  s=s+'\n'
  return s

def text_noreuse(text,tags):
  global commande_courante
  s=''
  for tag,l,r,subtags in tags:
    if tag == 'ident' :
      sd=text[l:r]
      s=s+ text[l:r]
    elif tag == 'nom_ope' :
      s=s+ '='+ text_nom_ope(text,subtags,l,r)
    elif tag == 'affe' :
      liste_concepts_produits.append(sd)
      s=s+ '='+text_affe(text,subtags)
    elif tag == 'comm' :
      if oldtag=='ident':
        if sd in liste_macros:
          s=s+'('+text_macro(text,subtags)+')'
        else:
          s=s+'('+text_com(text,subtags)+')'
      else:
        liste_concepts_produits.append(sd)
        if commande_courante in liste_macros:
          s=s+text_macro(text,subtags)+')'
        else:
          s=s+text_com(text,subtags)+')'
    else:pass
    oldtag=tag
  s=s+'\n'
  return s

def list_mc(lmc,mcs):
  s=''
  for k in lmc:
    v=mcs[k]
    if len(v) ==1:
      va,c=v[0]
      s=s+c+k+'='+va+','
    elif len(v) > 1:
      s=s+k+'=('
      for va,c in v:
        s=s+string.join((c,va,','),'')
      s=s[:-1]+'),'
  s=s[:-1]
  return s

def text_com(text,tags):
  mcs={}
  lmc=[]
  currid=None
  comment=''
  for tag,l,r,subtags in tags:
    if tag == 'ident' :
      currid=text[l:r]
      if not mcs.has_key(currid):
        mcs[currid]=[]
        lmc.append(currid)
    elif tag == 'mcf':
      ll=text_mcf(text,subtags)
      mcs[currid].append((ll,comment))
      comment=''
    elif tag == 'num' :
      a=string.replace(text[l:r],'D','E')
      mcs[currid].append((a,comment))
      comment=''
    elif tag == 'CPLX' :
      a=text_cplx(text,text[l:r],subtags)
      mcs[currid].append((a,comment))
      comment=''
    elif tag == 'arg' :
      a=''
      if currid in Keywords :
        # FR : (SGDG) il faut tester s'il n'y a pas déjà des cotes !!!
        if text[l]!="'" and text[r-1]!="'":
          a=a+"'"+text[l:r]+"'"
        else:
          a=a+text[l:r]
      else:
        a=a+text[l:r]
      mcs[currid].append((a,comment))
      comment=''
    elif tag == 'EVAL' :
      a=text_eval(text,subtags)
      mcs[currid].append((a,comment))
      comment=''
    elif tag == 'comment' :
      comment=comment + '#'+text[l+1:r]
    elif tag == 'comments' :
      comment=comment + text[l:r]
    elif tag == 'larg' :
      if currid in Keywords:mcs[currid].append((text_larg2(text,subtags),comment))
      else:mcs[currid].append((text_larg(text,subtags),comment))
      comment=''
    else :pass
  s=list_mc(lmc,mcs)
  if comment :s=s+comment
  return s

def text_macro(text,tags):
  mcs={}
  lmc=[]
  currid=None
  comment=''
  for tag,l,r,subtags in tags:
    if tag == 'ident' :
      currid=text[l:r]
      if not mcs.has_key(currid):
        mcs[currid]=[]
        lmc.append(currid)
    elif tag == 'mcf':
      ll=text_macro_mcf(text,subtags)
      mcs[currid].append((ll,comment))
      comment=''
    elif tag == 'num' :
      a=string.replace(text[l:r],'D','E')
      mcs[currid].append((a,comment))
      comment=''
    elif tag == 'CPLX' :
      a=text_cplx(text,text[l:r],subtags)
      mcs[currid].append((a,comment))
      comment=''
    elif tag == 'arg' :
      a=''
      if text[l] == "'":
        # FR : (SGDG) il faut tester s'il n'y a pas déjà des cotes !!!
        a=a+text[l:r]
      elif currid in Keywords :
        a=a+"'"+text[l:r]+"'"
      else:
        sd=text[l:r]
        if sd not in liste_concepts_produits:
          # Il s agit d un concept produit par la macro mais situe à droite de =
          a=a+'CO("'+sd+'")'
          liste_concepts_produits.append(sd)
        else:
          a=a+sd
      mcs[currid].append((a,comment))
      comment=''
    elif tag == 'EVAL' :
      a=text_eval(text,subtags)
      mcs[currid].append((a,comment))
      comment=''
    elif tag == 'comment' :
      comment=comment + '#'+text[l+1:r]
    elif tag == 'comments' :
      comment=comment + text[l:r]
    elif tag == 'larg' :
      if currid in Keywords:mcs[currid].append((text_larg2(text,subtags),comment))
      else:mcs[currid].append((text_larg(text,subtags),comment))
      comment=''
    else :pass
  s=list_mc(lmc,mcs)
  if comment :s=s+comment
  return s

def comments_text(text):
  l=string.replace(text,'%','#')
  return l

def text_eval(text,tags):
  # on retourne l expression sans conversion dans un objet EVAL et entre quotes
  for tag,l,r,subtags in tags:
    if tag == 'vexpr':
      s='EVAL("""'+text[l:r]+'""")'
      return s
  return ''

def text_mcf(text,tags):
  s='_F( '
  comment=''
  for tag,l,r,subtags in tags:
    if tag == 'ident' :
      s=s+comment
      comment=''
      currid=text[l:r]
      s=s+ currid +' = '
    elif tag == 'arg' :
      if currid in Keywords :
        # FR : (SGDG) il faut tester s'il n'y a pas déjà des cotes !!!
        if text[l]!="'" and text[r-1]!="'":
          s=s+"'"+text[l:r]+"',"
        else:
          s=s+text[l:r]+","
      else:s=s+text[l:r]+","
    elif tag == 'num' :
      s=s+string.replace(text[l:r],'D','E')+','
    elif tag == 'CPLX' :
      s=s+text_cplx(text,text[l:r],subtags)+','
    elif tag == 'EVAL' :
      s=s+text_eval(text,subtags)+','
    elif tag == 'larg' :
      if currid in Keywords:s=s+text_larg2(text,subtags)+','
      else: s=s+text_larg(text,subtags)+','
    elif tag == 'comments' :
      comment=comment+text[l:r]
  if comment != '':
    s=s+comment
  return s+')'

def text_macro_mcf(text,tags):
  s='_F( '
  comment=''
  for tag,l,r,subtags in tags:
    if tag == 'ident' :
      s=s+comment
      currid=text[l:r]
      s=s+ currid +' = '
    elif tag == 'arg' :
      if text[l] == "'":
        # FR : (SGDG) il faut tester s'il n'y a pas déjà des cotes !!!
        s=s+text[l:r]+","
      elif currid in Keywords :
        s=s+"'"+text[l:r]+"',"
      else:
        sd=text[l:r]
        if sd not in liste_concepts_produits:
          # Il s agit d un concept produit par la macro mais situe à droite de =
          s=s+'CO("'+sd+'"),'
          liste_concepts_produits.append(sd)
        else:
          s=s+sd+','
      comment=''
    elif tag == 'num' :
      s=s+string.replace(text[l:r],'D','E')+','
    elif tag == 'CPLX' :
      s=s+text_cplx(text,text[l:r],subtags)+','
      comment=''
    elif tag == 'EVAL' :
      s=s+text_eval(text,subtags)+','
      comment=''
    elif tag == 'larg' :
      if currid in Keywords:s=s+text_larg2(text,subtags)+','
      else: s=s+text_larg(text,subtags)+','
      comment=''
    elif tag == 'comments' :
      comment=comment+text[l:r]
  return s[:-1]+')'

def text_cplx(texte,text,tags):
  """ Retourne une chaîne de caractères représentant un complexe """
  s="('"+text[0:2]+"'," #text[0:2] = RI ou MP
  for tag,l,r,subtags in tags:
    if tag == 'num' :
      s=s+string.replace(texte[l:r],'D','E')+','
  s=s+')'
  return s
  
def text_larg2(text,tags):
  """ Pareil que text_larg mais ajoute des cotes autour des arg """
  ll=[]
  for tag,l,r,subtags in tags:
    if tag == 'arg' :
      # FR : (SGDG) il faut tester le cas où les cotes sont déjà là !!!!
      if text[l] != "'" and text[r-1] != "'":
        ll.append( "'"+text[l:r]+"',")
      else:
        ll.append(text[l:r]+",")
    elif tag == 'num' :
      ll.append(string.replace(text[l:r],'D','E')+',')
    elif tag == 'CPLX' :
      ll.append(text_cplx(text,text[l:r],subtags)+',')
    elif tag == 'comments' :
      ll.append(text[l:r])
  return '('+string.join(ll,'')+')'

def text_larg(text,tags):
  # Pour les listes d arguments il semble plus rapide de construire 
  # une liste puis de faire join (ne pas exagerer : voir ajout ,)
  ll=[]
  for tag,l,r,subtags in tags:
    if tag == 'arg' :
      ll.append((text,l,r))
      ll.append(',')
    elif tag == 'num' :
 # cette facon de faire est un peu plus rapide que la suivante
      ll.append(string.replace(text[l:r],'D','E')+',')
    elif tag == 'comments' :
      ll.append((text,l,r))
    elif tag == 'EVAL' :
      ll.append(text_eval(text,subtags)+',')
    else:
      print "Argument ignore: ",text[l:r]
  return '('+TextTools.join(ll,'')+')'

def comment_text(text):
  l=string.replace(text,'\n','\n#')
  if l[-1]=='#':return '#'+l[:-1]
  else:return '#'+l

def text_affe(text,tags):
  s=''
  for tag,l,r,subtags in tags:
    if tag == 'arg' :
      s=s+text[l:r]
    elif tag == 'EVAL' :
      s=s+text_eval(text,subtags)
    elif tag == 'larg' :
      s=s+text_larg(text,subtags)
    elif tag == 'num' :
      s=s+string.replace(text[l:r],'D','E')
    elif tag == 'CPLX' :
      s=s+text_cplx(text,text[l:r],subtags)+','
  return s

def text_commande(text,tags):
  """
     Convertit une taglist de type commande en une chaine de caracteres
     à la syntaxe Python représentative d'une commande
  """
  s=''
  for tag,l,r,subtags in tags:
    if tag == 'noreuse':
      s=s+text_noreuse(text,subtags)
    elif tag == 'reuse':s=s+text_reuse(text,subtags)
  return s

def text_formule(text,tags):
  """
     Convertit une taglist de type formule en une chaine de caracteres
     à la syntaxe Python représentative d'une formule
  """
  s=''
  count=0
  typ=''
  for tag,l,r,subtags in tags:
    if tag == 'id':
      if count == 0:
        s=text[l:r]+' = FORMULE('+ty+'="""('
      else:
        if count > 1:s=s+','
        s=s+typ+text[l:r]
        typ=''
      count = count +1
    elif tag == 'typ':
      typ=text[l:r]
    elif tag == 'vexpr':
      s=s+ ') =\n'+text[l:r]
    elif tag == 'type':
      ty=text[l:r]
  return s +'""")\n'

def text_comms(text,tags):
  """
     Convertit une taglist resultat d'un appel à TextTools.tag avec une table de type Aster
     en une chaine de caracteres à la syntaxe Python
  """
  # On met la liste globale des concepts produits à zero
  global liste_concepts_produits
  liste_concepts_produits=[]

  s=''
  for tag,l,r,subtags in tags:
    if tag == 'comment':
      s=s+ '#'+text[l+1:r]
    elif tag == 'Null':
      s=s+ '\n'
    elif tag == 'formule':
      s=s+ text_formule(text,subtags)
    elif tag == 'commande' :
      s=s+text_commande(text,subtags)
    else:
      s=s+ comment_text(text[l:r])
  return s

def format_errs(text,tags):
  s=''
  warnings=''
  for tag,l,r,subtags in tags:
    if subtags:
       err,warn=format_errs(text,subtags)
       s=s+err
       warnings=warnings+warn
    if tag in ERRORS:
       s=s+ tag+" ligne : "+`TextTools.countlines(text[:l])`+" texte erroné : "+text[l-10:l]+'?'+text[l:r]+'\n'
    if tag == 'passline':
       warnings=warnings+ " ligne "+`TextTools.countlines(text[:l])`+" ignorée : " +text[l:r]+'\n'
  return s,warnings

def conver(text):
   from tables import aster_script
   import re
   # On ajoute un '\n' en fin au cas ou il serait absent
   text=text+'\n'
   text=string.upper(text)
   result, taglist, next = TextTools.tag(text,aster_script)
   # Pour vérifier les résultats intermédiaires décommenter la ligne suivante
   #TextTools.print_tags(text,taglist)
   text=string.replace(text,'%','#')
   s_errors,warnings = format_errs(text,taglist)
   if s_errors:
      return None,s_errors,warnings
   else:
      ss=text_comms(text,taglist)
      return string.replace(ss,'\r\n','\n'),s_errors,warnings





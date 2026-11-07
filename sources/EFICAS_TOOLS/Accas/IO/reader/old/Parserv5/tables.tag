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

"""
    Ce fichier définit une table de tags à utiliser avec le package
    mxTextTools pour décoder un fichier au format Asterv5.

    XXX Ce fichier doit etre corrigé pour incorporer deux modifications
    réalisées dans la version V1_1p1 d'EFICAS
"""
from TextTools import *

#
__version__="$Name: V7_main $"
__Id__="$Id: tables.tag,v 1.2.62.1 2013-01-24 14:25:23 pnoyret Exp $"
#

err0='ERR0 , erreur non identifiee : '
err1='ERR1 , arguments commande errones : '
err2='ERR2 , parenthese obligatoire : '
err3='ERR3 , point virgule obligatoire : '
err4='ERR4 , ":" obligatoire avant mot cle : '
err5='ERR5 , mot cle facteur ou arg obligatoire : '
err6='ERR6 , identificateur obligatoire : '
err7='ERR7 , mot cle facteur errone : '
err8='ERR8 , signe = ou ( attendu : '
err9='ERR9 , ( attendue : '
err10='ERR10 , vexpr attendue : '
err11='ERR11 , ) attendue : '

ERRORS=(err0,err1,err2,err3,err4,err5,err6,err7,err8,err9,
        err10,err11)

white_set=set(whitespace)

delim=" ();:=,!&*/%\n"

whitespace is:
    AllIn ' \t'

opt_whitespace is:
    whitespace F:MatchOk

t_opt_whitespace is:
    whitespace F:next

t_opt_whitenl is:
  AllIn ' \t\n\r' F:next

t_err = Table is:
    AllNotIn ';' F:next
    Is ';'
    Skip back

commespaces is:
    'comments' = Table is:
      IsInSet white_set F:next T:<blancs>
      Is '%' F:MatchFail
      <comment>
      AllNotIn '\n\r' F:next
      AllIn '\n\r' F:next
      <blancs>
      AllInSet white_set F:next
      Is '%' F:MatchOk T:<comment>

t_commespaces = Table is:
      IsInSet white_set F:next T:<blancs>
      Is '%' F:MatchFail
      <comment>
      AllNotIn '\n\r' F:next
      AllIn '\n\r' F:next
      <blancs>
      AllInSet white_set F:next
      Is '%' F:MatchOk T:<comment>

x_commespaces is:
    'comments' = Table is:
         <debut>
         Is '%':
            AllNotIn '\n\r' F:next
            AllIn '\n\r' F:next T:<debut>
         AllInSet white_set F:next T:<debut>
 
t_ident is:
    'ident' = Table is:
      IsIn alpha+'_'
      AllIn alpha+'_'+number F:MatchOk

t_identificateur = Table is:
      IsIn alpha+'_'
      AllIn alpha+'_'+number F:MatchOk

t_identmc = Table is:
      IsIn alpha+'_'
      AllIn alpha+'_'+number F:next
      None = Table t_commespaces F:next
      Is ':' F:MatchFail

n_ident is:
    None = Table is:
      IsIn alpha+'_'
      AllIn alpha+'_'+number F:MatchOk

n_string is:
    None = Table is:
      Is "'"
      <loop>
      AllNotIn "'" F:next
      Word "''" F:next T:<loop>
      Is "'" F:MatchFail T:MatchOk

t_number is:
    'num' = Table is:
      IsIn '-+' F:next
      Is '.' F:<entiere>
      IsIn number  F:MatchFail T:<decimal>
      <entiere>
      IsIn number F:MatchFail
      AllIn number F:next
      Is '.' F:<exposant>
      <decimal>
      AllIn number F:next
      <exposant>   # si pas exposant termine number trouve
      IsIn 'deDE' F:MatchOk
      IsIn '-+' F:next
      AllIn number F:MatchFail T:MatchOk

n_number is:
    None = Table is:
      IsIn '-+' F:next
      Is '.' F:<entiere>
      IsIn number  F:MatchFail T:<decimal>
      <entiere>
      IsIn number F:MatchFail
      AllIn number F:next
      Is '.' F:<exposant>
      <decimal>
      AllIn number F:next
      <exposant>   # si pas exposant termine number trouve
      IsIn 'deDE' F:MatchOk
      IsIn '-+' F:next
      AllIn number F:MatchFail T:MatchOk

t_complexe is:
  'CPLX' = Table is:
    "RI" = Word 'RI' F:<mp>
    commespaces F:next
    t_number F:MatchFail  # ce n est pas un complexe
    commespaces F:next # a partir d ici c est un complexe => produire erreurs
    Is ',' F:next
    commespaces F:next
    t_number F:MatchFail T:MatchOk
    <mp>
    "MP" = Word 'MP' F:MatchFail
    commespaces F:next
    t_number F:MatchFail  # ce n est pas un complexe
    commespaces F:next # a partir d ici c est un complexe => produire erreurs
    Is ',' F:next
    commespaces F:next
    t_number F:MatchFail T:MatchOk
    <err>
    err7 = Table t_err F:MatchFail T:MatchOk

# Table pour identifier le keyword PI

t_PI is:
    'PI' = Table is:
      Word 'PI' F:MatchFail
      IsIn alpha+'_'+number F:MatchOk T:next
      Skip back
      Jump To MatchFail

t_vexpr = Table is:
    'par' = Is '(':
      commespaces F:next
      'vexpr' = Table ThisTable F:<err10> 
      commespaces F:next
      'par2' = Is ')' F:<err9> T:<op>
    t_number F:next T:<op>
    t_complexe F:next T:<op>
    'sign' = IsIn '+-':
      commespaces F:next
      'vexpr' = Table ThisTable F:<err10> T:<op>
    t_PI              F:next T:<op>
    t_ident F:MatchFail
    commespaces F:next
    'listpar' = Is '(': # on peut avoir une liste de parametres
      <params>
      commespaces F:next
      'param' = Table ThisTable F:<err10> 
      commespaces F:next
      Is ',' F:next T:<params>
      'finlist' = Is ')' F:<err9>
    <op>
    commespaces F:next
    'exp' = Word '**':
      commespaces F:next
      'vexpr' = Table ThisTable F:<err10> T:MatchOk
    'op' = IsIn '+-*/':
      commespaces F:next
      'vexpr' = Table ThisTable F:<err10> T:MatchOk
    Jump To MatchOk
    <err>
    err0 = Table t_err F:MatchFail T:MatchOk
    <err10>
    err10 = Table t_err F:MatchFail T:MatchOk
    <err9>
    err9 = Table t_err F:MatchFail T:MatchOk

t_liste_param is:
  'liste' = Table is:
    t_ident 
    commespaces F:next
    Is '('
    commespaces F:next
    t_vexpr F:MatchFail
    <suite>
    commespaces F:next
    Is ',' F:<fin>
    commespaces F:next
    t_vexpr F:<err> T:<suite>
    <fin>
    commespaces F:next
    Is ')' F:<err> T:MatchOk
    <err>
    err7 = Table t_err F:MatchFail T:MatchOk

t_eval_expr is:
  'EVAL' = Table is:
    Word 'EVAL' 
    commespaces F:next
    Is '(' F:<err>
    commespaces F:next
    'vexpr' = Table t_vexpr F:<err>
    commespaces F:next
    Is ')' F:<err> T:MatchOk
    <err>
    err7 = Table t_err F:MatchFail T:MatchOk

t_entier is:
    'entier' = Table is:
      IsIn number 
      AllIn number F:next
      IsIn delim T:next
      Skip back

t_comment is:
  'comment' = Table is:
     Is '%'
     AllNotIn '\n\r' F:next
     AllIn '\n\r' F:MatchOk

t_nullline is:
  'Null' = AllIn ' ;\t\n\r'

t_passline is:
  'passline' = Table is:
    AllNotIn newline F:next
    IsIn newline

t_reste is:
  'reste' = Table is:
    AllNotIn ';' F:next

t_rest2 is:
  'reste' = Table is:
    AllNotIn ';' F:next
    Is ';'
    AllNotIn '\n' F:next
    Is '\n' F:MatchOk T:MatchOk

t_formule is:
  'formule' = Table is:
    commespaces F:next
    Word '!FORMULE' 
    commespaces F:next
    Is '(' F:<err9>
    commespaces F:next
    'type' = Table t_identificateur F:<err>
    commespaces F:next
    Is ':' F:<err>
    commespaces F:next
    Is '(' F:<err9>
    commespaces F:next
    'id' = Table t_identificateur F:<err>
    commespaces F:next
    Is '(' F:<err9>
    <params>
    commespaces F:next
    'typ' = Table t_identmc F:next
    commespaces F:next
    'id' = Table t_identificateur F:<err>
    commespaces F:next
    Is ',' F:next T:<params>
    commespaces F:next
    Is ')' F:<params>
    commespaces F:next
    Is '=' F:<err>
    commespaces F:next
    'vexpr' = Table t_vexpr F:<err>
    commespaces F:next
    Is ')' F:<err11>
    commespaces F:next
    Is ')' F:<err11>
    commespaces F:next
    Is ';' F:<err>
    AllNotIn '\n' F:next
    Is '\n' F:MatchOk T:MatchOk
    <err>
    err0 = Table t_err F:MatchFail T:MatchOk
    <err9>
    err9 = Table t_err F:MatchFail T:MatchOk
    <err11>
    err11 = Table t_err F:MatchFail T:MatchOk
    
t_nom_ope is:
    'nom_ope' = Table is:
      Word 'EVAL' F:next T:MatchFail   # EVAL n est pas un nom d operateur, il est reserve
      IsIn alpha+'_'
      AllIn alpha+'_'+number F:next
      commespaces F:next
      Is '(' F:MatchFail
      Skip back

t_arg is:
  'arg' = Table is:
    n_string F:next T:MatchOk
    n_ident 

t_larg is:
  'larg' = Table is:
    Is '(' F:MatchFail
    <arg>
    commespaces F:next
    t_complexe F:next T:<suite>
    t_number F:next T:<suite>
    t_eval_expr F:next T:<suite>
    t_arg F:MatchFail T:<suite>
    <suite>
    commespaces F:next
    Is ',' F:next
    Is ')' F:<arg> T:MatchOk

t_mcf is:
  'mcf' = Table is:
    Is '(' F:MatchFail
    "comments" = Table t_commespaces F:next
    Is ')' F:next T:MatchOk
    t_ident F:MatchFail
    "comments" = Table t_commespaces F:next
    Is ':' F:MatchFail # a partir d ici on est dans un mot cle facteur (erreurs eventuelles)
    <args>
    "comments" = Table t_commespaces F:next
    t_larg F:next T:<suite>
    t_complexe F:next T:<suite>
    t_number F:next T:<suite>
    t_eval_expr F:next T:<suite>
    t_arg F:<err>
    <suite>
    "comments" = Table t_commespaces F:next
    Is ',' F:next
    "comments" = Table t_commespaces F:next
    Is ')' F:next T:MatchOk
    t_ident F:<err>
    "comments" = Table t_commespaces F:next
    Is ':' F:<err> T:<args>
    <err>
    err7 = Table t_err F:MatchFail T:MatchOk

t_comm is:
  'comm' = Table is: # on attend les arguments entre () sinon erreur
    Is '(' F:<err>
    commespaces F:next
    Is ')' F:<call> T:MatchOk
    <call>
    t_ident F:<err>
    commespaces F:next
    Is ':' F:<err>
    commespaces F:next
    t_mcf F:<args>
    <mcfsuite>
    commespaces F:next
    Is ',' F:next
    commespaces F:next
    t_mcf F:<sep> T:<mcfsuite>
    <args>
    t_larg F:next T:<suite>
    t_complexe F:next T:<suite>
    t_number F:next T:<suite>
    t_eval_expr F:next T:<suite>
    t_arg F:<err>
    <suite>
    commespaces F:next
    <sep>
    Is ',' F:next
    commespaces F:next
    Is ')' F:<call> T:MatchOk
    <err>
    err1 = Table t_err F:MatchFail T:MatchOk

t_affe is:
  'affe' = Table is:
    commespaces F:next
    t_larg F:next T:<suite>
    t_complexe F:next T:<suite>
    t_number F:next T:<suite>
    t_eval_expr F:next T:<suite>
    t_arg F:next T:<suite>
    Jump To <err>
    <suite>
    Jump To MatchOk
    <err>
    err0 = Table t_err F:MatchFail T:MatchOk

t_reuse is:
  'reuse' = Table is:
    t_opt_whitespace
    t_ident
    t_opt_whitespace
    Is '=' F:<err>
    t_opt_whitespace
    t_nom_ope F:<affe> T:<comm>
    <comm>
    t_comm F:MatchFail T:MatchOk
    <affe>
    t_affe F:MatchFail T:MatchOk
    <err>
    err8 = Table t_err F:MatchFail T:MatchOk

t_noreuse is:
  'noreuse' = Table is:
    t_opt_whitespace
    t_ident
    t_opt_whitenl
    Is '=':    # on a affaire a un operateur ou une affectation
      t_opt_whitespace
      t_nom_ope F:<affe> T:<comm>
    Is '(' F:<err8> T:next
    Skip back
    <comm>
    t_comm F:<err> T:MatchOk
    <affe>
    t_affe F:<err> T:MatchOk
    <err>
    err0 = Table t_err F:MatchFail T:MatchOk
    <err8>
    err8 = Table t_err F:MatchFail T:MatchOk

t_fin is:
  'commande' = Table is:
    'noreuse' = Table is:
      t_opt_whitespace
      'ident' = Word "FIN"
      t_opt_whitenl
      Is '(' F:MatchFail  # On est vraiment sur d avoir la commande FIN apres avoir identifie (
      # On recule d un caractere pour identifier les arguments entre parenthèses
      Skip back
      t_comm F:next T:MatchOk
      err0 = Table t_err F:MatchFail T:MatchOk
    commespaces F:next
    Is ';' F:<err> T:MatchOk
    <err>
    err0 = Table t_err F:MatchFail T:MatchOk

t_commande is:
  'commande' = Table is:
    t_opt_whitespace
    Is '&':
      t_reuse F:MatchFail T:<fin>
    t_noreuse F:MatchFail 
    <fin>
    commespaces F:next
    Is ';' F:<err> T:MatchOk
    <err>
    err0 = Table t_err F:MatchFail T:MatchOk

aster_script = Table is:
  <top>
  t_nullline F:next T:<top>
  t_comment F:next T:<top>
  t_formule F:next T:<top>
  t_fin     F:next T:<AfterFin>
  t_commande F:next T:<top>
  t_passline F:next T:<top>
  EOF Here F:<top>
  <AfterFin>
  t_nullline F:next T:<AfterFin>
  t_passline F:next T:<AfterFin>
  EOF Here F:<AfterFin>




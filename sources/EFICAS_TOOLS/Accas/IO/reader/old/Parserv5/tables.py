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

"""
    Ce fichier définit une table de tags à utiliser avec le package
    mxTextTools pour décoder un fichier au format Asterv5.

    XXX Ce fichier doit etre corrigé pour incorporer deux modifications
    réalisées dans la version V1_1p1 d'EFICAS
"""
from TextTools import *

#
__version__="$Name: V7_main $"
__Id__="$Id: tables.py,v 1.5.52.1 2013-01-24 14:25:23 pnoyret Exp $"
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

whitespace = \
    (None,AllIn,' \t')

opt_whitespace = \
    whitespace      + (MatchOk,)

t_opt_whitespace = \
    whitespace      + (+1,)

t_opt_whitenl = \
  (None,AllIn,' \t\n\r',+1)

t_err = (
    (None,AllNotIn,';',+1),
    (None,Is,';'),
    (None,Skip,-1),
)

commespaces = \
    ('comments',Table,(
      (None,IsInSet,white_set,+1,+4),
      (None,Is,'%',MatchFail),
      # <comment>
      (None,AllNotIn,'\n\r',+1),
      (None,AllIn,'\n\r',+1),
      # <blancs>
      (None,AllInSet,white_set,+1),
      (None,Is,'%',MatchOk,-3),
    ))

t_commespaces = (
      (None,IsInSet,white_set,+1,+4),
      (None,Is,'%',MatchFail),
      # <comment>
      (None,AllNotIn,'\n\r',+1),
      (None,AllIn,'\n\r',+1),
      # <blancs>
      (None,AllInSet,white_set,+1),
      (None,Is,'%',MatchOk,-3),
)

x_commespaces = \
    ('comments',Table,(
         # <debut>
         (None,Is,'%',+3,+1),
            (None,AllNotIn,'\n\r',+1),
            (None,AllIn,'\n\r',+1,-2),
         (None,AllInSet,white_set,+1,-3),
    ))

t_ident = \
    ('ident',Table,(
      (None,IsIn,alpha+'_'),
      (None,AllIn,alpha+'_'+number,MatchOk),
    ))

t_identificateur = (
      (None,IsIn,alpha+'_'),
      (None,AllIn,alpha+'_'+number,MatchOk),
)

t_identmc = (
      (None,IsIn,alpha+'_'),
      (None,AllIn,alpha+'_'+number,+1),
      (None,Table,t_commespaces,+1),
      (None,Is,':',MatchFail),
)

n_ident = \
    (None,Table,(
      (None,IsIn,alpha+'_'),
      (None,AllIn,alpha+'_'+number,MatchOk),
    ))

n_string = \
    (None,Table,(
      (None,Is,"'"),
      # <loop>
      (None,AllNotIn,"'",+1),
      (None,Word,"''",+1,-1),
      (None,Is,"'",MatchFail,MatchOk),
    ))

t_number = \
    ('num',Table,(
      (None,IsIn,'-+',+1),
      (None,Is,'.',+2),
      (None,IsIn,number,MatchFail,+4),
      # <entiere>
      (None,IsIn,number,MatchFail),
      (None,AllIn,number,+1),
      (None,Is,'.',+2),
      # <decimal>
      (None,AllIn,number,+1),
      # <exposant>                      # si pas exposant termine number trouve
      (None,IsIn,'deDE',MatchOk),
      (None,IsIn,'-+',+1),
      (None,AllIn,number,MatchFail,MatchOk),
    ))

n_number = \
    (None,Table,(
      (None,IsIn,'-+',+1),
      (None,Is,'.',+2),
      (None,IsIn,number,MatchFail,+4),
      # <entiere>
      (None,IsIn,number,MatchFail),
      (None,AllIn,number,+1),
      (None,Is,'.',+2),
      # <decimal>
      (None,AllIn,number,+1),
      # <exposant>                      # si pas exposant termine number trouve
      (None,IsIn,'deDE',MatchOk),
      (None,IsIn,'-+',+1),
      (None,AllIn,number,MatchFail,MatchOk),
    ))

t_complexe = \
  ('CPLX',Table,(
    ("RI",Word,'RI',+7),
    commespaces     + (+1,),
    t_number        + (MatchFail,),      # ce n est pas un complexe
    commespaces     + (+1,),             # a partir d ici c est un complexe => produire erreurs
    (None,Is,',',+1),
    commespaces     + (+1,),
    t_number        + (MatchFail,MatchOk),
    # <mp>
    ("MP",Word,'MP',MatchFail),
    commespaces     + (+1,),
    t_number        + (MatchFail,),      # ce n est pas un complexe
    commespaces     + (+1,),             # a partir d ici c est un complexe => produire erreurs
    (None,Is,',',+1),
    commespaces     + (+1,),
    t_number        + (MatchFail,MatchOk),
    # <err>
    (err7,Table,t_err,MatchFail,MatchOk),
  ))

# Table pour identifier le keyword PI

t_PI = \
    ('PI',Table,(
      (None,Word,'PI',MatchFail),
      (None,IsIn,alpha+'_'+number,MatchOk,+1),
      (None,Skip,-1),
      (None,Jump,To,MatchFail),
    ))

t_vexpr = (
    ('par',Is,'(',+5,+1),
      commespaces     + (+1,),
      ('vexpr',Table,ThisTable,+26),
      commespaces     + (+1,),
      ('par2',Is,')',+25,+15),
    t_number        + (+1,+14),
    t_complexe      + (+1,+13),
    ('sign',IsIn,'+-',+3,+1),
      commespaces     + (+1,),
      ('vexpr',Table,ThisTable,+19,+10),
    t_PI            + (+1,+9),
    t_ident         + (MatchFail,),
    commespaces     + (+1,),
    ('listpar',Is,'(',+6,+1), # on peut avoir une liste de parametres
      # <params>
      commespaces     + (+1,),
      ('param',Table,ThisTable,+13),
      commespaces     + (+1,),
      (None,Is,',',+1,-3),
      ('finlist',Is,')',+11),
    # <op>
    commespaces     + (+1,),
    ('exp',Word,'**',+3,+1),
      commespaces     + (+1,),
      ('vexpr',Table,ThisTable,+6,MatchOk),
    ('op',IsIn,'+-*/',+3,+1),
      commespaces     + (+1,),
      ('vexpr',Table,ThisTable,+3,MatchOk),
    (None,Jump,To,MatchOk),
    # <err>
    (err0,Table,t_err,MatchFail,MatchOk),
    # <err10>
    (err10,Table,t_err,MatchFail,MatchOk),
    # <err9>
    (err9,Table,t_err,MatchFail,MatchOk),
)

t_liste_param = \
  ('liste',Table,(
    t_ident,
    commespaces     + (+1,),
    (None,Is,'('),
    commespaces     + (+1,),
    t_vexpr         + (MatchFail,),
    # <suite>
    commespaces     + (+1,),
    (None,Is,',',+3),
    commespaces     + (+1,),
    t_vexpr         + (+3,-3),
    # <fin>
    commespaces     + (+1,),
    (None,Is,')',+1,MatchOk),
    # <err>
    (err7,Table,t_err,MatchFail,MatchOk),
  ))

t_eval_expr = \
  ('EVAL',Table,(
    (None,Word,'EVAL'),
    commespaces     + (+1,),
    (None,Is,'(',+5),
    commespaces     + (+1,),
    ('vexpr',Table,t_vexpr,+3),
    commespaces     + (+1,),
    (None,Is,')',+1,MatchOk),
    # <err>
    (err7,Table,t_err,MatchFail,MatchOk),
  ))

t_entier = \
    ('entier',Table,(
      (None,IsIn,number),
      (None,AllIn,number,+1),
      (None,IsIn,delim,MatchFail,+1),
      (None,Skip,-1),
    ))

t_comment = \
  ('comment',Table,(
     (None,Is,'%'),
     (None,AllNotIn,'\n\r',+1),
     (None,AllIn,'\n\r',MatchOk),
  ))

t_nullline = \
  ('Null',AllIn,' ;\t\n\r')

t_passline = \
  ('passline',Table,(
    (None,AllNotIn,newline,+1),
    (None,IsIn,newline),
  ))

t_reste = \
  ('reste',Table,(
    (None,AllNotIn,';',+1),
  ))

t_rest2 = \
  ('reste',Table,(
    (None,AllNotIn,';',+1),
    (None,Is,';'),
    (None,AllNotIn,'\n',+1),
    (None,Is,'\n',MatchOk,MatchOk),
  ))

t_formule = \
  ('formule',Table,(
    commespaces     + (+1,),
    (None,Word,'!FORMULE'),
    commespaces     + (+1,),
    (None,Is,'(',+32),
    commespaces     + (+1,),
    ('type',Table,t_identificateur,+29),
    commespaces     + (+1,),
    (None,Is,':',+27),
    commespaces     + (+1,),
    (None,Is,'(',+26),
    commespaces     + (+1,),
    ('id',Table,t_identificateur,+23),
    commespaces     + (+1,),
    (None,Is,'(',+22),
    # <params>
    commespaces     + (+1,),
    ('typ',Table,t_identmc,+1),
    commespaces     + (+1,),
    ('id',Table,t_identificateur,+17),
    commespaces     + (+1,),
    (None,Is,',',+1,-5),
    commespaces     + (+1,),
    (None,Is,')',-7),
    commespaces     + (+1,),
    (None,Is,'=',+11),
    commespaces     + (+1,),
    ('vexpr',Table,t_vexpr,+9),
    commespaces     + (+1,),
    (None,Is,')',+9),
    commespaces     + (+1,),
    (None,Is,')',+7),
    commespaces     + (+1,),
    (None,Is,';',+3),
    (None,AllNotIn,'\n',+1),
    (None,Is,'\n',MatchOk,MatchOk),
    # <err>
    (err0,Table,t_err,MatchFail,MatchOk),
    # <err9>
    (err9,Table,t_err,MatchFail,MatchOk),
    # <err11>
    (err11,Table,t_err,MatchFail,MatchOk),
  ))

t_nom_ope = \
    ('nom_ope',Table,(
      (None,Word,'EVAL',+1,MatchFail),  # EVAL n est pas un nom d operateur, il est reserve
      (None,IsIn,alpha+'_'),
      (None,AllIn,alpha+'_'+number,+1),
      commespaces     + (+1,),
      (None,Is,'(',MatchFail),
      (None,Skip,-1),
    ))

t_arg = \
  ('arg',Table,(
    n_string        + (+1,MatchOk),
    n_ident,
  ))

t_larg = \
  ('larg',Table,(
    (None,Is,'(',MatchFail),
    # <arg>
    commespaces     + (+1,),
    t_complexe      + (+1,+4),
    t_number        + (+1,+3),
    t_eval_expr     + (+1,+2),
    t_arg           + (MatchFail,+1),
    # <suite>
    commespaces     + (+1,),
    (None,Is,',',+1),
    (None,Is,')',-7,MatchOk),
  ))

t_mcf = \
  ('mcf',Table,(
    (None,Is,'(',MatchFail),
    ("comments",Table,t_commespaces,+1),
    (None,Is,')',+1,MatchOk),
    t_ident         + (MatchFail,),
    ("comments",Table,t_commespaces,+1),
    (None,Is,':',MatchFail),            # a partir d ici on est dans un mot cle facteur (erreurs eventuelles)
    # <args>
    ("comments",Table,t_commespaces,+1),
    t_larg          + (+1,+5),
    t_complexe      + (+1,+4),
    t_number        + (+1,+3),
    t_eval_expr     + (+1,+2),
    t_arg           + (+8,),
    # <suite>
    ("comments",Table,t_commespaces,+1),
    (None,Is,',',+1),
    ("comments",Table,t_commespaces,+1),
    (None,Is,')',+1,MatchOk),
    t_ident         + (+3,),
    ("comments",Table,t_commespaces,+1),
    (None,Is,':',+1,-12),
    # <err>
    (err7,Table,t_err,MatchFail,MatchOk),
  ))

t_comm = \
  ('comm',Table,(                        # on attend les arguments entre () sinon erreur
    (None,Is,'(',+21),
    commespaces     + (+1,),
    (None,Is,')',+1,MatchOk),
    # <call>
    t_ident         + (+18,),
    commespaces     + (+1,),
    (None,Is,':',+16),
    commespaces     + (+1,),
    t_mcf           + (+5,),
    # <mcfsuite>
    commespaces     + (+1,),
    (None,Is,',',+1),
    commespaces     + (+1,),
    t_mcf           + (+7,-3),
    # <args>
    t_larg          + (+1,+5),
    t_complexe      + (+1,+4),
    t_number        + (+1,+3),
    t_eval_expr     + (+1,+2),
    t_arg           + (+5,),
    # <suite>
    commespaces     + (+1,),
    # <sep>
    (None,Is,',',+1),
    commespaces     + (+1,),
    (None,Is,')',-17,MatchOk),
    # <err>
    (err1,Table,t_err,MatchFail,MatchOk),
  ))

t_affe = \
  ('affe',Table,(
    commespaces     + (+1,),
    t_larg          + (+1,+6),
    t_complexe      + (+1,+5),
    t_number        + (+1,+4),
    t_eval_expr     + (+1,+3),
    t_arg           + (+1,+2),
    (None,Jump,To,+2),
    # <suite>
    (None,Jump,To,MatchOk),
    # <err>
    (err0,Table,t_err,MatchFail,MatchOk),
  ))

t_reuse = \
  ('reuse',Table,(
    t_opt_whitespace,
    t_ident,
    t_opt_whitespace,
    (None,Is,'=',+5),
    t_opt_whitespace,
    t_nom_ope       + (+2,+1),
    # <comm>
    t_comm          + (MatchFail,MatchOk),
    # <affe>
    t_affe          + (MatchFail,MatchOk),
    # <err>
    (err8,Table,t_err,MatchFail,MatchOk),
  ))

t_noreuse = \
  ('noreuse',Table,(
    t_opt_whitespace,
    t_ident,
    t_opt_whitenl,
    (None,Is,'=',+3,+1),     # on a affaire a un operateur ou une affectation
      t_opt_whitespace,
      t_nom_ope       + (+4,+3),
    (None,Is,'(',+5,+1),
    (None,Skip,-1),
    # <comm>
    t_comm          + (+2,MatchOk),
    # <affe>
    t_affe          + (+1,MatchOk),
    # <err>
    (err0,Table,t_err,MatchFail,MatchOk),
    # <err8>
    (err8,Table,t_err,MatchFail,MatchOk),
  ))

t_fin = \
  ('commande',Table,(
    ('noreuse',Table,(
      t_opt_whitespace,
      ('ident',Word,"FIN"),
      t_opt_whitenl,
      (None,Is,'(',MatchFail),          # On est vraiment sur d avoir la commande FIN apres avoir identifie (
      # On recule d un caractere pour identifier les arguments entre parenthèses
      (None,Skip,-1),
      t_comm          + (+1,MatchOk),
      (err0,Table,t_err,MatchFail,MatchOk),
    )),
    commespaces     + (+1,),
    (None,Is,';',+1,MatchOk),
    # <err>
    (err0,Table,t_err,MatchFail,MatchOk),
  ))

t_commande = \
  ('commande',Table,(
    t_opt_whitespace,
    (None,Is,'&',+2,+1),
      t_reuse         + (MatchFail,+2),
    t_noreuse       + (MatchFail,),
    # <fin>
    commespaces     + (+1,),
    (None,Is,';',+1,MatchOk),
    # <err>
    (err0,Table,t_err,MatchFail,MatchOk),
  ))

aster_script = (
  # <top>
  t_nullline      + (+1,+0),
  t_comment       + (+1,-1),
  t_formule       + (+1,-2),
  t_fin           + (+1,+4),
  t_commande      + (+1,-4),
  t_passline      + (+1,-5),
  (None,EOF,Here,-6),
  # <AfterFin>
  t_nullline      + (+1,+0),
  t_passline      + (+1,-1),
  (None,EOF,Here,-2),
)




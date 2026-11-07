# -*- coding: utf-8 -*-
# Copyright (C) 2007-2026   EDF R&D
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
#
# See http://www.salome-platform.org/ or email : webmaster.salome@opencascade.com
#
from __future__ import absolute_import
from __future__ import print_function

try:
    standard_library.install_aliases()
except:
    pass
try:
    from builtins import str
except:
    pass
from builtins import object
import sys, re, tokenize
import io


class ENTITE_JDC(object):
    def __init__(self):
        self.texte = ""

    def setText(self, texte):
        self.texte = texte

    def appendText(self, texte):
        """ """
        self.texte = self.texte + texte


class COMMENTAIRE(ENTITE_JDC):
    def __str__(self):
        """
        Retourne une chaine de caracteres representant self
        sous une forme interpretable par EFICAS
        """
        t = repr(self.texte)
        return "COMMENTAIRE(u" + t + ")\n"

    def appendText(self, texte):
        """
        Ajoute texte a self.texte en enlevant le # initial
        """
        if texte[0] == "#":
            self.texte = self.texte + texte[1:]
        else:
            # le diese n'est pas sur le premier caractere
            amont, aval = texte.split(
                "#", 1
            )  # on decoupe suivant la premiere occurrence de #
            self.texte = self.texte + amont + aval


class AFFECTATION(ENTITE_JDC):
    def appendText(self, texte):
        """
        Ajoute texte a self.texte en enlevant tout retour chariot et tout point virgule
        """
        self.texte = self.texte + texte

    def __str__(self):
        """
        Retourne une expression de l'affectation comprehensible par ACCAS
        et exploitable par EFICAS
        """
        # t=repr(self.texte)
        t = self.texte
        return "PARAMETRE(nom='" + self.name + "',valeur=" + t + ")"


class COMMANDE_COMMENTARISEE(ENTITE_JDC):
    def appendText(self, texte):
        """
        Ajoute texte a self.texte en enlevant les doubles commentaires
        """
        texte = texte.strip()
        texte = texte[2:].strip()
        self.texte = self.texte + (len(self.texte) > 0) * "\n" + texte

    def __str__(self):
        """
        Retourne une expression de la commande commentarisee comprehensible par ACCAS
        et exploitable par EFICAS
        """
        return "COMMANDE_COMM(texte=" + repr(self.texte) + ")\n"


next = {}
next["if"] = next["elif"] = "elif", "else", "end"
next["while"] = next["for"] = "else", "end"
next["try"] = "except", "finally"
next["except"] = "except", "else", "end"
next["else"] = next["finally"] = next["def"] = next["class"] = "end"
next["end"] = ()
start = "if", "while", "for", "try", "def", "class"


class PARSEUR_PYTHON(object):
    """
    Cette classe sert a creer un objet PARSEUR_PYTHON qui realise l'analyse d'un texte
    representant un JDC Python en distinguant :
      - les commentaires inter commandes
      - les affectations
      - les commandes
    """

    # au moins 1 caractere non blanc ou non tabulation
    # pattern_ligne_non_blanche = re.compile(r'^[\w\t]+')
    pattern_ligne_non_blanche = re.compile(r"[^ \t]+")
    kwprog = re.compile(r"^\s*(?P<kw>[a-z]+)" r"(\s+(?P<id>[a-zA-Z_]\w*))?" r"[^\w]")
    endprog = re.compile(
        r"^\s*#?\s*end\s+(?P<kw>[a-z]+)" r"(\s+(?P<id>[a-zA-Z_]\w*))?" r"[^\w]"
    )
    wsprog = re.compile(r"^[ \t]*")
    optionprog = re.compile(r'#\s*parse:\s*([^\n\'"]*)$')

    def __init__(self, texte):
        # on verifie que le texte fourni se compile correctement
        compile(texte, "<string>", "exec")
        self.texte = io.StringIO(texte)
        self.line = ""
        self.out = ""
        self.lastcol = 0
        self.lastrow = 1
        self.please_indent = 1
        self.indent_list = []
        self.indentation = 0
        self.paren_level = 0
        self.affectation = 0
        self.indent_list = [""]
        self.objet_courant = None
        self.affectation_flag = 1
        self.comment_flag = 1
        self.buffer = []
        self.buffer_indent = ""

    def getOptions(self):
        m = self.optionprog.match(self.line)
        if m:
            option = m.group(1)
            name = option[1:]
            flag = option[0] == "+"
            if name == "affectation":
                self.affectation_flag = flag
            if name == "comment":
                self.comment_flag = flag
            if name == "all":
                self.comment_flag = flag
                self.affectation_flag = flag

    def readline(self):
        self.line = self.texte.readline()
        # print "line:",self.line
        # option ?
        self.getOptions()
        return self.line

    def getTexte(self, appliEficas=None):
        """
        Retourne le texte issu de l'analyse
        """
        for tk in tokenize.generate_tokens(self.readline):
            self.processToken(tk)
        return self.out

    def processToken(self, tk):
        """ """
        ttype, tstring, spos, epos, line = tk
        thisrow, thiscol = spos
        # print spos, epos,tokenize.tok_name[ttype],self.lastrow, self.lastcol

        if thisrow > self.lastrow:
            # si plusieurs lignes (>1)
            self.out = self.out + "\n" * (thisrow - self.lastrow - 1)
            self.lastcol = 0

        #        if thiscol > self.lastcol :
        #            self.out=self.out+ " " * (thiscol - self.lastcol)
        #            self.please_indent = None

        self.thiscol = thiscol
        # self.nextrow, self.nextcol = epos

        try:
            fn = getattr(self, tokenize.tok_name[ttype])
        except AttributeError:
            print("No match!", tokenize.tok_name[ttype], tstring)
            return

        if ttype != tokenize.DEDENT and ttype != tokenize.INDENT and self.please_indent:
            self.doIndent()

        fn(tstring)
        self.lastrow, self.lastcol = epos

    def output(self, tstring):
        # print "output",tstring

        if self.thiscol > self.lastcol:
            # print self.thiscol,self.lastcol
            self.out = self.out + " " * (self.thiscol - self.lastcol)
            self.lastcol = self.thiscol

        self.out = self.out + tstring

    def outputCom(self, tstring):
        self.out = self.out + tstring

    def updateIndent(self):
        # print "updateIndent",len(self.indent_list[-1]),len(self.buffer_indent)
        if len(self.indent_list[-1]) > len(self.buffer_indent):
            self.out = (
                self.out + (len(self.indent_list[-1]) - len(self.buffer_indent)) * " "
            )
            self.buffer_indent = self.indent_list[-1]

    def doIndent(self):
        # print "indentation dans doIndent",len(self.indent_list)

        self.out = self.out + self.indent_list[-1]
        self.buffer_indent = self.indent_list[-1]
        if self.lastcol + len(self.indent_list[-1]) > self.thiscol:
            self.lastcol = self.thiscol
        else:
            self.lastcol = self.lastcol + len(self.indent_list[-1])
        self.please_indent = None

    def flush_buffer(self):
        # if self.buffer:
        #   print len(self.indent_list),self.please_indent
        for ob in self.buffer:
            self.out = self.out + str(ob)
            self.doIndent()
        self.buffer = []
        self.objet_courant = None

    def NL(self, tstring):
        if self.affectation:
            if self.paren_level == 0:
                # affectation en cours mais complete
                self.out = self.out + str(self.affectation_courante)
                self.affectation_courante = None
                self.please_indent = 1
                self.affectation = 0
            else:
                # affectation en cours, on ajoute
                if self.thiscol > self.lastcol:
                    self.affectation_courante.appendText(
                        (self.thiscol - self.lastcol) * " "
                    )
                self.affectation_courante.appendText(tstring)
                return

        if self.objet_courant:
            self.objet_courant = None
            self.buffer.append(tstring)
            #   self.please_indent = None
            return
        self.output(tstring)
        self.please_indent = 1

    def COMMENT(self, tstring):
        liste = string.split(self.line, "##", 1)
        if len(liste) > 1:
            # On a trouve un double commentaire
            before, after = liste
            if self.affectation:
                # affectation en cours, on ignore
                pass
            elif self.paren_level > 0:
                self.output(tstring)
            elif self.comment_flag and not self.pattern_ligne_non_blanche.search(
                before
            ):
                # il s'agit d'une commande commentarisee
                if self.objet_courant == None:
                    if not self.buffer:
                        self.buffer_indent = self.indent_list[-1]
                    self.objet_courant = COMMANDE_COMMENTARISEE()
                    self.buffer.append(self.objet_courant)
                    self.objet_courant.appendText(tstring)
                    self.please_indent = None
                elif isinstance(self.objet_courant, COMMENTAIRE):
                    self.objet_courant = COMMANDE_COMMENTARISEE()
                    self.buffer.append(self.objet_courant)
                    self.objet_courant.appendText(tstring)
                    self.please_indent = None
                else:
                    self.objet_courant.appendText(tstring)
                    self.please_indent = None
            else:
                # commentaire inline
                self.output(tstring)
                self.please_indent = 1
            return

        else:
            # On a un commentaire simple
            new_line = self.line.split("#")[0]
            if self.affectation:
                # affectation en cours, on ignore
                pass
            elif self.paren_level > 0:
                self.output(tstring)
            elif self.comment_flag and not self.pattern_ligne_non_blanche.search(
                new_line
            ):
                # commentaire precede de blancs
                if self.objet_courant == None:
                    if not self.buffer:
                        self.buffer_indent = self.indent_list[-1]
                    self.objet_courant = COMMENTAIRE()
                    self.buffer.append(self.objet_courant)
                    self.objet_courant.appendText(tstring)
                    self.please_indent = None
                elif isinstance(self.objet_courant, COMMANDE_COMMENTARISEE):
                    self.objet_courant = COMMENTAIRE()
                    self.buffer.append(self.objet_courant)
                    self.objet_courant.appendText(tstring)
                    self.please_indent = None
                else:
                    self.objet_courant.appendText(tstring)
                    self.please_indent = None
            else:
                # commentaire inline
                self.output(tstring)
                self.please_indent = 1
            return

    def ERRORTOKEN(self, tstring):
        print("ERRORTOKEN", tstring)

    def NAME(self, tstring):
        if self.buffer:
            self.updateIndent()
        self.flush_buffer()

        if self.affectation == 1:
            # on a une expression du type NAME=NAME
            # on ne veut pas des expressions qui commencent par NAME=NAME(NAME=
            # on en prend le chemin : on met affectation a 3 pour le signaler
            # on attend d'en savoir plus
            if self.thiscol > self.lastcol:
                self.affectation_courante.appendText(
                    (self.thiscol - self.lastcol) * " "
                )
            self.affectation_courante.appendText(tstring)
            self.affectation = 3
            return
        elif self.affectation == 4:
            # on a une expression qui commence par NAME=NAME(NAME
            # il s'agit tres probablement d'une commande
            # on annule l'affectation en cours
            if self.thiscol > self.lastcol:
                self.affectation_courante.appendText(
                    (self.thiscol - self.lastcol) * " "
                )
            self.affectation_courante.appendText(tstring)
            self.affectation = 5
            return
        elif self.affectation == 2:
            # affectation en cours, on ajoute
            if self.thiscol > self.lastcol:
                self.affectation_courante.appendText(
                    (self.thiscol - self.lastcol) * " "
                )
            self.affectation_courante.appendText(tstring)
            self.affectation = 2
            return
        self.affectation = 0
        self.name = None
        if self.paren_level == 0 and self.affectation_flag:
            # si on est en dehors de parentheses et en mode transformation d'affectation
            # on initialise l'attribut name qui indique une affectation en cours
            self.name = tstring
        self.output(tstring)

    def ident(self, tstring):
        self.flush_buffer()
        self.affectation = 0
        self.output(tstring)

    def NUMBER(self, tstring):
        self.flush_buffer()
        if self.affectation >= 1:
            # affectation en cours, on ajoute
            if self.thiscol > self.lastcol:
                self.affectation_courante.appendText(
                    (self.thiscol - self.lastcol) * " "
                )
            self.affectation_courante.appendText(tstring)
            self.affectation = 2
            return
        self.output(tstring)

    def OP(self, tstring):
        self.flush_buffer()
        if tstring in ("(", "[", "{"):
            self.paren_level = self.paren_level + 1
        if tstring in (")", "]", "}"):
            self.paren_level = self.paren_level - 1

        if tstring == "=" and self.affectation == 5:
            # on a une expression qui commence par NAME=NAME(NAME=)
            # il peut s'agir d'une commande
            # on annule l'affectation en cours
            self.out = self.out + self.affectation_courante.texte
            self.affectation_courante = None
            self.name = None
            self.affectation = 0
        elif tstring == ")" and self.affectation == 4:
            # on a une expression qui commence par NAME=NAME()
            # il peut s'agir d'une commande
            # on annule l'affectation en cours
            self.out = self.out + self.affectation_courante.texte
            self.affectation_courante = None
            self.affectation = 0
        elif tstring == "(" and self.affectation == 3:
            # on a deja trouve NAME=NAME
            # on passe affectation a 4
            if self.thiscol > self.lastcol:
                self.affectation_courante.appendText(
                    (self.thiscol - self.lastcol) * " "
                )
            self.affectation_courante.appendText(tstring)
            self.affectation = 4
            return
        elif tstring == ";" and self.affectation >= 1:
            # l'affectation est terminee
            self.out = self.out + str(self.affectation_courante)
            self.affectation_courante = None
            self.please_indent = 1
            self.affectation = 0
        elif self.affectation >= 1:
            # on complete l'affectation
            if self.thiscol > self.lastcol:
                self.affectation_courante.appendText(
                    (self.thiscol - self.lastcol) * " "
                )
            self.affectation_courante.appendText(tstring)
            self.affectation = 2
            return

        self.affectation = 0
        if self.name and tstring == "=":
            self.affectation = 1
            self.affectation_courante = AFFECTATION()
            self.affectation_courante.name = self.name
        self.output(tstring)

    ENDMARKER = ident
    NEWLINE = NL

    def INDENT(self, tstring):
        # tstring=str(len(self.indent_list))*len(tstring)
        self.indent_list.append(tstring)
        # print "indentation dans INDENT",len(self.indent_list),len(tstring)
        self.affectation = 0
        if self.buffer:
            self.updateIndent()
        self.flush_buffer()

    def DEDENT(self, tstring):
        # print "DEDENT",tstring,len(tstring)
        if self.buffer:
            self.out = self.out + str(self.buffer[0])
            if len(self.buffer) > 1:
                for ob in self.buffer[1:]:
                    self.doIndent()
                    self.out = self.out + str(ob)
            self.buffer = []
            self.objet_courant = None
            self.please_indent = 1

        self.affectation = 0
        self.indent_list = self.indent_list[:-1]
        # print "indentation dans DEDENT",len(self.indent_list)

    def STRING(self, tstring):
        self.flush_buffer()
        if self.affectation >= 1:
            # affectation en cours, on ajoute
            if self.thiscol > self.lastcol:
                self.affectation_courante.appendText(
                    (self.thiscol - self.lastcol) * " "
                )
            self.affectation_courante.appendText(tstring)
            self.affectation = 2
            return
        self.output(tstring)


if __name__ == "__main__":
    import sys
    import io

    text = """
#
#   comment
#   comment
#   comment
#

import sys,os

# commentaire
# commentaire
# commentaire

DEBUT();
##toto = FORMULE(REEL='(REEL:A) = A',);

x=2*cos(90.)/34.

a=1.
if a != 0:
  a=+1

b=2.
c=a+b
#if 1:
#  d=3
#  e=5
#try:
#  a=1/2
#except KeyError:
#  pass

if 1:
  a=2
  b=3
               # commenta
else:
  # commen
  # commen
  a=3
               #qqqqqqqqqqqqqqqqqqqqqqqq
  c=5

b=5
          # commentaire
toto = FORMULE(REEL='(REEL:A) = A',);
titi = FORMULE(REEL='(REEL:A) = A',) # commentaire inline
tutu = FORMULE(REEL='(REEL:A) = A',) ## commentaire inline

TEST_TABLE( TABLE=RELV[k],
               FILTRE=(
                        _F( NOM_PARA = 'QUANTITE',
                            VALE_K = 'MAXIMUM'),),
        # commentaire
               NOM_PARA='VMIS',  # comm
               VALE=1.9669824189084E9,
               REFERENCE='NON_REGRESSION',
               VERSION='8.1.0'  )

if 1:
   a=fff(a=1,
         b=2)
if 1:
  a=2
  b=3
               # commenta
else:
  # commen
  # commen
  a=3

for k in range(1,10):

   # Appel a GMSH pour le maillage

   f=open("coque.geo","w")


a = 1.
b=3
c= 3 * 5
d= 4 + \
 5 \
 -4
e=toto(a=1)
x=(1,2)
y=[3,
#comme
4]
z="a"
zz='v'
u='''aaaa
bbbb'''
if 1:
  a=45
else:
  a=5.6
d={"a":0}
e={"a":0,
#comme
"d":4}
a==1
x=a==1
s="-"*80
fmt_raison='-'*80+'''

   Exception erreur_Fatale interceptee
   Raison : %s

'''+'-'*80+'xxxxxxxxxxxxxxxx'
q=30*cos(12)
f=cos(12)
#commen'''
#commen'''
y=a[1]
y=["x"]*10

##toto = FORMULE(REEL='(REEL:A) = A',
##               X=2
##              );
#
#   comment
#   comment
#   comment
#
zz=8.9;
zz=8.9;aa=10
P1 = 9.8;

P2 = 8.8;

P3 = 7;

P5 = P3*P1;

P6 = P1-3;

P4 = [2,3,4];

P7=P4[1]
MA=LIRE_MAILLAGE()
MA=LIRE_MAILLAGE(#comment
)
xyz=cos(10)
MA=LIRE_MAILLAGE(INFO=1)
MA=LIRE_MAILLAGE(
        NFO=1)
MA=LIRE_MAILLAGE(#comme
        NFO=1)
MA=\
LIRE_MAILLAGE(INFO=1)
MA= LIRE_MAILLAGE()
TFIN = 1.790     # Temps fin pour le calcul

PAS = 0.001      # pas de temps du calcul
# parse: -affectation
DS1=[None]*5
DS2=[None]*5
DS3=[None]*5
DS4=[None]*5
CHS1=[None]*5
CHS2=[None]*5
MO=AFFE_MODELE(  MAILLAGE=MA,
          #test de validateur GEOM (typ=grma) avec grma derive de GEOM
                 AFFE=(_F(GROUP_MA = ('LI1'),
                          PHENOMENE = 'MECANIQUE',
                          MODELISATION = 'DIS_TR'),
                                ),
                  INFO=2,);

for k in range(1,5):
  DS1[k] = CREA_CHAMP( OPERATION='EXTR', TYPE_CHAM='NOEU_DEPL_R',
                  RESULTAT= MODESTA1, NUME_ORDRE=k, NOM_CHAM = 'DEPL');

# parse: +affectation
ff=23 # parametre bidon

# parse: -all
a=45
#commment1
##toto = FORMULE(REEL='(REEL:A) = A',
##               X=2
##              );
# parse: +all
b=45
#commment2
##toto = FORMULE(REEL='(REEL:A) = A',
##               X=2
##              );
# parse: -comment
c=45
#commment3
##toto = FORMULE(REEL='(REEL:A) = A',
##               X=2
##              );
# parse: +comment
d=45
#commment5
##toto = FORMULE(REEL='(REEL:A) = A',
##               X=2
##              );
p=sin(ff)

e=toto(a=1)
e=toto(a=1,b=3)
e=toto(1,b=3)
e=toto(a,b=3)
e=toto()
sensible=[2.1E11, 0.3,  1.E-6,   1.E-6,   ]

n=len(sensible)
# parse: -affectation

PS=[None]*n

for i in range(n):
    PS[i]=DEFI_PARA_SENSI(VALE=sensible[i])
# parse: +affectation

TEST_RESU(RESU=(_F(RESULTAT   = U3L,
                   INST       = 1.0,
                   NOM_CHAM   = 'DEPL',
                   GROUP_NO   = 'PPA',
                   NOM_CMP    = 'DX',
                   VALE       = 2.86E-5,
                   PRECISION  = 5.E-2,
                   REFERENCE  = 'AUTRE_ASTER',
                   VERSION    = '7.1.11',
                   ),
                )
       )#
#
FIN()
#

TEST_RESU(RESU=(_F(RESULTAT   = U3L,
                   INST       = 1.0,
                   NOM_CHAM   = 'DEPL',
                   GROUP_NO   = 'PPA',
                   NOM_CMP    = 'DX',
                   VALE       = 2.86E-5,
                   PRECISION  = 5.E-2,
                   REFERENCE  = 'AUTRE_ASTER',
                   VERSION    = '7.1.11',
                   ),
                )
       ) #a

titi = FORMULE(REEL='(REEL:A) = A',
) # commentaire inline
titi = FORMULE(REEL='(REEL:A) = A',
 ) # commentaire inline

def f(x):return x
#comment
def f(x):
#comment
  for i in range(10): s=0

#com1
#com2

#com3
a=1
##commendcomm
for k in range(1,10):

   # Appel a GMSH pour le maillage

   f=open("coque.geo","w")
#comm
   if a==1:

                         #comm

      for i in x:
#comm
##commendcomm
#comm
##commendcomm
#comm
        if x==3:
#comm
          r=1
        if w==4:
#comm

           if k:

#comm
             if g:

#comm

               if t:
                 a=5
#comm
if 1:
  a=2
  b=3
               # commenta
else:
  # commen
  # commen
  a=3
           # qqqqqqqqqqqqqqqq
  c=5

b=5

if 1:
  a=2
               # commenta
else:
  a=3
if 1:
  if 2:
     if 3:
       a=1
     elif 4:
       b=1
     else:
       c=5
  elif 3:
     x=1
  else:
     y=4
elif 4:
  s=1
else:
  t=9
#com1
#com2

#com3
a=1
##commendcomm
for k in range(1,10):

   # Appel a GMSH pour le maillage

   f=open("coque.geo","w")
#comm
   if 1:
      if 2:
         if 3:
            a=1
      else:
         a=6
a=1
##commendcomm
for k in range(1,10):

   # Appel a GMSH pour le maillage

   f=open("coque.geo","w")
#comm

   if a==1:

                         #comm

      for i in x:
#comm
##commendcomm
#comm
##commendcomm
#comm
        if x==3:
#comm
          r=1

   if 1:
      if 2:
         if 3:
            a=1
      else:
         a=6

if 1:
   if 2:
      if 3:
         r=1
         # comm
   else:
      x=7
      toto(a=1,
b=3)
SUP_=dict([(grand,0.) for grand in grand_obs])

for k in range(1,ns+1):
   x=toto(a=1,b=2)
#   comm
   if 1:
     #com

     #com
      x=1
     #com

     #com
   ##com
   elif 3:
   ##com
      x=1
   else:
      y=3

def f():
    return
########################################################################

########################################################################
# macro commande de post-traitement (ex POST_GOUJ2E)
# calcul des reactions cumulees suivant les filets

def POST_GOUJ_ops(self,TABLE):
  ier=0

"""
    if len(sys.argv) == 2:
        progname, input = sys.argv
        f = open(input)
        t = f.read()
        f.close()
    else:
        t = text
    txt = PARSEUR_PYTHON(t).getTexte()
    print(txt)
    compile(txt, "<string>", "exec")

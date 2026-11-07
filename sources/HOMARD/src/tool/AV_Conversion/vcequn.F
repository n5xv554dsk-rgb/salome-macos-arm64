      subroutine vcequn ( laret1, laret2,
     >                    noehom, arehom,
     >                    somare, povoso, voisom,
     >                    ulsort, langue, codret)
c ______________________________________________________________________
c
c                             H O M A R D
c
c Outil de Maillage Adaptatif par Raffinement et Deraffinement d'EDF R&D
c
c Version originale enregistree le 18 juin 1996 sous le numero 96036
c aupres des huissiers de justice Simart et Lavoir a Clamart
c Version 11.2 enregistree le 13 fevrier 2015 sous le numero 2015/014
c aupres des huissiers de justice
c Lavoir, Silinski & Cherqui-Abrahmi a Clamart
c
c    HOMARD est une marque deposee d'Electricite de France
c
c Copyright EDF 1996
c Copyright EDF 1998
c Copyright EDF 2002
c Copyright EDF 2020
c ______________________________________________________________________
c
c    aVant adaptation Conversion - EQUivalence - Noeud
c     -               -            ---           -
c    Cela permet de mettre en association les noeuds lies a une
c    paire d'aretes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . laret1 . e   .    1   . numero global de l'arete de depart         .
c . laret2 . e   .    1   . numero global de l'arete d'arrivee         .
c . noehom . es  . nbnoto . liste etendue des homologues par noeuds    .
c . arehom . e   . nbarto . liste etendue des homologues par aretes    .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . povoso . e   .0:nbnoto. pointeur des voisins par sommet            .
c . voisom . e   . nvosom . elements 1d, 2d ou 3d voisins par sommet   .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c ______________________________________________________________________
c
c====
c 0. declarations et dimensionnement
c====
c
c 0.1. ==> generalites
c
      implicit none
      save
c
      character*6 nompro
      parameter ( nompro = 'VCEQUN' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nbutil.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer noehom(nbnoto)
      integer laret1, laret2
      integer arehom(nbarto)
      integer somare(2,nbarto), povoso(0:nbnoto), voisom(nvosom)
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer larete, noeud, ndaux
      integer noeud1, noeud2
      integer ideb, ifin
      integer iaux, jaux, kaux, laux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     >'(''Impossible de trouver l''''homologue du noeud'',i10)'
#ifdef _DEBUG_HOMARD_
      texte(1,5) = '(''. Recherche de l''''homologue du noeud'',i10)'
      texte(1,6) = '(''Aretes'',i10,'' et'',i10)'
      texte(1,7) =
     > '(''.. Examen de l''''arete'',i10,'' (homologue'',i10,'')'')'
      texte(1,8) = '(''... Noeud'',i10,'' (ndaux)'')'
      texte(1,9) = '(''.... Noeud'',i10,'' (somare)'')'
#endif
      texte(1,10) = '(a,i10,'' : est homologue de'',i10)'
c
      texte(2,4) =
     > '(''Homologous for node #'',i10,''cannot be found.'')'
#ifdef _DEBUG_HOMARD_
      texte(2,5) = '(''. Search for the homologous for node # '',i10)'
      texte(2,6) = '(''Edges'',i10,'' and'',i10)'
      texte(2,7) =
     > '(''.. Check for edge #'',i10,'' (homologous'',i10,'')'')'
      texte(2,8) = '(''... Node'',i10,'' (ndaux)'')'
      texte(2,9) = '(''.... Node'',i10,'' (somare)'')'
#endif
      texte(2,10) = '(a,i10,'' : is homologous with'',i10)'
c
c====
c 2. explication :
c    en entre, nous avons deux aretes (laret1 et laret2) dont on sait
c    qu'elles sont homologues l'une de l'autre, mais dont aucune des 2
c    paires de noeuds n'a ete declaree homologue. Le but de ce programme
c    est de trouver une de ces deux paires.
c
c                       larete1
c                  O-----------------O
c
c                  O-----------------O
c                       larete2
c
c    On part du premier noeud de l'arete laret1. On passe en revue
c    toutes les aretes dont il est un des sommets.
c    Quand on tombe sur une arete differente de laret1 et qui possede
c    une homologue (aaa sur le croquis ci-dessous), on est bon. On
c    cherche quel est le noeud commun a son homologue (bbb) et laret2.
c    Logiquement, ce noeud commun (noeud2) est l'homologue du noeud de
c    depart (noeud1).
c    Si cela echoue, c'est que le noeud de depart etait l'extremite de
c    la zone en equivalence. On recommence avec l'autre noeud de
c    l'arete laret1.
c    Si cela echoue encore, c'est un probleme. Vraisemblablement parce
c    que l'arete en equivalence est seule dans son coin. On ne peut rien
c    faire ! Il faut que la donnee des noeuds homologues soit presente
c    dans le maillage de depart.
c
c                               O    O    O
c                                \   |   /
c                                 \  |  /
c                                  \ | /
c                       laret1      \|/       aaa
c                  O-----------------O--------------------0
c                                  noeud1
c
c                  O-----------------O--------------------0
c                       laret2     noeud2     bbb
c
c    A la sortie, on aura donc repere une paire de noeuds homologues
c    pour la paire d'aretes desirees. La seconde paire sera reperee
c    dans l'algorithme suivant dans le programme appelant.
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) laret1, laret2
#endif
c
      noeud1 = 0
c
      do 21 , iaux = 1 , 2
c
        noeud = somare(iaux,laret1)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) noeud
#endif
c
        ideb = povoso(noeud-1)+1
        ifin = povoso(noeud)
c
        do 211 , jaux = ideb , ifin
c
          larete = voisom(jaux)
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,7)) larete, arehom(larete)
#endif
c
          if ( larete.ne.laret1 .and. arehom(larete).ne.0 ) then
c
            do 212 , kaux = 1 , 2
              ndaux = somare(kaux,abs(arehom(larete)))
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,8)) ndaux
#endif
              do 213 , laux = 1 , 2
c
#ifdef _DEBUG_HOMARD_
                write (ulsort,texte(langue,9)) somare(laux,abs(laret2))
#endif
                if ( ndaux.eq.somare(laux,abs(laret2)) ) then
                  noeud1 = noeud
                  noeud2 = somare(laux,abs(laret2))
                  goto 22
                endif
c
  213         continue
  212       continue
c
          endif
c
  211   continue
c
   21 continue
c
      endif
c
c 2.2. ==> enregistrement
c
   22 continue
c
      if ( noeud1.ne.0 ) then
        noehom(noeud1) = - noeud2
        noehom(noeud2) = noeud1
      else
        codret = 5
      endif
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
        write (ulsort,texte(langue,2)) codret
        write (ulsort,texte(langue,10)) mess14(langue,2,1),
     >                                 laret1, laret2
        write (ulsort,texte(langue,4)) noeud
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      endif
c
      end

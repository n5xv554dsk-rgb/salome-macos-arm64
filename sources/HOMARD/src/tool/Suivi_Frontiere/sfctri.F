      subroutine sfctri ( somseg, seglig,
     >                    tbiaux,
     >                    ulsort, langue, codret)
c ______________________________________________________________________
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
c   Suivi de Frontiere - ConTRole des Intersections enter les lignes
c   -        -           -  --        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somseg . e   . sfnbse . liste des sommets des lignes separees par  .
c                           des 0                                      .
c . seglig . e   .0:sfnbli. pointeur dans le tableau somseg : les      .
c .        .     .        . segments de la ligne i sont aux places de  .
c .        .     .        . seglig(i-1)+1 a seglig(i)-1 inclus         .
c . tbiaux . e   . sfnbso . tableau auxiliaire                         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . !=0 : nombre d'intersections               .
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
      parameter ( nompro = 'SFCTRI' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "front1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer somseg(sfnbse), seglig(0:sfnbli)
      integer tbiaux(sfnbso)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer jdeb, jfin
      integer extred, extref
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Ligne numero'',i4)'
      texte(1,5) =
     > '(''.. Le noeud'',i10,'' appartient a'',i3,'' lignes.'')'
      texte(1,6) =
     > '(''.. Les lignes forment'',i3,'' intersection(s).'')'
      texte(1,7) =
     > '(''.. Le noeud'',i10,'' est une extremite de la ligne'',i4)'
      texte(1,8) = '(''.. Il appartient aussi a la ligne'',i4,/)'
c
      texte(2,4) = '(''. Line #"'',i4)'
      texte(2,5) =
     > '(''.. The vertex #'',i10,'' belongs to'',i3,'' lines.'')'
      texte(2,6) =
     > '(''.. The lines make'',i3,'' intersection(s).'')'
      texte(2,7) =
     > '(''.. The vertex #'',i10,'' is end of the line #'',i4)'
      texte(2,8) = '(''.. It belongs to the line #'',i4,/)'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. Recherche des points communs qui ne sont pas des extremites
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. points communs ; codret', codret
#endif
c
c 2.1. ==> Aucun noeud n'appartient a une ligne
c
      do 21 , iaux = 1 , sfnbso
c
        tbiaux(iaux) = 0
c
   21 continue
c
c 2.2. ==> Parcours des lignes
c          Pour chacun de ses noeuds, sauf les extremites, on
c          cumule le nombre de ligne d'appartenance.
c
      do 22 , iaux = 1 , sfnbli
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) iaux
#endif
c
        jdeb = seglig(iaux-1)+2
        jfin = seglig(iaux)-2
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'extremites', somseg(jdeb-1), somseg(jfin+1)
      write (ulsort,90002) 'jdeb, jfin', jdeb, jfin
#endif
        do 221 , jaux = jdeb, jfin
c
          tbiaux(somseg(jaux)) = tbiaux(somseg(jaux)) + 1
c
  221   continue
c
   22 continue
c
c 2.3. ==> Aucun noeud ne doit appartenir a plus d'une ligne
c
      do 23 , iaux = 1 , sfnbso
c
        if ( tbiaux(iaux).gt.1 ) then
          write (ulsort,texte(langue,5)) iaux, tbiaux(iaux)
          codret = codret + 1
        endif
c
   23 continue
c
c====
c 3. Recherche des extremites qui sont des points interieurs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. extremites ; codret', codret
#endif
c
c 3.1. ==> Parcours des lignes
c          On repere les deux extremites et on
c          cherche si elles appartiennent a une autre ligne
c
      do 31 , iaux = 1 , sfnbli
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) iaux
#endif
c
        jdeb = seglig(iaux-1)+1
        jfin = seglig(iaux)-1
        extred = somseg(jdeb)
        extref = somseg(jfin)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'extremites', extred, extref
#endif
c
        do 311 , kaux = 1 , sfnbli
c
          if ( kaux.ne.iaux ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) kaux
#endif
c
            jdeb = seglig(kaux-1)+2
            jfin = seglig(kaux)-2
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'extremites', somseg(jdeb-1), somseg(jfin+1)
      write (ulsort,90002) 'jdeb, jfin', jdeb, jfin
#endif
            do 3111 , jaux = jdeb, jfin
c
              if ( somseg(jaux).eq.extred .or.
     >             somseg(jaux).eq.extref ) then
                codret = codret + 1
                write (ulsort,texte(langue,7)) somseg(jaux), iaux
                write (ulsort,texte(langue,8)) kaux
              endif
c
 3111       continue
c
          endif
c
  311   continue
c
   31 continue
c
c====
c 4. Bilan
c====
c
      if ( codret.ne.0 ) then
c
      write (ulsort,texte(langue,6)) codret
c
      endif
c
c====
c 5. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

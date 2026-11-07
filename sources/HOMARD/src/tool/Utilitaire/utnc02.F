      subroutine utnc02 ( nbanci,
     >                    arreca, arrecb,
     >                    merare,
     >                    ulsort, langue, codret )
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
c    UTilitaire - Non Conformite - phase 02
c    --           -   -                  --
c    A partir de la filiation "adoptive" entre aretes, on memorise les
c    correspondances dans 2 listes paralleles.
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbanci . e   .    1   . nombre d'aretes de non conformite initiale .
c .        .     .        . egal au nombre d'aretes recouvrant 2 autres.
c . arreca .  s  .2*nbanci. liste des aretes recouvrant une autre      .
c . arrecb .  s  .2*nbanci. liste des aretes recouvertes par une autre .
c . merare . e   . nbarto . mere des aretes                            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 3 : probleme                               .
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
      parameter ( nompro = 'UTNC02' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbanci
      integer arreca(2*nbanci), arrecb(2*nbanci)
      integer merare(nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. preliminaires
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
      texte(1,4) = '(''Examen du '',a,i10)'
      texte(1,5) = '(''.. couvert par le '',a,i10)'
      texte(1,6) = '(''Recollement des '',a)'
      texte(1,7) = '(''Nombre trouve  :'',i10)'
      texte(1,8) = '(''Nombre attendu :'',i10)'
c
      texte(2,4) = '(''Examination of '',a,'' #'',i10)'
      texte(2,5) = '(''.. covered by '',a,'' #'',i10)'
      texte(2,6) = '(''Glue for '',a)'
      texte(2,7) = '(''Found number    :'',i10)'
      texte(2,8) = '(''Exepcted number :'',i10)'
c
      codret = 0
c
c====
c 2. On regarde toutes les aretes qui sont recouvertes par une autre
c    C'est repere par le fait qu'elles ont une mere negative (cf utnc01)
c====
c
      if ( codret.eq.0 ) then
c
      jaux = 0
c
      do 21 , iaux = 1 , nbarto
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,1,1), iaux
#endif
c
        if ( merare(iaux).lt.0 ) then
c
          jaux = jaux + 1
          arreca(jaux) = -merare(iaux)
          arrecb(jaux) = iaux
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) mess14(langue,1,1), -merare(iaux)
#endif
c
        endif
c
   21 continue
c
      endif
c
c====
c 3. controle
c====
c
      if ( codret.eq.0 ) then
c
      if ( jaux.ne.2*nbanci ) then
c
        write (ulsort,texte(langue,6)) mess14(langue,3,1)
        write (ulsort,texte(langue,7)) jaux
        write (ulsort,texte(langue,8)) 2*nbanci
        codret = 1
c
      endif
c
      endif
c
c====
c 4. la fin
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

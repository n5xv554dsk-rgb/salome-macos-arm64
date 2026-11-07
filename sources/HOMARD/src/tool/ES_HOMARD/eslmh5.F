      subroutine eslmh5 ( typenh, norenu, reento, reenac, adenhn,
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
c  Entree-Sortie : Lecture du Maillage Homard - phase 5
c  -      -        -          -        -              -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : segments                             .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c . norenu . e   . char8  . nom de la branche Renum du maillage HOMARD .
c . reento . e   .    1   . nombre d'entites                           .
c . reenac . e   .    1   . nbr d'elements utiles et contenant entites .
c . adenhn . e   .    1   . adresse du numero d'entite dans HOMARD     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
      parameter ( nompro = 'ESLMH5' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
c
#include "envex1.h"
#include "enti01.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh
      integer reento, reenac, adenhn
c
      character*8 norenu
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer ideb, ifin
      integer adencn
c
      character*3 saux03
#ifdef _DEBUG_HOMARD_
      character*6 saux06
#endif
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Mise a jour des renumerotations relatives aux '',a)'
      texte(1,5) = '(a3,''Calcul impossible a allouer.'')'
      texte(1,6) =
     > '(''Adresse de '',a3,''HOMARD impossible a trouver.'')'
c
      texte(2,4) = '(''Updating of renumbering for '',a)'
      texte(2,5) = '(a3,''Calcul cannot be allocated.'')'
      texte(2,6) =
     > '(''Adress for '',a3,''HOMARD cannot be found.'')'
c
#ifdef _DEBUG_HOMARD_
      write(ulsort,texte(langue,4)) mess14(langue,3,typenh)
      saux06 = 're'//suffix(2,typenh)(1:2)//'to'
      write (ulsort,*) '==> ', saux06, ' = ', reento
      saux06 = 're'//suffix(2,typenh)(1:2)//'ac'
      write (ulsort,*) '==> ', saux06, ' = ', reenac
#endif
c
c 1.2. ==> types d'entites
c
      saux03 = '.'//suffix(3,typenh)(1:2)
cgn      write(ulsort,*) saux03
c
      codret = 0
c
      if ( reenac.ne.0 .and. reento.ne.0 ) then
c
c====
c 2. Numerotation dans le calcul
c====
c
        jaux = 21
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01', nompro
#endif
        call utre01 ( typenh, jaux,
     >                norenu, reenac, reento,
     >                adenhn, adencn, kaux,
     >                ulsort, langue, codret)
c
c====
c 3. Numerotation dans HOMARD
c====
c
        if ( codret.eq.0 ) then
c
        ideb = adencn
        ifin = adencn + reento - 1
        do 311 , iaux = ideb , ifin
          imem(iaux) = 0
  311   continue
c
        do 312 , iaux = 1, reenac
          jaux = imem(adenhn+iaux-1)
          if ( jaux.ne.0 ) then
           imem(adencn+jaux-1) = iaux
          endif
  312   continue
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
      write(ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write(ulsort,texte(langue,4+codret)) saux03
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

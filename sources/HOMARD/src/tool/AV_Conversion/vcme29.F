      subroutine vcme29 ( nofaar, cofaar,
     >                    cfanoe,
     >                    nharfa,
     >                    pcfaar,
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
c    aVant adaptation - Conversion de Maillage Extrude - phase 29
c     -                 -             -        -               --
c Determine les familles pour le lien face avant / face perpendiculaire
c au cours de l'extrusion des noeuds
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nofaar . e   .  1     . nombre d'origine de familles d'aretes      .
c . cofaar . e   . ncffar*. codes d'origine des familles d'aretes      .
c .        .     . nofaar .                                            .
c . cfanoe . e   . nctfno*. codes des familles des noeuds              .
c .        .     . nbfnoe .   1 : famille MED                          .
c .        .     .        . si extrusion :                             .
c .        .     .        .   2 : famille du noeud extrude             .
c .        .     .        .   3 : famille de l'arete perpendiculaire   .
c .        .     .        .   4 : position du noeud                    .
c .        .     .        . si equivalence :                           .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . nharfa . e   . char8  . objet decrivant les familles d'aretes      .
c . pcfaar .  s  .  1     . codes des familles d'aretes                .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . e   .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'VCME29' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
#include "nbfami.h"
#include "dicfen.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nofaar, cofaar(ncffar,nofaar)
      integer cfanoe(nctfno,nbfnoe)
      integer pcfaar
c
      character*8 nharfa
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbfar0
      integer numfam
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
c
      texte(1,4) = '(''Familles d''''extrusion des '',a)'
      texte(1,5) = '(''Influence des '',a)'
c
      texte(2,4) = '(''Description of families of extruded '',a)'
      texte(2,5) = '(''Influence of the '',a)'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,-1)
      write (ulsort,texte(langue,5)) mess14(langue,3,1)
      write (ulsort,90002) 'nctfno', nctfno
      write (ulsort,90002) 'ncffar', ncffar
#endif
c
c====
c. Parcours des familles initiales
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. parcours ; codret', codret
#endif
c
c 2.1. ==> Taille initiale du tableau
c
      nbfar0 = nbfare
      numfam = 0
c
c 2.2. ==> Allongement de la taille du tableau des familles
c
   22 continue
c
      if ( codret.eq.0 ) then
c
      nbfar0 = nbfar0 + 29
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFAM2', nompro
#endif
      call utfam2 (   iaux, nharfa, nctfar, nbfar0,
     >              pcfaar,
     >              ulsort, langue, codret)
c
      endif
c
c 2.3. ==> Programme utilitaire
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME30', nompro
#endif
      call vcme30 ( numfam,
     >              nbfar0,
     >              nofaar, cofaar,
     >              nbfnoe, cfanoe,
     >              nbfare, imem(pcfaar),
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ==> A rallonger ?
c
      if ( codret.eq.0 ) then
c
      if ( nbfare.lt.0 ) then
c
        nbfare = -nbfare
        goto 22
c
      endif
c
      endif
c
c====
c 3. Redimensionnement final
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Redimensionnement ; codret', codret
      write (ulsort,90002) 'nbfare', nbfare
      write (ulsort,90002) 'nbfar0', nbfar0
#endif
c
      if ( nbfare.ne.nbfar0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 1
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTFAM2', nompro
#endif
        call utfam2 (   iaux, nharfa, nctfar, nbfare,
     >                pcfaar,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx ( mess14(langue,3,1), nharfa//'.Codes')
#endif
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

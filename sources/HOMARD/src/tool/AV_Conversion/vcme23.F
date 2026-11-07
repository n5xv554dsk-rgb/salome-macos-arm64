      subroutine vcme23 ( nhpefa,
     >                    pcfaqu,
     >                    pcfahe,
     >                    pcfape,
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
c    aVant adaptation - Conversion de Maillage Extrude - phase 23
c     -                 -             -        -               --
c Determine les familles pour la relation hexaedres/pentaedres
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nhpefa . e   . char8  . objet decrivant les familles de pentaedres .
c . pcfaqu . es  .    1   . codes des familles des quadrangles         .
c . pcfahe . es  .    1   . codes des familles des hexaedres           .
c . pcfape .  s  .  1     . codes des familles de pentaedres           .
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
      parameter ( nompro = 'VCME23' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
#include "impr02.h"
#include "dicfen.h"
#include "nbfami.h"
c
c 0.3. ==> arguments
c
      integer pcfaqu
      integer pcfahe
      integer pcfape
c
      character*8 nhpefa
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbfpe0
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
      codret = 0
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
      nbfpe0 = nbfpen
      numfam = 0
c
c 2.2. ==> Allongement de la taille du tableau des familles
c          des pentaedres
c
   22 continue
c
      if ( codret.eq.0 ) then
c
      nbfpe0 = nbfpe0 + 23
c
      iaux = 7
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFAM2', nompro
#endif
      call utfam2 (   iaux, nhpefa, nctfpe, nbfpe0,
     >              pcfape,
     >              ulsort, langue, codret)
c
      endif
c
c 2.3. ==> Programme utilitaire
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME24', nompro
#endif
      call vcme24 ( numfam,
     >              nbfpe0,
     >              imem(pcfaqu),
     >              imem(pcfahe),
     >              imem(pcfape),
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ==> A rallonger ?
c
      if ( codret.eq.0 ) then
c
      if ( nbfpen.lt.0 ) then
c
        nbfpen = -nbfpen
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
      write (ulsort,90002) 'nbfpen', nbfpen
      write (ulsort,90002) 'nbfpe0', nbfpe0
#endif
c
      if ( nbfpen.ne.nbfpe0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 7
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTFAM2', nompro
#endif
        call utfam2 (   iaux, nhpefa, nctfpe, nbfpen,
     >                pcfape,
     >                ulsort, langue, codret)
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

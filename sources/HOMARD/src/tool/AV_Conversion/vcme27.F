      subroutine vcme27 ( notftr, nofatr, cofatr,
     >                    nhtrfa,
     >                    pcfatr,
     >                    pcfaqu,
     >                    pcfahe,
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
c    aVant adaptation - Conversion de Maillage Extrude - phase 27
c     -                 -             -        -               --
c Determine les familles pour la relation quadrangles/triangles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . notftr . e   .  1     . nombre d'origine des carac. des triangles  .
c . nofatr . e   .  1     . nombre d'origine de familles de triangles  .
c . cofatr . e   . notftr*. codes d'origine des familles des triangles .
c .        .     . nofatr .                                            .
c . nhtrfa . e   . char8  . objet decrivant les familles de triangles  .
c . pcfatr . es  .    1   . codes des familles des triangles           .
c . pcfaqu . es  .    1   . codes des familles des quadrangles         .
c . pcfahe . e   .    1   . codes des familles des hexaedres           .
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
      parameter ( nompro = 'VCME27' )
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
      integer notftr, nofatr, cofatr(notftr,nofatr)
      integer pcfatr
      integer pcfaqu
      integer pcfahe
c
      character*8 nhtrfa
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbftr0
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
      nbftr0 = nbftri
      numfam = 0
c
c 2.2. ==> Allongement de la taille du tableau des familles de triangles
c
   22 continue
c
      if ( codret.eq.0 ) then
c
      nbftr0 = nbftr0 + 27
c
      iaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFAM2', nompro
#endif
      call utfam2 (   iaux, nhtrfa, nctftr, nbftr0,
     >              pcfatr,
     >              ulsort, langue, codret)
c
      endif
c
c 2.3. ==> Programme utilitaire
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCME28', nompro
#endif
      call vcme28 ( numfam,
     >              nbftr0,
     >              notftr, nofatr, cofatr,
     >              imem(pcfatr),
     >              imem(pcfaqu),
     >              imem(pcfahe),
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ==> A rallonger ?
c
      if ( codret.eq.0 ) then
c
      if ( nbftri.lt.0 ) then
c
        nbftri = -nbftri
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
      write (ulsort,90002) 'nbftri', nbftri
      write (ulsort,90002) 'nbftr0', nbftr0
#endif
c
      if ( nbftri.ne.nbftr0 ) then
c
        if ( codret.eq.0 ) then
c
        iaux = 2
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTFAM2', nompro
#endif
        call utfam2 (   iaux, nhtrfa, nctftr, nbftri,
     >                pcfatr,
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

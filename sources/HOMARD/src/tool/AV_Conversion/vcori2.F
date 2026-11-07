      subroutine vcori2 ( elemen, typhom, numfac, lequad,
     >                    areele, arequa,
     >                    code,
     >                    ulsort, langue, codret  )
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
c    aVant adaptation - Conversion - ORIentation - phase 2
c     -                 -            ---                 -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c ______________________________________________________________________
c . elemen . e   .   1    . numero de l'element en cours d'examen      .
c . typhom . e   .   1    . type homard de l'element en cours d'examen .
c . numfac . e   .   1    . numero de la face en cours d'examen        .
c . lequad . e   .   1    . numero homard du quadrangle                .
c . areele . e   . nbelem . aretes des elements                        .
c .        .     .*nbmaae .                                            .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . code   .  s .    1    . code de la numfac-eme face dans elemen     .
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
      parameter ( nompro = 'VCORI2' )
c
#include "nblang.h"
#include "referx.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "refere.h"
#include "nbutil.h"
#include "nombqu.h"
#include "j1234j.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer elemen, typhom, numfac
      integer lequad
      integer areele(nbelem,nbmaae)
      integer arequa(nbquto,4)
      integer code
#ifdef _DEBUG_HOMARD_
      integer glop
      integer jaux
#endif
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer a1, a2, a3, a4
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c
#ifdef _DEBUG_HOMARD_
      data glop / 0 /
#endif
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
      texte(1,4) = '(''Element'',i10,'', de type HOMARD'',i4)'
      texte(1,5) =
     > '(4x,''==> '',a,i10,'', face de numero local'',i2,'' :'')'
      texte(1,7) = '(''Impossible de trouver le code'')'
c
      texte(2,4) = '(''Element'',i10,'', with HOMARD type'',i4)'
      texte(2,5) = '(4x,''==> '',a,i10,'', local face position'',i2)'
      texte(2,7) = '(''Code cannot be found'')'
c
#include "impr03.h"
c
c====
c 2. exploration des possibilites
c====
c
#ifdef _DEBUG_HOMARD_
        if ( glop.ne.0 ) then
        write (ulsort,90002) mess14(langue,1,4), lequad
        write (ulsort,90002) mess14(langue,3,1),
     >                       (arequa(lequad,jaux),jaux=1,3)
        endif
#endif
c
      a1 = areele(elemen,defref(typhom,numfac,1))
      a2 = areele(elemen,defref(typhom,numfac,2))
      a3 = areele(elemen,defref(typhom,numfac,3))
      a4 = areele(elemen,defref(typhom,numfac,4))
      do 21 , iaux = 1 , 8
        if ( arequa(lequad,j1(iaux)).eq.a1 .and.
     >       arequa(lequad,j2(iaux)).eq.a2 .and.
     >       arequa(lequad,j3(iaux)).eq.a3 .and.
     >       arequa(lequad,j4(iaux)).eq.a4 ) then
          code = iaux
          goto 22
        endif
   21 continue
c
      codret = codret + 1
c
      write (ulsort,texte(langue,4)) elemen, typhom
      write (ulsort,texte(langue,5)) mess14(langue,2,2),
     >                               lequad, iaux
      write (ulsort,texte(langue,7))
c
   22 continue
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

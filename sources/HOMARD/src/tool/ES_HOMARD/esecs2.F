      subroutine esecs2 ( idfmed,
     >                    nomail,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : ECriture des informations Supplementaires - 2
c  -      -        --                        -                 -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomail . e   . char*8 . structure du maillage a ecrire             .
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
      parameter ( nompro = 'ESECS2' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
#include "enti01.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
c
      character*8 nomail
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer typenh
      integer nbenac, nbento, adenho, adenca
      integer codre0
c
      integer nbattx
      parameter ( nbattx = 19 )
      integer tabaux(nbattx)
c
      logical afaire
c
      character*8 saux08
      character*8 norenu
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''... Ecriture des renumerotations'')'
      texte(1,7) = '(''Premieres valeurs : '',10i6)'
c
      texte(2,4) = '(''... Writings of numbering'')'
      texte(2,7) = '(''First values : '',10i6)'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
c====
c 2. La renumerotation existe-t-elle ?
c====
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nomail//'.RenuMail', jaux )
c
      if ( jaux.eq.1 ) then
        call gmnomc ( nomail//'.RenuMail', norenu, codret )
        afaire = .true.
      else
        afaire = .false.
      endif
c
      endif
c
c====
c 3. Ecriture des renumerotations sous forme de profil
c====
c
      if ( afaire ) then
c
c 3.1. ==> Les renumerotations des entites
c
      if ( codret.eq.0 ) then
c
      do 31 , typenh = -1 , 7
c
c 3.1.1. ==> La renumerotation existe-t-elle ?
c          Si non, on passe a l'entite suivante
c
        if ( codret.eq.0 ) then
c
        saux08 = suffix(3,typenh)(1:2)//'HOMARD'
        call gmobal ( norenu//'.'//saux08, jaux )
        if ( jaux.ne.2 ) then
          goto 31
        endif
c
        endif
c
c 3.1.2. ==> Nombre et adresse
c
        if ( codret.eq.0 ) then
c
        iaux = typenh
        jaux = 10
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTRE03', nompro
#endif
        call utre03 ( iaux, jaux, norenu,
     >                nbenac, nbento, adenho, adenca,
     >                ulsort, langue, codret)
c
        endif
c
c 3.1.3. ==> Ecriture si la longueur n'est pas nulle
c
        if ( nbenac.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          noprof = blan64
          noprof(1:8) = saux08
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,texte(langue,61)) noprof
          write (ulsort,texte(langue,62)) nbenac
          write (ulsort,texte(langue,7))
     >   (imem(adenho+jaux-1), jaux = 1, min(10,nbenac))
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW', nompro
#endif
          call mpfprw ( idfmed, noprof, nbenac, imem(adenho), codret )
c
          endif
c
        endif
c
   31 continue
c
      endif
c
c 3.2. ==> La branche des nombres lies aux renumerotations
c 3.2.1. ==> Longueur et adresse
c
      if ( codret.eq.0 ) then
c
      saux08 = 'Nombres '
      call gmadoj ( norenu//'.'//saux08, jaux, kaux, codret )
c
      endif
c
c 3.2.2. ==> Ecriture
c
      if ( codret.eq.0 ) then
c
      noprof = blan64
      noprof(1:8) = saux08
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
      write (ulsort,texte(langue,62)) kaux
      write (ulsort,texte(langue,7)) (imem(jaux+iaux-1), iaux = 1, kaux)
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW', nompro
#endif
      call mpfprw ( idfmed, noprof, kaux, imem(jaux), codret )
c
      endif
c
c 3.3. ==> Les attributs lies aux renumerotations
c 3.3.1. ==> Les valeurs
c
      if ( codret.eq.0 ) then
c
      do 331 , iaux = 1 , nbattx
c
        jaux = iaux
        call gmliat ( norenu, jaux, kaux, codre0 )
        tabaux(iaux) = kaux
c
        codret = max ( abs(codre0), codret )
c
  331 continue
c
      endif
c
c 3.3.2. ==> Ecriture
c
      if ( codret.eq.0 ) then
c
      noprof = blan64
c                     1234567890123456789
      noprof(1:19) = 'Attributs_de_norenu'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
      write (ulsort,texte(langue,62)) nbattx
      write (ulsort,texte(langue,7)) (tabaux(jaux), jaux = 1, nbattx)
#endif
c
      kaux = nbattx
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW', nompro
#endif
      call mpfprw ( idfmed, noprof, kaux, tabaux, codret )
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

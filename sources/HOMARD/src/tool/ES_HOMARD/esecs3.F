      subroutine esecs3 ( idfmed,
     >                    nhnoeu,
     >                    nhmapo, nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
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
c  Entree-Sortie : ECriture des informations Supplementaires - 3
c  -      -        --                        -                 -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
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
      parameter ( nompro = 'ESECS3' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
#include "impr02.h"
#include "enti01.h"
#include "nombno.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
c
      character*8 nhnoeu
      character*8 nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
      integer typenh
      integer nbenti
      integer codre1, codre2, codre3
      integer codre0
      integer tabaux(3)
      integer adress(2), lgtab(2)
      logical tabsim
c
      character*1 saux01(2)
      character*8 nhenti
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisation
c
      data saux01 / 'A', 'B' /
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
      texte(1,4) = '(''... Ecriture des recollements'')'
      texte(1,5) = '(/,''..... pour les '',a)'
      texte(1,7) = '(''Premieres valeurs : '',10i6)'
c
      texte(2,4) = '(''... Writings of gluing'')'
      texte(2,5) = '(/,''..... for '',a)'
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
c 2. Ecriture par type des recollements sous forme de profil
c====
c
      do 20 , typenh = -1 , 7
c
c 2.1. ==> decodage des caracteristiques
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.-1 ) then
          nbenti = nbnoto
          nhenti = nhnoeu
        elseif ( typenh.eq.0 ) then
          nbenti = nbmpto
          nhenti = nhmapo
        elseif ( typenh.eq.1 ) then
          nbenti = nbarto
          nhenti = nharet
        elseif ( typenh.eq.2 ) then
          nbenti = nbtrto
          nhenti = nhtria
       elseif ( typenh.eq.3 ) then
          nbenti = nbteto
          nhenti = nhtetr
        elseif ( typenh.eq.4 ) then
          nbenti = nbquto
          nhenti = nhquad
        elseif ( typenh.eq.5 ) then
          nbenti = nbpyto
          nhenti = nhpyra
        elseif ( typenh.eq.6 ) then
          nbenti = nbheto
          nhenti = nhhexa
        else
          nbenti = nbpeto
          nhenti = nhpent
        endif
c
        endif
c
        if ( nbenti.eq.0 ) then
          goto 20
        endif
c
c 2.2. ==> Le recollement existe-t-il ?
c          Si non, on passe a l'entite suivante
c
        if ( codret.eq.0 ) then
c
        call gmobal ( nhenti//'.Recollem', codre0 )
        if ( codre0.eq.1 ) then
          tabsim = .false.
        elseif ( codre0.eq.2 ) then
          tabsim = .true.
        else
          goto 20
        endif
c
        endif
c
c 2.3. ==> decodage dans le cas d'un objet simple
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) mess14(langue,3,typenh)
#endif
c
c 2.3.1. ==> decodage dans le cas d'un objet simple
c
        if ( tabsim ) then
c
          if ( codret.eq.0 ) then
c
cc          call gmprsx ( nompro, nhenti )
cc          call gmprsx ( nompro, nhenti//'.Recollem' )
          call gmadoj ( nhenti//'.Recollem',
     >                  adress(1), lgtab(1), codre0 )
c
          codret = max ( abs(codre0), codret )
          lgtab(2) = 0
c
          endif
c
        else
c
c 2.3.2. ==> decodage dans le cas d'un objet structure
c
          if ( codret.eq.0 ) then
c
          call gmliat ( nhenti//'.Recollem', 1, tabaux(1), codre1 )
          call gmliat ( nhenti//'.Recollem', 2, tabaux(2), codre2 )
          call gmliat ( nhenti//'.Recollem', 3, tabaux(3), codre3 )
c
          codre0 = min ( codre1, codre2, codre3 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3 )
c
          endif
c
          if ( codret.eq.0 ) then
c
          if ( tabaux(1).gt.0 ) then
c
            call gmadoj ( nhenti//'.Recollem.ListeA',
     >                    adress(1), lgtab(1), codre1 )
            call gmadoj ( nhenti//'.Recollem.ListeB',
     >                    adress(2), lgtab(2), codre2 )
c
            codre0 = min ( codre1, codre2 )
            codret = max ( abs(codre0), codret,
     >                     codre1, codre2 )
c
          else
c
            lgtab(1) = 0
            lgtab(2) = 0
c
          endif
c
          endif
c
        endif
c
c 2.4. ==> Ecriture
c
        noprof = blan64
        noprof(1:2) = suffix(3,typenh)(1:2)
c                       3456789012
        noprof(3:12) = '_Recollem_'
c
c 2.4.1. ==> Ecriture des attributs de l'objet structure
c
        if ( .not.tabsim ) then
c
          if ( codret.eq.0 ) then
c
c                          345678901
          noprof(13:21) = 'Attributs'
c
          iaux = 3
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
      write (ulsort,texte(langue,62)) iaux
      write (ulsort,texte(langue,7))(tabaux(jaux),jaux=1,min(iaux,10))
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW_attributs', nompro
#endif
          call mpfprw ( idfmed, noprof, iaux, tabaux, codret )
c
          endif
c
        endif
c
c 2.4.2. ==> Ecriture des listes
c
        do 242 , iaux = 1 , 2
c
          if ( lgtab(iaux).gt.0 ) then
c
            if ( codret.eq.0 ) then
c
c                            34567   8              901
            noprof(13:21) = 'Liste'//saux01(iaux)//'   '
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
      write (ulsort,texte(langue,62)) lgtab(iaux)
      write (ulsort,texte(langue,7))
     >(imem(adress(iaux+jaux)),jaux=0,min(lgtab(iaux)-1,9))
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW_'//saux01(iaux), nompro
#endif
            call mpfprw ( idfmed, noprof,
     >                    lgtab(iaux), imem(adress(iaux)), codret )
c
            endif
c
          endif
c
  242   continue
c
   20 continue
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
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

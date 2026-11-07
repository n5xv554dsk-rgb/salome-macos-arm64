      subroutine esle02 ( idfmed,
     >                    typenh, nhenti, nbenca,
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
c  Entree-Sortie : LEcture noeud-maille - 02
c  -      -        --                     --
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . typenh . e   .   1    . code des entites                           .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nhenti . e   . char*8 . objet decrivant l'entite                   .
c . nbenca . e   .   1    . nombre d'entites decrites par aretes       .
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
      parameter ( nompro = 'ESLE02' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "impr02.h"
#include "enti01.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer typenh
      integer nbenca
c
      character*8 nhenti
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux, kaux, laux
      integer nbprof
      integer nbvapr, adins2
      integer typpro
      integer adcoar
      integer codre1, codre2, codre3
      integer codre0
      integer tabaux(3)
c
      character*1 saux01(2)
      character*64 noprof
      character*64 saux64
c
      logical afaire
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
      texte(1,4) = '(''... Lecture des profils pour les '',a)'
c
      texte(2,4) = '(''... Readings of profiles for '',a)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#endif
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbenca', nbenca
#endif
c
c====
c 2. Lecture sous forme de profil pour les informations supplementaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Lecture profil ; codret', codret
#endif
c 2.1. ==> Nombre de profils
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFNPF', nompro
#endif
      call mpfnpf ( idfmed, nbprof, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,86)) nbprof
#endif
c
      endif
c
c 2.2. ==> Parcours des profils
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. ==> Parcours profil ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      afaire = .true.
c
      do 22 , iaux = 1 , nbprof
c
c 2.2.1. ==> nom et taille du profil a lire
#ifdef _DEBUG_HOMARD_
      write (ulsort,90032) 'Profil numero', iaux
#endif
c
        if ( codret.eq.0 ) then
c
        jaux = iaux
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPFI', nompro
#endif
        call mpfpfi ( idfmed, jaux, noprof, nbvapr, codret )
        if ( codret.ne.0 ) then
        write (ulsort,texte(langue,79))
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,61)) noprof
        write (ulsort,texte(langue,62)) nbvapr
#endif
c
        endif
c
c 2.2.2. ==> On ne continue que pour les informations supplementaires,
c            les recollements ou les connectivites par arete
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2.2. suite ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        typpro = 0
        saux64 = blan64
c                      12                      34567890
        saux64(1:10) = suffix(3,typenh)(1:2)//'InfoSup2'
        if ( noprof.eq.saux64 ) then
          typpro = -1
        endif
c
        if ( typpro.eq.0 ) then
c
          saux64 = blan64
c                        12                      3456789012
          saux64(1:12) = suffix(3,typenh)(1:2)//'_Recollem_'
          if ( noprof(1:12).eq.saux64(1:12) ) then
            typpro = -2
          endif
c
        endif
c
        if ( typpro.eq.0 ) then
c
          saux64 = blan64
c                        12                      3456789012
          saux64(1:12) = suffix(3,typenh)(1:2)//'_ConnAret_'
          if ( noprof(1:12).eq.saux64(1:12) ) then
            read ( noprof(13:14) , fmt='(i2)' ) typpro
          endif
c
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'typpro', typpro
        if ( typpro.gt.0 ) then
          write (ulsort,texte(langue,61)) noprof
          write (ulsort,texte(langue,62)) nbvapr
        endif
#endif
c
        endif
c
c 2.2.3. ==> informations supplementaires
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2.3. infos compl. ; codret', codret
      write (ulsort,90002) 'typpro', typpro
#endif
c
        if ( codret.eq.0 ) then
c
        if ( typpro.eq.-1 ) then
c
c 2.2.3.1. ==> Allocation du tableau receptacle
c
          if ( codret.eq.0 ) then
          call gmaloj ( nhenti//'.InfoSup2', ' ',
     >                  nbvapr, adins2, codret )
          endif
c
c 2.2.3.2. ==> Lecture de la liste des valeurs
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRR pour InfoSup2', nompro
#endif
          call mpfprr ( idfmed, noprof, imem(adins2), codret )
c
          endif
c
c 2.2.4. ==> recollements
c
        elseif ( typpro.eq.-2 ) then
c
c 2.2.4.1. ==> Allocation de la structure generale si maille
c
          if ( codret.eq.0 ) then
c
          if ( afaire ) then
            if ( typenh.ge.0 ) then
              call gmaloj ( nhenti//'.Recollem', ' ', 0, jaux, codret )
            endif
            afaire = .false.
          endif
c
          endif
c
c 2.2.4.2. ==> Attributs
c
c                           345678901
          saux64(13:21) = 'Attributs'
          if ( noprof.eq.saux64 ) then
c
            if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,3)) 'MPFPRR / '//saux64, nompro
#endif
            call mpfprr ( idfmed, noprof, tabaux, codret )
c
            endif
c
            if ( codret.eq.0 ) then
c
            call gmecat ( nhenti//'.Recollem', 1, tabaux(1), codre1 )
            call gmecat ( nhenti//'.Recollem', 2, tabaux(2), codre2 )
            call gmecat ( nhenti//'.Recollem', 3, tabaux(3), codre3 )
c
            codre0 = min ( codre1, codre2, codre3 )
            codret = max ( abs(codre0), codret,
     >                     codre1, codre2, codre3 )
c
            endif
c
          endif
c
c 2.2.4.3. ==> listes
c
          if ( typenh.ge.0 ) then
            laux = 2
          else
            laux = 1
          endif
c
          do 2243 , jaux = 1 , laux
c
c                          34567   8              901
          saux64(13:21) = 'Liste'//saux01(jaux)//'   '
          if ( noprof.eq.saux64 ) then
c
            if ( codret.eq.0 ) then
c
            if ( typenh.ge.0 ) then
              call gmaloj ( nhenti//'.Recollem.Liste'//saux01(jaux),
     >                     ' ',  nbvapr, kaux, codret )
            else
              call gmaloj ( nhenti//'.Recollem',
     >                      ' ', nbvapr, kaux, codret )
            endif
c
            endif
c
            if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,3)) 'MPFPRR / '//saux64, nompro
#endif
            call mpfprr ( idfmed, noprof, imem(kaux), codret )
c
            endif
c
          endif
c
 2243     continue
c
c 2.2.5. ==> suite de la connectivite par aretes
c
        elseif ( typpro.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          call gmadoj ( nhenti//'.ConnAret', adcoar, jaux, codre0 )
c
          codret = max ( abs(codre0), codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          jaux = adcoar + nbenca*(typpro-1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRR / '//noprof, nompro
#endif
          call mpfprr ( idfmed, noprof, imem(jaux), codret )
cgn        write(ulsort,*) imem(jaux)
c
          endif
c
        endif
c
        endif
c
   22 continue
c
      endif
cgn      call gmprsx ( nompro,nhenti//'.ConnAret' )
cgn      call gmprsx ( nompro,nhenti//'.Recollem' )
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

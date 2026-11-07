      subroutine eslmh4 ( idfmed,
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
c  Entree-Sortie : Lecture du Maillage Homard - phase 4
c  -      -        -          -        -              -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomail . e   . char*8 . nom du maillage a lire                     .
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
      parameter ( nompro = 'ESLMH4' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
c
#include "envex1.h"
#include "enti01.h"
#include "nbutil.h"
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
#include "meddc0.h"
c
      integer iaux, jaux, kaux, laux
      integer codre1, codre2
      integer codre0
      integer nbprof
      integer nbvapr, adenho
      integer typenh
c
      integer nbattx
      parameter ( nbattx = 19 )
      integer tbiaux(nbattx)
c
      character*8 norenu
      character*8 saux08
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. intialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''... Renumerotations'')'
      texte(1,7) = '(''Premieres valeurs : '',10i6)'
c
      texte(2,4) = '(''... Numbers'')'
      texte(2,7) = '(''First values : '',10i6)'
c
#include "esimpr.h"
c
c====
c 2. Recuperation des parametres essentiels
c====
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
c
      if ( codret.eq.0 ) then
c
      do 22 , iaux = 1 , nbprof
c
c 2.2.1. ==> nom et taille du profil a lire
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
c 2.2.2. ==> On ne continue que pour les renumerotations
c
        if ( codret.eq.0 ) then
c
        jaux = -2
        saux08 = 'Nombres '
        if ( noprof(1:8).eq.saux08 ) then
          jaux = 8
        else
          do 222 , typenh = -1 , 7
            saux08 = suffix(3,typenh)(1:2)//'HOMARD'
            if ( noprof(1:8).eq.saux08 ) then
              jaux = typenh
              goto 223
            endif
  222     continue
        endif
c
        if ( jaux.eq.-2 ) then
          goto 22
        else
          typenh = jaux
        endif
c
        endif
c
c 2.2.3. ==> Allocation du tableau receptacle
c
  223   continue
c
        if ( typenh.le.7 ) then
c
          if ( codret.eq.0 ) then
c
          call gmobal ( nomail//'.RenuMail', codre1 )
          if ( codre1.eq.1 ) then
            codret = 0
          elseif ( codre1.eq.0 ) then
            call gmaloj ( nomail//'.RenuMail', ' ', 0, jaux, codret )
          else
            codret = 1
          endif
c
          endif
c
          if ( codret.eq.0 ) then
c
          call gmnomc ( nomail//'.RenuMail', norenu, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          jaux = 30
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE01', nompro
#endif
          call utre01 ( typenh, jaux,
     >                  norenu, nbvapr, 0,
     >                  adenho, kaux, laux,
     >                  ulsort, langue, codret)
c
          endif
c
        elseif ( typenh.eq.8 ) then
c
          if ( codret.eq.0 ) then
c
          call gmaloj ( norenu//'.'//saux08, ' ',
     >                  nbvapr, adenho, codre1 )
          call gmecat ( norenu , 19, nbvapr, codre2 )
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
c
          endif
c
        endif
c
c 2.2.4. ==> Lecture de la liste des valeurs
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRR', nompro
#endif
        call mpfprr ( idfmed, noprof, imem(adenho), codret )
ccc       call gmprsx ( nompro, norenu//'.'//saux08 )
c
        endif
c
   22 continue
c
      endif
c
c====
c 3. les attributs
c    Il faut le faire seulement maintenant, sinon certaines valeurs
c    sont ecrasees par utre01
c====
c
c 3.1. ==> Allocation eventuelle
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nomail//'.RenuMail', norenu, codret )
c
      endif
c
c 3.2. ==> Lecture
c
      if ( codret.eq.0 ) then
c
      noprof = blan64
c                     1234567890123456789
      noprof(1:19) = 'Attributs_de_norenu'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRR', nompro
#endif
      call mpfprr ( idfmed, noprof, tbiaux, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
      write (ulsort,texte(langue,62)) nbattx
      write (ulsort,texte(langue,7)) (tbiaux(jaux), jaux = 1, nbattx)
#endif
c
c 3.3. ==> Transfert
c
      if ( codret.eq.0 ) then
c
      do 33 , jaux = 1 , nbattx
c
        kaux = jaux
        call gmecat ( norenu, kaux, tbiaux(jaux), codre0 )
c
        codret = max ( abs(codre0), codret )
c
   33 continue
c
      endif
c
c 3.4. ==> Initialisation des nombres de mailles du calcul
c
      if ( codret.eq.0 ) then
c
      nbmapo = tbiaux(3)
      nbsegm = tbiaux(5)
      nbtria = tbiaux(7)
      nbtetr = tbiaux(9)
      nbquad = tbiaux(11)
      nbpyra = tbiaux(13)
      nbhexa = tbiaux(15)
      nbpent = tbiaux(17)
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

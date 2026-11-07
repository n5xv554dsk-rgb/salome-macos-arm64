      subroutine esleen ( idfmed, nomamd,
     >                    nhmapo, nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    ltbiau, tbiaux,
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
c  Entree-Sortie : LEcture des ENtites
c  -      -        --          --
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . ltbiau . e   .    1   . longueur allouee a tbiaux                  .
c . tbiaux .     .    *   . tableau tampon entier                      .
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
      parameter ( nompro = 'ESLEEN' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "gmenti.h"
c
#include "envca1.h"
#include "nbfami.h"
#include "dicfen.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer ltbiau, tbiaux(ltbiau)
c
      character*8 nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer typenh, typgeo, typent
      integer nbenti, nbencf, nbenca, nbrfma, nbrama, numfam
      integer nctfen, nbfent
      integer adcode, adcoar
      integer adfami, adcofa
      integer codre0
      integer codre1, codre2, codre3, codre4
c
      character*8 nhenti, nhenfa
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
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
      texte(1,4) = '(''. Lecture des mailles.'')'
      texte(1,5) = '(''... Taille du tableau temporaire :'',i10)'
      texte(1,6) = '(''.. Lecture des '',a14)'
c
      texte(2,4) = '(''. Readings of meshes.'')'
      texte(2,5) = '(''... Size of temporary array :'',i10)'
      texte(2,6) = '(''.. Readings of the '',a14)'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
      codret = 0
c
c====
c 2. Lecture type par type
c====
c
      do 21 , typenh = 0 , 7
c
c 2.1. ==> decodage des caracteristiques
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2.1. decodage ; codret = ', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,6)) mess14(langue,3,typenh)
#endif
c
        nbenca = 0
        nbrama = 0
c
        if ( typenh.eq.0 ) then
          nbenti = nbmpto
          nhenti = nhmapo
          nbencf = nbenti
          typgeo = edpoi1
          typent = edmail
          numfam = 0
          nctfen = nctfmp
          nbfent = nbfmpo
          nbrfma = 1
        elseif ( typenh.eq.1 ) then
          nbenti = nbarto
          nbencf = nbenti
          nhenti = nharet
          if ( degre.eq.1 ) then
            typgeo = edseg2
            nbrfma = 2
          else
            typgeo = edseg3
            nbrfma = 3
          endif
          typent = edaret
          numfam = numfam - nbfmpo
          nctfen = nctfar
          nbfent = nbfare
        elseif ( typenh.eq.2 ) then
          nbenti = nbtrto
          nbencf = nbenti
          nhenti = nhtria
          if ( degre.eq.1 ) then
            typgeo = edtri3
          else
            typgeo = edtri6
          endif
          typent = edface
          numfam = numfam - nbfare
          nctfen = nctftr
          nbfent = nbftri
          nbrfma = 3
       elseif ( typenh.eq.3 ) then
          nbenti = nbteto
          nbencf = nbtecf
          nbenca = nbteca
          nhenti = nhtetr
          if ( degre.eq.1 ) then
            typgeo = edtet4
          else
            typgeo = edte10
          endif
          typent = edmail
          numfam = numfam - nbftri
          nctfen = nctfte
          nbfent = nbftet
          nbrfma = 4
          nbrama = 6
        elseif ( typenh.eq.4 ) then
          nbenti = nbquto
          nbencf = nbenti
          nhenti = nhquad
          if ( degre.eq.1 ) then
            typgeo = edqua4
          else
            typgeo = edqua8
          endif
          typent = edface
          numfam = numfam - nbftet
          nctfen = nctfqu
          nbfent = nbfqua
          nbrfma = 4
        elseif ( typenh.eq.5 ) then
          nbenti = nbpyto
          nbencf = nbpycf
          nbenca = nbpyca
          nhenti = nhpyra
          if ( degre.eq.1 ) then
            typgeo = edpyr5
          else
            typgeo = edpy13
          endif
          typent = edmail
          numfam = numfam - nbfqua
          nctfen = nctfpy
          nbfent = nbfpyr
          nbrfma = 5
          nbrama = 8
        elseif ( typenh.eq.6 ) then
          nbenti = nbheto
          nbencf = nbhecf
          nbenca = nbheca
          nhenti = nhhexa
          if ( degre.eq.1 ) then
            typgeo = edhex8
          else
            typgeo = edhe20
          endif
          typent = edmail
          numfam = numfam - nbfpyr
          nctfen = nctfhe
          nbfent = nbfhex
          nbrfma = 6
          nbrama = 12
        else
          nbenti = nbpeto
          nbencf = nbpecf
          nbenca = nbpeca
          nhenti = nhpent
          if ( degre.eq.1 ) then
            typgeo = edpen6
          else
            typgeo = edpe15
          endif
          typent = edmail
          numfam = numfam - nbfhex
          nctfen = nctfpe
          nbfent = nbfpen
          nbrfma = 5
          nbrama = 9
        endif
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          write (ulsort,*) ' '
          write (ulsort,*) mess14(langue,4,typenh)
          write (ulsort,90002) 'nbenti, nbencf, nbenca',
     >                          nbenti, nbencf, nbenca
          endif
#endif
c
        endif
c
c 2.2. ==> gestion de la memoire
c 2.2.1. ==> connectivite
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2.2.1. connectivite ; codret = ', codret
#endif
c
        if ( nbenti.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
          if ( codret.eq.0 ) then
          write (ulsort,90002) 'typgeo', typgeo
          write (ulsort,90002) 'typent', typent
          write (ulsort,90002) 'nctfen', nctfen
          write (ulsort,90002) 'nbfent', nbfent
          write (ulsort,90002) 'nbrfma', nbrfma
          write (ulsort,90002) 'nbrama', nbrama
          write (ulsort,90002) 'numfam', numfam
          endif
#endif
c
          if ( codret.eq.0 ) then
c
          call gmecat ( nhenti, 1, nbenti, codre1 )
          call gmecat ( nhenti, 2, nbenca, codre2 )
          if ( typenh.eq.1 ) then
            iaux = 2*nbencf
          else
            iaux = nbrfma*nbencf
          endif
          call gmaloj ( nhenti//'.ConnDesc', ' ', iaux,
     >                  adcode, codre3 )
          if ( nbenca.gt.0 ) then
            iaux = nbrama*nbenca
            call gmaloj ( nhenti//'.ConnAret', ' ', iaux,
     >                    adcoar, codre4 )
          else
            codre4 = 0
          endif
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2, codre3, codre4 )
c
          endif
c
        endif
c
c 2.2.2. ==> appel du programme generique pour l'allocation de
c            la branche liee aux familles
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2.2.2. familles ; codret = ', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTALFE', nompro
#endif
        iaux = typenh
        call utalfe ( iaux, nhenti,
     >                nbenti, nctfen, nbfent,
     >                nhenfa, adfami, adcofa,
     >                ulsort, langue, codret)
c
        endif
c
c 2.3. ==> Lecture des connectivites
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2.3. lecture ; codret = ', codret
#endif
c
        if ( nbenti.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          jaux = typenh
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'ESLEE0', nompro
#endif
          call eslee0 ( idfmed, nomamd,
     >                  jaux, typgeo, typent,
     >                  nbencf, nbenca, nbrfma, nbrama,
     >                  imem(adcode), imem(adcoar),
     >                  tbiaux,
     >                  ulsort, langue, codret )
c
          endif
c
        endif
c
c 2.4. ==> Lecture des complements
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2.4. complements ; codret = ', codret
#endif
c
        if ( nbenti.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
          jaux = typenh
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'ESLEE2', nompro
#endif
          call eslee2 ( idfmed, nomamd,
     >                  nhenti,
     >                  jaux, typgeo, typent,
     >                  nbenti, nbencf, nbenca,
     >                  tbiaux,
     >                  ulsort, langue, codret )
c
cgn        call gmprsx ( nompro, nhenti )
cgn        call gmprsx ( nompro, nhenti//'.Famille' )
cgn        call gmprsx ( nompro, nhenti//'.ConnDesc' )
cgn        call gmprsx ( nompro, nhenti//'.HistEtat' )
cgn        call gmprsx ( nompro, nhenti//'.Mere' )
cgn        call gmprsx ( nompro, nhenti//'.InfoSupp' )
c
          endif
c
        endif
c
   21 continue
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

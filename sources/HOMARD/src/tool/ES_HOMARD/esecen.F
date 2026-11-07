      subroutine esecen ( idfmed, nomamd,
     >                    nhmapo, nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                     numdt,  numit, instan,
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
c  Entree-Sortie : ECriture des ENtites
c  -      -        --           --
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . ltbiau . e   .    1   . longueur allouee a tbiaux                  .
c . tbiaux .     .    *   . tableau tampon entier                      .
c . numdt  . e   .   1    . numero du pas de temps                     .
c . numit  . e   .   1    . numero d'iteration                         .
c . instan . e   .   1    . pas de temps                               .
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
      parameter ( nompro = 'ESECEN' )
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
      integer numdt, numit
      integer ltbiau, tbiaux(*)
c
      character*8 nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*64 nomamd
c
      double precision instan
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer typenh, typgeo, typent
      integer nbenti, nbencf, nbenca, nbnfma, numfam
      integer adcode, adcoar, adhist
      integer adnivo, admere, adfill
      integer adenho
      integer adinsu, lginsu
      integer adins2, lgins2
      integer adnoim
      integer addera, adinfg
      integer adfami, adcofa
      integer psomar
c
      character*8 nhenti
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''. Ecriture des mailles.'')'
      texte(1,5) = '(/,''... '',a)'
c
      texte(2,4) = '(''. Writings of meshes.'')'
      texte(2,5) = '(/,''... '',a)'
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
c 2. Ecriture type par type
c====
c
      do 21 , typenh = 0 , 7
c
c 2.1. ==> decodage des caracteristiques
c
        if ( codret.eq.0 ) then
c
        nbenca = 0
c
        if ( typenh.eq.0 ) then
          nbenti = nbmpto
          nhenti = nhmapo
          nbencf = nbenti
          typgeo = edpoi1
          typent = edmail
          numfam = 0
          nbnfma = 1
        elseif ( typenh.eq.1 ) then
          nbenti = nbarto
          nbencf = nbenti
          nhenti = nharet
          if ( degre.eq.1 ) then
            typgeo = edseg2
            nbnfma = 2
          else
            typgeo = edseg3
            nbnfma = 3
          endif
          typent = edaret
          numfam = numfam - nbfmpo
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
          nbnfma = 3
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
          nbnfma = 4
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
          nbnfma = 4
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
          nbnfma = 5
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
          nbnfma = 6
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
          nbnfma = 5
        endif
c
        endif
c
c 2.2. ==> Determination de toutes les adresses possibles
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,5)) mess14(langue,4,typenh)
        write (ulsort,90002) 'nbenti, nbencf, nbenca',
     >                        nbenti, nbencf, nbenca
        write (ulsort,90002) 'typgeo', typgeo
        write (ulsort,90002) 'nbnfma', nbnfma
#endif
c
        if ( nbenti.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD22', nompro
#endif
          call utad22 ( nhenti,
     >                  adcode, adcoar, adhist,
     >                  adnivo, admere, adfill,
     >                  adenho,
     >                  adinsu, lginsu,
     >                  adins2, lgins2,
     >                  adnoim,
     >                  addera, adinfg,
     >                  adfami, adcofa,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( typenh.eq.1 ) then
          psomar = adcode
        endif
c
        endif
c
c 2.3. ==> ecriture des connectivites
c
        if ( codret.eq.0 ) then
c
        if ( nbenti.gt.0 ) then
c
          jaux = typenh
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'ESECE0', nompro
#endif
          call esece0 ( idfmed, nomamd,
     >                  jaux, typgeo, typent,
     >                  nbenti, nbencf, nbenca, nbnfma,
     >                  imem(psomar),
     >                  imem(adcode), imem(adinsu), imem(adcoar),
     >                  numdt, numit, instan,
     >                  ltbiau, tbiaux,
     >                  ulsort, langue, codret )
c
        endif
c
        endif
cgn        call gmprsx(nompro,nhenti//'.HistEtat')
cgn        call gmprsx(nompro,nhenti//'.Niveau  ')
cgn        call gmprsx(nompro,nhenti//'.InfoSupp')
c
c 2.3. ==> ecriture des complements
c
        if ( codret.eq.0 ) then
c
        if ( nbenti.gt.0 ) then
c
          jaux = typenh
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'ESECE1', nompro
#endif
          call esece1 ( idfmed, nomamd,
     >                  jaux, typgeo, typent,
     >                  nbenti, nbencf, nbenca,
     >                  adfami, adhist,
     >                  adnivo, admere,
     >                  adenho,
     >                  adinsu, lginsu,
     >                  adins2, lgins2,
     >                  adnoim,
     >                  addera,
     >                  numdt, numit, instan,
     >                  ltbiau, tbiaux,
     >                  ulsort, langue, codret )
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

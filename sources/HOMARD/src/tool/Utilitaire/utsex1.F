      subroutine utsex1 ( nbpafo, nopafo,
     >                    edsuav, edsuap, edsaav, edsaap, nbenti,
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
c    UTilitaire - Solution - EXtrusion - phase 1
c    --           -          --                -
c    Changement du support dans un paquet de fonctions
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbpafo . e   .   1    . nombre de paquets de fonctions a traiter   .
c . nopafo . e   . nbpafo . nom des objets qui contiennent la          .
c .        .     .        . description de chaque paquets de fonctions .
c . edsuav . e   .   1    . type med avant                             .
c . edsuap . e   .   1    . type med apres                             .
c . edsaav . e   .   1    . type med associe avant                     .
c . edsaap . e   .   1    . type med associe apres                     .
c . nbenti . e   .   1    . nombre d'entites apres                     .
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
      parameter ( nompro = 'UTSEX1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer nbpafo
      integer edsuav, edsuap, edsaav, edsaap, nbenti
c
      character*8 nopafo(nbpafo)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer nrpafo, nbsupp
c
      integer nbfopa, nbtyas, ngauss, carsup, typint
      integer adobfo, adtyge
c
      character*8 obpafo
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Paquet de fonctions numero'',i3)'
c
      texte(2,4) = '(''Pack of functions #'',i3)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'Passage de', edsuav,' a', edsuap
      write (ulsort,90015) 'S. associe. Passage de', edsaav,' a', edsaap
      write (ulsort,90002) 'nbenti', nbenti
#endif
c
      codret = 0
c
c====
c 2. exploration des paquets de fonctions
c====
c
      do 20 , nrpafo = 1 , nbpafo
c
        obpafo = nopafo(nrpafo)
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nrpafo
#endif
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, obpafo )
        call gmprsx (nompro, obpafo//'.Fonction' )
        call gmprsx (nompro, obpafo//'.TypeSuAs' )
        call gmprsx (nompro, '%%%%%%18' )
#endif
c
c 2.1. ==> caracterisation du paquet de fonctions courant
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.1. caracterisation ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPF', nompro
#endif
        call utcapf ( obpafo,
     >                nbfopa, nbtyas, ngauss, carsup, typint,
     >                adobfo, adtyge,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,90002) 'nbfopa', nbfopa
        write (ulsort,90002) 'nbtyas', nbtyas
        write (ulsort,90002) 'ngauss', ngauss
        write (ulsort,90002) 'carsup', carsup
        write (ulsort,90002) 'typint', typint
        endif
#endif
c
c 2.2. ==> types de support du paquet
c          Attribut 2, nbtyas :
c            si >0 : le type geometrique global quand il est unique
c            si <0 : le nombre total de types geometriques associe
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. types de support ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
        jaux = 0
        if ( nbtyas.gt.0 ) then
c
          nbsupp = 1
          if ( nbtyas.eq.edsuav ) then
            jaux = 1
          endif
c
        else
c
          nbsupp = abs(nbtyas)
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002)
     >  'Supports',(imem(adtyge-1+iaux),iaux=1,nbsupp)
#endif
c
          do 22 , iaux = 1 , nbsupp
            if ( imem(adtyge-1+iaux).eq.edsuav ) then
              jaux = iaux
            endif
   22     continue
c
          endif
c
        endif
c
        endif
c
c 2.3. ==> Si l'un des supports est le bon, changement
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. changement ; codret', codret
#endif
c
        if ( jaux.gt.0 ) then
c
c 2.3.1. ==> modification de chaque fonction du paquet courant
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTSEX2', nompro
#endif
          call utsex2 ( nbfopa, smem(adobfo),
     >                  edsuav, edsuap, edsaav, edsaap, nbenti,
     >                  ulsort, langue, codret )
c
          endif
c
c 2.3.2. ==> mise a jour du support du paquet
c
          if ( codret.eq.0 ) then
c
          if ( nbsupp.eq.1 ) then
            call gmecat ( obpafo, 2, edsuap, codret )
          else
            imem(adtyge-1+jaux) = edsuap
          endif
c
          endif
c
        endif
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

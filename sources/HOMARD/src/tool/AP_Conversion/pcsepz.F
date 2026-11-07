      subroutine pcsepz ( propor,
     >                    lepent, etat,
     >                    coonoe, somare, aretri, arequa,
     >                    tritet, cotrte, aretet,
     >                    facpen, cofape, arepen,
     >                    facpyr, cofapy, arepyr,
     >                    filpen, fppyte,
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
c    aPres adaptation - Conversion de Solution Elements de volume -
c     -                 -             -        -
c                       Pentaedres - calcul des proportions fils/pere
c                       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . propor .   s .   11   . proportion de volume entre fils et pere    .
c . lepent . e   .    1   . hexaedre courant                           .
c . etat   . e   .    1   . etat du pentaedre                          .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
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
      parameter ( nompro = 'PCSEPZ' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpe.h"
#include "nombpy.h"
c
c 0.3. ==> arguments
c
      integer lepent, etat
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
      integer filpen(nbpeto), fppyte(2,nbpeco)
c
      double precision propor(11)
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer fipent, fipyra, fitetr
      integer nfpent, nfpyra, nftetr, nbfils
c
      double precision daux
      double precision daux0
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "pcimp2.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) lepent, etat
#endif
c
c====
c 2. denombrement des fils pour les differents cas de figure
c====
c 2.0. ==> a priori, aucun
c
      nfpent = 0
      nfpyra = 0
      nftetr = 0
c
c 2.1. ==> etat = 1, ..., 6 :
c          decoupage en 1 tetraedre et 2 pyramides
c
      if ( etat.ge.1 .and. etat.le.6 ) then
c
        nfpyra = 2
        nftetr = 1
c
c 2.2. ==> etat = 17, ..., 19 :
c          decoupage en 2 tetraedres et 1 pyramide.
c
      elseif ( etat.ge.17 .and. etat.le.19 ) then
c
        nfpyra = 1
        nftetr = 2
c
c 2.3. ==> etat = 21, ..., 26 :
c          decoupage en 6 tetraedres
c
      elseif ( etat.ge.21 .and. etat.le.26 ) then
c
        nftetr = 6
c
c 2.4. ==> etat = 31, ..., 36 :
c          decoupage en 10 tetraedres et 1 pyramide.
c
      elseif ( etat.ge.31 .and. etat.le.36 ) then
c
        nfpyra = 1
        nftetr = 10
c
c 2.5. ==> etat = 43, ..., 45 :
c          decoupage en 2 tetraedres et 4 pyramides
c
      elseif ( etat.ge.43 .and. etat.le.45 ) then
c
        nfpyra = 4
        nftetr = 2
c
c 2.6. ==> etat = 51, 52 :
c          decoupage en 11 tetraedres
c
      elseif ( etat.ge.51 .and. etat.le.52 ) then
c
        nftetr = 11
c
c 2.7. ==> etat = 80 :
c          decoupage en 8 pentaedres.
c
      elseif ( etat.eq.80 .or. etat.eq.99 ) then
c
        nfpent = 8
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nfpent', nfpent
      write (ulsort,90002) 'nfpyra', nfpyra
      write (ulsort,90002) 'nftetr', nftetr
#endif
c
c====
c 3. Calcul
c====
c 3.1. ==> Calcul des volumes
c          Remarque : certains des volumes des fils sont identiques
c          par paires, par construction. On les calcule quand meme
c          pour la lisibilite du programme.
c
      nbfils = nfpent + nfpyra + nftetr
c
c 3.1.1. ==> Pentaedres
c
      if ( nfpent.gt.0 ) then
c
        fipent = filpen(lepent) - 1
        do 321 , iaux = 1, nfpent
          call utvpen ( fipent+iaux, propor(iaux),
     >                  coonoe, somare, arequa,
     >                  facpen, cofape, arepen )
  321   continue
c
      endif
c
c 3.1.2. ==> Pyramides
c
      if ( nfpyra.gt.0 ) then
c
        fipyra = fppyte(1,-filpen(lepent)) - 1
        do 322 , iaux = 1 , nfpyra
          call utvpyr ( fipyra+iaux, propor(iaux),
     >                  coonoe, somare, aretri,
     >                  facpyr, cofapy, arepyr )
  322  continue
c
      endif
c
c 3.1.3. ==> Tetraedres
c
      if ( nftetr.gt.0 ) then
c
        fitetr = fppyte(2,-filpen(lepent)) - 1
        do 323 , iaux = 1 , nftetr
          call utvtet ( fitetr+iaux, propor(iaux+nfpyra),
     >                  coonoe, somare, aretri,
     >                  tritet, cotrte, aretet )
  323  continue
c
      endif
c
c 3.2. ==> Le volume total ; c'est donc le volume du pere
c
      daux0 = 0.d0
      do 32 , iaux = 1, nbfils
        daux0 = daux0 + propor(iaux)
   32 continue
c
c 3.3. ==> Rapport
c
      do 33 , iaux = 1, nbfils
        propor(iaux) = propor(iaux) / daux0
   33 continue
c
#ifdef _DEBUG_HOMARD_
      if ( nfpent.gt.0 ) then
        write (ulsort,90015) 'propor pour les', nfpent, ' pentaedres'
        do 3391 , iaux = 1, nfpent
          write (ulsort,90014) iaux, propor(iaux)
 3391   continue
      endif
      if ( nfpyra.eq.1 ) then
        write (ulsort,90015) 'propor pour la pyramide'
        write (ulsort,90014) 1, propor(1)
      elseif ( nfpyra.gt.0 ) then
        write (ulsort,90015) 'propor pour les', nfpyra, ' pyramides'
        do 3392 , iaux = 1, nfpyra
          write (ulsort,90014) iaux, propor(iaux)
 3392   continue
      endif
      if ( nftetr.eq.1 ) then
        write (ulsort,90015) 'propor pour le tetradre'
        write (ulsort,90014) 1, propor(1+nfpyra)
      elseif ( nftetr.gt.0 ) then
        write (ulsort,90015) 'propor pour les', nftetr, ' tetradres'
        do 3393 , iaux = 1, nftetr
          write (ulsort,90014) iaux, propor(iaux+nfpyra)
 3393   continue
      endif
#endif
c
c====
c 4. la fin
c====
c
      if ( codret.ne.0 ) then
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

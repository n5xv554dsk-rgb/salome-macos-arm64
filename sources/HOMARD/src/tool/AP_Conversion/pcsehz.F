      subroutine pcsehz ( propor,
     >                    lehexa, etat,
     >                    coonoe, somare, aretri, arequa,
     >                    tritet, cotrte, aretet,
     >                    quahex, coquhe, arehex,
     >                    facpyr, cofapy, arepyr,
     >                    filhex, fhpyte,
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
c                       Hexaedres - calcul des proportions fils/pere
c                       -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . propor .   s .   18   . proportion de volume entre fils et pere    .
c . lehexa . e   .    1   . hexaedre courant                           .
c . etat   . e   .    1   . etat de l'hexaedre                         .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
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
      parameter ( nompro = 'PCSEHZ' )
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
#include "nombhe.h"
#include "nombpy.h"
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer lehexa, etat
c
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
      integer filhex(nbheto), fhpyte(2,nbheco)
c
      double precision propor(18)
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer fihexa, fipyra, fitetr
      integer nfhexa, nfpyra, nftetr, nbfils
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
      write (ulsort,texte(langue,4)) lehexa, etat
#endif
c
c====
c 2. denombrement des fils pour les differents cas de figure
c====
c
      jaux = chbiet(etat)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) 'etat', etat, ' ==> code binaire', jaux
#endif
c
      nfhexa = chnhe(jaux)
      nfpyra = chnpy(jaux)
      nftetr = chnte(jaux)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nfhexa', nfhexa
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
      nbfils = nfhexa + nfpyra + nftetr
c
c 3.1.1. ==> Hexaedres
c
      if ( nfhexa.gt.0 ) then
c
        fihexa = filhex(lehexa) - 1
        do 321 , iaux = 1, nfhexa
          call utvhex ( fihexa+iaux, propor(iaux),
     >                  coonoe, somare, arequa,
     >                  quahex, coquhe, arehex )
  321   continue
c
      endif
c
c 3.1.2. ==> Pyramides
c
      if ( nfpyra.gt.0 ) then
c
        fipyra = fhpyte(1,-filhex(lehexa)) - 1
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
        fitetr = fhpyte(2,-filhex(lehexa)) - 1
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
      if ( nfhexa.gt.0 ) then
        write (ulsort,90015) 'propor pour les', nfhexa,' hexaedres'
        do 3391 , iaux = 1, nfhexa
          write (ulsort,90014) iaux, propor(iaux)
 3391   continue
      endif
      if ( nfpyra.gt.0 ) then
        write (ulsort,90015) 'propor pour les', nfpyra, ' pyramides'
        do 3392 , iaux = 1, nfpyra
          write (ulsort,90014) iaux, propor(iaux)
 3392   continue
      endif
      if ( nftetr.gt.0 ) then
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

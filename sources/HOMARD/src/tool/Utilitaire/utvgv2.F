      subroutine utvgv2 ( nbarto, nbtrto, nbquto,
     >                    nbteto, nbtecf, nbteca,
     >                    nbheto, nbhecf, nbheca,
     >                    nbpyto, nbpycf, nbpyca,
     >                    nbpeto, nbpecf, nbpeca,
     >                    aretri,
     >                    arequa,
     >                    tritet, cotrte, aretet,
     >                    quahex, coquhe, arehex,
     >                    facpyr, cofapy, arepyr,
     >                    facpen, cofape, arepen,
     >                    nbtear, pttear,
     >                    nbhear, pthear,
     >                    nbpyar, ptpyar,
     >                    nbpear, ptpear,
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
c     UTilitaire : VoisinaGes Volumes / aretes - phase 2
c     --           -      -   -                        -
c ______________________________________________________________________
c
c  determine le nombre de volumes voisins de chaque arete, par categorie
c  En sortie :
c    pttear(0) = 0
c    pttear(i) = position du dernier voisin de l'arete i-1
c              = nombre cumule de voisins pour les (i-1) 1eres aretes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbarto . e   .  1     . nombre total d'aretes                      .
c . nbtrto . e   .  1     . nombre total de triangles                  .
c . nbquto . e   .  1     . nombre total de quadrangles                .
c . nbteto . e   .  1     . nombre de tetraedres total                 .
c . nbtecf . e   .  1     . nombre total de tetraedres decrits par face.
c . nbteca . e   .  1     . nombre total de tetras decrits par aretes  .
c . nbheto . e   .   1    . nombre d'hexaedres total                   .
c . nbhecf . e   .  1     . nombre d'hexaedres decrits par faces       .
c . nbheca . e   .  1     . nombre d'hexaedres decrits par aretes      .
c . nbpyto . e   .   1    . nombre de pyramides total                  .
c . nbpycf . e   .  1     . nombre total de pyramides decrits par faces.
c . nbpyca . e   .  1     . nombre total de pyras decrits par aretes   .
c . nbpeto . e   .   1    . nombre de pentaedres total                 .
c . nbpecf . e   .  1     . nombre total de pentas decrits par faces   .
c . nbpeca . e   .  1     . nombre total de pentas decrits par aretes  .
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
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . arepen . e   .nbpeca*9. numeros des 9 aretes des pentaedres        .
c . nbtear .  s  .    1   . nombre de tetraedres voisins d'aretes      .
c . pttear .  s  .0:nbarto. nombre de tetraedres voisins par aretes    .
c . nbhear .  s  .    1   . nombre d'hexaedres voisins d'aretes        .
c . pthear .  s  .0:nbarto. nombre d'hexaedres voisins par aretes      .
c . nbpyar .  s  .    1   . nombre de pyramides voisines d'aretes      .
c . ptpyar .  s  .0:nbarto. nombre de pyramides voisines par aretes    .
c . nbpear .  s  .    1   . nombre de pentaedres voisins d'aretes      .
c . ptpear .  s  .0:nbarto. nombre de pentaedres voisins par aretes    .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . non nul : probleme                         .
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
      parameter ( nompro = 'UTVGV2' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbarto, nbtrto, nbquto
      integer nbteto, nbtecf, nbteca
      integer nbheto, nbhecf, nbheca
      integer nbpyto, nbpycf, nbpyca
      integer nbpeto, nbpecf, nbpeca
c
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
c
      integer nbtear, pttear(0:nbarto)
      integer nbhear, pthear(0:nbarto)
      integer nbpyar, ptpyar(0:nbarto)
      integer nbpear, ptpear(0:nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer letetr, lehexa, lapyra, lepent
      integer listar(12)
c
      integer nbmess
      parameter ( nbmess = 10 )
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
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbarto', nbarto
      write (ulsort,90002) 'nbtrto', nbtrto
      write (ulsort,90002) 'nbquto', nbquto
      write (ulsort,90002) 'nbteto, nbtecf', nbteto, nbtecf
      write (ulsort,90002) 'nbheto, nbhecf', nbheto, nbhecf
      write (ulsort,90002) 'nbpyto, nbpycf', nbpyto, nbpycf
      write (ulsort,90002) 'nbpeto, nbpecf', nbpeto, nbpecf
#endif
c
c====
c 2. decompte des tetraedres voisins d'aretes
c====
c
      if ( nbteto.gt.0 ) then
c
        do 21 , iaux = 0 , nbarto
          pttear(iaux) = 0
  21    continue
c
        do 22 , letetr = 1 , nbteto
c
          if ( letetr.le.nbtecf ) then
c
            call utarte ( letetr,
     >                    nbtrto, nbtecf,
     >                    aretri, tritet, cotrte,
     >                    listar )
c
          else
c
            do 221 , iaux = 1 , 6
              listar(iaux) = aretet(letetr-nbtecf,iaux)
  221       continue
c
          endif
c
          do 222 , iaux = 1 , 6
            pttear(listar(iaux)) = pttear(listar(iaux)) + 1
  222     continue
c
   22   continue
c
        do 23 , iaux = 1 , nbarto
          pttear(iaux) = pttear(iaux-1) + pttear(iaux)
  23    continue
        nbtear = pttear(nbarto)
        do 24 , iaux = nbarto , 1 , -1
          pttear(iaux) = pttear(iaux-1)
  24    continue
c
      endif
c
c====
c 3. decompte des hexaedres voisins d'aretes
c====
c
      if ( nbheto.gt.0 ) then
c
        do 31 , iaux = 0 , nbarto
          pthear(iaux) = 0
  31    continue
c
        do 32 , lehexa = 1 , nbheto
c
          if ( lehexa.le.nbhecf ) then
c
            call utarhe ( lehexa,
     >                    nbquto, nbhecf,
     >                    arequa, quahex, coquhe,
     >                    listar )
c
          else
c
            do 321 , iaux = 1 , 12
              listar(iaux) = arehex(lehexa-nbhecf,iaux)
  321       continue
c
          endif
c
          do 322 , iaux = 1 , 12
            pthear(listar(iaux)) = pthear(listar(iaux)) + 1
  322     continue
c
   32   continue
c
        do 33 , iaux = 1 , nbarto
          pthear(iaux) = pthear(iaux-1) + pthear(iaux)
  33    continue
        nbhear = pthear(nbarto)
        do 34 , iaux = nbarto , 1 , -1
          pthear(iaux) = pthear(iaux-1)
  34    continue
c
      endif
c
c====
c 4. decompte des pyramides voisines d'aretes
c====
c
      if ( nbpyto.gt.0 ) then
c
        do 41 , iaux = 0 , nbarto
          ptpyar(iaux) = 0
  41    continue
c
        do 42 , lapyra = 1 , nbpyto
c
          if ( lapyra.le.nbpycf ) then
c
            call utarpy ( lapyra,
     >                    nbtrto, nbpycf,
     >                    aretri, facpyr, cofapy,
     >                    listar )
c
          else
c
            do 421 , iaux = 1 , 8
              listar(iaux) = arepyr(lapyra-nbpycf,iaux)
  421       continue
c
          endif
c
          do 422 , iaux = 1 , 8
            ptpyar(listar(iaux)) = ptpyar(listar(iaux)) + 1
  422     continue
c
   42   continue
c
        do 43 , iaux = 1 , nbarto
          ptpyar(iaux) = ptpyar(iaux-1) + ptpyar(iaux)
  43    continue
        nbpyar = ptpyar(nbarto)
        do 44 , iaux = nbarto , 1 , -1
          ptpyar(iaux) = ptpyar(iaux-1)
  44    continue
c
      endif
c
c====
c 5. decompte des pentaedres voisins d'aretes
c====
c
      if ( nbpeto.gt.0 ) then
c
        do 51 , iaux = 0 , nbarto
          ptpear(iaux) = 0
  51    continue
c
        do 52 , lepent = 1 , nbpeto
c
          if ( lepent.le.nbpecf ) then
c
            call utarpe ( lepent,
     >                    nbquto, nbpecf,
     >                    arequa, facpen, cofape,
     >                    listar )
c
          else
c
            do 521 , iaux = 1 , 9
              listar(iaux) = arepen(lepent-nbpecf,iaux)
  521       continue
c
          endif
c
          do 522 , iaux = 1 , 9
            ptpear(listar(iaux)) = ptpear(listar(iaux)) + 1
  522     continue
c
   52   continue
c
        do 53 , iaux = 1 , nbarto
          ptpear(iaux) = ptpear(iaux-1) + ptpear(iaux)
  53    continue
        nbpear = ptpear(nbarto)
        do 54 , iaux = nbarto , 1 , -1
          ptpear(iaux) = ptpear(iaux-1)
  54    continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbtear', nbtear
      write (ulsort,90002) 'nbhear', nbhear
      write (ulsort,90002) 'nbpyar', nbpyar
      write (ulsort,90002) 'nbpear', nbpear
#endif
c
c====
c 6. La fin
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

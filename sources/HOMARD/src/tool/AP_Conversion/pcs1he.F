      subroutine pcs1he ( nbfop1, profho,
     >                    somare,
     >                    aretri, arequa,
     >                    tritet, cotrte, aretet,
     >                    quahex, coquhe, arehex,
     >                    filhex, hethex, fhpyte,
     >                    facpyr, cofapy, arepyr,
     >                    vap1ho )
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c    interpolation p1 sur les noeuds lors du decoupage des HExaedres
c                   -                                      --
c remarque : on devrait optimiser cela car si l'hexaedre etait dans
c            un etat de decoupage avec presence de noeud central, on
c            recalcule une valeur qui est deja presente
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop1 . e   .    1   . nombre de fonctions P1                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
c . vap1ho . es  . nbfop1*. variables p1 numerotation homard           .
c .        .     . nbnoto .                                            .
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
#include "fractf.h"
c
c 0.2. ==> communs
c
#include "nombar.h"
#include "nombno.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer nbfop1
      integer profho(nbnoto)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer filhex(nbheto), hethex(nbheto)
      integer fhpyte(2,nbheco)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
      double precision vap1ho(nbfop1,*)
c
c 0.4. ==> variables locales
c
      integer lehexa, lehex0
      integer listar(12), listso(8)
      integer etahex
      integer sm, nuv
      integer iaux
c
      double precision daux
c ______________________________________________________________________
c
#include "impr03.h"
c
c====
c 1. interpolation p1 pour les hexaedres qui viennent d'etre decoupes
c    avec creation d'un noeud central. Ce noeud est au barycentre
c    des 8 sommets de l'hexaedre pere. Donc on prend la moyenne de la
c    fonction sur ces 8 noeuds.
c====
c
      if ( nbfop1.ne.0 ) then
c
      do 10 , lehex0 = 1, nbheto
c
          lehexa = lehex0
c
        etahex = mod(hethex(lehexa),1000)
cgn          write(6,90015) 'hexa',lehexa,' => etat, binaire, chnp1',
cgn     >       hethex(lehexa), chbiet(etahex), chnp1(chbiet(etahex))
cgn          write(6,*) (quahex(lehexa,iaux),iaux=1,6)
cgn          write(6,*) (coquhe(lehexa,iaux),iaux=1,6)
c
        if ( chnp1(chbiet(etahex)).gt.0 ) then
c
c         les aretes et les sommets de l'hexaedre
c
          call utashe ( lehexa,
     >                  nbquto, nbhecf, nbheca,
     >                  somare, arequa,
     >                  quahex, coquhe, arehex,
     >                  listar, listso )
cgn          write(6,*) listso
c
c         tous les sommets doivent etre dans le profil
c
          do 102 , iaux = 1 , 8
            if ( profho(listso(iaux)).ne.1 ) then
              goto 10
            endif
  102     continue
c
c         recherche du noeud central
c
          iaux = lehexa
          call utnmhe ( iaux, sm,
     >                  somare, aretri, arequa,
     >                  tritet, cotrte, aretet,
     >                  quahex, coquhe, filhex, fhpyte,
     >                  facpyr, cofapy, arepyr )
cgn          write(6,*) 'sm', sm
c
c         le noeud central est a ajouter dans le profil
c
          profho(sm) = 1
c
c         interpolation = 1/8 (u1+u2+u3...u8)
c
          do 103 , nuv = 1, nbfop1
c
            daux = 0.d0
            do 1031 , iaux = 1 , 8
              daux = daux + vap1ho(nuv,listso(iaux))
 1031       continue
            vap1ho(nuv,sm) = unshu * daux
c
  103     continue
c
        endif
c
   10 continue
c
      endif
c
      end

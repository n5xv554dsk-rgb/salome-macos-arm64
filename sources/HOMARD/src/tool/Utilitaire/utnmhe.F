      subroutine utnmhe ( lehexa, noeumi,
     >                    somare, aretri, arequa,
     >                    tritet, cotrte, aretet,
     >                    quahex, coquhe, filhex, fhpyte,
     >                    facpyr, cofapy, arepyr )
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
c    UTilitaire - Noeud Milieu d'un HExaedre
c    --           -     -           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lehexa . e   . 1      . numero de l'hexaedre a examiner            .
c . noeumi .  s  . 1      . numero du noeud milieu                     .
c . somare . e   .2*nbaret. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des triangles des tetraedres       .
c . cotrte . e   .nbtecf*4. codes des triangles des tetraedres         .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . fhpyte . e   .2*nbheco. fhpyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille de l'hexaedre k tel que filhex(k) =-j.
c .        .     .        . fhpyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils de l'hexaedre k tel que filhex(k) = -j.
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . arepyr . e   .nbpyca*8. numeros des 8 aretes des pyramides         .
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
c 0.2. ==> communs
c
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer lehexa, noeumi
      integer somare(2,*)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer quahex(nbhecf,6), filhex(nbheto)
      integer coquhe(nbhecf,6), fhpyte(2,nbheco)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c     f1hp = Fils 1er de l'hexaedre en numerotation Homard a l'it. N+1
      integer f1hp
      integer listar(12), listso(8)
c
c====
c 1. Le fils enregistre.
c    Si positif, c'est un decoupage standard en 8 hexaedres
c    Si negatif, c'est un decoupage de conformite en pyramides et
c    tetraedres.
c====
c
      f1hp = filhex(lehexa)
cgn      print *,'f1hp =',f1hp
cgn      print *,fhpyte(1,1),fhpyte(2,1)
c
c====
c 2. Quand l'hexaedre est decoupe en 8 : pour trouver le noeud central,
c    on examine le premier fils de l'hexaedre.
c    Remarque : regarder cmrdhe pour ces conventions
c====
c
      if ( f1hp.gt.0) then
c
c       les aretes et les sommets de l'hexaedre fils
c
        call utarhe ( f1hp,
     >                nbquto, nbhecf,
     >                arequa, quahex, coquhe,
     >                listar )
c
        call utsohe ( somare, listar, listso )
c
c     recuperation du noeud sommet central : le huitieme sommet
c
        noeumi = listso(8)
c
c====
c 3. Quand l'hexaedre est decoupe par conformite pour trouver le noeud
c    central, on examine le premier fils de l'hexaedre, pyramide ou
c    tetraedre
c    Remarque : regarder cmcdhe pour ces conventions
c====
c
      else
c
        iaux = fhpyte(1,abs(f1hp))
cgn          print *,'iaux =',iaux
c
c 3.1. ==> On a au moins une pyramide
c
        if ( iaux.ne.0 ) then
c
c       les aretes et les sommets de la 1ere pyramide fils
c
cgn          print *,'==> pyramide =',iaux
          call utaspy ( iaux,
     >                  nbtrto, nbpycf, nbpyca,
     >                  somare, aretri,
     >                  facpyr, cofapy, arepyr,
     >                  listar, listso )
c
c     recuperation du noeud sommet central : le cinquieme sommet
c
          noeumi = listso(5)
c
c 3.2. ==> Il n'y a que des tetraedres
c
        else
c
          iaux = fhpyte(2,abs(f1hp))
c
c       les aretes et les sommets du 1er tetraedre fils
c
cgn          print *,'==> tetraedre =',iaux
          call utaste ( iaux,
     >                  nbtrto, nbtecf, nbteca,
     >                  somare, aretri,
     >                  tritet, cotrte, aretet,
     >                  listar, listso )
c
c     recuperation du noeud sommet central : le premier sommet
c
          noeumi = listso(1)
c
        endif
c
      endif
cgn          print *,'noeumi =',noeumi
c
      end

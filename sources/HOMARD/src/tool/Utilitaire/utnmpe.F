      subroutine utnmpe ( lepent, noeumi,
     >                    somare, aretri, arequa,
     >                    tritet, cotrte,
     >                    facpen, cofape, filpen, fppyte,
     >                    facpyr, cofapy )
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
c    UTilitaire - Noeud Milieu d'un PEntaedre
c    --           -     -           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   . 1      . numero du pentaedre a examiner            .
c . noeumi .  s  . 1      . numero du noeud milieu                     .
c . somare . e   .2*nbaret. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des triangles des tetraedres       .
c . cotrte . e   .nbtecf*4. codes des triangles des tetraedres         .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . e   .nbpecf*5. codes des faces des pentaedres             .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . fppyte . e   .  2**   . fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
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
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer lepent, noeumi
      integer somare(2,*)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer facpen(nbpecf,5), filpen(nbpeto)
      integer cofape(nbpecf,5), fppyte(2,nbpeco)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5)
c
c 0.4. ==> variables locales
c
      integer iaux
c     f1hp = Fils 1er du pentaedre en numerotation Homard a l'it. N+1
      integer f1hp
      integer listar(9), listso(6)
c
c====
c 1. Quand le pentaedre est decoupe par conformite pour trouver le noeud
c    central, on est toujours dans un cas ou on a produit des tetraedres
c    si le noeud central est un de leurs sommets, c'est S1.
c    en prenant le 4eme tetraedre, on couvre tous les cas de figure
c    Remarque : regarder cmcdpe pour ces conventions
c====
c
      f1hp = filpen(lepent)
c
      iaux = fppyte(2,abs(f1hp)) + 3
c
c       les aretes et les sommets du 4eme tetraedre fils
c
cgn          print *,'==> tetraedre =',iaux
      call utarte ( iaux,
     >              nbtrto, nbtecf,
     >              aretri, tritet, cotrte,
     >              listar )
c
      call utsote ( somare, listar, listso )
c
c     recuperation du noeud sommet central : le premier sommet
c
      noeumi = listso(1)
cgn          print *,'noeumi =',noeumi
c
      end

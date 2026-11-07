      subroutine pcsihe ( nbfop2, profho, vap2ho,
     >                    hethex, quahex, coquhe, arehex,
     >                    filhex, fhpyte,
     >                    somare, np2are,
     >                    aretri,
     >                    arequa,
     >                    tritet, cotrte, aretet,
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c    interpolation iso/p2 sur les noeuds - decoupage des HExaedres
c                  -                                     --
c remarque : on devrait optimiser cela car si l'hexaedre etait dans
c            un etat de decoupage similaire, on recalcule une valeur
c            qui est deja presente
c remarque : pcs2he et pcsihe sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop2 . e   .    1   . nombre de fonctions P2                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vap2ho . es  . nbfop2*. variables p1 numerotation homard           .
c .        .     . nbnoto .                                            .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . arehex . e   .nbheca12. numeros des 12 aretes des hexaedres        .
c . filhex . e   . nbheto . premier fils des hexaedres                 .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
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
      character*6 nompro
      parameter ( nompro = 'PCSIHE' )
c
#include "nblang.h"
c
#include "fract0.h"
#include "fracta.h"
c
c 0.2. ==> communs
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
c
#include "hexcf0.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(*)
      integer hethex(nbheto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer filhex(nbheto)
      integer fhpyte(2,nbheco)
      integer somare(2,nbarto), np2are(nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
c
      double precision vap2ho(nbfop2,*)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lehexa
      integer bindec, typdec, etanp1
      integer sm, nuv
      integer s1, s2, noemi
      integer nbarcp, tbarcp(12), areint(20)
c
      integer listar(12), listso(8), listno(12)
c
      logical afaire
c
      double precision daux
c
      integer langue
      integer nbmess
      parameter ( nbmess = 100 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
#include "impr01.h"
#include "impr03.h"
cgn      write (*,*) 'Entree dans ', nompro, ' avec nbheto = ',nbheto
      langue = 1
c
      do 10 , lehexa = 1, nbheto
c
c====
c 1. interpolation iso-p2 pour un hexaedre qui vient d'etre decoupe :
c    on a une valeur a mettre sur l'eventuel noeud central et les
c    milieux des aretes internes
c====
c
        iaux = lehexa
#ifdef _DEBUG_HOMARD_
      write (*,texte(langue,3)) 'PCS0HE', nompro
#endif
        call pcs0he ( iaux, profho,
     >                hethex, quahex, coquhe, arehex,
     >                filhex, fhpyte,
     >                somare, np2are,
     >                aretri,
     >                arequa,
     >                tritet, cotrte, aretet,
     >                facpyr, cofapy, arepyr,
     >                afaire, listar, listso, listno,
     >                bindec, typdec, etanp1,
     >                nbarcp, tbarcp, areint, sm )
#ifdef _DEBUG_HOMARD_
      write (*,90002) 'typdec', typdec
      write(*,90002) 'listar 1- 6', (listar(iaux),iaux=1,6)
      write(*,90002) 'listar 7-12', (listar(iaux),iaux=7,12)
      write(*,90002) 'listno 1- 6', (listno(iaux),iaux=1,6)
      write(*,90002) 'listno 7-12', (listno(iaux),iaux=7,12)
#endif
c
        if ( afaire ) then
c
c====
c 2. L'eventuel noeud central
c====
c
        if ( ( mod(typdec,2).eq.0 ) .or.
     >       ( mod(typdec,17).eq.0 ) ) then
#ifdef _DEBUG_HOMARD_
      write (*,90002) 'noeud central', sm
#endif
c
          profho(sm) = 1
c
c         formule iso-p2 :
c         interpolation = moyenne des valeurs sur les noeuds au milieu
c                         des aretes de l'hexaedre
c         remarque : pour un decoupage en 8, cela equivaut a prendre
c                   la moyenne sur les milieux des faces
c
          do 22 , nuv = 1, nbfop2
c
            daux = 0.d0
            do 221 , iaux = 1 , 12
              daux = daux + vap2ho(nuv,listno(iaux))
  221       continue
            vap2ho(nuv,sm) = unsdz * daux
cgn        write(*,*) 'vap2ho(nuv,',sm,') =',vap2ho(nuv,sm)
c
   22     continue
c
        endif
c
c====
c 3. Les noeuds sur les aretes internes
c====
c
        do 31 , iaux = 1 , chnar(bindec)
c
          s1 = somare(1,areint(iaux))
          s2 = somare(2,areint(iaux))
          noemi = np2are(areint(iaux))
          profho(noemi) = 1
c
          do 311, nuv = 1 , nbfop2
c
            vap2ho(nuv,noemi) = unsde * ( vap2ho(nuv,s1)
     >                                  + vap2ho(nuv,s2) )
cgn        write(*,*) 'vap2ho(nuv,',noemi,') =',vap2ho(nuv,noemi)
c
  311     continue
c
   31   continue
c
        endif
c
   10 continue
c
      end

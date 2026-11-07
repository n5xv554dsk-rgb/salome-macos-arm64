      subroutine pcs0pe ( lepent, profho,
     >                    hetpen, facpen, cofape, filpen, fppyte,
     >                    somare, np2are,
     >                    aretri, arequa,
     >                    tritet, cotrte,
     >                    facpyr, cofapy,
     >                    afaire, listar, listno, typdec, etanp1,
     >                    noeumi )
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
c    interpolation p2 sur les noeuds - phase 0
c                                            -
c    decoupage des PEntaedres
c                  --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .    1   . pentaedre a examiner                       .
c . profho . e   .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . e   .nbpecf*5. codes des faces des pentaedres             .
c . filpen . e   . nbpeto . premier fils des pentaedres                .
c . fppyte . e   .2*nbpeco. fppyte(1,j) = numero de la 1ere pyramide   .
c .        .     .        . fille du pentaedre k tel que filpen(k) =-j .
c .        .     .        . fppyte(2,j) = numero du 1er tetraedre      .
c .        .     .        . fils du pentaedre k tel que filpen(k) = -j .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des 5 faces des pyramides            .
c . afaire .  s  .    1   . vrai si l'interpolation est a faire        .
c . listar .  s  .    9   . liste des aretes du pentaedre              .
c . listno .  s  .   15   . liste des noeuds du pentaedre              .
c . typdec .  s  .    1   . type de decoupage                          .
c . etanp1 .  s  . 1      . etat du pentaedre a l'iteration N+1        .
c . noeumi .  s  . 1      . numero du noeud milieu                     .
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
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer lepent
      integer profho(nbnoto)
      integer hetpen(nbpeto), facpen(nbpecf,5), cofape(nbpecf,5)
      integer filpen(nbpeto), fppyte(2,nbpeco)
      integer somare(2,nbarto), np2are(nbarto)
      integer aretri(nbtrto,3)
      integer arequa(nbquto,4)
      integer tritet(nbtecf,4), cotrte(nbtecf,4)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5)
      integer listar(9), listno(15)
      integer typdec, etanp1
      integer noeumi
c
      logical afaire
c
c 0.4. ==> variables locales
c
      integer iaux
c
c     etan   = ETAt du pentaedre a l'iteration N
c
      integer etan
c ______________________________________________________________________
c
#include "impr03.h"
c
c====
c 1. les seuls cas interessants sont ceux ou un noeud est cree a
c    l'interieur du pentaedre, donc quand il y a une arete interne
c====
c
      etanp1 = mod(hetpen(lepent),100)
      etan   = (hetpen(lepent)-etanp1) / 100
cgn      write(1,90001) 'etats du penta', lepent,etan,etanp1
cgn      write(1,90002) 'faces', (facpen(lepent,iaux),iaux=1,5)
cgn      write(1,90002) 'codes', (cofape(lepent,iaux),iaux=1,5)
c
c     type de decoupage
c
      typdec = 1
c    . l'eventuel noeud central
c       decoupage selon 2 aretes tria/tria
c       decoupage selon 1 face triangulaire
      if ( ( etanp1.ge.31 .and. etanp1.le.36 ) .or.
     >     ( etanp1.ge.51 .and. etanp1.le.52 ) ) then
        typdec = typdec*2
      endif
c
c    . d'un milieu de faces a un autre (en 8)
      if ( ( etanp1.eq.80 ) .and. ( etanp1.ne.etan ) ) then
        typdec = typdec*3
      endif
c
c    . du centre aux milieux d'aretes
c       decoupage selon 2 aretes tria/tria
c       decoupage selon 1 face triangulaire
      if ( ( etanp1.ge.31 .and. etanp1.le.36 ) .or.
     >     ( etanp1.ge.51 .and. etanp1.le.52 ) ) then
        typdec = typdec*5
      endif
c
c    . du centre aux sommets
c       decoupage selon 2 aretes tria/tria
c       decoupage selon 1 face triangulaire
      if ( ( etanp1.ge.31 .and. etanp1.le.36 ) .or.
     >     ( etanp1.ge.51 .and. etanp1.le.52 ) ) then
        typdec = typdec*7
      endif
c
c    . d'un milieu d'arete a un autre (aretes tria+quad)
      if ( etanp1.ge.21 .and. etanp1.le.26 ) then
        typdec = typdec*11
      endif
c
c    . d'un milieu d'arete a un sommet (selon 1 arete tria)
      if ( etanp1.ge. 1 .and. etanp1.le. 6 ) then
        typdec = typdec*13
      endif
c
c    . d'un milieu de face a un sommet (selon 1 face quad)
      if ( etanp1.ge.43 .and. etanp1.le.45 ) then
        typdec = typdec*17
      endif
c
cgn      write(1,90002) 'typdec',typdec
c
c====
c 2. Caracteristiques du pentaedre
c====
c
      if ( typdec.gt.1 ) then
c
c 2.1. ==> reperage des 9 aretes du pentaedre
c
        call utarpe ( lepent,
     >                nbquto, nbpeto,
     >                arequa, facpen, cofape,
     >                listar )
cgn        write(1,90002) 'listar', listar
c
c 2.2. ==> recuperation des 6 noeuds sommets
c
        call utsope ( somare, listar, listno )
cgn        write(1,90002) 'listno sommets', (listno(iaux),iaux=1,6))
c
c 2.3. ==> recuperation des 9 noeuds milieux
c
        do 23 , iaux = 1 , 9
          listno(6+iaux) = np2are(listar(iaux))
   23   continue
cgn        write(1,90002) 'listno milieux', (listno(iaux),iaux=7,15))
c
      endif
c
c====
c 3. on verifie que le champ est present sur tous les noeuds
c    du pentaedre
c====
c
      if ( typdec.gt.1 ) then
c
        afaire = .true.
        do 31  , iaux = 1 , 15
          if ( profho(listno(iaux)).eq.0 ) then
            afaire = .false.
            goto 32
          endif
   31   continue
c
   32   continue
c
      else
c
        afaire = .false.
c
      endif
cgn      write(1,*) 'afaire', afaire
c
c====
c 4. S'il faudra interpoler avec l'eventuel noeud central :
c====
c
      if ( afaire ) then
c
        if ( mod(typdec,2).eq.0 .or.
     >       mod(typdec,5).eq.0 .or.
     >       mod(typdec,7).eq.0 ) then
c
          iaux = lepent
          call utnmpe ( iaux, noeumi,
     >                  somare, aretri, arequa,
     >                  tritet, cotrte,
     >                  facpen, cofape, filpen, fppyte,
     >                  facpyr, cofapy )
c
        endif
c
      endif
c
      end

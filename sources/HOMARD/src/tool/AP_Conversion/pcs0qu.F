      subroutine pcs0qu ( lequad, profho,
     >                    hetqua, arequa,
     >                    somare, np2are,
     >                    afaire, listar, listno, typdec, etanp1 )
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
c    decoupage des QUadrangles
c                  --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lequad . e   .    1   . quadrangle a examiner                      .
c . profho . e   .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . afaire .  s  .    1   . vrai si l'interpolation est a faire        .
c . listar .  s  .    4   . liste des aretes du quadrangle             .
c . listno .  s  .    8   . liste des noeuds du quadrangle             .
c . typdec .  s  .    1   . type de decoupage                          .
c . etanp1 .  s  . 1      . etat de l'hexaedre a l'iteration N+1       .
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
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer lequad
      integer profho(nbnoto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer somare(2,nbarto), np2are(nbarto)
      integer listar(4), listno(8)
      integer typdec, etanp1
c
      logical afaire
c
c 0.4. ==> variables locales
c
      integer iaux
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
c
c     etan   = ETAt du quadrangle a l'iteration N
c
      integer etan
c
c 0.5. ==> initialisations
c
c ______________________________________________________________________
c
c====
c 1. les seuls cas interessants sont ceux ou un noeud est cree a
c    l'interieur du quadrangle :
c    . au centre pour un decoupage standard
c    . sur des milieux d'aretes internes pour un decoupage standard
c      ou de conformite
c====
c
      etanp1 = mod(hetqua(lequad),100)
      etan   = (hetqua(lequad)-etanp1) / 100
c
c     type de decoupage :
c          4 : en 4 standard
c          21, 22 : en 2 quadrangles selon les aretes 1/3 ou 2/4
c          31, 32, 33 ou 34 : en 3 triangles selon l'arete 1, 2, 3 ou 4
c          41, 42, 43 ou 44 : en 3 quadrangles selon les aretes 1/2,
c                             2/3, 3/4 ou 4/1
c
      if ( ( etanp1.eq.4 ) .and.
     >     ( etan.eq.0 .or.
     >       etan.eq.21 .or. etan.eq.22 .or.
     >       etan.eq.31 .or. etan.eq.32 .or.
     >       etan.eq.33 .or. etan.eq.34 .or.
     >       etan.eq.41 .or. etan.eq.42 .or.
     >       etan.eq.43 .or. etan.eq.44 ) ) then
        typdec = 4
c
      elseif ( etanp1.eq.21 .or. etanp1.eq.22 .or.
     >         etanp1.eq.31 .or. etanp1.eq.32 .or.
     >         etanp1.eq.33 .or. etanp1.eq.34 .or.
     >         etanp1.eq.41 .or. etanp1.eq.42 .or.
     >         etanp1.eq.43 .or. etanp1.eq.44 ) then
        typdec = etanp1
c
      else
        typdec = 0
c
      endif
c
c====
c 2. Caracteristiques du quadrangle
c====
c
      if ( typdec.ne.0 ) then
cgn        write(6,*) 'lequad,etan,etanp1=',lequad,etan,etanp1
cgn        write(6,*) 'typdec =', typdec
c
c 2.1. ==> reperage des 4 aretes du quadrangle
c
        a1 = arequa(lequad,1)
        a2 = arequa(lequad,2)
        a3 = arequa(lequad,3)
        a4 = arequa(lequad,4)
c
        listar(1) = a1
        listar(2) = a2
        listar(3) = a3
        listar(4) = a4
c
c 2.2. ==> recuperation des 4 noeuds sommets
c
        call utsoqu ( somare, a1, a2, a3, a4,
     >                sa1a2, sa2a3, sa3a4, sa4a1 )
c
        listno(1) = sa1a2
        listno(2) = sa2a3
        listno(3) = sa3a4
        listno(4) = sa4a1
c
c 2.3. ==> recuperation des 4 noeuds milieux
c
        listno(5) = np2are(a1)
        listno(6) = np2are(a2)
        listno(7) = np2are(a3)
        listno(8) = np2are(a4)
c
        endif
c
c====
c 3. on verifie que le champ est present sur tous les noeuds
c    du quadrangle
c====
c
      if ( typdec.ne.0 ) then
c
        afaire = .true.
        do 31  , iaux = 1 , 8
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
c
      end

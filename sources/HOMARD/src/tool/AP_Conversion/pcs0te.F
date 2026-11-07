      subroutine pcs0te ( letetr, profho,
     >                    tritet, cotrte, aretet,
     >                    hettet, filtet,
     >                    aretri,
     >                    somare, np2are,
     >                    afaire, listar, listno, adiag )
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
c    decoupage des TEtraedres
c                  --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letetr . e   .    1   . tetraedre a examiner                       .
c . profho . e   .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. code des 4 triangles des tetraedres        .
c . aretet . e   .nbteca*6. numeros des 6 aretes des tetraedres        .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . filtet . e   . nbteto . premier fils des tetraedres                .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . afaire .  s  .    1   . vrai si l'interpolation est a faire        .
c . listar .  s  .    6   . liste des aretes du tetraedre              .
c . listno .  s  .   10   . liste des noeuds du tetraedre              .
c . adiag  .  s  .    1   . arete diagonale si interpolation           .
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
#include "nombte.h"
c
c 0.3. ==> arguments
c
      integer letetr
      integer profho(nbnoto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hettet(nbteto), filtet(nbteto)
      integer aretri(nbtrto,3)
      integer somare(2,nbarto), np2are(nbarto)
      integer listar(6), listno(10)
      integer adiag
c
      logical afaire
c
c 0.4. ==> variables locales
c
      integer iaux
      integer typdec
      integer t16ff1, t25ff1, t34ff1, td16a2, td25a1, td34a1
      integer fd16n4, fd25n4, fd34n5, fd16s3, fd25s2, fd34s2
c
c     etan   = ETAt du tetraedre a l'iteration N
c     etanp1 = ETAt du tetraedre a l'iteration N+1
c
      integer etan, etanp1
c ______________________________________________________________________
c
c====
c 1. les seuls cas interessants sont ceux ou un noeud est cree a
c    l'interieur du tetraedre, donc quand il y a une diagonale.
c====
c
      etanp1 = mod( hettet(letetr), 100 )
      etan   = (hettet(letetr)-etanp1) / 100
c
c     type de decoupage
c          8 : en 8 standard
c          45, 46, 47 : en 4 par 2 fois 2 selon l'arete 5, 6, 7
c
      if ( ( etanp1.eq.85 .or. etanp1.eq.86 .or. etanp1.eq.87 ) .and.
     >     ( etan.ne.etanp1 ) ) then
        typdec = 8
c
      elseif (
     >     etanp1.eq.45 .or. etanp1.eq.46 .or. etanp1.eq.47 ) then
        typdec = etanp1
c
      else
        typdec = 0
c
      endif
c
c====
c 2. Caracteristiques du tetraedre
c====
c
      if ( typdec.ne.0 ) then
c
c 2.1. ==> reperage des aretes et des sommets du tetraedre
c
        call utaste ( letetr,
     >                nbtrto, nbtecf, nbteca,
     >                somare, aretri,
     >                tritet, cotrte, aretet,
     >                listar, listno )
c
c 2.2. ==> recuperation des 6 noeuds milieux
c
        do 22  , iaux = 1 , 6
          listno(4+iaux) = np2are(listar(iaux))
   22   continue
c
      endif
c
c====
c 3. on verifie que le champ est present sur tous les noeuds
c    du tetraedre
c====
c
      if ( typdec.ne.0 ) then
c
        afaire = .true.
        do 31  , iaux = 1 , 10
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
c====
c 4. S'il faudra interpoler, on cherche la diagonale
c====
c
      if ( afaire ) then
c
c 4.1. ==> le tetraedre vient d'etre decoupee en 8 par (1,6)
c
        if ( etanp1.eq.85 ) then
c
          t16ff1 = filtet(letetr) + 4
          fd16n4 = tritet(t16ff1,3)
          adiag = aretri(fd16n4,1)
c
c 4.2. ==> le tetraedre vient d'etre decoupee en 8 par (2,5)
c
        elseif ( etanp1.eq.86 ) then
c
          t25ff1 = filtet(letetr) + 4
          fd25n4 = tritet(t25ff1,2)
          adiag = aretri(fd25n4,1)
c
c 4.3. ==> le tetraedre vient d'etre decoupee en 8 par (3,4)
c
        elseif ( etanp1.eq.87 ) then
c
          t34ff1 = filtet(letetr) + 4
          fd34n5 = tritet(t34ff1,2)
          adiag = aretri(fd34n5,2)
c
c 4.4. ==> le tetraedre vient d'etre decoupee en 4 par (1,6)
c
        elseif ( etanp1.eq.45 ) then
c
          td16a2 = filtet(letetr)
          fd16s3 = tritet(td16a2,1)
          adiag = aretri(fd16s3,2)
c
c 4.5. ==> le tetraedre vient d'etre decoupee en 4 par (2,5)
c
        elseif ( etanp1.eq.46 ) then
c
          td25a1 = filtet(letetr)
          fd25s2 = tritet(td25a1,1)
          adiag = aretri(fd25s2,3)
c
c 4.6. ==> le tetraedre vient d'etre decoupee en 4 par (3,4)
c
        elseif ( etanp1.eq.47 ) then
c
          td34a1 = filtet(letetr)
          fd34s2 = tritet(td34a1,1)
          adiag = aretri(fd34s2,3)
c
        endif
c
      endif
c
      end

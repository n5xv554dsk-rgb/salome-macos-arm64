      subroutine pcs0tr ( letria, profho,
     >                    hettri, aretri,
     >                    somare, np2are,
     >                    afaire, listno, typdec )
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
c    decoupage des TRiangles
c                  --
c ______________________________________________________________________
c remarque : pcs0tr et pcs3tr sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . letria . e   .    1   . triangle a examiner                        .
c . profho . e   .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . afaire .  s  .    1   . vrai si l'interpolation est a faire        .
c . listno .  s  .    6   . liste des noeuds du triangle               .
c . typdec .  s  .    1   . type de decoupage                          .
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
c
c 0.3. ==> arguments
c
      integer letria
      integer profho(nbnoto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer somare(2,nbarto), np2are(nbarto)
      integer listno(6)
      integer typdec
c
      logical afaire
c
c 0.4. ==> variables locales
c
      integer iaux
      integer as1s2, as2s3, as1s3
      integer s1, s2, s3
c
c     etan   = ETAt du triangle a l'iteration N
c     etanp1 = ETAt du triangle a l'iteration N+1
c
      integer etan, etanp1
c
c 0.5. ==> initialisations
c
c ______________________________________________________________________
c
c====
c 1. Quel decoupage
c====
c
      etanp1 = mod(hettri(letria),10)
      etan   = (hettri(letria)-etanp1) / 10
c
c     type de decoupage
c          4 : en 4 standard
c          6, 7, 8 : en 4 avec basculement de l'arete typdec-5
c          1, 2, 3 : en 2 selon l'arete typdec
c
      if ( ( etanp1.eq.4 ) .and.
     >     ( etan.eq.0 .or. etan.eq.1 .or.
     >       etan.eq.2 .or. etan.eq.3 ) ) then
        typdec = 4
c
      elseif (
     >     ( etanp1.eq.6 .or. etanp1.eq.7 .or. etanp1.eq.8 ) .and.
     >     ( etan.eq.0 .or. etan.eq.1 .or.
     >       etan.eq.2 .or. etan.eq.3 ) ) then
        typdec = etanp1
c
      elseif ( etanp1.eq.1 .or. etanp1.eq.2 .or. etanp1.eq.3 ) then
        typdec = etanp1
c
      else
        typdec = 0
c
      endif
c
c====
c 2. Caracteristiques du triangle
c====
c
      if ( typdec.ne.0 ) then
c
c 2.1. ==> reperage des 3 aretes du triangle decoupe
c
        as2s3 = aretri(letria,1)
        as1s3 = aretri(letria,2)
        as1s2 = aretri(letria,3)
c
c 2.2. ==> recuperation des 3 noeuds sommets
c
        call utsotr ( somare, as2s3, as1s3, as1s2, s3, s1, s2 )
c
        listno(1) = s1
        listno(2) = s2
        listno(3) = s3
c
c 2.3. ==> recuperation des 3 noeuds milieux
c
        listno(4) = np2are(as2s3)
        listno(5) = np2are(as1s3)
        listno(6) = np2are(as1s2)
c
      endif
c
c====
c 3. on verifie que le champ est present sur tous les noeuds
c    du triangle
c====
c
      if ( typdec.ne.0 ) then
c
        afaire = .true.
        do 31  , iaux = 1 , 6
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

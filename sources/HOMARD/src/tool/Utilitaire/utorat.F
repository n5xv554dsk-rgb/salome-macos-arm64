      subroutine utorat ( somare, a1, a2, a3,
     >                    or1, or2, or3 )
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
c    UTilitaire - ORientation des Aretes d'un Triangle
c    --           --              -           -
c Remarque : cela suppose que les aretes a1, a2, a3 sont donnees
c            dans l'ordre standard
c Remarque : programme semblable a utsotr
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbaret. numeros des extremites d'arete             .
c .a1,a2,a3. e   . 1      . les numeros d'aretes du triangle           .
c . ori    .  s  . 1      . 1 ou -1 , selon que l'arete ari est dans   .
c .        .     .        . le sens du triangle                        .
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
c 0.3. ==> arguments
c
      integer somare(2,*)
      integer a1, a2, a3
      integer or1, or2, or3
c
c 0.4. ==> variables locales
c
c====
c 1. recherche des orientations :
c    l'orientation de l'arete i est positive si son second somemt est
c    un des sommets de l'arete i+1
c====
c
c                           S1 = sa2a3
c                            *
c                           . .
c                          .   .
c                         .     .
c                     a3 .       . a2
c                       .         .
c                      .           .
c                     .             .
c          sa3a1 = S2*---------------*S3 = sa1a2
c                           a1
c
c
      if ( somare(2,a1) .eq. somare(1,a2)  .or.
     >     somare(2,a1) .eq. somare(2,a2) ) then
c          le 2nd noeud de l'arete 1 est un sommet de a2 ;
c          donc l'orientation est positive
c
        or1 = 1
c
      else
c
        or1 = -1
c
      endif
c
      if ( somare(2,a2) .eq. somare(1,a3)  .or.
     >     somare(2,a2) .eq. somare(2,a3) ) then
c          le 2nd noeud de l'arete 2 est un sommet de a3 ;
c          donc l'orientation est positive
c
        or2 = 1
c
      else
c
        or2 = -1
c
      endif
c
      if ( somare(2,a3) .eq. somare(1,a1)  .or.
     >     somare(2,a3) .eq. somare(2,a1) ) then
c          le 2nd noeud de l'arete 3 est un sommet de a1 ;
c          donc l'orientation est positive
c
        or3 = 1
c
      else
c
        or3 = -1
c
      endif
c
      end

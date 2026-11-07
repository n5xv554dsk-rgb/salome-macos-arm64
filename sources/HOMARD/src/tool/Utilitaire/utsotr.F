      subroutine utsotr ( somare, a1, a2, a3,
     >                    sa1a2, sa2a3, sa3a1 )
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
c    UTilitaire - SOmmets d'un TRiangle
c    --           --           --
c Remarque : programme semblable a utorat
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbaret. numeros des extremites d'arete             .
c .a1,a2,a3. e   . 1      . les numeros d'aretes du triangle           .
c . sa1a2  .  s  . 1      . sommet commun aux aretes 1 et 2 = S3       .
c . sa2a3  .  s  . 1      . sommet commun aux aretes 2 et 3 = S1       .
c . sa3a1  .  s  . 1      . sommet commun aux aretes 3 et 4 = S2       .
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
      integer sa1a2, sa2a3, sa3a1
c
c 0.4. ==> variables locales
c
c====
c 1. recherche des sommets
c====
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
c     Cas 1 : les aretes a1 et a3 se coupent sur le premier sommet de a1
c
      if ( somare(1,a1).eq.somare(1,a3) .or.
     >     somare(1,a1).eq.somare(2,a3) ) then
c
        sa3a1 = somare(1,a1)
        if (somare(2,a1).eq.somare(1,a2)) then
          sa1a2 = somare(1,a2)
          sa2a3 = somare(2,a2)
        else
          sa1a2 = somare(2,a2)
          sa2a3 = somare(1,a2)
        endif
c
c     Cas 2 : les aretes a1 et a3 se coupent sur le second sommet de a1
c
      else
c
        sa3a1 = somare(2,a1)
        if (somare(1,a1).eq.somare(1,a2)) then
          sa1a2 = somare(1,a2)
          sa2a3 = somare(2,a2)
        else
          sa1a2 = somare(2,a2)
          sa2a3 = somare(1,a2)
        endif
c
      endif
c
      end

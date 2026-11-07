      subroutine utsoqu ( somare, a1, a2, a3, a4,
     >                    sa1a2, sa2a3, sa3a4, sa4a1 )
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
c    UTilitaire - SOmmets d'un QUadrangle
c    --           --           --
c Remarque : cela suppose que les aretes a1, a2, a3, a4 soient donnees
c            dans l'ordre standard
c Remarque : programme semblable a utoraq
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbaret. numeros des extremites d'arete             .
c .a1,..,a4. e   . 1      . les numeros d'aretes du quadrangle         .
c . sa1a2  .  s  . 1      . sommet commun aux aretes a1 et a2          .
c . sa2a3  .  s  . 1      . sommet commun aux aretes a2 et a3          .
c . sa3a4  .  s  . 1      . sommet commun aux aretes a3 et a4          .
c . sa4a1  .  s  . 1      . sommet commun aux aretes a4 et a1          .
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
      integer a1, a2, a3, a4
      integer sa1a2, sa2a3, sa3a4, sa4a1
c
c 0.4. ==> variables locales
c
c====
c 1. recherche des sommets
c====
c
c                      sa4a1   a4   sa3a4
c                          ._________.
c                          .         .
c                          .         .
c                        a1.         .a3
c                          .         .
c                          ._________.
c                      sa1a2   a2   sa2a3
c
c
      if ( somare(1,a1).eq.somare(1,a2)  .or.
     >     somare(1,a1).eq.somare(2,a2) ) then
c          le 1er noeud de l'arete 1 est un sommet de a2 ;
c          donc le 2nd noeud de l'arete 1 est un sommet de a4
c
        sa1a2 = somare(1,a1)
        sa4a1 = somare(2,a1)
c
      else
c               le 1er noeud de l'arete 1 n'est pas un sommet de a2 ;
c               donc c'est qu'il est un des sommets de a4
c               donc le 2nd noeud de l'arete 1 est un sommet de a2
        sa1a2 = somare(2,a1)
        sa4a1 = somare(1,a1)
c
      endif
c
      if ( somare(1,a3).eq.somare(1,a4)  .or.
     >     somare(1,a3).eq.somare(2,a4) ) then
c               le 1er noeud de l'arete 3 est un sommet de a4 ;
c               donc le 2nd noeud de l'arete 3 est un sommet de a2
        sa3a4 = somare(1,a3)
        sa2a3 = somare(2,a3)
c
      else
c               le 1er noeud de l'arete 3 n'est pas un sommet de a4 ;
c               donc c'est qu'il est un des sommets de a2
c               donc le 2nd noeud de l'arete 3 est un sommet de a4
        sa3a4 = somare(2,a3)
        sa2a3 = somare(1,a3)
c
      endif
c
      end

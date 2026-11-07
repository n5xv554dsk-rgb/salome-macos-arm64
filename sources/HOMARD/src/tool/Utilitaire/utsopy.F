      subroutine utsopy ( somare, listar, sommet )
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
c   UTilitaire : SOmmets d'une PYramide
c   --           --            --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . listar . e   .    8   . Liste des aretes ordonnees suivant la pyra .
c . sommet .  s  .    5   . Liste des sommets ordonnes suivant la pyra .
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
      integer somare(2,*), listar(8), sommet(5)
c
c 0.4. ==> variables locales
c
      integer iaux
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c                            S5
c                            x
c                         . . . .
c                       .  .   .   .
c                     .   .   a4.     .
c                   .    .       .       .
c                 .     .        x .         .
c            a1 .      .     .   S4    .        .a3
c             .       .  .                 .       .
c           .        .                         .      .
c         .      .  .                           a7 .     .
c       .    .a8   .                                   .    .
c     .  .        .                                        .   .
c S1 .           .a2                                           .  .
c  x .         .                                                  .  .
c     a5  .    .                                                      .
c             x--------------------------------------------------------x
c           S2                            a6                          S3
c   La face f5 est le quadrangle.
c   La face fi, i<5, est le triangle s'appuyant sur l'arete ai.
c
c====
c 1. Recherche des sommets
c====
c
      iaux = somare(1,listar(1))
      if ( iaux.eq.somare(1,listar(2)) ) then
        sommet(5) = iaux
        sommet(1) = somare(2,listar(1))
        sommet(2) = somare(2,listar(2))
      elseif ( iaux.eq.somare(2,listar(2)) )then
        sommet(5) = iaux
        sommet(1) = somare(2,listar(1))
        sommet(2) = somare(1,listar(2))
      else
        sommet(5) = somare(2,listar(1))
        sommet(1) = iaux
        if ( sommet(5).eq.somare(1,listar(2)) ) then
          sommet(2) = somare(2,listar(2))
        else
          sommet(2) = somare(1,listar(2))
        endif
      endif
c
      iaux = somare(1,listar(6))
      if ( iaux.eq.sommet(2) ) then
        sommet(3) = somare(2,listar(6))
      else
        sommet(3) = iaux
      endif
c
      iaux = somare(1,listar(7))
      if ( iaux.eq.sommet(3) ) then
        sommet(4) = somare(2,listar(7))
      else
        sommet(4) = iaux
      endif
c
      end

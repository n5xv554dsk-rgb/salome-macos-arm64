      subroutine utsote ( somare, listar, listso )
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
c    UTilitaire - SOmmets d'un TEtraedre
c    --           --           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbaret. numeros des extremites d'arete             .
c . listar . e   .    6   . Liste des aretes ordonnees suivant le tetr .
c . listso .  s  .    4   . Liste des sommets ordonnes suivant le tetr .
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
      integer somare(2,*), listar(6), listso(4)
c
c 0.4. ==> variables locales
c
      integer iaux
c
c====
c 1. recherche des sommets
c====
c                                    la face fi est opposee au sommet ni
c                     n1
c                     *
c                    .  ..
c                   .     . . a3
c                  .        .  .
c                 .           .   .
c             a1 .          a2  .    .  n4
c               .                 .    *
c              .                  . .   .
c             .        a5    .        .  . a6
c            .          .               . .
c           .      .                      ..
c          .  .                             .
c         *..................................*
c       n2               a4                  n3
c
      iaux = somare(1,listar(1))
      if ( iaux.eq.somare(1,listar(2)) ) then
c
        listso(1) = iaux
        listso(2) = somare(2,listar(1))
        listso(3) = somare(2,listar(2))
c
      elseif ( iaux.eq.somare(2,listar(2)) ) then
c
        listso(1) = iaux
        listso(2) = somare(2,listar(1))
        listso(3) = somare(1,listar(2))
c
      elseif ( somare(2,listar(1)).eq.somare(1,listar(2)) ) then
c
        listso(1) = somare(2,listar(1))
        listso(2) = iaux
        listso(3) = somare(2,listar(2))
c
      else
c
        listso(1) = somare(2,listar(1))
        listso(2) = iaux
        listso(3) = somare(1,listar(2))
c
      endif
c
      if ( somare(1,listar(6)).eq.somare(1,listar(3)) .or.
     >     somare(1,listar(6)).eq.somare(2,listar(3)) ) then
c
        listso(4) = somare(1,listar(6))
c
      else
c
        listso(4) = somare(2,listar(6))
c
      endif
c
      end

      subroutine utsope ( somare, listar, sommet)
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
c   UTilitaire :  SOmmets d'un PEntaedre
c   --            --           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . listar . e   .    9   . Liste des aretes ordonnees suivant le penta.
c . sommet .  s  .    *   . Liste des sommets ordonnes suivant le penta.
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
      integer somare(2,*), listar(9), sommet(*)
c
c 0.4. ==> variables locales
c
      integer iaux
c
c====
c 1. Recherche des sommets
c====
c 1.1. ==> du cote de la face 1
c
      iaux = somare(1,listar(1))
      if ( iaux.eq.somare(1,listar(2)) ) then
        sommet(1) = iaux
        sommet(2) = somare(2,listar(2))
        sommet(3) = somare(2,listar(1))
      elseif ( iaux.eq.somare(2,listar(2)) )then 
        sommet(1) = iaux
        sommet(2) = somare(1,listar(2))
        sommet(3) = somare(2,listar(1))
      else
        sommet(1) = somare(2,listar(1))
        if ( sommet(1).eq.somare(1,listar(2)) ) then
          sommet(2) = somare(2,listar(2))
        else
          sommet(2) = somare(1,listar(2))
        endif
        sommet(3) = iaux
      endif
c
c 1.2. ==> du cote de la face 2
c
      iaux = somare(1,listar(4))
      if ( iaux.eq.somare(1,listar(5)) ) then
        sommet(4) = iaux
        sommet(5) = somare(2,listar(5))
        sommet(6) = somare(2,listar(4))
      elseif ( iaux.eq.somare(2,listar(5)) )then 
        sommet(4) = iaux
        sommet(5) = somare(1,listar(5))
        sommet(6) = somare(2,listar(4))
      else
        sommet(4) = somare(2,listar(4))
        if ( sommet(4).eq.somare(1,listar(5)) ) then
          sommet(5) = somare(2,listar(5))
        else
          sommet(5) = somare(1,listar(5))
        endif
        sommet(6) = iaux
      endif
c
      end

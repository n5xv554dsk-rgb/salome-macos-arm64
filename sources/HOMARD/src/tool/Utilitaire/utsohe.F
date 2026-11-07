      subroutine utsohe ( somare, listar, listso )
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
c   UTilitaire :  SOmmets d'un HExaedre
c   --            --           --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . listar . e   .   12   . Liste des aretes de l'hexaedre             .
c . listso .  s  .    8   . Liste des sommets de l'hexaedre            .
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
      integer somare(2,*), listar(12), listso(8)
c
c 0.4. ==> variables locales
c
      integer iaux
c
c====
c 1. Recherche des sommets
c====
c
      iaux = somare(1,listar(1))
      if ( iaux.eq.somare(1,listar(2)) ) then
        listso(1) = iaux
        listso(2) = somare(2,listar(1))
        listso(4) = somare(2,listar(2))
        if ( listso(4).eq.somare(1,listar(4)) ) then
          listso(3) = somare(2,listar(4))
        else
          listso(3) = somare(1,listar(4))
        endif
      elseif ( iaux.eq.somare(2,listar(2)) )then
        listso(1) = iaux
        listso(2) = somare(2,listar(1))
        listso(4) = somare(1,listar(2))
        if ( listso(4).eq.somare(1,listar(4)) ) then
          listso(3) = somare(2,listar(4))
        else
          listso(3) = somare(1,listar(4))
        endif
      else
        listso(1) = somare(2,listar(1))
        listso(2) = iaux
        if ( listso(1).eq.somare(1,listar(2)) ) then
          listso(4) = somare(2,listar(2))
        else
          listso(4) = somare(1,listar(2))
        endif
        if ( listso(4).eq.somare(1,listar(4)) ) then
          listso(3) = somare(2,listar(4))
        else
          listso(3) = somare(1,listar(4))
        endif
      endif
c
      iaux = somare(1,listar(9))
      if ( iaux.eq.somare(1,listar(11)) ) then
        listso(5) = iaux
        listso(6) = somare(2,listar(9))
        listso(8) = somare(2,listar(11))
        if ( listso(8).eq.somare(1,listar(12)) ) then
          listso(7) = somare(2,listar(12))
        else
          listso(7) = somare(1,listar(12))
        endif
      elseif ( iaux.eq.somare(2,listar(11)) )then
        listso(5) = iaux
        listso(6) = somare(2,listar(9))
        listso(8) = somare(1,listar(11))
        if ( listso(8).eq.somare(1,listar(12)) ) then
          listso(7) = somare(2,listar(12))
        else
          listso(7) = somare(1,listar(12))
        endif
      else
        listso(5) = somare(2,listar(9))
        listso(6) = iaux
        if ( listso(5).eq.somare(1,listar(11)) ) then
          listso(8) = somare(2,listar(11))
        else
          listso(8) = somare(1,listar(11))
        endif
        if ( listso(8).eq.somare(1,listar(12)) ) then
          listso(7) = somare(2,listar(12))
        else
          listso(7) = somare(1,listar(12))
        endif
      endif
c
      end

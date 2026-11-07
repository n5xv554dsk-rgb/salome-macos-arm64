      subroutine dmalme ( adress, taille, codret )
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
c   Dependance Machine : ALlocation de MEmoire
c   -          -         --            --
c ______________________________________________________________________
c
c  but : alloue une place memoire de taille donnee
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . adress .  s  .   1    . adresse de depart de la zone allouee       .
c . taille . e   .   1    . taille voulue                              .
c . codret .  s  .    1   . code retour : 0 si tout va bien, 1 sinon   .
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
      integer adress, taille, codret
c
c 0.4. ==> variables locales
c ______________________________________________________________________
c
c====
c 1. appel de la fonction C equivalente
c====
c
      call dmalmc ( adress, taille )
c
      if ( adress.eq.0 ) then
        codret = 1
      else
        codret = 0
      endif
c
      end

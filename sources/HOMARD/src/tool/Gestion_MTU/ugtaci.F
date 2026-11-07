      subroutine ugtaci ( tab1, tab2, indinf, indsup )
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
c but : basculer le contenu du tableau tab2 dans le tableau tab1
c       les tableaux sont entiers
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tab1   .  s  . lgtab  . tableau a remplir                          .
c . tab2   . e   . lgtab  . tableau a copier                           .
c . indinf . e   .    1   . indice inferieur des tableaux tab1 et tab2 .
c . indsup . e   .    1   . indice superieur des tableaux tab1 et tab2 .
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
      integer indinf, indsup
c
      integer tab1(indinf:indsup), tab2(indinf:indsup)
c
c 0.4. ==> variables locales
c
      integer i
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. copie
c====
c
      do 1 , i = indinf, indsup
         tab1(i) = tab2(i)
    1 continue
c
      end

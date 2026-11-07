      subroutine pcsprn ( typprf, numnp1,
     >                    hetnoe, nnoeho,
     >                    nbvapr, listpr )
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
c    aPres adaptation - Conversion de Solution - PRofil - Noeuds
c     -                 -             -          -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typprf .  s  .    1   . type du support defini par le profil       .
c .        .     .        . 0 : rien de special                        .
c .        .     .        . 1 : tous les noeuds P1 et eux seuls        .
c .        .     .        . 2 : une partie des noeuds P1               .
c . numnp1 . e   .    1   . nombre de noeuds P1 en entree              .
c . hetnoe . e   . nbnoto . historique de l'etat des noeuds            .
c . nnoeho . e   . renoac . numero des noeuds en entre pour homard     .
c . nbvapr . e   .   1    . nombre de valeurs du profil                .
c . listpr . e   .   *    . liste des numeros de noeuds ou la fonction .
c .        .     .        . est definie.                               .
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
cgn      character*6 nompro
cgn      parameter ( nompro = 'PCSPRN' )
c
c 0.2. ==> communs
c
#include "nomber.h"
#include "nombno.h"
c
c 0.3. ==> arguments
c
      integer typprf
      integer numnp1
c
      integer nbvapr, listpr(*)
c
      integer hetnoe(nbnoto)
      integer nnoeho(renoac)
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer nbnpr1, nbnpr2
c ______________________________________________________________________
c
      nbnpr1 = 0
      nbnpr2 = 0
c
c====
c 1. si le maillage est inchange ou s'il n'y a eu que du raffinement,
c    chaque noeud en entree de HOMARD est encore un noeud en sortie.
c    Le numero d'un noeud dans HOMARD reste inchange.
c    Il suffit de tester l'etat du noeud en entree
c     Numero dans le calcul en entree  <--->  Numero HOMARD
c                lenoeu                <--->  nnoeho(lenoeu)
c====
c
cgn      write(*,*) 'Dans pcsprn, nbvapr =', nbvapr
cgn 1789 format(a,'(',i5,',) =',i10,', noeud',i10)
c
        do 10 , iaux = 1 , nbvapr
cgn      write (*,1789)'listpr',iaux,listpr(iaux),nnoeho(listpr(iaux))
          jaux = hetnoe(nnoeho(listpr(iaux)))
          if ( ((jaux-mod(jaux,10))/10).eq.1 ) then
            nbnpr1 = nbnpr1 + 1
          else
            nbnpr2 = nbnpr2 + 1
            goto 20
          endif
   10   continue
c
c====
c 2. Bilan
c    Si au moins un noeud non P1 est dans le profil, c'est du quelconque
c    Sinon, on trie
c====
c
   20   continue
c
cgn      write(*,*) 'Dans pcsprn, nbnpr1 =', nbnpr1
cgn      write(*,*) 'Dans pcsprn, nbnpr2 =', nbnpr2
cgn      write(*,*) 'Dans pcsprn, numnp1 =', numnp1
      if ( nbnpr2.gt.0 ) then
        typprf = 0
      else
        if ( nbnpr1.eq.numnp1 ) then
          typprf = 1
        elseif ( nbnpr1.lt.numnp1 ) then
          typprf = 2
        else
          typprf = 0
        endif
      endif
cgn      write(*,*) 'Dans pcsprn, typprf =', typprf
c
      end

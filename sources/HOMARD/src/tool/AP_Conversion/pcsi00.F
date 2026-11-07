      subroutine pcsi00 ( nbfop2, profho, vap2ho,
     >                    somare, np2are,
     >                    nbarco, nuaret )
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c    interpolation iso/p2 sur les noeuds - phase 00
c                  -                             --
c    Moyenne des valeurs aux extremites d'un ensmble d'aretes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop2 . e   .    1   . nombre de fonctions P2                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vap2ho . es  . nbfop2*. variables p2 numerotation homard           .
c .        .     . nbnoto .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . nbarco . e   .   1    . nombre d'aretes concernees                 .
c . nuaret . e   . nbarco . numero des aretes a traiter                .
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
#include "fracta.h"
c
c 0.2. ==> communs
c
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(*)
      integer somare(2,nbarto), np2are(nbarto)
      integer nbarco, nuaret(nbarco)
c
      double precision vap2ho(nbfop2,*)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer larete
      integer s1, s2, sm, nuv
c ______________________________________________________________________
c
#include "impr03.h"
c
cgn      write(1,90002) 'Aretes', (nuaret(iaux),iaux=1,nbarco)
c
      do 10 , iaux = 1 , nbarco
c
c====
c 1. L'arete concernee
c====
        larete = nuaret(iaux)
cgn      write(1,90002) 'larete',larete
c
c====
c 2. Interpolation
c====
c
        s1 = somare(1,larete)
        s2 = somare(2,larete)
        sm = np2are(larete)
cgn      write(1,90002) 'sm =',sm
c
        profho(sm) = 1
c
        do 21 , nuv = 1, nbfop2
c
cgn        write(1,90002) 'sommets',s1, s2)
          vap2ho(nuv,sm) = unsde * ( vap2ho(nuv,s1) + vap2ho(nuv,s2) )
cgn          write(1,*) 'vap2ho(nuv,',sm,') =',vap2ho(nuv,sm)
   21   continue
c
   10 continue
c
      end

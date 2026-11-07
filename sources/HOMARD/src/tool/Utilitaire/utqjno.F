      subroutine utqjno ( nbsomm, aresom, consta,
     >                    listar, listso, somare, coonoe,
     >                    qualij )
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
c     UTilitaire : Qualite en Jacobien NOrmalise
c     --           -          -        --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbsomm . e   .   1    . nombre de sommets a considerer             .
c . aresom . e   .   0:3  . connection autour de chaque sommet retenu  .
c .        .     . *nbsomm. 0 : numero du sommet dans listso           .
c .        .     .        . 1, 2, 3 : numeros des 3 aretes dans listar .
c . consta . e   .  1     . constante de normalisation de la qualite   .
c . listar . e   .   *    . Liste des aretes de la maille              .
c . listso . e   .   *    . Liste des sommets de la maille             .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . qualij .  s  .  1     . qualite selon le jacobien normalise        .
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
#include "nombno.h"
#include "nombar.h"
#include "infini.h"
c
c 0.3. ==> arguments
c
      integer nbsomm, aresom(0:3,nbsomm)
      integer listar(*), listso(*)
      integer somare(2,nbarto)
c
      double precision consta
      double precision coonoe(nbnoto,3)
      double precision qualij
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nbnega
      integer sommet
      integer arete1, arete2, arete3
c
      double precision jens
      double precision promix, promin
      double precision jensmi, jensma
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
#include "impr03.h"
c
c====
c 1. Parcours
c====
c
cgn      write(1,90002) 'nbsomm', nbsomm
      nbnega = 0
      jensmi = vinfpo
      jensma = vinfne
c
      do 11 , iaux = 1 , nbsomm
c
c 1.1. ==> sommet et aretes a considerer
c
        sommet = listso(aresom(0,iaux))
        arete1 = listar(aresom(1,iaux))
        arete2 = listar(aresom(2,iaux))
        arete3 = listar(aresom(3,iaux))
c
cgn        write(1,90012) 'aretes du sommet',sommet,arete1,arete2,arete3
c
c 1.2. ==> calcul du produit mixte normalise
c
        call utprma ( sommet, arete1, arete2, arete3,
     >                somare, nbnoto, coonoe,
     >                promix, promin )
c
c 1.3. ==> formule du jacobien pour ce sommet
c
        if ( promin.gt.consta ) then
          jens = 1.d0 + consta - promin
        elseif ( promin.gt.-consta ) then
          jens = promin/consta
        else
          jens = -1.d0 - consta - promin
        endif
cgn        write(1,*) 'promin, jens=', promin, jens
c
c 1.4. ==> tri entre >0 et <0 et memorisation des extremes
c
        jensmi = min(jensmi, jens)
        if ( jens.lt.0.d0 ) then
          jensma = max(jensma,jens)
          nbnega = nbnega + 1
        else
          jensmi = min(jensmi, jens)
        endif
cgn      write(1,*) 'jensmi, jensma, nbnega =', jensmi, jensma, nbnega
c
   11 continue
c
c====
c 2. Bilan
c====
c
      if ( nbnega.eq.nbsomm ) then
        qualij = -jensma
      elseif ( nbnega.gt.0 ) then
        qualij = jensma
      else
        qualij = jensmi
      endif
c
cgn      write(1,90002) 'nbnega', nbnega
cgn      write(1,90004) '==> qualij', qualij
c
      end

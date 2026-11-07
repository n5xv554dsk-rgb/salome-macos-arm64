      subroutine cmdrar ( hetare, filare, np2are, somare,
     >                    decare,
     >                    disare, disnoe, distri, disqua,
     >                    hetnoe, posifa, facare, codret )
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
c    Creation du Maillage - Deraffinement - Regroupement des ARetes
c    -           -          -               -                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetare . e   . nouvar . historique de l'etat des aretes            .
c . filare . e   . nouvar . premiere fille des aretes                  .
c . np2are . e   . nouvar . numero des noeuds p2 milieux d'aretes      .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
c . decare . e   .0:nbarto. table des decisions sur les aretes         .
c . disare . e   . nouvar . indicateurs de disparition des aretes      .
c . disnoe . e   . nouvno . indicateurs de disparition des noeuds      .
c . distri . e   . nouvtr . indicateurs de disparition des triangles   .
c . disqua . e   . nouvqu . indicateurs de disparition des quadrangles .
c . hetnoe . e/s . nouvno . historique de l'etat des noeuds            .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . codret .   s .   1    . code de retour, 0 si ok, (no arete) si pb  .
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
cgn      parameter ( nompro = 'CMRDAR' )
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nombar.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
c     remarque : "disnoe", "disare", "distet" et "distri" sont des
c     tableaux temporaires destines a la suppression ulterieure des
c     entites. par convention, une valeur 0 indique la conservation et
c     une valeur 1 la disparition de l'entite concernee par la liste.
c
      integer hetare(nouvar),   filare(nouvar),   np2are(nouvar)
      integer somare(2,nouvar), decare(0:nbarto), disare(nouvar)
      integer disnoe(nouvno),   hetnoe(nouvno),   codret
      integer distri(nouvtr), disqua(nouvqu)
      integer posifa(0:nbarto), facare(nbfaar)
c
c 0.4. ==> variables locales
c
      integer larete, lafill, noemil, noefil
      integer ideb,   ifin,   facvoi, nbdisp
      integer iaux
c
c 0.5. ==> initialisations
c
      codret = 0
c ______________________________________________________________________
c
c====
c 1. traitement des aretes
c====
c
      do 100 , larete = 1 , nbarpe
c
c 1.1   dans le cas ou l'arete est mere d'active
c
        if ( mod( hetare(larete) , 10 ) .eq. 2 ) then
c
c 1.1.1   dans le cas ou l'arete est marquee "a reactiver"
c
          if ( decare(larete) .eq. -1 ) then
c
c             on verifie que les faces voisines des aretes filles de
c             l'arete consideree sont toutes marquees a disparaitre.
c             pour cela, on comptabilise (en negatif) le nombre de faces
c             voisines des aretes fille marquees a disparaitre. si le
c             total est nul, c'est que toutes les faces doivent bien
c             disparaitre. dans ce cas, et dans ce cas seulement,
c             on pourra marquer les aretes filles comme etant a
c             disparaitre.
c
c             test des faces voisines de la premiere arete fille
c
            lafill = filare(larete)
            ideb = posifa(lafill - 1) + 1
            ifin = posifa(lafill)
c
            nbdisp = ifin - ideb + 1
            do 210 , facvoi = ideb , ifin
              if ( facare(facvoi).gt.0 ) then
                if (distri(facare(facvoi)).eq.1) then
                  nbdisp = nbdisp - 1
                endif
              else
                if (disqua(-facare(facvoi)).eq.1) then
                  nbdisp = nbdisp - 1
                endif
              endif
 210        continue
c
c             test des faces voisines de la seconde arete fille
c
            lafill = filare(larete) + 1
            ideb = posifa(lafill - 1) + 1
            ifin = posifa(lafill)
c
            nbdisp = ifin - ideb + 1 + nbdisp
            do 212 , facvoi = ideb , ifin
              if ( facare(facvoi).gt.0 ) then
                if (distri(facare(facvoi)).eq.1) then
                  nbdisp = nbdisp - 1
                endif
              else
                if (disqua(-facare(facvoi)).eq.1) then
                  nbdisp = nbdisp - 1
                endif
              endif
 212        continue
c
c             verification du nombre de faces marquees a disparaitre
c             (il ne doit pas en rester, qui ne soit pas marquees a
c             disparaitre, pour pouvoir eliminer les aretes filles)
c
            if ( nbdisp .eq. 0 ) then
c
c 1.1.1.1   marquage de ses deux aretes filles "a disparaitre"
c
              lafill = filare(larete)
              disare( lafill )     = 1
              disare( lafill + 1 ) = 1
c
c 1.1.1.2   marquage des noeuds milieux "a disparaitre"
c
              noemil = 0
              noefil = somare(1,lafill)
              if ( ( noefil .eq. somare(1,lafill+1) ).or.
     >             ( noefil .eq. somare(2,lafill+1) ) ) then
                noemil = noefil
              endif
              noefil = somare(2,lafill)
              if ( ( noefil .eq. somare(1,lafill+1) ).or.
     >             ( noefil .eq. somare(2,lafill+1) ) ) then
                noemil = noefil
              endif
c
              if ( noemil .eq. 0 ) then
                codret = larete
              endif
c
              if ( degre .eq. 2 ) then
c
                disnoe(np2are(lafill))     = 1
                disnoe(np2are(lafill + 1)) = 1
c
c             modification de l'etat du noeud p1 milieu en p2 :
c             . son etat anterieur, la dizaine, est conserve
c             . son etat courant passe de 1, P1, a 2, P2
c
                iaux = hetnoe(noemil) - mod(hetnoe(noemil),10)
                hetnoe(noemil) = iaux + 2
c
                if ( noemil .ne. np2are(larete) ) then
                  codret = larete
                endif
c
              else
c
                disnoe(noemil) = 1
c
              endif
c
            endif
c
          endif
c
        endif
c
  100 continue
c
      end

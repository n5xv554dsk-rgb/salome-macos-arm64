      subroutine cmdrtr ( aretri, decfac, hettri, filtri, nintri,
     >                    disnoe, disare, distri, disqua,
     >                    decare, filare,
     >                    np2are, posifa, facare, somare,
     >                    hetnoe, codret )
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
c    Creation du Maillage - Deraffinement - Regroupement des TRiangles
c    -           -          -               -                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . decfac . e   . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hettri . e   . nouvtr . historique de l'etat des triangles         .
c . filtri . e   . nouvtr . premier fils des triangles                 .
c . nintri . e   . nbtrto . noeud interne au triangle                  .
c . disnoe .   s . nouvno . indicateurs de disparition des noeuds      .
c . disare .   s . nouvar . indicateurs de disparition des aretes      .
c . distri .   s . nouvtr . indicateurs de disparition des triangles   .
c . disqua .   s . nouvqu . indicateurs de disparition des quadrangles .
c . decare . e   .0:nbarto. table des decisions sur les aretes         .
c . filare . e   . nouvar . premiere fille des aretes                  .
c . np2are . e   . nouvar . numero des noeuds p2 milieux d'aretes      .
c . posifa . e   .0:nbarto. pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
c . hetnoe . e/s . nouvno . historique de l'etat des noeuds            .
c . codret .   s .   1    . code de retour, 0 si ok                    .
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
cgn      parameter ( nompro = 'CMDRTR' )
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombar.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
c     remarque : "disnoe", "disare", "distri" et "disqua" sont des
c     tableaux temporaires destines a la suppression ulterieure des
c     entites. par convention, une valeur 0 indique la conservation et
c     une valeur 1 la disparition de l'entite concernee par la liste.
c
      integer decfac(-nbquto:nbtrto)
      integer aretri(nouvtr,3), hettri(nouvtr)
      integer filtri(nouvtr), nintri(nbtrto)
      integer disnoe(nouvno), disare(nouvar)
      integer distri(nouvtr), disqua(nouvqu)
      integer decare(0:nbarto), filare(nouvar), np2are(nouvar)
      integer posifa(0:nbarto), facare(nbfaar)
      integer somare(2,nouvar), hetnoe(nouvno)
      integer codret
c
c 0.4. ==> variables locales
c
      integer letria, lefils, fafils
      integer larete, lenoeu, noemil, noefil
      integer ideb,   ifin,   facvoi, nbdisp
      integer iaux
c
      logical noinma
c
c 0.5. ==> initialisations
c
      codret = 0
c ______________________________________________________________________
c
c====
c 1. traitement des faces
c====
c
      if ( mod(mailet,2).eq.0 ) then
        noinma = .true.
      else
        noinma = .false.
      endif
c
      do 100 , letria = 1 , nbtrpe
c
c 1.1. ==> dans le cas ou le triangle est pere d'actif
c
        if ( mod( hettri(letria) , 10 ).eq.4 ) then
c
c 1.1.1. ==> dans le cas ou le triangle est marque "a reactiver"
c
          if ( decfac(letria).eq.-1 ) then
c
c 1.1.1.1. ==> marquage de ses quatre triangles fils "a disparaitre"
c
            lefils = filtri(letria)
c
            do 200 , fafils = lefils , lefils + 3
c
              distri(fafils) = 1
c
  200       continue
c
c 1.1.1.2. ==> marquage des filles de ses trois aretes "a disparaitre"
c              a condition que l'arete reapparaisse.
c
            do 220 , iaux = 1 , 3
c
              larete = aretri(letria,iaux)
c
              if ( decare(larete).eq.-1 ) then
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
              lefils = filare(larete)
              ideb = posifa(lefils - 1) + 1
              ifin = posifa(lefils)
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
 210          continue
c
c             test des faces voisines de la seconde arete fille
c
              lefils = filare(larete) + 1
              ideb = posifa(lefils - 1) + 1
              ifin = posifa(lefils)
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
 212          continue
c
c             verification du nombre de triangles marques a disparaitre
c             (il ne doit pas en rester, qui ne soit pas marques a
c             disparaitre, pour pouvoir eliminer les aretes filles)
c
              if ( nbdisp.eq.0 ) then
c
                lefils = filare(larete)
                disare( lefils )     = 1
                disare( lefils + 1 ) = 1
c
                noemil = 0
                noefil = somare(1,lefils)
                if ( ( noefil.eq.somare(1,lefils+1) ).or.
     >               ( noefil.eq.somare(2,lefils+1) ) ) then
                  noemil = noefil
                endif
                noefil = somare(2,lefils)
                if ( ( noefil.eq.somare(1,lefils+1) ).or.
     >               ( noefil.eq.somare(2,lefils+1) ) ) then
                  noemil = noefil
                endif
                if ( noemil.eq.0 ) then
                  codret = larete
                endif
c
                if ( degre.eq.2 ) then
c
                  if ( noemil .ne. np2are(larete) ) then
                    codret = larete
                  endif
c
                  disnoe(np2are(lefils))     = 1
                  disnoe(np2are(lefils + 1)) = 1
c
c             modification de l'etat du noeud p1 milieu en p2 :
c             . son etat anterieur, la dizaine, est conserve
c             . son etat courant passe a 2, P2
                  hetnoe(noemil) = hetnoe(noemil)
     >                           - mod(hetnoe(noemil),10)
     >                           + 2
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
  220       continue
c
c 1.1.1.3. ==> marquage de ses trois aretes internes "a disparaitre"
c              et des trois eventuels noeuds p2
c
c           remarque : ses trois aretes internes sont celles du triangle
c           fils central, range le premier
c
            lefils = filtri(letria)
c
            do 240 , iaux = 1 , 3
c
              larete = aretri(lefils,iaux)
c
              disare(larete) = 1
c
              if ( degre.eq.2 ) then
                lenoeu = np2are(larete)
                disnoe(lenoeu) = 1
              endif
c
  240       continue
c
c 1.1.1.4. ==> marquage des eventuels noeuds internes "a disparaitre"
c              ce sont ceux des trois fils peripheriques
c
            if ( noinma ) then
c
              do 241 , iaux = 1 , 3
c
                lenoeu = nintri(lefils+iaux)
                disnoe(lenoeu) = 1
c
  241         continue
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

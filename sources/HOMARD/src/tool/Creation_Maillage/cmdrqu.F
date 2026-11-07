      subroutine cmdrqu ( arequa, decfac, hetqua, filqua, ninqua,
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
c    Creation du Maillage - Deraffinement - Regroupement des QUadrangles
c    -           -          -               -                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . decfac . e   . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hetqua . e   . nouvqu . historique de l'etat des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . ninqua . e   . nbquto . noeud interne au quadrangle                .
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
#ifdef _DEBUG_HOMARD_
      character*6 nompro
      parameter ( nompro = 'CMDRQU' )
#endif
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
      integer arequa(nouvqu,4), hetqua(nouvqu)
      integer filqua(nouvqu), ninqua(nbquto)
      integer disnoe(nouvno), disare(nouvar)
      integer distri(nouvtr), disqua(nouvqu)
      integer decare(0:nbarto), filare(nouvar), np2are(nouvar)
      integer posifa(0:nbarto), facare(nbfaar)
      integer somare(2,nouvar), hetnoe(nouvno),   codret
c
c 0.4. ==> variables locales
c
      integer lequad, lefils, fafils, numare
      integer larete, lenoeu, noemil, noefil
      integer ideb,   ifin,   facvoi, nbdisp
c
      logical noinma
c
c 0.5. ==> initialisations
c
      codret = 0
c
#include "impr03.h"
c ______________________________________________________________________
c
#ifdef _DEBUG_HOMARD_
        write (1,*) 'entree de ',nompro
        do 1105 , lequad = 1 , nouvqu
        if ( lequad.eq.1094 .or.
     >(lequad.ge.3341 .and. lequad.le.3344)) then
          write (1,90001) 'quadrangle', lequad,
     >    arequa(lequad,1), arequa(lequad,2),
     >    arequa(lequad,3), arequa(lequad,4)
          write (1,90001) 'quadrangle', lequad,
     >    decare(arequa(lequad,1)), decare(arequa(lequad,2)),
     >    decare(arequa(lequad,3)), decare(arequa(lequad,4))
          write (1,90112) 'decfac', lequad,decfac(-lequad)
      endif
 1105   continue
#endif
c
c====
c 1. traitement des faces
c====
c
      if ( mod(mailet,3).eq.0 ) then
        noinma = .true.
      else
        noinma = .false.
      endif
c
      do 100 , lequad = 1 , nbqupe
c
c 1.1. ==> dans le cas ou le quadrangle est pere d'actif
c
        if ( mod( hetqua(lequad) , 100 ).eq.4 ) then
c
c 1.1.1. ==> dans le cas ou le quadrangle est marque "a reactiver"
c
          if ( decfac(-lequad).eq.-1 ) then
c
c 1.1.1.1. ==> marquage de ses quatre quadrangles fils "a disparaitre"
c
            lefils = filqua(lequad)
c
            do 200 , fafils = lefils , lefils + 3
c
              disqua(fafils) = 1
c
  200       continue
c
c 1.1.1.2. ==> marquage des filles de ses quatre aretes "a disparaitre"
c              a condition que l'arete reapparaisse.
c
            do 220 , numare = 1 , 4
c
              larete = arequa(lequad,numare)
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
c             verification du nombre de quadrangles marques a
c             disparaitre
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
                  if ( noemil.ne.np2are(larete) ) then
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
c 1.1.1.3. ==> marquage des quatre aretes internes
c              les quatre eventuels noeuds p2 sont aussi marques
c
c           remarque : ses quatre aretes internes sont les deuxiemes
c                      dans la definition des faces filles
c
            lefils = filqua(lequad)
c
            do 240 , fafils = lefils , lefils + 3
c
              larete = arequa(fafils,2)
cgn              print 1789,larete, somare(1,larete), somare(2,larete)
cgn 1789 format('Arete ',i10,' de',i10,' a',i10)
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
c              ce sont ceux des fils
c           remarque : le noeud central est le second de chacune de ces
c                      aretes internes
c                      il ne disparait que si on n'est pas en quad9
c
            if ( noinma ) then
c
              do 241 , fafils = lefils , lefils + 3
c
                lenoeu = ninqua(fafils)
                disnoe(lenoeu) = 1
c
  241         continue
c
            else
c
              disnoe(somare(2,arequa(lefils,2))) = 1
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

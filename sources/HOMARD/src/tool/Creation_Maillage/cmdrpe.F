      subroutine cmdrpe ( aretri, decfac,
     >                    facpen, hetpen,
     >                    filpen,
     >                    disare, distri, disqua, dispen,
     >                    disnoe,
     >                    np2are,
     >                    codret )
c
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
c    Creation du Maillage - Deraffinement - Regroupement des Pentaedres
c    -           -          -               -                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . decfac . e   . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . facpen . e   .nouvpf*5. numeros des faces des pentaedres           .
c . hetpen . e   . nouvpe . historique de l'etat des pentaedres        .
c . filpen . e   . nouvpe . premier fils des pentaedres                .
c . disare .   s . nouvar . indicateurs de disparition des aretes      .
c . distri .   s . nouvtr . indicateurs de disparition des triangles   .
c . disqua .   s . nouvqu . indicateurs de disparition des quadrangles .
c . dispen .   s . nouvpe . indicateurs de disparition des pentaedres  .
c . disnoe .   s . nouvno . indicateurs de disparition des aretes      .
c . np2are . e   . nouvar . numero des noeuds p2 milieux d'aretes      .
c . codret . e/s .   1    . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
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
cgn      parameter ( nompro = 'CMDRPE' )
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombpe.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
c     remarque : "disnoe", "disare", "dispen" et "disqua" sont des
c     tableaux temporaires destines a la suppression ulterieure des
c     entites. par convention, une valeur 0 indique la conservation et
c     une valeur 1 la disparition de l'entite concernee par la liste.
c
      integer decfac(-nbquto:nbtrto)
      integer aretri(nouvtr,3)
      integer facpen(nouvpe,5)
      integer hetpen(nouvpe),   filpen(nouvpe),   disare(nouvar)
      integer distri(nouvtr), disqua(nouvqu)
      integer dispen(nouvpe), disnoe(nouvno)
      integer np2are(nouvar)
c
      integer codret
c
c 0.4. ==> variables locales
c
      integer nf3nf4, nf4nf5, nf5nf3
      integer pf3f1, pf3f2, pf4f1, pf4f2, pf5f1, pf5f2
      integer pf1, pf1n7, pf1n8, pf1n9
c
      integer lepent, lefils, leprem
      integer etapen, dt, d1, d2, d3, d4, d5
c
c 0.5. ==> initialisations
c
      codret = 0
c ______________________________________________________________________
c
c====
c 1. traitement des pentaedres
c====
c
      do 100 , lepent = 1 , nbpepe
c
        etapen = mod(hetpen(lepent),100)
c
        if ( etapen.eq.80 ) then
c
c         Le pentaedre est coupe en 8.
c         Il est a reactiver dans 2 cas :
c           . ses 5 faces sont a reactiver : decision -1 pour chacune
c           . 4 faces sont a reactiver : decision -1 pour chacune
c             la derniere reste coupee : decision 0
c         donc des que la somme des decisions est <= -4
c
          d1 = decfac(facpen(lepent,1))
          d2 = decfac(facpen(lepent,2))
          d3 = decfac(-facpen(lepent,3))
          d4 = decfac(-facpen(lepent,4))
          d5 = decfac(-facpen(lepent,5))
          dt = d1 + d2 + d3 + d4 + d5
cgn          print *,'pour penta ',lepent,', dt = ',dt
c
          if ( dt.le.-4 ) then
c
c 1.2.1. ==> marquage de ses huit pentaedres fils "a disparaitre"
c
            leprem = filpen(lepent)
c
            do 210 , lefils = leprem , leprem + 7
c
              dispen(lefils) = 1
c
 210        continue
c
c 1.2.2. ==> marquage de ses six quadrangles internes "a disparaitre"
c
            lefils = leprem + 6
            pf3f1 = facpen(lefils,3)
            disqua(pf3f1) = 1
            pf4f1 = facpen(lefils,4)
            disqua(pf4f1) = 1
            pf5f1 = facpen(lefils,5)
            disqua(pf5f1) = 1
c
            lefils = lefils + 1
            pf3f2 = facpen(lefils,3)
            disqua(pf3f2) = 1
            pf4f2 = facpen(lefils,4)
            disqua(pf4f2) = 1
            pf5f2 = facpen(lefils,5)
            disqua(pf5f2) = 1
c
c 1.2.3. ==> marquage de ses quatre triangles internes "a disparaitre"
c
            lefils = leprem
            pf1n7 = facpen(lefils,2)
            distri(pf1n7) = 1
c
            lefils = leprem + 1
            pf1n8 = facpen(lefils,2)
            distri(pf1n8) = 1
c
            lefils = leprem + 2
            pf1n9 = facpen(lefils,2)
            distri(pf1n9) = 1
c
            lefils = leprem + 6
            pf1 = facpen(lefils,2)
            distri(pf1) = 1
c
c 1.2.4. ==> marquage des trois des aretes internes "a disparaitre"
c
            nf3nf4 = aretri(pf1,1)
            disare(nf3nf4) = 1
            if ( degre.eq.2 ) then
              disnoe(np2are(nf3nf4)) = 1
            endif
c
            nf4nf5 = aretri(pf1,2)
            disare(nf4nf5) = 1
            if ( degre.eq.2 ) then
              disnoe(np2are(nf4nf5)) = 1
            endif
c
            nf5nf3 = aretri(pf1,3)
            disare(nf5nf3) = 1
            if ( degre.eq.2 ) then
              disnoe(np2are(nf5nf3)) = 1
            endif
c
          endif
c
        endif
c
  100 continue
c
      end

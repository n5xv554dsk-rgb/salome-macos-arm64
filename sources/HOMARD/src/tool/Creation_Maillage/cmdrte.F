      subroutine cmdrte ( aretri, decfac, tritet, hettet,
     >                    filtet, disare, distri, distet,
     >                    arenoe, somare, cotrte, disnoe,
     >                    np2are, pertri,
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
c    Creation du Maillage - Deraffinement - Regroupement des TEtraedres
c    -           -          -               -                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . aretri . e   .nouvtr*3. numeros des 3 aretes des triangles         .
c . decfac . e   . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . tritet . e   .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . hettet . e   . nouvte . historique de l'etat des tetraedres        .
c . filtet . e   . nouvte . premier fils des tetraedres                .
c . disare .   s . nouvar . indicateurs de disparition des aretes      .
c . distri .   s . nouvtr . indicateurs de disparition des triangles   .
c . distet .   s . nouvte . indicateurs de disparition des tetraedres  .
c . arenoe . e   . nouvno . arete liee a un nouveau noeud              .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
c . cotrte . e   .nouvtf*4. code des 4 triangles des tetraedres        .
c . disnoe .   s . nouvno . indicateurs de disparition des aretes      .
c . np2are . e   . nouvar . numero des noeuds p2 milieux d'aretes      .
c . pertri . e   . nouvtr . pere des triangles                         .
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
cgn      parameter ( nompro = 'CMDRTE' )
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
c     remarque : "disnoe", "disare", "distet" et "distri" sont des
c     tableaux temporaires destines a la suppression ulterieure des
c     entites. par convention, une valeur 0 indique la conservation et
c     une valeur 1 la disparition de l'entite concernee par la liste.
c
      integer decfac(-nbquto:nbtrto)
      integer aretri(nouvtr,3)
      integer tritet(nouvtf,4)
      integer hettet(nouvte),   filtet(nouvte),   disare(nouvar)
      integer distri(nouvtr),   distet(nouvte),   disnoe(nouvno)
      integer arenoe(nouvno),   somare(2,nouvar), cotrte(nouvtf,4)
      integer np2are(nouvar),   pertri(nouvtr)
c
      integer codret
c
c 0.4. ==> variables locales
c
      integer letria, letetr, lefils, leprem
      integer etatet, dt, ardiag, d1, d2, d3, d4, decoup
      integer numfac
c
c 0.5. ==> initialisations
c
      codret = 0
c ______________________________________________________________________
c
c====
c 1. traitement des tetraedres
c====
c
      do 100 , letetr = 1 , nbtepe
c
        etatet = mod(hettet(letetr),100)
        etatet = ( etatet - mod(etatet,10) ) / 10
c
        if ( etatet.eq.8 ) then
c
c         Le tetraedre est coupe en 8.
c         Il est a reactiver dans 2 cas :
c           . ses 4 faces sont a reactiver : decision -1 pour chacune
c           . 3 faces sont a reactiver : decision -1 pour chacune
c             la derniere reste coupee : decision 0
c         donc des que la somme des decisions est <= -3
c
          d1 = decfac(tritet(letetr,1))
          d2 = decfac(tritet(letetr,2))
          d3 = decfac(tritet(letetr,3))
          d4 = decfac(tritet(letetr,4))
          dt = d1 + d2 + d3 + d4
c
          if ( dt.le.-3 ) then
c
c 1.2.1     marquage de ses huit tetraedres fils "a disparaitre"
c
            leprem = filtet(letetr)
c
            do 210 , lefils = leprem , leprem + 7
c
              distet(lefils) = 1
c
  210       continue
c
c 1.2.2     marquage de ses huit faces internes "a disparaitre"
c           ce sont les faces sans mere des 4 tetraedres internes
c
            leprem = filtet(letetr) + 4
c
            do 220 , lefils = leprem , leprem + 3
              do 222 , numfac = 1 , 4
c
                letria = tritet(lefils,numfac)
                if ( pertri(letria).eq.0 ) then
                  distri(letria) = 1
                endif
c
  222         continue
  220       continue
c
c 1.2.3     recherche de l'arete diagonale interne
c
            call utdiag (letetr,
     >                   filtet, tritet, aretri,
     >                   arenoe, somare, cotrte,
     >                   ardiag, decoup, codret )
c
            if (codret .ne. 0) then
              goto 120
            endif
c
c 1.2.3.3   marquage de l'arete diagonale commune "a disparaitre"
c
            disare(ardiag) = 1
c
            if ( degre.eq.2 ) then
              disnoe(np2are(ardiag)) = 1
            endif
c
          endif
c
        endif
c
  100 continue
c
  120 continue
c
      end

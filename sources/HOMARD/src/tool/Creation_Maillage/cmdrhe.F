      subroutine cmdrhe ( arequa, decfac, quahex, hethex,
     >                    filhex, disare, disqua, dishex,
     >                    somare, disnoe,
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
c    Creation du Maillage - Deraffinement - Regroupement des Hexaedres
c    -           -          -               -                --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . decfac . e   . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . quahex . e   .nouvhf*6. numeros des 6 quadrangles des hexaedres    .
c . hethex . e   . nouvhe . historique de l'etat des hexaedres         .
c . filhex . e   . nouvhe . premier fils des hexaedres                 .
c . disare .   s . nouvar . indicateurs de disparition des aretes      .
c . disqua .   s . nouvqu . indicateurs de disparition des quadrangles .
c . dishex .   s . nouvhe . indicateurs de disparition des hexaedres   .
c . somare . e   .2*nouvar. numeros des extremites d'arete             .
c . disnoe .   s . nouvno . indicateurs de disparition des noeuds      .
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
#ifdef _DEBUG_HOMARD_
      character*6 nompro
      parameter ( nompro = 'CMDRHE' )
#endif
c
c 0.2. ==> communs
c
#include "envca1.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombhe.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
c     remarque : "disnoe", "disare", "dishex" et "disqua" sont des
c     tableaux temporaires destines a la suppression ulterieure des
c     entites. par convention, une valeur 0 indique la conservation et
c     une valeur 1 la disparition de l'entite concernee par la liste.
c
      integer decfac(-nbquto:nbtrto)
      integer arequa(nouvqu,4)
      integer quahex(nouvhf,6)
      integer hethex(nouvhe),   filhex(nouvhe),   disare(nouvar)
      integer disqua(nouvqu),   dishex(nouvhe),   disnoe(nouvno)
      integer somare(2,nouvar)
      integer np2are(nouvar)
c
      integer codret
c
c 0.4. ==> variables locales
c
      integer pf1n5, pf1n6, pf1n7, pf1n8
      integer pf2n2, pf2n3, pf2n10, pf2n11
      integer pf3n1, pf3n4, pf3n9, pf3n12
      integer nf1n0,nf2n0,nf3n0,nf4n0,nf5n0,nf6n0
c
      integer lehexa, lefils, leprem
      integer etahex, dt, d1, d2, d3, d4, d5, d6
c
c 0.5. ==> initialisations
c
#include "impr03.h"
c
      codret = 0
c ______________________________________________________________________
c
c====
c 1. traitement des hexaedres
c====
c
      do 100 , lehexa = 1 , nbhepe
c
        etahex = mod(hethex(lehexa),1000)
c
        if ( etahex.eq.8 ) then
c
c 1.1. ==> verification de l'etat des 6 faces de l'hexaedre
c         attention, cette methode pour verifier l'etat n'est valable
c         que si la seule solution pour obtenir "-6" a partir des
c         decisions sur les faces est d'avoir 6 fois "-1",
c         et idem pour "-5", "-4" ou "-3".
c
          d1 = decfac(-quahex(lehexa,1))
          d2 = decfac(-quahex(lehexa,2))
          d3 = decfac(-quahex(lehexa,3))
          d4 = decfac(-quahex(lehexa,4))
          d5 = decfac(-quahex(lehexa,5))
          d6 = decfac(-quahex(lehexa,6))
          dt = d1 + d2 + d3 + d4 + d5 + d6
c
c 1.2. ==> cas ou les 6 faces du hexaedre sont a reactiver
c
          if ( dt.le.-3 ) then
c
c 1.2.1. ==> marquage de ses huit hexaedres fils "a disparaitre"
c
            leprem = filhex(lehexa)
c
            do 210 , lefils = leprem , leprem + 7
c
              dishex(lefils) = 1
c
 210        continue
c
c 1.2.2. ==> marquage de ses douze faces internes "a disparaitre"
c
            lefils = leprem
            pf1n5=quahex(lefils,6)
            disqua(pf1n5)=1
            pf2n2=quahex(lefils,5)
            disqua(pf2n2)=1
            pf3n1=quahex(lefils,4)
            disqua(pf3n1)=1
c
            lefils=lefils+1
            pf2n3=quahex(lefils,5)
            disqua(pf2n3)=1
            pf1n6=quahex(lefils,6)
            disqua(pf1n6)=1
c
            lefils=lefils+1
            pf3n4=quahex(lefils,3)
            disqua(pf3n4)=1
            pf1n8=quahex(lefils,6)
            disqua(pf1n8)=1
c
            lefils=lefils+1
            pf1n7=quahex(lefils,6)
            disqua(pf1n7)=1
c
            lefils=lefils+1
            pf3n9=quahex(lefils,3)
            disqua(pf3n9)=1
            pf2n11=quahex(lefils,5)
            disqua(pf2n11)=1
c
            lefils=lefils+1
            pf2n10=quahex(lefils,5)
            disqua(pf2n10)=1
c
            lefils=lefils+1
            pf3n12=quahex(lefils,4)
            disqua(pf3n12)=1
c
c 1.2.3. ==> recherche des aretes internes "a disparaitre"
c
            nf1n0=arequa(pf2n2,2)
            disare(nf1n0)=1
            if ( degre.eq.2 ) then
              disnoe(np2are(nf1n0)) = 1
            endif
c
            nf2n0=arequa(pf1n6,2)
            disare(nf2n0)=1
            if ( degre.eq.2 ) then
              disnoe(np2are(nf2n0)) = 1
            endif
c
            nf3n0=arequa(pf1n5,2)
            disare(nf3n0)=1
            if ( degre.eq.2 ) then
              disnoe(np2are(nf3n0)) = 1
            endif
c
            nf4n0=arequa(pf1n8,2)
            disare(nf4n0)=1
            if ( degre.eq.2 ) then
              disnoe(np2are(nf4n0)) = 1
            endif
c
            nf5n0=arequa(pf1n7,2)
            disare(nf5n0)=1
            if ( degre.eq.2 ) then
              disnoe(np2are(nf5n0)) = 1
            endif
c
            nf6n0=arequa(pf3n9,2)
            disare(nf6n0)=1
            if ( degre.eq.2 ) then
              disnoe(np2are(nf6n0)) = 1
            endif
c
c 1.2.4. ==> recherche du point central
c
            disnoe(somare(2,nf1n0)) = 1
c
          endif
c
        endif
c
  100 continue
c
      end

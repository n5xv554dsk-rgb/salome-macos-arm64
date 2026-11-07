      subroutine utsute ( distet,
     >                    hettet, pertet, filtet,
     >                    tritet, cotrte,
     >                    arenoe,
     >                    somare,
     >                    aretri,
     >                    anctet, noutet,
     >                    nbtere,
     >                    codret )
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
c    UTilitaire - SUppression des TEtraedres
c    --           --              --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . distet . e   . nouvte . indicateurs de disparition des tetraedres  .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . es  .nouvtf*4. code des 4 triangles des tetraedres        .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . anctet .   s . nouvte . anciens numeros des tetraedres conserves   .
c . noutet .   s .0:nouvte. nouveaux numeros des tetraedres conserves  .
c . nbtere .   s .   1    . nombre de tetraedres restants              .
c . codret .   s .   1    . code de retour, 0 si ok, (no tetra) si pb  .
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
cgn      parameter ( nompro = 'UTSUTE' )
c
c 0.2. ==> communs
c
#include "nombte.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer distet(nouvte)
      integer hettet(nouvte), pertet(nouvte), filtet(nouvte)
      integer tritet(nouvtf,4), cotrte(nouvtf,4)
      integer arenoe(nouvno)
      integer somare(2,nouvar)
      integer aretri(nouvtr,3)
      integer anctet(nouvte), noutet(0:nouvte)
      integer nbtere
      integer codret
c
c 0.4. ==> variables locales
c
      integer letetr, gdpere, lepere, lefrer
      integer etgper, htfrer, etfrer, ardiag
      integer cmptr,  actifs, decoup
      integer iaux
c
c 0.5. ==> initialisations
c
      codret = 0
c ______________________________________________________________________
c
c====
c 1. fabrication des tableaux anctet et noutet
c====
c
      cmptr = 0
      noutet(0) = 0
c
c 1.1 generation des tableaux reciproques
c
      do 100 , letetr = 1 , nbtepe
c
        if ( distet(letetr).eq.1 ) then
c
          noutet(letetr) = 0
          hettet(letetr) = 100 * int( hettet(letetr)/100 ) + 55
c
        else
c
          cmptr = cmptr + 1
          anctet(cmptr)  = letetr
          noutet(letetr) = cmptr
c
        endif
c
  100 continue
c
c 1.2 nombre d'entites restantes apres suppression
c     (pour la remise a jour du nombre d'entites du maillage)
c
      nbtere = cmptr
c
c====
c 2. modification des etats des peres des tetraedres
c====
c
      do 200 , letetr = 1 , nbtepe
c
        if ( distet(letetr).eq.1 ) then
c
c         mise a zero de l'etat actuel du pere
c
          lepere = pertet(letetr)
          hettet(lepere) = hettet(lepere) - mod(hettet(lepere),100)
c
        endif
c
  200 continue
c
c====
c 3. modification des etats des grand-peres des tetraedres,
c    s'ils existent
c====
c
      do 300 , letetr = 1 , nbtepe
c
        if ( distet(letetr).eq.1 ) then
c
c 3.1     verification de l'etat du grand-pere
c
          lepere = pertet(letetr)
          gdpere = pertet(lepere)
c
          if ( gdpere.ne.0 ) then
c
            iaux = mod(hettet(gdpere),100)
            etgper = (iaux-mod(iaux,10)) / 10
c
            if ( etgper.ne.8 ) then
c
c 3.1.1     verification de l'etat des freres du pere
c
              lefrer = filtet(gdpere)
              actifs = 1
c
              do 310 , htfrer = lefrer , lefrer + 7
c
                etfrer = mod( hettet(htfrer) , 100)
c
                if ( etfrer.ne.0 ) then
                  actifs = 0
                endif
c
  310         continue
c
              if ( actifs.eq.1 ) then
c
c 3.1.2       recherche de la diagonale de decoupe et de l'etat du
c             tetraedre
c
                call utdiag (gdpere,
     >                       filtet, tritet, aretri,
     >                       arenoe, somare, cotrte,
     >                       ardiag, decoup, codret )
c
                if (codret.ne.0) then
                  goto 320
                endif
c
c 3.1.3       attribution de l'etat de l'entite
c
                hettet(gdpere) = hettet(gdpere)
     >                         - mod(hettet(gdpere),100)
     >                         + decoup
c
              endif
c
            endif
c
          endif
c
        endif
c
  300 continue
c
  320 continue
c
      end

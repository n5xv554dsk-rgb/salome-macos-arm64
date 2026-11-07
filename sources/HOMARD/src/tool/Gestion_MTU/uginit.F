      subroutine uginit ( ulsort, langdf, nfconf, lfconf, codret )
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
c but : initialiser une execution
c       au premier passage :
c       - gestionnaire d'unites logiques
c       au second passage :
c       - gestionnaire des mesures de temps de calcul
c       - gestionnaire de memoire
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ulsort . e   .    1   . unite logique d'impression                 .
c . langdf . e   .    1   . langue des messages par defaut             .
c .        .     .        . 1 : francais                               .
c .        .     .        . 2 : anglais                                .
c . nfconf . e   . ch<200 . nom du fichier de configuration            .
c . lfconf . e   .    1   . longueur de ce nom                         .
c . codret .  s  .    1   . 0 : tout va bien                           .
c .        .     .        . 2 : problemes pour la memoire              .
c .        .     .        . 3 : problemes pour les unites logiques     .
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
      character*6 nompro
      parameter ( nompro = 'UGINIT' )
c
#include "gelggt.h"
c
c 0.2. ==> communs
c
c 0.3. ==> arguments
c
      character*(*) nfconf
c
      integer ulsort, langdf, lfconf
      integer codret
c
c 0.4. ==> variables locales
c
      integer tabges(lgtage)
c
      integer guimp, gmimp, raison
      integer enstul, sostul
      integer code, nropas
      integer langlo, messlo
      integer imprgt
c
c 0.5. ==> initialisations
c
      data nropas / 1 /
c
c ______________________________________________________________________
c
      langlo = max(1, langdf )
c
c====
c 1. premier passage
c====
c
      if ( nropas.eq.1 ) then
c
        codret = 0
c
c 1.1. ==> recuperation des numeros des unites standard
c
        call dmunit ( enstul, sostul )
c
c 1.2. ==> archivage du point de depart : aucun gestionnaire n'est
c          encore initialise
c
c     (1): unites logiques (1 : initialise, 0 : non)
c     (2): mesures de temps de calcul (1 : initialise, 0 : non)
c     (3): memoire (1 : initialise, 0 : non)
c     (4): langue (1: francais, 2:anglais)
c
        tabges(1) = 0
        tabges(2) = 0
        tabges(3) = 0
        tabges(4) = langlo
c
        code = 0
        call ugtabl ( code, tabges, sostul )
c
c 1.3. ==> gestion des unites logiques
c
        call guinit ( enstul, sostul, langlo,
     >                nfconf, lfconf, codret )
c
c====
c 2. second passage
c====
c
      elseif ( nropas.eq.2 ) then
c
        codret = 0
c
        if ( ulsort.le.0 ) then
          messlo = sostul
        else
          messlo = ulsort
        endif
c
c 2.1. ==> la langue
c
        code = 1
        call ugtabl ( code, tabges, messlo)
c
        tabges(4) = langlo
c
        code = 0
        call ugtabl ( code, tabges, messlo)
c
c 2.2. ==> redirection des messages de gu
c
        call gumess ( ulsort, codret )
c
c 2.3. ==> mesures de temps de calcul
c
        imprgt = 1
        call gtinit ( messlo, langlo, imprgt )
c
c 2.4. ==> initialisation de la gestion de la memoire
c
        call gminge ( messlo, langlo, nfconf, lfconf )
c
c====
c 3. autre passage : erreur
c====
c
      else
c
        if ( ulsort.le.0 ) then
          messlo = sostul
        else
          messlo = ulsort
        endif
c
        guimp = 1
        gmimp = 1
        raison = 1
        call ugstop ( nompro,messlo,guimp, gmimp, raison)
c
      endif
c
c====
c 4. fin
c====
c
      nropas = nropas + 1
c
      end

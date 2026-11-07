      subroutine utsupe ( dispen,
     >                    hetpen, perpen, filpen,
     >                    ancpen, noupen,
     >                    nbpere )
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
c    UTilitaire - SUppression des PEntaedres
c    --           --              --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . dispen . e   . nouvpe . indicateurs de disparition des pentaedres  .
c . hetpen . es  . nouvpe . historique de l'etat des pentaedres        .
c . perpen . es  . nouvpe . pere des pentaedres                        .
c . filpen . es  . nouvpe . premier fils des pentaedres                .
c . ancpen .   s . nouvpe . anciens numeros des pentaedres conserves   .
c . noupen .   s .0:nouvpe. nouveaux numeros des pentaedres conserves  .
c . nbpere .   s .   1    . nombre de pentaedres restants              .
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
cgn      parameter ( nompro = 'UTSUPE' )
c
c 0.2. ==> communs
c
#include "nombpe.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer dispen(nouvpe)
      integer hetpen(nouvpe), perpen(nouvpe), filpen(nouvpe)
      integer ancpen(nouvpe), noupen(0:nouvpe)
      integer nbpere
c
c 0.4. ==> variables locales
c
      integer lepent, gdpere, lepere, lefrer
      integer etgper, htfrer, etfrer
      integer cmptr,  actifs
      integer iaux
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. fabrication des tableaux ancpen et noupen
c====
c
      cmptr = 0
      noupen(0) = 0
c
c 1.1 generation des tableaux reciproques
c
      do 100 , lepent = 1 , nbpepe
c
        if ( dispen(lepent).eq.1 ) then
c
          noupen(lepent) = 0
          hetpen(lepent) = 100 * int( hetpen(lepent)/100 ) + 55
c
        else
c
          cmptr = cmptr + 1
          ancpen(cmptr)  = lepent
          noupen(lepent) = cmptr
c
        endif
c
  100 continue
c
c 1.2 nombre d'entites restantes apres suppression
c     (pour la remise a jour du nombre d'entites du maillage)
c
      nbpere = cmptr
c
c====
c 2. modification des etats des peres des pentaedres
c====
c
      do 200 , lepent = 1 , nbpepe
c
        if ( dispen(lepent).eq.1 ) then
c
c         mise a zero de l'etat actuel du pere
c
          lepere = perpen(lepent)
          hetpen(lepere) = hetpen(lepere) - mod(hetpen(lepere),100)
c
        endif
c
  200 continue
c
c====
c 3. modification des etats des grand-peres des pentaedres,
c    s'ils existent
c====
c
      do 300 , lepent = 1 , nbpepe
c
        if ( dispen(lepent).eq.1 ) then
c
c 3.1     verification de l'etat du grand-pere
c
          lepere = perpen(lepent)
          gdpere = perpen(lepere)
c
          if ( gdpere.ne.0 ) then
c
            iaux = mod(hetpen(gdpere),100)
            etgper = (iaux-mod(iaux,10)) / 10
c
            if ( etgper.ne.8 ) then
c
c 3.1.1     verification de l'etat des freres du pere
c
              lefrer = filpen(gdpere)
              actifs = 1
c
              do 310 , htfrer = lefrer , lefrer + 7
c
                etfrer = mod( hetpen(htfrer) , 100)
c
                if ( etfrer.ne.0 ) then
                  actifs = 0
                endif
c
  310         continue
c
              if ( actifs.eq.1 ) then
c
c 3.1.3       attribution de l'etat de l'entite
c
                hetpen(gdpere) = hetpen(gdpere)
     >                         - mod(hetpen(gdpere),100)
     >                         + 80
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
      end

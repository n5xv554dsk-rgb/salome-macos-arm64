      subroutine utsuhe ( dishex,
     >                    hethex, perhex, filhex,
     >                    anchex, nouhex,
     >                    nbhere )
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
c    UTilitaire - SUppression des HExaedres
c    --           --              --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . dishex . e   . nouvhe . indicateurs de disparition des hexaedres   .
c . hethex . es  . nouvhe . historique de l'etat des hexaedres         .
c . perhex . es  . nouvhe . pere des hexaedres                         .
c . filhex . es  . nouvhe . premier fils des hexaedres                 .
c . anchex .   s . nouvhe . anciens numeros des hexaedres conserves    .
c . nouhex .   s .0:nouvhe. nouveaux numeros des hexaedres conserves   .
c . nbhere .   s .   1    . nombre de hexaedres restants               .
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
cgn      parameter ( nompro = 'UTSUHE' )
c
c 0.2. ==> communs
c
#include "nombhe.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer dishex(nouvhe)
      integer hethex(nouvhe), perhex(nouvhe), filhex(nouvhe)
      integer anchex(nouvhe), nouhex(0:nouvhe)
      integer nbhere
c
c 0.4. ==> variables locales
c
      integer lehexa, gdpere, lepere, lefrer
      integer etgper, htfrer, etfrer
      integer cmptr,  actifs
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. fabrication des tableaux anchex et nouhex
c====
c
      cmptr = 0
      nouhex(0) = 0
c
c 1.1 generation des tableaux reciproques
c
      do 100 , lehexa = 1 , nbhepe
c
        if ( dishex(lehexa).eq.1 ) then
c
          nouhex(lehexa) = 0
          hethex(lehexa) = 1000 * int( hethex(lehexa)/1000 ) + 5
c
        else
c
          cmptr = cmptr + 1
          anchex(cmptr)  = lehexa
          nouhex(lehexa) = cmptr
c
        endif
c
  100 continue
c
c 1.2 nombre d'entites restantes apres suppression
c     (pour la remise a jour du nombre d'entites du maillage)
c
      nbhere = cmptr
c
c====
c 2. modification des etats des peres des hexaedres
c    remarque : on le fait 8 fois de suite mais tant pis !
c====
c
      do 200 , lehexa = 1 , nbhepe
c
        if ( dishex(lehexa).eq.1 ) then
c
c         mise a zero de l'etat actuel du pere
c
          lepere = perhex(lehexa)
          hethex(lepere) = hethex(lepere) - mod(hethex(lepere),1000)
c
        endif
c
  200 continue
c
c====
c 3. modification des etats des grand-peres des hexaedres,
c    s'ils existent
c====
c
      do 300 , lehexa = 1 , nbhepe
c
        if ( dishex(lehexa).eq.1 ) then
c
c 3.1     verification de l'etat du grand-pere
c
          lepere = perhex(lehexa)
          gdpere = perhex(lepere)
c
          if ( gdpere.ne.0 ) then
c
            etgper = mod(hethex(gdpere),1000)
c
            if ( etgper.ne.8 ) then
c
c 3.1.1     verification de l'etat des freres du pere
c
              lefrer = filhex(gdpere)
              actifs = 1
c
              do 310 , htfrer = lefrer , lefrer + 7
c
                etfrer = mod(hethex(htfrer),1000)
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
                hethex(gdpere) = hethex(gdpere) - etgper + 8
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

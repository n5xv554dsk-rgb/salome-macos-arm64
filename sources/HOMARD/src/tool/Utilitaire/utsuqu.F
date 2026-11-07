      subroutine utsuqu ( disqua,
     >                    hetqua, perqua, filqua,
     >                    ancqua, nouqua,
     >                    nbqure )
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
c    UTilitaire - SUppression des QUadrangles
c    --           --              --
c ______________________________________________________________________
c
c   Attention : tous les quadrangles n'ont pas forcement un pere !
c               en effet ceux crees en interne a des volumes
c               sont de la premiere generation, meme s'ils
c               sont a des niveaux > 1
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . disqua . e   . nouvqu . indicateurs de disparition des quadrangles .
c . hetqua . es  . nouvqu . historique de l'etat des quadrangles       .
c . perqua . es  . nouvqu . pere des quadrangles                       .
c . filqua . es  . nouvqu . premier fils des quadrangles               .
c . ancqua .   s . nouvqu . anciens numeros des quadrangles conserves  .
c . nouqua .   s .0:nouvqu. nouveaux numeros des quadrangles conserves .
c . nbqure .   s .   1    . nombre de quadrangles restants             .
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
cgn      parameter ( nompro = 'UTSUQU' )
c
c 0.2. ==> communs
c
#include "nombqu.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer disqua(nouvqu)
      integer hetqua(nouvqu), perqua(nouvqu), filqua(nouvqu)
      integer ancqua(nouvqu), nouqua(0:nouvqu)
      integer nbqure
c
c 0.4. ==> variables locales
c
      integer lequad, lepere, gdpere, etgper, lefrer
      integer cmptr, e1, e2, e3, e4, et
c ______________________________________________________________________
c
c====
c 1. fabrication des tableaux ancqua et nouqua
c====
c
      cmptr = 0
      nouqua(0) = 0
c
c 1.1 generation des tableaux reciproques
c
      do 100 , lequad = 1 , nbqupe
c
        if ( disqua(lequad).ne.0 ) then
c
          nouqua(lequad) = 0
          hetqua(lequad) = 100 * int( hetqua(lequad) / 100 ) + 55
c
        else
c
          cmptr = cmptr + 1
          ancqua(cmptr)  = lequad
          nouqua(lequad) = cmptr
c
        endif
c
  100 continue
c
c 1.2 nombre d'entites restantes apres suppression
c     (pour la remise a jour du nombre d'entites du maillage)
c
      nbqure = cmptr
c
c====
c 2. modification des etats des peres eventuels des quadrangles disparus
c    Remarque : si on est parti d'un macro-maillage non conforme,
c               certains quadrangles ont des peres adoptifs de numero
c               negatif. Il ne faut pas changer leur etat
c====
c
      do 200 , lequad = 1 , nbqupe
c
        if ( disqua(lequad).ne.0 ) then
c
c         mise a zero de l'etat actuel du pere eventuel
c
          lepere = perqua(lequad)
          if ( lepere.gt.0 ) then
            hetqua(lepere) = hetqua(lepere) - mod(hetqua(lepere),100)
          endif
c
        endif
c
  200 continue
c
c====
c 3. modification des etats des eventuels grand-peres des quadrangles
c    Remarque : si on est parti d'un macro-maillage non conforme,
c               certains quadrangles ont des peres adoptifs de numero
c               negatif. Il ne faut pas changer leur etat
c====
c
      do 300 , lequad = 1 , nbqupe
c
        if ( disqua(lequad).ne.0 ) then
c
          lepere = perqua(lequad)
c
          if ( lepere.gt.0 ) then
c
            gdpere = perqua(lepere)
c
            if ( gdpere.gt.0 ) then
c
c 3.1     verification de l'etat du grand-pere
c
              etgper = mod( hetqua(gdpere) , 100 )
c
              if ( etgper.ne.4 ) then
c
c 3.1.1     verification de l'etat des freres du pere
c
                lefrer = filqua(gdpere)
                e1 = mod( hetqua(lefrer) , 100 )
                e2 = mod( hetqua(lefrer+1) , 100 )
                e3 = mod( hetqua(lefrer+2) , 100 )
                e4 = mod( hetqua(lefrer+3) , 100 )
                et = e1 + e2 + e3 + e4
c
c 3.1.2     attribution de l'etat 'coupee en 4' a l'entite
c
                if ( et.eq.0 ) then
                  hetqua(gdpere) = hetqua(gdpere)
     >                           - mod(hetqua(gdpere),100)
     >                           + 4
                endif
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

      subroutine utsutr ( distri,
     >                    hettri, pertri, filtri,
     >                    anctri, noutri,
     >                    nbtrre )
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
c    UTilitaire - SUppression des TRiangles
c    --           --              --
c ______________________________________________________________________
c
c   Attention : tous les triangles n'ont pas forcement un pere !
c               en effet ceux crees en interne a des tetraedres
c               sont de la premiere generation, meme s'ils
c               sont a des niveaux > 1
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . distri . e   . nouvtr . indicateurs de disparition des triangles   .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . pertri . es  . nouvtr . pere des triangles                         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . anctri .   s . nouvtr . anciens numeros des triangles conserves    .
c . noutri .   s .0:nouvtr. nouveaux numeros des triangles conserves   .
c . nbtrre .   s .   1    . nombre de triangles restants               .
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
cgn      parameter ( nompro = 'UTSUTR' )
c
c 0.2. ==> communs
c
#include "nombtr.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer distri(nouvtr)
      integer hettri(nouvtr), pertri(nouvtr), filtri(nouvtr)
      integer anctri(nouvtr), noutri(0:nouvtr)
      integer nbtrre
c
c 0.4. ==> variables locales
c
      integer letria, lepere, gdpere, etgper, lefrer
      integer cmptr, e1, e2, e3, e4, et
c ______________________________________________________________________
c
c====
c 1. fabrication des tableaux anctri et noutri
c====
c
      cmptr = 0
      noutri(0) = 0
c
c 1.1 ==> generation des tableaux reciproques
c
      do 100 , letria = 1 , nbtrto
c
        if ( distri(letria).ne.0 ) then
c
          noutri(letria) = 0
          hettri(letria) = 10 * int( hettri(letria) / 10 ) + 5
c
        else
c
          cmptr = cmptr + 1
          anctri(cmptr)  = letria
          noutri(letria) = cmptr
c
        endif
c
  100 continue
c
c 1.2 ==> nombre d'entites restantes apres suppression
c     (pour la remise a jour du nombre d'entites du maillage)
c
      nbtrre = cmptr
c
c====
c 2. mise a zero de l'etat actuel des peres eventuels des triangles
c    disparus
c Remarque : si on est parti d'un macro-maillage non conforme,
c            certains triangles ont des peres adoptifs de numero
c            negatif. Il ne faut pas changer leur etat
c            Le cas des peres negatif parce que quadrangle de conformite
c            n'existe plus a ce stade : ces triangles ont ete detruits
c            en amont
c====
c
      do 200 , letria = 1 , nbtrpe
c
        if ( distri(letria).ne.0 ) then
c
          lepere = pertri(letria)
          if ( lepere.gt.0 ) then
            hettri(lepere) = hettri(lepere) - mod(hettri(lepere),10)
          endif
c
        endif
c
  200 continue
c
c====
c 3. modification des etats des eventuels grand-peres des triangles
c Remarque : si on est parti d'un macro-maillage non conforme,
c            certains triangles ont des peres adoptifs de numero
c            negatif. Il ne faut pas changer leur etat
c            Le cas des peres negatif parce que quadrangle de conformite
c            n'existe plus a ce stade : ces triangles ont ete detruits
c            en amont
c====
c
      do 300 , letria = 1 , nbtrpe
c
        if ( distri(letria).ne.0 ) then
c
          lepere = pertri(letria)
c
          if ( lepere.gt.0 ) then
c
            gdpere = pertri(lepere)
c
            if ( gdpere.gt.0 ) then
c
c 3.1     verification de l'etat du grand-pere
c
              etgper = mod( hettri(gdpere) , 10 )
c
              if ( etgper.ne.4 ) then
c
c 3.1.1     verification de l'etat des freres du pere
c
                lefrer = filtri(gdpere)
                e1 = mod( hettri(lefrer)   , 10 )
                e2 = mod( hettri(lefrer+1) , 10 )
                e3 = mod( hettri(lefrer+2) , 10 )
                e4 = mod( hettri(lefrer+3) , 10 )
                et = e1 + e2 + e3 + e4
c
c 3.1.2     attribution de l'etat 'coupee en 4' a l'entite
c
                if ( et .eq. 0 ) then
                  hettri(gdpere) = hettri(gdpere)
     >                           - mod(hettri(gdpere),10)
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

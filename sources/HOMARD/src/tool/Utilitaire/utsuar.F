      subroutine utsuar ( disare,
     >                    hetare, merare, filare,
     >                    ancare, nouare,
     >                    nbarre )
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
c    UTilitaire - SUppression des ARetes
c    --           --              --
c ______________________________________________________________________
c
c   Attention : toutes les aretes n'ont pas forcement une mere !
c               celles crees en interne a des tetraedres/triangles
c               sont de la premiere generation, meme si elles
c               sont a des niveaux > 1
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . disare . e   . nouvar . indicateurs de disparition des aretes      .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . merare . es  . nouvar . mere des aretes                            .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . ancare .   s . nouvar . anciens numeros des aretes conservees      .
c . nouare .   s .0:nouvar. nouveaux numeros des aretes conservees     .
c . nbarre .   s .   1    . nombre d'aretes restantes                  .
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
cgn      parameter ( nompro = 'UTSUAR' )
c
c 0.2. ==> communs
c
#include "nombar.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer hetare(nouvar), merare(nouvar), filare(nouvar)
      integer disare(nouvar), ancare(nouvar)
      integer nouare(0:nouvar)
      integer nbarre
c
c 0.4. ==> variables locales
c
      integer larete, lamere, gdmere, etgmer
      integer cmptr, e1, e2, et
c ______________________________________________________________________
c
c====
c 1. fabrication des tableaux ancare et nouare
c====
c
      cmptr = 0
      nouare(0) = 0
c
c 1.1 generation des tableaux reciproques
c
      do 100 , larete = 1 , nbarpe
c
        if ( disare(larete).ne.0 ) then
c
          nouare(larete) = 0
          hetare(larete) = 10 * int( hetare(larete) / 10 ) + 5
c
        else
c
          cmptr = cmptr + 1
          ancare(cmptr)  = larete
          nouare(larete) = cmptr
c
        endif
c
  100 continue
c
c 1.2 nombre d'entites restantes apres suppression
c     (pour la remise a jour du nombre d'entites du maillage)
c
      nbarre = cmptr
c
c====
c 2. modification des etats des meres eventuelles des aretes disparues
c====
c
      do 200 , larete = 1 , nbarpe
c
        if ( disare(larete).ne.0 ) then
c
c         mise a zero de l'etat actuel de la mere
c
          lamere = merare(larete)
c
          if ( lamere.ne.0 ) then
            hetare(lamere) = hetare(lamere) - mod(hetare(lamere),10)
          endif
c
        endif
c
  200 continue
c
c====
c 3. modification des etats des eventuelles grand-meres des aretes
c====
c
      do 300 , larete = 1 , nbarpe
c
        if ( disare(larete).ne.0 ) then
c
          lamere = merare(larete)
c
          if ( lamere.ne.0 ) then
c
            gdmere = merare(lamere)
c
            if ( gdmere.ne.0 ) then
c
c 3.1     verification de l'etat de la grand-mere
c
              etgmer = mod( hetare(gdmere) , 10 )
c
              if ( etgmer.ne.2 ) then
c
c 3.1.1     verification de l'etat des soeurs de la mere
c
                e1 = mod( hetare(filare(gdmere))   , 10 )
                e2 = mod( hetare(filare(gdmere)+1) , 10 )
                et = e1 + e2
c
c 3.1.2       attribution de l'etat 'coupee en 2' a l'entite
c
                if ( et .eq. 0 ) then
                  hetare(gdmere) = hetare(gdmere)
     >                           - mod(hetare(gdmere),10)
     >                           + 2
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

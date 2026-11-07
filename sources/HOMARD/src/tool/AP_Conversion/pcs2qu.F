      subroutine pcs2qu ( nbfop2, profho, vap2ho,
     >                    hetqua, arequa, filqua,
     >                    somare, np2are,
     >                    aretri )
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
c    aPres adaptation - Conversion de Solution -
c     -                 -             -
c    interpolation p2 sur les noeuds - decoupage des QUadrangles
c                   -                                --
c remarque : on devrait optimiser cela car si le quadrangle etait dans
c            un etat de decoupage similaire, on recalcule une valeur
c            qui est deja presente
c remarque : pcs2qu et pcsiqu sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfop2 . e   .    1   . nombre de fonctions P2                     .
c . profho . es  .   *    . pour chaque entite en numerotation homard :.
c .        .     .        . 0 : l'entite est absente du profil         .
c .        .     .        . 1 : l'entite est presente dans le profil   .
c . vap2ho . es  . nbfop2*. variables p2 numerotation homard           .
c .        .     . nbnoto .                                            .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
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
#include "fracta.h"
#include "fractc.h"
#include "fractf.h"
#include "fractg.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer nbfop2
      integer profho(nbnoto)
      integer hetqua(nbquto), arequa(nbquto,4), filqua(nbquto)
      integer somare(2,nbarto), np2are(nbarto)
      integer aretri(nbtrto,3)
c
      double precision vap2ho(nbfop2,*)
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lequad
      integer typdec, etanp1
      integer iaux1, iaux2, iaux3, iaux4
      integer jaux1,        jaux3, jaux4
      integer m1, m2, m3, m4
      integer sm, nuv
c
      integer listar(4), listno(8)
c
c     f1hp = Fils 1er du quadrangle en numerotation Homard a l'it. N+1
      integer f1hp
c
      logical afaire
c
      double precision daux
c
c 0.5. ==> initialisations
c ______________________________________________________________________
cgn       write (*,*) 'PCS2QU'
c
      do 10 , lequad = 1, nbquto
c
c====
c 1. interpolation p2 pour un quadrangle qui vient d'etre decoupe :
c    on a une valeur a mettre sur l'eventuel noeud central et les
c    milieux des aretes internes
c====
c
        iaux = lequad
        call pcs0qu ( iaux, profho,
     >                hetqua, arequa,
     >                somare, np2are,
     >                afaire, listar, listno, typdec, etanp1 )
c
        if ( afaire ) then
cgn        write(1,*) 'typdec, etanp1 =', typdec, etanp1
c
c====
c 2. La valeur sur le noeud au centre du quadrangle
c    . Soit le quadrangle vient d'etre decoupe en 4 quadrangles alors
c      qu'il ne l'etait pas a l'iteration precedente
c    . Soit le quadrangle vient d'etre decoupe en 3 quadrangles
c    . Soit le quadrangle vient d'etre decoupe en 2 quadrangles
c    Remarque : regarder cmcdqu pour les conventions
c====
c
          if ( typdec.eq.4 .or.
     >         typdec.eq.21 .or. typdec.eq.22 .or.
     >         ( typdec.ge.41 .and. typdec.le.44 ) ) then
c
            f1hp = filqua(lequad)
c
c 2.1. ==> la valeur sur le noeud au centre du quadrangle
c
            if ( typdec.eq.4 ) then
              sm = somare(2,arequa(f1hp,2))
            elseif ( typdec.eq.21 .or. typdec.eq.22 ) then
              sm = np2are(arequa(f1hp,4))
            else
              sm = somare(2,arequa(f1hp,3))
            endif
            profho(sm) = 1
cgn        write(1,*) 'f1hp =', f1hp
            if ( typdec.ne.4 ) then
cgn        write(1,*) 'sm =', sm
            endif
c
c         interpolation = -1/4 (u1+u2+u3+u4) + 1/2 (u5+u6+u7+u8)
c
 1789 format( 4g13.5)
            do 21, nuv = 1, nbfop2
cgn        write(1,1789) vap2ho(nuv,listno(1))
cgn     >                                   , vap2ho(nuv,listno(2))
cgn     >                                   , vap2ho(nuv,listno(3))
cgn     >                                   , vap2ho(nuv,listno(4))
cgn        write(1,1789) vap2ho(nuv,listno(5))
cgn     >                                   , vap2ho(nuv,listno(6))
cgn     >                                   , vap2ho(nuv,listno(7))
cgn     >                                   , vap2ho(nuv,listno(8))
c
              vap2ho(nuv,sm) = - unsqu * ( vap2ho(nuv,listno(1))
     >                                   + vap2ho(nuv,listno(2))
     >                                   + vap2ho(nuv,listno(3))
     >                                   + vap2ho(nuv,listno(4)) )
     >                         + unsde * ( vap2ho(nuv,listno(5))
     >                                   + vap2ho(nuv,listno(6))
     >                                   + vap2ho(nuv,listno(7))
     >                                   + vap2ho(nuv,listno(8)) )
            if ( typdec.ne.4 ) then
cgn        write(1,1789) vap2ho(nuv,sm)
            endif
c
   21       continue
c
          endif
c
c====
c 3. Les valeurs sur les noeuds au milieu des aretes tracees a
c    l'interieur du quadrangle
c====
c 3.1. ==> Le quadrangle vient d'etre decoupe en 4 quadrangles alors
c          qu'il ne l'etait pas a l'iteration precedente
c          Remarque : regarder cmrdqu pour les conventions
c
          if ( typdec.eq.4 ) then
c
            f1hp = filqua(lequad)
c
c            Par convention, la deuxieme arete du i-eme fils va du
c            noeud ni, milieu de l'arete ai du quadrangle pere, vers
c            le noeud central.
c
            m1 = np2are(arequa(f1hp,2))
            m2 = np2are(arequa(f1hp+1,2))
            m3 = np2are(arequa(f1hp+2,2))
            m4 = np2are(arequa(f1hp+3,2))
            profho(m1) = 1
            profho(m2) = 1
            profho(m3) = 1
            profho(m4) = 1
c
c         interpolation = -3/16 (u1+u2+u3+u4)
c                        + 3/4 u5 +3/8 (u6+u8) + 1/4 u7
c         avec u5 pour le noeud le plus proche, u6 et u8 pour ceux qui
c         'encadrent' et u7 pour le noeud 'oppose'
c
            do 31, nuv = 1, nbfop2
c
              daux = - trssz * ( vap2ho(nuv,listno(1))
     >                         + vap2ho(nuv,listno(2))
     >                         + vap2ho(nuv,listno(3))
     >                         + vap2ho(nuv,listno(4)) )
c
              vap2ho(nuv,m1) = daux
     >        + trsqu * vap2ho(nuv,listno(5))
     >        + trshu * ( vap2ho(nuv,listno(6)) + vap2ho(nuv,listno(8)))
     >        + unsqu *  vap2ho(nuv,listno(7))
c
              vap2ho(nuv,m2) = daux
     >        + trsqu * vap2ho(nuv,listno(6))
     >        + trshu * ( vap2ho(nuv,listno(7)) + vap2ho(nuv,listno(5)))
     >        + unsqu *  vap2ho(nuv,listno(8))
c
              vap2ho(nuv,m3) = daux
     >        + trsqu * vap2ho(nuv,listno(7))
     >        + trshu * ( vap2ho(nuv,listno(8)) + vap2ho(nuv,listno(6)))
     >        + unsqu *  vap2ho(nuv,listno(5))
c
              vap2ho(nuv,m4) = daux
     >        + trsqu * vap2ho(nuv,listno(8))
     >        + trshu * ( vap2ho(nuv,listno(5)) + vap2ho(nuv,listno(7)))
     >        + unsqu *  vap2ho(nuv,listno(6))
c
   31       continue
c
c 3.2. ==> Le quadrangle vient d'etre decoupe en 3 triangles
c          on doit creer les valeurs sur les noeuds au milieu des
c          aretes tracees
c          Remarque : regarder cmcdqu pour les conventions
c
          elseif ( typdec.ge.31 .and. typdec.le.34 ) then
c
            f1hp = - filqua(lequad)
c
c            Par convention :
c            . la premiere arete du 1-er fils va du noeud ni, milieu de
c              l'arete ai du quadrangle pere, vers le sommet commun
c              aux aretes i+1 et i+2.
c            . la troisieme arete du 1-er fils va du noeud ni, milieu de
c              l'arete ai du quadrangle pere, vers le sommet commun
c              aux aretes i+2 et i+3.
c
c         interpolation :
c         interpolee (ui,i=1,8) = -3/16 (u1+u2+u3+u4)
c                                + 3/4 u5 +3/8 (u6+u8) + 1/4 u7
c         avec u5 pour le noeud le plus proche, u6 et u8 pour ceux qui
c         'encadrent' et u7 pour le noeud 'oppose'
c
            if ( typdec.eq.31 ) then
              iaux1 = listno(5)
              iaux2 = listno(6)
              iaux3 = listno(7)
              iaux4 = listno(8)
            elseif ( typdec.eq.32 ) then
              iaux1 = listno(6)
              iaux2 = listno(7)
              iaux3 = listno(8)
              iaux4 = listno(5)
            elseif ( typdec.eq.33 ) then
              iaux1 = listno(7)
              iaux2 = listno(8)
              iaux3 = listno(5)
              iaux4 = listno(6)
            else
              iaux1 = listno(8)
              iaux2 = listno(5)
              iaux3 = listno(6)
              iaux4 = listno(7)
            endif
c
            m1 = np2are(aretri(f1hp,1))
            m2 = np2are(aretri(f1hp,3))
            profho(m1) = 1
            profho(m2) = 1
cgn        write(1,*) 'm1 =', m1, ', m2 =', m2
c
            do 32 , nuv = 1, nbfop2
c
              daux = - trssz * ( vap2ho(nuv,listno(1))
     >                         + vap2ho(nuv,listno(2))
     >                         + vap2ho(nuv,listno(3))
     >                         + vap2ho(nuv,listno(4)) )
     >               + trshu * ( vap2ho(nuv,iaux1) + vap2ho(nuv,iaux3) )
c
              vap2ho(nuv,m1) = daux + trsqu * vap2ho(nuv,iaux2)
     >                       + unsqu * vap2ho(nuv,iaux4)
c
              vap2ho(nuv,m2) = daux + trsqu * vap2ho(nuv,iaux4)
     >                       + unsqu * vap2ho(nuv,iaux2)
cgn        write(1,1789) vap2ho(nuv,m1), vap2ho(nuv,m2)
c
   32       continue
c
c 3.3. ==> Le quadrangle vient d'etre decoupe en 3 quadrangles
c          on doit creer les valeurs sur les noeuds au milieu des
c          aretes tracees
c          Remarque : regarder cmcdqu pour les conventions
c
          elseif ( typdec.ge.41 .and. typdec.le.44 ) then
c
            f1hp = filqua(lequad)
c
c         pour les noeuds milieux des aretes entre le noeud central
c         et des milieux d'aretes du quadrangle pere :
c         interpolation = -3/16 (u1+u2+u3+u4)
c                        + 3/4 u5 + 3/8 (u6+u8) + 1/4 u7
c         avec u5 pour le noeud le plus proche, u6 et u8 pour ceux qui
c         'encadrent' et u7 pour le noeud 'oppose'
c
c         pour le noeud milieux de l'arete entre le noeud central
c         et un sommet du quadrangle pere :
c         interpolation = -3/16 (u1+u3) - 1/8 u4
c                        + 9/16 (u5+u6) + 3/16 (u7+u8)
c         avec u1 et u3 pour les sommets qui 'encadrent', u2 pour le
c         sommet le plus proche, u4 pour le sommet le plus loin,
c         u5 et u6 pour les noeuds qui 'encadrent'
c         et u7 et u8 pour les noeuds 'opposes'
c
            if ( typdec.eq.41 ) then
              jaux1 = listno(2)
              jaux3 = listno(4)
              jaux4 = listno(1)
              iaux1 = listno(5)
              iaux2 = listno(6)
              iaux3 = listno(7)
              iaux4 = listno(8)
            elseif ( typdec.eq.42 ) then
              jaux1 = listno(3)
              jaux3 = listno(1)
              jaux4 = listno(2)
              iaux1 = listno(6)
              iaux2 = listno(7)
              iaux3 = listno(8)
              iaux4 = listno(5)
            elseif ( typdec.eq.43 ) then
              jaux1 = listno(4)
              jaux3 = listno(2)
              jaux4 = listno(3)
              iaux1 = listno(7)
              iaux2 = listno(8)
              iaux3 = listno(5)
              iaux4 = listno(6)
            else
              jaux1 = listno(1)
              jaux3 = listno(3)
              jaux4 = listno(4)
              iaux1 = listno(8)
              iaux2 = listno(5)
              iaux3 = listno(6)
              iaux4 = listno(7)
            endif
c
            m1 = np2are(arequa(f1hp,4))
            m2 = np2are(arequa(f1hp,3))
            m3 = np2are(arequa(f1hp+1,3))
            profho(m1) = 1
            profho(m2) = 1
            profho(m3) = 1
cgn        write(1,*) 'm1 =', m1, ', m2 =', m2, ', m3 =', m3
cgn        write(1,*) 'listno =', listno
c
            do 33 , nuv = 1, nbfop2
c
              daux = - trssz * ( vap2ho(nuv,listno(1))
     >                         + vap2ho(nuv,listno(2))
     >                         + vap2ho(nuv,listno(3))
     >                         + vap2ho(nuv,listno(4)) )
c
              vap2ho(nuv,m1) = daux
     >               + trsqu * vap2ho(nuv,iaux1)
     >               + trshu * ( vap2ho(nuv,iaux2) + vap2ho(nuv,iaux4) )
     >               + unsqu * vap2ho(nuv,iaux3)
c
              vap2ho(nuv,m2) = daux
     >               + trsqu * vap2ho(nuv,iaux2)
     >               + trshu * ( vap2ho(nuv,iaux3) + vap2ho(nuv,iaux1) )
     >               + unsqu * vap2ho(nuv,iaux4)
c
              vap2ho(nuv,m3) =
     >               - trssz * ( vap2ho(nuv,jaux1)
     >               +           vap2ho(nuv,jaux3) )
     >               - unshu * vap2ho(nuv,jaux4)
     >               + nessz * ( vap2ho(nuv,iaux3) + vap2ho(nuv,iaux4) )
     >               + trssz * ( vap2ho(nuv,iaux1) + vap2ho(nuv,iaux2) )
cgn        write(1,1789) vap2ho(nuv,m1), vap2ho(nuv,m2),  vap2ho(nuv,m3)
c
   33       continue
c
          endif
c
        endif
c
   10 continue
c
      end

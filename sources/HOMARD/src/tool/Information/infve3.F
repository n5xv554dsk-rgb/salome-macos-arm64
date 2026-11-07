      subroutine infve3 ( coonoe,
     >                    anglex, angley, anglez,
     >                    zoom, triedr, xyzmiz, xyzmaz,
     >                    coopro,
     >                    ulsort, langue, codret )
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
c   INformation : Fichiers VEctoriel - 3eme partie
c   --            -        --          -
c ______________________________________________________________________
c
c but : calcul des coordonnees projetees selon les angles demandes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . anglex . e   .   1    . angle de rotation autour de x              .
c . angley . e   .   1    . angle de rotation autour de y              .
c . anglez . e   .   1    . angle de rotation autour de z              .
c . zoom   . e   .   1    . vrai ou faux selon zoom ou non             .
c . triedr . e   .   1    . 0 : pas de trace du triedre                .
c .        .     .        . 1 : trace du triedre                       .
c . xyzmiz . e   .   1    . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) minimales de la fenetre de zoom .
c . xyzmaz . e   .   1    . abscisse (i=1), ordonnee (i=2) et          .
c .        .     .        . cote (i=3) maximales de la fenetre de zoom .
c . coopro .   s .    3*  . coordonnees projetees de :                 .
c .        .     .nbnot+12. le triedre : -8:O ; -9:I ; -10:J ; -11:K   .
c .        .     .        . la fenetre de zoom : de -7 a 0 en 3D ou    .
c .        .     .        .                      de -3 a 0 en 2D       .
c .        .     .        . les noeuds de 1 a nbnoto                   .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
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
      character*6 nompro
      parameter ( nompro = 'INFVE3' )
c
#include "nblang.h"
c
#include "consta.h"
#include "fracta.h"
c
c 0.2. ==> communs
c
#include "nombno.h"
#include "envca1.h"
#include "precis.h"
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer triedr
c
      double precision anglex, angley, anglez
      double precision coonoe(nbnoto,sdim)
      double precision coopro(3,-11:nbnoto)
      double precision xyzmiz(sdim), xyzmaz(sdim)
c
      logical zoom
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer noeud
c
      double precision anglrx, anglry, anglrz
      double precision daux1, daux2
      double precision rotate(3,3), centre(3), taille(3)
      double precision pidegr, valmin, valmax
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c_______________________________________________________________________
c
c====
c 1. les messages
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Angles en degres'')'
      texte(1,5) = '(''Matrice de rotation'')'
      texte(1,6) = '(''Centre = '',3g12.5)'
      texte(1,7) = '(''Taille = '',3g12.5)'
c
      texte(2,4) = '(''Angles (degrees)'')'
      texte(2,5) = '(''Matrix of the rotation'')'
      texte(2,6) = '(''Centre = '',3g12.5)'
      texte(2,7) = '(''Size   = '',3g12.5)'
c
#include "impr03.h"
c
      codret = 0
c
c====
c 2. En 3D ou si le triedre est demande, calcul des dimensions
c    de l'objet
c====
c
      if ( sdim.eq.3 .or. triedr.eq.1 ) then
c
        do 21 , iaux = 1 , sdim
c
          valmin = coonoe(1,iaux)
          valmax = valmin
          do 211 , noeud = 2 , nbnoto
            valmin = min( coonoe(noeud,iaux), valmin )
            valmax = max( coonoe(noeud,iaux), valmax )
 211      continue
c
          centre(iaux) = ( valmax + valmin ) * unsde
          taille(iaux) = valmax - valmin
c
  21    continue

#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) (centre(iaux), iaux = 1 , sdim)
      write (ulsort,texte(langue,7)) (taille(iaux), iaux = 1 , sdim)
#endif
c
      endif
c
c====
c 3. En 3D, calcul de la tranformation de coordonnees associee a
c    une rotation autour de x, puis de y, puis de z
c    Attention : l'ordre d'enchainement des rotations est important !
c                Il n'y a pas commutativite !
c====
c
      if ( sdim.eq.3 ) then
c
c 3.1. ==> transformation des angles de degres en radians
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,92010) anglex, angley, anglez
#endif
      pidegr = pi / 180.d0
      anglrx = anglex * pidegr
      anglry = angley * pidegr
      anglrz = anglez * pidegr
c
c 3.2. ==> calcul prealable de la matrice de rotation
c
      rotate(1,1) =   cos(anglry) * cos(anglrz)
      rotate(2,1) =   cos(anglry) * sin(anglrz)
      rotate(3,1) = - sin(anglry)
c
      rotate(1,2) =   sin(anglrx) * sin(anglry) * cos(anglrz)
     >              - cos(anglrx) * sin(anglrz)
      rotate(2,2) =   sin(anglrx) * sin(anglry) * sin(anglrz)
     >              + cos(anglrx) * cos(anglrz)
      rotate(3,2) =   sin(anglrx) * cos(anglry)
c
      rotate(1,3) =   cos(anglrx) * sin(anglry) * cos(anglrz)
     >              + sin(anglrx) * sin(anglrz)
      rotate(2,3) =   cos(anglrx) * sin(anglry) * sin(anglrz)
     >              - sin(anglrx) * cos(anglrz)
      rotate(3,3) =   cos(anglrx) * cos(anglry)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5))
      do 3333 , iaux = 1 , 3
        write (ulsort,92010) (rotate(iaux,noeud),noeud=1,3)
 3333 continue
#endif
c
      endif
c
c====
c 4. transformation des coordonnees des noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. transformation ; codret', codret
#endif
c 4.1. ==> En 1D, transfert du tableau
c
      if ( sdim.eq.1 ) then
c
        do 41 , noeud = 1 , nbnoto
          coopro(1,noeud) = coonoe(noeud,1)
          coopro(2,noeud) = 0.d0
          coopro(3,noeud) = 0.d0
  41    continue
c
c 4.2. ==> En 2D, transfert du tableau
c
      elseif ( sdim.eq.2 ) then
c
        do 42 , noeud = 1 , nbnoto
            coopro(1,noeud) = coonoe(noeud,1)
            coopro(2,noeud) = coonoe(noeud,2)
            coopro(3,noeud) = 0.d0
  42    continue
c
      elseif ( sdim.eq.3 ) then
c
c 4.3. ==> En 3D, centrage de l'objet puis rotation
c
        do 43 , iaux = 1 , sdim
          do 431 , noeud = 1 , nbnoto
            coopro(iaux,noeud) =
     >          rotate(iaux,1) * ( coonoe(noeud,1) - centre(1) )
     >        + rotate(iaux,2) * ( coonoe(noeud,2) - centre(2) )
     >        + rotate(iaux,3) * ( coonoe(noeud,3) - centre(3) )
 431      continue
  43    continue
c
      endif
cgn      do 34 , noeud = 1 , nbnoto
cgn        print 1797,noeud,(coopro(iaux,noeud),iaux=1,sdim)
cgn   34 continue
cgn 1797 format(i5,' *',6f12.5)
c
c====
c 5. transformation des coordonnees de la fenetre de zoom
c====
c
      if ( zoom ) then
c
      if ( sdim.eq.1 ) then
c
        coopro(1,-3) = xyzmiz(1)
        coopro(2,-3) = 0.d0
        coopro(3,-3) = 0.d0
        coopro(1,-2) = xyzmaz(1)
        coopro(2,-2) = 0.d0
        coopro(3,-2) = 0.d0
        coopro(1,-1) = xyzmaz(1)
        coopro(2,-1) = 0.d0
        coopro(3,-1) = 0.d0
        coopro(1, 0) = xyzmiz(1)
        coopro(2, 0) = 0.d0
        coopro(3, 0) = 0.d0
c
      elseif ( sdim.eq.2 ) then
c
        coopro(1,-3) = xyzmiz(1)
        coopro(2,-3) = xyzmiz(2)
        coopro(3,-3) = 0.d0
        coopro(1,-2) = xyzmaz(1)
        coopro(2,-2) = xyzmiz(2)
        coopro(3,-2) = 0.d0
        coopro(1,-1) = xyzmaz(1)
        coopro(2,-1) = xyzmaz(2)
        coopro(3,-1) = 0.d0
        coopro(1, 0) = xyzmiz(1)
        coopro(2, 0) = xyzmaz(2)
        coopro(3, 0) = 0.d0
c
      elseif ( sdim.eq.3 ) then
c
        do 52 , iaux = 1 , sdim
          coopro(iaux,-7) =
     >          rotate(iaux,1) * ( xyzmiz(1) - centre(1) )
     >        + rotate(iaux,2) * ( xyzmiz(2) - centre(2) )
     >        + rotate(iaux,3) * ( xyzmiz(3) - centre(3) )
          coopro(iaux,-6) =
     >          rotate(iaux,1) * ( xyzmaz(1) - centre(1) )
     >        + rotate(iaux,2) * ( xyzmiz(2) - centre(2) )
     >        + rotate(iaux,3) * ( xyzmiz(3) - centre(3) )
          coopro(iaux,-5) =
     >          rotate(iaux,1) * ( xyzmaz(1) - centre(1) )
     >        + rotate(iaux,2) * ( xyzmaz(2) - centre(2) )
     >        + rotate(iaux,3) * ( xyzmiz(3) - centre(3) )
          coopro(iaux,-4) =
     >          rotate(iaux,1) * ( xyzmiz(1) - centre(1) )
     >        + rotate(iaux,2) * ( xyzmaz(2) - centre(2) )
     >        + rotate(iaux,3) * ( xyzmiz(3) - centre(3) )
          coopro(iaux,-3) =
     >          rotate(iaux,1) * ( xyzmiz(1) - centre(1) )
     >        + rotate(iaux,2) * ( xyzmiz(2) - centre(2) )
     >        + rotate(iaux,3) * ( xyzmaz(3) - centre(3) )
          coopro(iaux,-2) =
     >          rotate(iaux,1) * ( xyzmaz(1) - centre(1) )
     >        + rotate(iaux,2) * ( xyzmiz(2) - centre(2) )
     >        + rotate(iaux,3) * ( xyzmaz(3) - centre(3) )
          coopro(iaux,-1) =
     >          rotate(iaux,1) * ( xyzmaz(1) - centre(1) )
     >        + rotate(iaux,2) * ( xyzmaz(2) - centre(2) )
     >        + rotate(iaux,3) * ( xyzmaz(3) - centre(3) )
          coopro(iaux,0) =
     >          rotate(iaux,1) * ( xyzmiz(1) - centre(1) )
     >        + rotate(iaux,2) * ( xyzmaz(2) - centre(2) )
     >        + rotate(iaux,3) * ( xyzmaz(3) - centre(3) )
  52    continue
c
      endif
c
      endif
c
c====
c 6. transformation des coordonnees du triedre
c    On a les points classiques : -8:O ; -9:I ; -10:J ; -11:K
c    Quand une coordonnee est constante, on prend un point identifie a
c    l'origine. Cela evite des traces bizarres apres projection.
c====
c
      if ( triedr.ne.0 ) then
c
      if ( sdim.le.2 ) then
c
        if ( zoom ) then
          daux1 = max(xyzmaz(1)-xyzmiz(1),xyzmaz(2)-xyzmiz(2))
        else
          daux1 = max(taille(1),taille(2))
        endif
        daux1 = 0.20d0 * daux1
cgn            print *,'=====> daux1 =',daux1
c
        coopro(1, -8) = 0.d0
        coopro(2, -8) = 0.d0
        coopro(1, -9) = daux1
        coopro(2, -9) = 0.d0
        coopro(1,-10) = 0.d0
        coopro(2,-10) = daux1
c
      elseif ( sdim.eq.3 ) then
c
        if ( zoom ) then
          daux1 = max(xyzmaz(1)-xyzmiz(1),
     >                xyzmaz(2)-xyzmiz(2),
     >                xyzmaz(3)-xyzmiz(3))
        else
          daux1 = max(taille(1),taille(2),taille(3))
        endif
        daux1 = 0.20d0 * daux1
cgn            print *,'=====> daux1 =',daux1
c
        do 61 , iaux = 1 , sdim
          coopro(iaux,-8) =
     >          rotate(iaux,1) * ( 0.d0  - centre(1) )
     >        + rotate(iaux,2) * ( 0.d0  - centre(2) )
     >        + rotate(iaux,3) * ( 0.d0  - centre(3) )
          if ( taille(1).le.epsima ) then
            daux2 = 0.d0
          else
            daux2 = daux1
          endif
          coopro(iaux,-9) =
     >          rotate(iaux,1) * ( daux2 - centre(1) )
     >        + rotate(iaux,2) * ( 0.d0  - centre(2) )
     >        + rotate(iaux,3) * ( 0.d0  - centre(3) )
          if ( taille(2).le.epsima ) then
            daux2 = 0.d0
          else
            daux2 = daux1
          endif
          coopro(iaux,-10) =
     >          rotate(iaux,1) * ( 0.d0  - centre(1) )
     >        + rotate(iaux,2) * ( daux2 - centre(2) )
     >        + rotate(iaux,3) * ( 0.d0  - centre(3) )
          if ( taille(3).le.epsima ) then
            daux2 = 0.d0
          else
            daux2 = daux1
          endif
          coopro(iaux,-11) =
     >          rotate(iaux,1) * ( 0.d0  - centre(1) )
     >        + rotate(iaux,2) * ( 0.d0  - centre(2) )
     >        + rotate(iaux,3) * ( daux2 - centre(3) )
  61    continue
c
      endif
c
      endif
c
c====
c 7. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

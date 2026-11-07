      subroutine utwipg ( ngauss, nbnorf, sdim, typgeo,
     >                    conorf, copgrf, wipg,
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
c    UTilitaire - fonctions de forme WI sur les Points de Gauss
c    --                              --         -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . ngauss . e   .   1    . nbre de points de Gauss des fonctions pg   .
c . nbnorf . e   .   1    . nbre de noeuds de l'element de reference   .
c . sdim   . e   .   1    . dimension de l'element de reference        .
c . typgeo . e   .   1    . type geometrique au sens MED               .
c . conorf . e   .  sdim* . coordonnees des noeuds de l'element de     .
c .        .     . nbnorf . reference                                  .
c . copgrf . e   .  sdim* . coordonnees des points de Gauss            .
c .        .     . ngauss . de l'element de reference                  .
c . wipg   .   s . nbnorf*. fonctions de forme exprimees aux points de .
c .        .     . ngauss . Gauss                                      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : les coordonnees de l'element de        .
c .        .     .        .     reference sont incorrectes             .
c .        .     .        . 2 : pas encore operationnel                .
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
      parameter ( nompro = 'UTWIPG' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "precis.h"
c
#include "meddc0.h"
#include "fracta.h"
#include "fractc.h"
c
c 0.3. ==> arguments
c
      integer ngauss, nbnorf, sdim, typgeo
c
      double precision conorf(sdim,nbnorf), copgrf(sdim,ngauss)
      double precision wipg(nbnorf,ngauss)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nugaus
      integer iaux, jaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,''Type geometrique :'',i8)'
      texte(1,5) = '(''Coordonnees incorrectes'')'
      texte(1,5) = '(''Impossible de calculer les fonctions de forme'')'
c
      texte(2,4) = '(/,''Geometrical type :'',i8)'
      texte(2,5) = '(''Uncorrect coordinates'')'
      texte(2,6) = '(''Functions cannot be computed'')'
c
#ifdef _DEBUG_HOMARD_
      iaux = 2
      call utimpg ( iaux, ngauss, nbnorf, sdim,
     >              conorf, copgrf, wipg,
     >              ulsort, langue, codret )
#endif
c
      codret = 0
c
c====
c 2. calcul des valeurs des fonctions de forme aux points de Gauss
c====
c 2.1. ==> triangle en degre 2
c
      if ( typgeo.eq.edtri6 ) then
c
c 2.1.1. ==> Test sur les coordonnees des points de Gauss
c
        if     (abs(conorf(1,1)).gt.epsima) then
          codret = 1
        elseif (abs(conorf(2,1)).gt.epsima) then
          codret = 1
        elseif (abs(conorf(1,2)-1.d0).gt.epsima) then
          codret = 1
        elseif (abs(conorf(2,2)).gt.epsima) then
          codret = 1
        elseif (abs(conorf(1,3)).gt.epsima) then
          codret = 1
        elseif (abs(conorf(2,3)-1.d0).gt.epsima) then
          codret = 1
        elseif (abs(conorf(1,4)-unsde).gt.epsima) then
          codret = 1
        elseif (abs(conorf(2,4)).gt.epsima) then
          codret = 1
        elseif (abs(conorf(1,5)-unsde).gt.epsima) then
          codret = 1
        elseif (abs(conorf(2,5)-unsde).gt.epsima) then
          codret = 1
        elseif (abs(conorf(1,6)).gt.epsima) then
          codret = 1
        elseif (abs(conorf(2,6)-unsde).gt.epsima) then
          codret = 1
        endif
c
c 2.1.2. ==> Calcul
c
        if ( codret.eq.0 ) then

        do 212 , nugaus = 1 , ngauss
c
          wipg(1,nugaus) = -(1.d0-copgrf(1,nugaus)-copgrf(2,nugaus))*
     >          (1.d0-2.d0*(1.d0-copgrf(1,nugaus)-copgrf(2,nugaus)))
          wipg(2,nugaus) = -copgrf(1,nugaus)*
     >                   (1.d0-2.d0*copgrf(1,nugaus))
          wipg(3,nugaus) = -copgrf(2,nugaus)*
     >                   (1.d0-2.d0*copgrf(2,nugaus))
          wipg(4,nugaus) = 4.d0*copgrf(1,nugaus)*
     >        (1.d0-copgrf(1,nugaus)-copgrf(2,nugaus))
          wipg(5,nugaus) = 4.d0*copgrf(1,nugaus)*copgrf(2,nugaus)
          wipg(6,nugaus) = 4.d0*copgrf(2,nugaus)*
     >        (1.d0-copgrf(1,nugaus)-copgrf(2,nugaus))
c
  212   continue
c
        endif
c
c 2.2. ==> quadrangle en degre 2
c
      elseif ( typgeo.eq.edqua8 ) then
c
c 2.2.1. ==> Test sur les coordonnees des points de Gauss
c
        if     (abs(conorf(1,1)+1.d0).gt.epsima) then
          codret = 1
        elseif (abs(conorf(2,1)+1.d0).gt.epsima) then
        codret = 1
        elseif (abs(conorf(1,2)-1.d0).gt.epsima) then
        codret = 1
        elseif (abs(conorf(2,2)+1.d0).gt.epsima) then
        codret = 1
        elseif (abs(conorf(1,3)-1.d0).gt.epsima) then
        codret = 1
        elseif (abs(conorf(2,3)-1.d0).gt.epsima) then
        codret = 1
        elseif (abs(conorf(1,4)+1.d0).gt.epsima) then
        codret = 1
        elseif (abs(conorf(2,4)-1.d0).gt.epsima) then
        codret = 1
        elseif (abs(conorf(1,5)).gt.epsima) then
        codret = 1
        elseif (abs(conorf(2,5)+1.d0).gt.epsima) then
        codret = 1
        elseif (abs(conorf(1,6)-1.d0).gt.epsima) then
        codret = 1
        elseif (abs(conorf(2,6)).gt.epsima) then
        codret = 1
        elseif (abs(conorf(1,7)).gt.epsima) then
        codret = 1
        elseif (abs(conorf(2,7)-1.d0).gt.epsima) then
        codret = 1
        elseif (abs(conorf(1,8)+1.d0).gt.epsima) then
        codret = 1
        elseif (abs(conorf(2,8)).gt.epsima) then
        codret = 1
        endif
c
c 2.2.2. ==> Calcul
c
        if ( codret.eq.0 ) then
c
        do 222 , nugaus = 1 , ngauss
c
          wipg(1,nugaus) = unsqu*(1.d0-copgrf(1,nugaus))*
     >                           (1.d0-copgrf(2,nugaus))*
     >            (-1.d0-copgrf(1,nugaus)-copgrf(2,nugaus))
          wipg(2,nugaus) = unsqu*(1.d0+copgrf(1,nugaus))*
     >                           (1.d0-copgrf(2,nugaus))*
     >            (-1.d0+copgrf(1,nugaus)-copgrf(2,nugaus))
          wipg(3,nugaus) = unsqu*(1.d0+copgrf(1,nugaus))*
     >                           (1.d0+copgrf(2,nugaus))*
     >            (-1.d0+copgrf(1,nugaus)+copgrf(2,nugaus))
          wipg(4,nugaus) = unsqu*(1.d0-copgrf(1,nugaus))*
     >                           (1.d0+copgrf(2,nugaus))*
     >            (-1.d0-copgrf(1,nugaus)+copgrf(2,nugaus))
          wipg(5,nugaus) = unsde*(1.d0-copgrf(1,nugaus))*
     >                           (1.d0-copgrf(1,nugaus))*
     >                           (1.d0-copgrf(2,nugaus))
          wipg(6,nugaus) = unsde*(1.d0+copgrf(1,nugaus))*
     >                           (1.d0-copgrf(2,nugaus))*
     >                           (1.d0-copgrf(2,nugaus))
          wipg(7,nugaus) = unsde*(1.d0-copgrf(1,nugaus))*
     >                           (1.d0-copgrf(1,nugaus))*
     >                           (1.d0+copgrf(2,nugaus))
          wipg(8,nugaus) = unsde*(1.d0-copgrf(1,nugaus))*
     >                           (1.d0-copgrf(2,nugaus))*
     >                           (1.d0-copgrf(2,nugaus))
c
  222   continue
c
        endif
c
c 2.3. ==> tetraedre en degre 1
c
      elseif ( typgeo.eq.edtet4 ) then
c
c 2.3.1. ==> Test sur les coordonnees des points de Gauss
c
c 2.3.2. ==> Calcul
c
        if ( codret.eq.0 ) then
c
        do 232 , nugaus = 1 , ngauss
c
          wipg(1,nugaus) = copgrf(2,nugaus)
          wipg(2,nugaus) = copgrf(3,nugaus)
          wipg(3,nugaus) = 1.d0-copgrf(1,nugaus)
     >                         -copgrf(2,nugaus)
     >                         -copgrf(3,nugaus)
          wipg(4,nugaus) = copgrf(1,nugaus)
c
  232   continue
c
        endif
c
c 2.4. ==> tetraedre en degre 4 : on fait comme si ...
c
      elseif ( typgeo.eq.edte10 ) then
c
        codret = 0
c
c 2.n. ==> non encore disponible
c
      else
c
        codret = 2
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      iaux = 3
      call utimpg ( iaux, ngauss, nbnorf, sdim,
     >              conorf, copgrf, wipg,
     >              ulsort, langue, codret )
      endif
#endif
c
c====
c 3. la fin
c====
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      iaux = 2
      call utimpg ( iaux, ngauss, nbnorf, sdim,
     >              conorf, copgrf, wipg,
     >              ulsort, langue, jaux )
      write (ulsort,texte(langue,4)) typgeo
      write (ulsort,texte(langue,3+codret))
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

      subroutine sffa01 ( nouvno, coopro,
     >                    lenoeu,
     >                    coonoe,
     >                    cencyl, axecyl, raycyl,
     >                    ulsort, langue, codret )
c ______________________________________________________________________
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
c   Suivi de Frontiere - Frontiere Analytique - type 01 - cylindre
c   -        -           -         -                 --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nouvno . e   .    1   . dernier numero de noeud cree               .
c . coopro .   s .  sdim  . nouvelles coordonnees du noeud             .
c . lenoeu . e   .    1   . noeud en cours d'examen                    .
c . coonoe . e   . nouvno . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . cencyl . e   .  sdim  . origine de l'axe du cylindre               .
c . axecyl . e   .  sdim  . axe du cylindre                            .
c . raycyl . e   .    1   . rayon du cylindre                          .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . x : probleme                               .
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
      parameter ( nompro = 'SFFA01' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer lenoeu
      integer nouvno
c
      double precision coonoe(nouvno,sdim)
      double precision coopro(sdim)
      double precision cencyl(sdim), axecyl(sdim), raycyl
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      double precision vectca(3)
      double precision daux1(3)
      double precision daux
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
c 1.1. ==> messages
c
      texte(1,4) = '(''Axe du cylindre    :'',3g17.9)'
      texte(1,5) = '(''Centre du cylindre :'',3g17.9)'
      texte(1,6) = '(''Rayon du cylindre  :'',g17.9)'
      texte(1,7) = '(''Noeud '',i8,'' :'',3g17.9)'
      texte(1,8) = '(''Coordonnees initiales :'',3g17.9)'
      texte(1,9) = '(''Coordonnees projetees :'',3g17.9)'
c
      texte(2,4) = '(''Axis of the cylindre  :'',3g17.9)'
      texte(2,5) = '(''Center of the cylindre:'',3g17.9)'
      texte(2,6) = '(''Radius of the cylindre:'',g17.9)'
      texte(2,7) = '(''Node '',i8,'' :'',3g17.9)'
      texte(2,8) = '(''Initial coordonnates:'',3g17.9)'
      texte(2,9) = '(''Moved coordonnates  :'',3g17.9)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      if ( lenoeu.eq.-113 .or.lenoeu.eq.-13 ) then
      write (ulsort,texte(langue,4)) (axecyl(iaux), iaux = 1 , sdim)
      write (ulsort,texte(langue,5)) (cencyl(iaux), iaux = 1 , sdim)
      write (ulsort,texte(langue,6)) raycyl
      endif
#endif
#ifdef _DEBUG_HOMARD_
      if ( lenoeu.eq.-113 .or.lenoeu.eq.-13 ) then
      write (ulsort,texte(langue,7))
     > lenoeu, (coonoe(lenoeu,iaux),iaux=1,sdim)
      endif
#endif
c
c 1.2. ==> Tout va bien a priori
c
      codret = 0
c
c====
c 2. Projection
c====
c 2.1. ==> daux = produit scalaire de CM avec l'axe
c          daux = CM * axe = ( OmegaM - OmegaC ) * axe
c
c                             x  M
c                          .  .
c                       .     .
c                    .        .
c                 .           .
c              .              .
c       C   .                 . A
c     ---x--------------------x------------------
c        <-------------------->
c              daux
c
cgn      if ( lenoeu.eq.-113 .or.lenoeu.eq.-13 ) then
cgn        write (ulsort,90004) 'vectcm',
cgn     >((coonoe(lenoeu,iaux)-cencyl(iaux)),iaux=1,sdim)
cgn      endif
      daux = 0.d0
      do 21 , iaux = 1 , sdim
        daux = daux
     >       + (coonoe(lenoeu,iaux)-cencyl(iaux)) * axecyl(iaux)
   21 continue
cgn      if ( lenoeu.eq.-113 .or.lenoeu.eq.-13 ) then
cgn        write (ulsort,90004) 'daux',daux
cgn      endif
c
c 2.2. ==> Vecteur CA = daux * vect(axe)
c
      do 22 , iaux = 1 , sdim
        vectca(iaux) = daux * axecyl(iaux)
   22 continue
cgn      if ( lenoeu.eq.-113 .or.lenoeu.eq.-13 ) then
cgn        write (ulsort,90004) 'vectca',(vectca(iaux),iaux=1,sdim)
cgn      endif
c
c 2.3. ==> Vecteur AM = CM - CA = ( OmegaM - OmegaC ) - CA
c
      do 23 , iaux = 1 , sdim
        daux1(iaux) = coonoe(lenoeu,iaux)
     >              - cencyl(iaux)
     >              - vectca(iaux)
   23 continue
cgn      if ( lenoeu.eq.-113 .or.lenoeu.eq.-13 ) then
cgn        write (ulsort,90004) 'vectAM',(daux1(iaux),iaux=1,sdim)
cgn      endif
c
c 2.4. ==> Rayon pour le point M avant projection
c
      daux = 0.d0
      do 24 , iaux = 1 , sdim
        daux = daux + daux1(iaux)*daux1(iaux)
   24 continue
      daux = sqrt(daux)
cgn      if ( lenoeu.eq.-113 .or.lenoeu.eq.-13 ) then
cgn        write (ulsort,90004) 'AM',daux
cgn      endif
c
c 2.5. ==> Vecteur AP = (Rayon cylindre/dist(AM)) * Vecteur AM
c
      daux = raycyl / daux
      do 25 , iaux = 1 , sdim
        daux1(iaux) = daux *daux1(iaux)
   25 continue
cgn      if ( lenoeu.eq.-113 .or.lenoeu.eq.-13 ) then
cgn        write (ulsort,90004) 'vectAP',(daux1(iaux),iaux=1,sdim)
cgn      endif
c
c 2.6. ==> Coordonnees projetees : OmegaP = OmegaC + CD + DP
c
      do 26 , iaux = 1 , sdim
        coopro(iaux) = cencyl(iaux) + vectca(iaux) + daux1(iaux)
   26 continue
#ifdef _DEBUG_HOMARD_
      if ( lenoeu.eq.-113 .or.lenoeu.eq.-13 ) then
      write (ulsort,texte(langue,9)) (coopro(iaux), iaux = 1 , sdim)
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

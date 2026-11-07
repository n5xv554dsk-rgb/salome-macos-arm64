      subroutine sffa05 ( nouvno, coopro,
     >                    lenoeu,
     >                    coonoe,
     >                    centor, axetor, rayrev, raypri,
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
c   Suivi de Frontiere - Frontiere Analytique - type 05 - tore
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
c . centor . e   .  sdim  . origine de l'axe du tore                   .
c . axetor . e   .  sdim  . axe du tore                                .
c . rayrev . e   .    1   . rayon de revolution du tore                .
c . raypri . e   .    1   . rayon primaire du tore                     .
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
      parameter ( nompro = 'SFFA05' )
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
      double precision centor(sdim), axetor(sdim)
      double precision rayrev, raypri
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      double precision vectnp(3)
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
      texte(1,4) = '(''Axe du tore         :'',3g16.9)'
      texte(1,5) = '(''Centre du tore      :'',3g16.9)'
      texte(1,6) = '(''Rayon de revolution :'',g16.9)'
      texte(1,7) = '(''Rayon primaire      :'',g16.9)'
      texte(1,8) = '(''Noeud '',i8,'' :'',3g16.9)'
      texte(1,9) = '(''Coordonnees initiales :'',3g16.9)'
      texte(1,10) = '(''Coordonnees projetees :'',3g16.9)'
c
      texte(2,4) = '(''Axis of the torus  :'',3g16.9)'
      texte(2,5) = '(''Center of the torus:'',3g16.9)'
      texte(2,6) = '(''Revolution radius  :'',g16.9)'
      texte(2,7) = '(''Primary radius     :'',g16.9)'
      texte(2,8) = '(''Node '',i8,'' :'',3g16.9)'
      texte(2,9) = '(''Initial coordonnates:'',3g16.9)'
      texte(2,10) = '(''Moved coordonnates  :'',3g16.9)'
c
cgn 1001 format(a,' :',3g16.9)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) (axetor(iaux), iaux = 1 , sdim)
      write (ulsort,texte(langue,5)) (centor(iaux), iaux = 1 , sdim)
      write (ulsort,texte(langue,6)) rayrev
      write (ulsort,texte(langue,7)) raypri
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8))
     > lenoeu, (coonoe(lenoeu,iaux),iaux=1,sdim)
#endif
c
c 1.2. ==> Tout va bien a priori
c
      codret = 0
c
c====
c 2. Projection
c====
c La figure est dans le plan de l'axe et du point M.
c Le vecteur normal qui s'enfonce dans le plan est : u = axe x CM
c Le point A est l'intersection de ce plan avec le cercle de revolution
c Le vecteur CA est colineaire au produit vectoriel u x axe
c                        Axe
c                         |
c                         |
c                         |
c                         |
c                         |                                 P
c                         |                                x
c                         |                          M   .
c                         |                            x
c                         |                          .
c                         |                        .
c                       C |----------------------x----------->
c                                                A
c
c 2.1. ==> vectnp = vecteur normal au plan
c                   produit vectoriel de l'axe avec CM
c                 = axe x CM  = axe x ( OmegaM - OmegaC )
c
      do 21 , iaux = 1 , sdim
        daux1(iaux) = coonoe(lenoeu,iaux) - centor(iaux)
   21 continue
c
      vectnp(1) = axetor(2)*daux1(3) - axetor(3)*daux1(2)
      vectnp(2) = axetor(3)*daux1(1) - axetor(1)*daux1(3)
      vectnp(3) = axetor(1)*daux1(2) - axetor(2)*daux1(1)
cgn      write (ulsort,1001) 'vectnp',vectnp
c
c 2.2. ==> Vecteur CA = vectnp x vect(axe)
c
      vectca(1) = vectnp(2)*axetor(3) - vectnp(3)*axetor(2)
      vectca(2) = vectnp(3)*axetor(1) - vectnp(1)*axetor(3)
      vectca(3) = vectnp(1)*axetor(2) - vectnp(2)*axetor(1)
c
      daux = 0.d0
      do 221 , iaux = 1 , sdim
        daux = daux + vectca(iaux)**2
  221 continue
      daux = rayrev / sqrt(daux)
c
      do 222 , iaux = 1 , sdim
        vectca(iaux) = vectca(iaux) * daux
  222 continue
cgn      write (ulsort,1001) 'vectca',(vectca(iaux),iaux=1,sdim)
c
c 2.3. ==> Vecteur AM = CM - CA = ( OmegaM - OmegaC ) - CA
c
      do 23 , iaux = 1 , sdim
        daux1(iaux) = coonoe(lenoeu,iaux)
     >              - centor(iaux)
     >              - vectca(iaux)
   23 continue
cgn      write (ulsort,1001) 'vectAM',(daux1(iaux),iaux=1,sdim)
c
c 2.4. ==> Rayon pour le point M avant projection
c
      daux = 0.d0
      do 24 , iaux = 1 , sdim
        daux = daux + daux1(iaux)*daux1(iaux)
   24 continue
      daux = sqrt(daux)
cgn      write (ulsort,1001) 'AM',daux
c
c 2.5. ==> Vecteur AP = (Rayon primaire/dist(AM)) * Vecteur AM
c
      daux = raypri / daux
      do 25 , iaux = 1 , sdim
        daux1(iaux) = daux *daux1(iaux)
   25 continue
cgn      write (ulsort,1001) 'vectAP',(daux1(iaux),iaux=1,sdim)
c
c 2.6. ==> Coordonnees projetees : OmegaP = OmegaC + CD + DP
c
      do 26 , iaux = 1 , sdim
        coopro(iaux) = centor(iaux) + vectca(iaux) + daux1(iaux)
   26 continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10)) (coopro(iaux), iaux = 1 , sdim)
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

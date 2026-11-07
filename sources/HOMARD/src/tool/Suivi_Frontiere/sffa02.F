      subroutine sffa02 ( nouvno, coopro,
     >                    lenoeu,
     >                    coonoe,
     >                    censph, raysph,
     >                    ulsort, langue, codret)
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
c   Suivi de Frontiere - Frontiere Analytique - type 02 - sphere
c   -        -           -         -                 --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nouvno . e   .    1   . dernier numero de noeud cree               .
c . coopro . e   .  sdim  . nouvelles coordonnees du noeud             .
c . lenoeu . e   .    1   . noeud en cours d'examen                    .
c . coonoe . e   . nouvno . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . censph . e   .  sdim  . centre de la sphere                        .
c . raycyl . e   .    1   . rayon de la sphere                         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
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
      parameter ( nompro = 'SFFA02' )
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
      double precision censph(sdim), raysph
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      double precision vectcm(3)
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
      texte(1,4) = '(''Centre de la sphere :'',3g15.8)'
      texte(1,5) = '(''Rayon de la sphere  :'',g15.8)'
      texte(1,7) = '(''Noeud '',i8,'' :'',3g15.8)'
      texte(1,8) = '(''Coordonnees initiales :'',3g15.8)'
      texte(1,9) = '(''Coordonnees projetees :'',3g15.8)'
c
      texte(2,4) = '(''Centre of the sphere:'',3g15.8)'
      texte(2,5) = '(''Radius of the sphere:'',g15.8)'
      texte(2,7) = '(''Node '',i8,'' :'',3g15.8)'
      texte(2,8) = '(''Initial coordonnates:'',3g15.8)'
      texte(2,9) = '(''Moved coordonnates  :'',3g15.8)'
c
 1001 format(a,' :',3g15.8)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) (censph(iaux), iaux = 1 , sdim)
      write (ulsort,texte(langue,5)) raysph
#endif
c
c 1.2. ==> Tout va bien a priori
c
      codret = 0
c
c====
c 2. Projection
c====
c 2.1. ==> Vecteur CM
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7))
     >    lenoeu,(coonoe(lenoeu,iaux),iaux=1,sdim)
#endif
c
      do 21 , iaux = 1 , sdim
        vectcm(iaux) = coonoe(lenoeu,iaux) - censph(iaux)
   21 continue
cgn      write (ulsort,1001) 'vectCM',(vectcm(iaux),iaux=1,sdim)
c
c 2.2. ==> Rayon pour le point M avant projection
c
      daux = 0.d0
      do 22 , iaux = 1 , sdim
        daux = daux + vectcm(iaux)*vectcm(iaux)
   22 continue
      daux = sqrt(daux)
cgn      write (ulsort,1001) 'DM',daux
c
c 2.3. ==> Vecteur CP = (Rayon cylindre/dist(CM)) * Vecteur CM
c
      daux = raysph / daux
      do 23 , iaux = 1 , sdim
        vectcm(iaux) = daux *vectcm(iaux)
   23 continue
cgn      write (ulsort,1001) 'vectCP',(vectcm(iaux),iaux=1,sdim)
c
c 2.4. ==> Coordonnees projetees : OmegaP = OmegaC + CP
c
      do 24 , iaux = 1 , sdim
        coopro(iaux) = censph(iaux) + vectcm(iaux)
   24 continue
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) (coonoe(lenoeu,iaux),iaux=1,sdim)
      write (ulsort,texte(langue,9)) (coopro(iaux), iaux = 1 , sdim)
#endif
      daux = 0.d0
      do 222 , iaux = 1 , sdim
        daux = daux + (coopro(iaux)-censph(iaux))**2
  222 continue
      daux = sqrt(daux)
cgn      write (ulsort,1001) 'DM',daux
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

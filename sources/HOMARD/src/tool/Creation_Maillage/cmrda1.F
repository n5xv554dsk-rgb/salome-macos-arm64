      subroutine cmrda1 ( coonoe, hetnoe, arenoe, somare,
     >                    hetare, filare, merare, decare,
     >                    cfaare, famare, famnoe,
     >                    indnoe, indare,
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
c    Creation du Maillage - DEcoupage des Aretes en degre 1
c    -           -          --            -               -
c ______________________________________________________________________
c
c but : decoupage des aretes en degre 1
c       creation de 2 aretes et de 1 noeud
c       les coordonnees des nouveaux noeuds sont calculees par
c       interpolation lineaire sur les deux noeuds voisins
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . es  .nouvno*3. coordonnees des noeuds                     .
c . hetnoe . es  . nouvno . historique de l'etat des noeuds            .
c . arenoe . es  . nouvno . arete liee a un nouveau noeud              .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . decare . es  .0:nbarto. decision des aretes                        .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famare . es  . nouvar . famille des aretes                         .
c . famnoe . es  . nouvno . caracteristiques des noeuds                .
c . indnoe . es  . 1      . indice du dernier noeud cree               .
c . indare . es  . 1      . indice de la derniere arete creee          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'CMRDA1' )
c
#include "nblang.h"
c
#include "fracta.h"
#include "cofaar.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "nbfami.h"
#include "nombar.h"
#include "nouvnb.h"
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nouvno,sdim)
c
      integer hetnoe(nouvno), arenoe(nouvno)
      integer somare(2,nouvar), hetare(nouvar)
      integer filare(nouvar), merare(nouvar), decare(0:nbarto)
      integer famare(nouvar), cfaare(nctfar,nbfare), famnoe(nouvno)
      integer indare, indnoe
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer etat, larete, mere, na1, na2, s1, s2
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. preliminaires
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Decoupage de l''''arete'',i10)'
      texte(1,5) = '(''... Noeud milieu'',i10,'', aretes filles'',2i10)'
c
      texte(2,4) = '(''Splitting of edge #'',i10)'
      texte(2,5) = '(''... Node'',i10,'', edges'',2i10)'
c
c====
c 2. decoupage en 2 des aretes de decision 2
c====
c
      do 200 , larete = 1 , nbarpe
c
        if ( decare(larete).eq.2 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) larete
#endif
c
c 2.1. ==> creation du noeud milieu : nouveau sommet
c
          indnoe = indnoe + 1
          arenoe(indnoe) = larete
          s1 = somare(1,larete)
          s2 = somare(2,larete)
          coonoe(indnoe,1) = ( coonoe(s1,1) + coonoe(s2,1) ) * unsde
          if ( sdim.ge.2 ) then
            coonoe(indnoe,2) = ( coonoe(s1,2) + coonoe(s2,2) ) * unsde
            if ( sdim.eq.3 ) then
              coonoe(indnoe,3) = ( coonoe(s1,3) + coonoe(s2,3) ) * unsde
            endif
          endif
          famnoe(indnoe) = 1
          hetnoe(indnoe) = 51
c
c 2.2. ==> creation de la premiere arete
c
          na1 = indare + 1
          somare(1,na1) = s1
          somare(2,na1) = indnoe
c
c 2.3. ==> creation de la seconde arete
c
          na2 = na1 + 1
          somare(1,na2) = s2
          somare(2,na2) = indnoe
c
c 2.4. ==> mise a jour de la mere et de la grand-mere eventuelle
c
          filare(larete) = na1
          hetare(larete) = hetare(larete) + 2
          mere = merare(larete)
          if ( mere .ne. 0 ) then
            etat = hetare(mere)
            hetare(mere) = etat - mod(etat,10) + 9
          endif
c
c 2.5. ==> caracteristiques des deux filles
c
          famare(na1) = famare(larete)
c         correction pour l'orientation de la deuxieme fille
          famare(na2) = cfaare(cofifa,famare(larete))
c
          hetare(na1) = 50
          hetare(na2) = 50
          filare(na1) = 0
          filare(na2) = 0
          merare(na1) = larete
          merare(na2) = larete
c
          indare = na2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) indnoe, na1, na2
#endif
c
        endif
c
  200 continue
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

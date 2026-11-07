      subroutine utcorn ( lenoeu, lequad, larete,
     >                    coonoe,
     >                    somare, filare,
     >                    cfaare, famare,
     >                    arequa, filqua,
     >                    cfaqua, famqua,
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
c   UTilitaire - COntroles - Reprise d'un Noeud
c   --           --          -            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lenoeu . e   .   1    . noeud dont les coordonnees sont a changer  .
c . lequad . e   .   1    . quadrangle dont lenoeu est centre (si >0)  .
c . larete . e   .   1    . arete dont lenoeu est centre (si >0)       .
c . coonoe . es  . nbnoto . coordonnees des noeuds                     .
c .        .     . *sdim  .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . filare . e   . nbarto . premiere fille des aretes                  .
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
c . famare . es  . nbarto . famille des aretes                         .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . e   . nbquto . famille des quadrangles                    .
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
      parameter ( nompro = 'UTCORN' )
c
#include "nblang.h"
#include "cofina.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer lenoeu, lequad, larete
      integer somare(2,nbarto), filare(nbarto)
      integer cfaare(nctfar,nbfare), famare(nbarto)
      integer arequa(nbquto,4), filqua(nbquto)
      integer cfaqua(nctfqu,nbfqua), famqua(nbquto)
c
      double precision coonoe(nbnoto,sdim)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer noeud1, noeud2, noeud3, noeud4
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,7) = '(''... Reprise du '',a,i10)'
      texte(1,8) = '(''... Au milieu du '',a,i10)'
c
      texte(2,7) = '(''... Correction of '',a,i10)'
      texte(2,8) = '(''... Center of '',a,i10)'
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) mess14(langue,1,-1), lenoeu
#endif
c
c====
c 2. Noeud au milieu d'un quadrangle
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Noeud quadrangle ; codret = ', codret
#endif
c
      if ( lequad.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,1,4), lequad
#endif
c
c 2.1. ==> Retour au milieu
c
        call utsoqu ( somare, arequa(lequad,1), arequa(lequad,2),
     >                arequa(lequad,3), arequa(lequad,4),
     >                noeud1, noeud2, noeud3, noeud4 )
c
        do 21 , iaux = 1 , sdim
          coonoe(lenoeu,iaux) =
     >           0.25d0*(coonoe(noeud1,iaux)+coonoe(noeud2,iaux)
     >                  +coonoe(noeud3,iaux)+coonoe(noeud4,iaux))
   21 continue
c
c 2.2. ==> Le quadrangle ne doit plus etre considere en sf, ni ses fils
c
        jaux = cfaqua(cosfin,famqua(lequad))
        famqua(lequad) = jaux
        do 22 , iaux = 0 , 3
          jaux = cfaqua(cosfin,famqua(filqua(lequad)+iaux))
          famqua(filqua(lequad)+iaux) = jaux
   22    continue
c
      endif
c
c====
c 3. Noeud au milieu d'une arete
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Noeud arete ; codret = ', codret
#endif
c
      if ( larete.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,8)) mess14(langue,1,1), larete
#endif
c
c 3.1. ==> Retour au milieu
c
        noeud1 = somare(1,larete)
        noeud2 = somare(2,larete)
        do 31 , iaux = 1 , sdim
          coonoe(lenoeu,iaux) =
     >                  0.5d0*(coonoe(noeud1,iaux)+coonoe(noeud2,iaux))
   31   continue
c
c 3.2. ==> L'arete ne doit plus etre consideree en sf ni ses filles
c
        jaux = cfaare(cosfin,famare(larete))
        famare(larete) = jaux
        do 32 , iaux = 0 , 1
          jaux = cfaare(cosfin,famare(filare(larete)+iaux))
          famare(filare(larete)+iaux) = jaux
   32   continue
c
      endif
c
c====
c 4. La fin
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

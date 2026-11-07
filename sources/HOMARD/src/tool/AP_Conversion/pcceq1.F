      subroutine pcceq1 ( cfanoe, famnoe, nnosho,
     >                    cfampo, fammpo, nmpsho,
     >                    cfaare, famare, narsho,
     >                    cfatri, famtri, ntrsho,
     >                    cfaqua, famqua, nqusho,
     >                    typele,
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
c    aPres adaptation - Conversion - Creation des EQuivalences - phase 1
c     -                 -            -            --                   -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . cfanoe . e   . nctfno*. codes des familles des noeuds              .
c .        .     . nbnoto .   1 : famille MED                          .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famnoe . e   . nbnoto . famille des aretes                         .
c . nnosho . e   . rsnoto . numero des noeuds dans HOMARD              .
c . cfampo . e   . nctfmp*. codes des familles des mailles-points      .
c .        .     . nbfmpo .   1 : famille MED                          .
c .        .     .        .   2 : type de maille-point                 .
c .        .     .        .   3 : famille des sommets                  .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . fammpo . e   . nbmpto . famille des mailles-points                 .
c . nmpsho . e   . rsmpac . numero des mailles-points dans HOMARD      .
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
c . famare . e   . nbarto . famille des aretes                         .
c . narsho . e   . rsarac . numero des aretes dans HOMARD              .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famtri . e   . nbtrto . famille des triangles                      .
c . ntrsho . e   . rstrac . numero des triangles dans HOMARD           .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua .     . nbquto . famille des quadrangles                    .
c . nqusho . e   . rsquac . numero des quadrangles dans HOMARD         .
c . typele . e   . nbelem . type des elements                          .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
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
      parameter ( nompro = 'PCCEQ1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nbfami.h"
#include "nombar.h"
#include "nombmp.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombsr.h"
#include "nbutil.h"
#include "dicfen.h"
#include "refert.h"
c
c 0.3. ==> arguments
c
      integer nnosho(rsnoto), nmpsho(rsmpac), narsho(rsarac)
      integer ntrsho(rstrac), nqusho(rsteac)
      integer typele(nbelem)
c
      integer cfanoe(nctfno,nbfnoe), famnoe(nbnoto)
      integer cfampo(nctfmp,nbfmpo), fammpo(nbmpto)
      integer cfaare(nctfar,nbfare), famare(nbarto)
      integer cfatri(nctftr,nbftri), famtri(nbtrto)
      integer cfaqua(nctfqu,nbfqua), famqua(nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
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
      texte(1,10) = '(/,''Decompte des equivalences - Phase 1 :'')'
c
      texte(2,10) = '(/,''Description of equivalences - Phase # 1 :'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,10))
#endif
c
      codret = 0
c
c====
c 2. on compte combien d'entites appartiennent a des equivalences.
c====
c
c 2.1. ==> les noeuds
c
      if ( codret.eq.0 ) then
c
      iaux = -1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ2_no', nompro
#endif
      call pcceq2 ( iaux,
     >              nbnoto, nctfno, nbfnoe,
     >              ncefno, nbeqno, jaux, jaux, rsnoto,
     >              cfanoe, famnoe, nnosho,
     >              typele,
     >              ulsort, langue, codret )
c
      endif
c
c 2.2. ==> les mailles-points
c
      if ( codret.eq.0 ) then
c
      iaux = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ2_mp', nompro
#endif
      call pcceq2 ( iaux,
     >              nbmpto, nctfmp, nbfmpo,
     >              ncefmp, nbeqmp, tyhmpo, tyhmpo, nbelem,
     >              cfampo, fammpo, nmpsho,
     >              typele,
     >              ulsort, langue, codret )
c
      endif
c
c 2.3. ==> les aretes
c
      if ( codret.eq.0 ) then
c
      iaux = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ2_ar', nompro
#endif
      call pcceq2 ( iaux,
     >              nbarto, nctfar, nbfare,
     >              ncefar, nbeqar, tyhse1, tyhse2, nbelem,
     >              cfaare, famare, narsho,
     >              typele,
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ==> les triangles
c
      if ( codret.eq.0 ) then
c
      iaux = 2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ2_tr', nompro
#endif
      call pcceq2 ( iaux,
     >              nbtrto, nctftr, nbftri,
     >              nceftr, nbeqtr, tyhtr1, tyhtr2, nbelem,
     >              cfatri, famtri, ntrsho,
     >              typele,
     >              ulsort, langue, codret )
c
      endif
c
c 2.5. ==> les quadrangles
c
      if ( codret.eq.0 ) then
c
      iaux = 4
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCCEQ2_qu', nompro
#endif
      call pcceq2 ( iaux,
     >              nbquto, nctfqu, nbfqua,
     >              ncefqu, nbeqqu, tyhqu1, tyhqu2, nbelem,
     >              cfaqua, famqua, nqusho,
     >              typele,
     >              ulsort, langue, codret )
c
      endif
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

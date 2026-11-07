      subroutine pcfaa2 ( fahope, numfam, nromat, numboi,
     >                    cfaqua, lgpile, lapile,
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
c    aPres adaptation - Conversion - FAmilles pour ATHENA - Phase 2
c     -                 -            --            -              -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . fahope . e   .   1    . famille HOMARD du quadrangle pere          .
c . numfam . e   .   1    . famille MED a associer a cette famille     .
c . nromat . e   .   1    . numero du materiau de la boite             .
c . numboi . e   .   1    . numero de la boite                         .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . lgpile . es  .   1    . longueur de la pile                        .
c . lapile .  a  .   *    . tableau de travail                         .
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
      parameter ( nompro = 'PCFAA2' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
#include "nbfami.h"
#include "nbfamm.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      integer fahope, numfam, nromat, numboi
c
      integer cfaqua(nctfqu,*)
c
      integer lgpile, lapile(*)
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
c 1. initialisations
c====
c
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Creation de la famille HOMARD numero : '',i8)'
      texte(1,5) = '(/,a14,'' : nombre de familles crees : '',i8)'
      texte(1,6) = '(''Ce nombre est superieur au maximum :'',i8)'
      texte(1,7) = '(''Modifier le programme UTINCG'',/)'
c
      texte(2,4) = '(''Creation of HOMARD family # : '',i8)'
      texte(2,5) = '(/,a14,'' : number of created families : '',i8)'
      texte(2,6) = '(''This number is greater than maximum :'',i8)'
      texte(2,7) = '(''Modify UTINCG program.'',/)'
c
      codret = 0
c
c====
c 2. creation d'une nouvelle famille homard pour les quadrangles
c====
c
c 2.1. ==> numero de cette famille
c
      nbfqua = nbfqua + 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbfqua
#endif
c
      if ( nbfqua.gt.nbfqum ) then
        write (ulsort,texte(langue,5)) mess14(langue,4,8), nbfqua
        write (ulsort,texte(langue,6)) nbfqum
        write (ulsort,texte(langue,7))
        codret = 1
      endif
c
c 2.2. ==> les caracteristiques : celles du pere, sauf la famille MED
c
      if ( codret.eq.0 ) then
c
      do 22 , iaux = 1 , nctfqu
        cfaqua(iaux,nbfqua) = cfaqua(iaux,fahope)
   22 continue
      cfaqua(cofamd,nbfqua) = numfam
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,60030)
        write (ulsort,60031) nbfqua,
     >                       (cfaqua(jaux,nbfqua),jaux=1,ncffqu)
        write (ulsort,60032)
60030 format(
     >/,5x,41('*'),
     >/,5x,'* Numero code  *   1   *   2   *    3   *',
     >/,5x,41('*'),
     >/,5x,'* Numero de la * Fami. * Type  * Fami. *',
     >/,5x,'*   famille    *  MED  *       * tria. *',
     >/,5x,41('*'))
60031 format(
     >  5x,'*',  i8,'      *',i6,' *',i6,' *',i6,' *')
60032 format(
     >  5x,41('*'),/)
#endif
c
      endif
c
c 2.3. ==> memorisation des caracteristiques dans la pile
c
      if ( codret.eq.0 ) then
c
      jaux = lgpile * (nctfqu+3)
      lgpile = lgpile + 1
cgn      write(ulsort,*) '.. lgpile', lgpile
      lapile(jaux+1) = nbfqua
      lapile(jaux+2) = nromat
      lapile(jaux+3) = numboi
      do 23 , iaux = 1 , nctfqu
        lapile(jaux+3+iaux) = cfaqua(iaux,nbfqua)
   23 continue
cgn      write(ulsort,1007) (lapile(iaux),iaux=1,lgpile * (nctfqu+3))
cgn 1007 format(7i6)
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

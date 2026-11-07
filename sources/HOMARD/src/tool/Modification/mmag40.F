      subroutine mmag40 ( nbpejs, nbpejt, nbhejq,
     >                    nbvojm, nbjoto,
     >                    nbjois, nbjoit, nbjoiq,
     >                    tbaux1, tbau41,
     >                    coonoe, somare, aretri,
     >                    famhex, cfahex,
     >                    fampen, cfapen,
     >                    nbfmed, numfam,
     >                    grfmpo, grfmtl, grfmtb,
     >                    nbgrfm, nomgro, lgnogr,
     >                    famnum, famval,
     >                    lifagr,
     >                    ulbila,
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
c    Modification de Maillage - AGRegat - phase 4.0
c    -               -          --              - -
c    Taille des joints
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbpejs . e   .   1    . nombre de pentaedres de joints simples     .
c . nbpejt . e   .   1    . nombre de pentaedres de joints triples     .
c . nbhejq . e   .   1    . nombre d'hexaedres de joints quadruples    .
c . nbvojm . e   .   1    . nombre de volumes de joints multiples      .
c . nbjoto . e   .   1    . nombre total de joints                     .
c . nbjois . e   .   1    . nombre de joints simples                   .
c . nbjoit . e   .   1    . nombre de joints triples                   .
c . nbjoiq . e   .   1    . nombre de joints quadruples                .
c . tbaux1 . e   .4*nbpejs. Pour le i-eme pentaedre de joint simple :  .
c .        .     .        . (1,i) : numero du triangle a dupliquer     .
c .        .     .        . (2,i) : numero du joint simple cree        .
c .        .     .        . (3,i) : tetraedre du cote min(fammed)      .
c .        .     .        . (4,i) : tetraedre du cote max(fammed)      .
c . tbau41 . e   .4*nbvojm. Les pentaedres de joint triple, puis les   .
c .        .     .        . hexaedres de joint quadruple :             .
c .        .     .        . (1,i) : arete multiple                     .
c .        .     .        . (2,i) : numero du joint                    .
c .        .     .        . Pour le i-eme pentaedre de joint triple :  .
c .        .     .        . (3,i) : triangle cree cote 1er sommet      .
c .        .     .        . (4,i) : triangle cree cote 2nd sommet      .
c .        .     .        . Pour le i-eme hexaedre de joint quadruple :.
c .        .     .        . (3,i) : quadrangle cree cote 1er sommet    .
c .        .     .        . (4,i) : quadrangle cree cote 2nd sommet    .
c . coonoe . e   .nbnoto*3. coordonnees des noeuds                     .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . famhex . e   . nbheto . famille des hexaedres                      .
c . cfahex . e   . nctfhe*. codes des familles des hexaedres           .
c .        .     . nbfhex .   1 : famille MED                          .
c .        .     .        .   2 : type d'hexaedres                     .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . fampen . e   . nbpeto . famille des pentaedres                     .
c . cfapen . e   . nctfpe*. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . nbfmed . e   .    1   . nombre de familles au sens MED             .
c . numfam . e   . nbfmed . numero des familles au sens MED            .
c . grfmpo . e   .0:nbfmed. pointeur des groupes des familles          .
c . grfmtl . e   .   *    . taille des groupes des familles            .
c . grfmtb . e   .10ngrouc. table des groupes des familles             .
c . nbgrfm . e   .    1   . nombre de groupes                          .
c . nomgro . e   .char*(*). noms des groupes (paquets de 10char8)      .
c . lgnogr . e   . nbgrfm . longueur des noms des groupes              .
c . famnum .  a  .   *    . famille : numero avec une valeur           .
c . famval .  a  .   *    . famille : la valeur                        .
c . lifagr .  a  .   *    . liste des familles contenant le groupe     .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
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
      parameter ( nompro = 'MMAG40' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombhe.h"
#include "nombpe.h"
#include "dicfen.h"
#include "nbfami.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer nbpejs, nbpejt, nbhejq
      integer nbvojm, nbjoto
      integer nbjois, nbjoit, nbjoiq
      integer tbaux1(4,nbpejs), tbau41(4,nbvojm)
      integer somare(2,nbarto)
      integer aretri(nbtrto,3)
      integer famhex(nbheto), cfahex(nctfhe,nbfhex)
      integer fampen(nbpeto), cfapen(nctfpe,nbfpen)
c
      double precision coonoe(nbnoto,sdim)
c
      integer nbfmed, numfam(nbfmed)
      integer grfmpo(0:nbfmed)
      integer grfmtl(*)
      integer nbgrfm, lgnogr(nbgrfm)
c
      character*8 grfmtb(*)
      character*8 nomgro(*)
c
      integer famnum(*)
      double precision famval(*)
c
      integer  lifagr(*)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 30 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "mmag01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,7)) mess14(langue,3,7), nbpejs+nbpejt
      write (ulsort,texte(langue,7)) mess14(langue,3,6), nbhejq
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,12)) nbjois
      write (ulsort,texte(langue,13)) nbjoit
      write (ulsort,texte(langue,14)) nbjoiq
      write (ulsort,texte(langue,21)) 0, nbjoto-nbjois-nbjoit-nbjoiq
#endif
c
      codret = 0
c
c====
c 2. Calcul des tailles des joints simples
c    Remarque : on s'inspire de utb13c
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Joints simples ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG41', nompro
#endif
        call mmag41 ( coonoe, somare, aretri,
     >                fampen, cfapen,
     >                nbpejs, nbjois,
     >                tbaux1,
     >                nbfmed, numfam,
     >                grfmpo, grfmtl, grfmtb,
     >                nbgrfm, nomgro, lgnogr,
     >                famnum, famval,
     >                lifagr,
     >                ulbila,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 3. Calcul des tailles des joints triples
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Joints triples ; codret = ', codret
#endif
c
      if ( nbpejt.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG42', nompro
#endif
        call mmag42 ( coonoe, somare,
     >                fampen, cfapen,
     >                nbvojm, nbpejt, nbpejs, nbjois, nbjoit,
     >                tbau41,
     >                nbfmed, numfam,
     >                grfmpo, grfmtl, grfmtb,
     >                nbgrfm, nomgro, lgnogr,
     >                famnum, famval,
     >                lifagr,
     >                ulbila,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 4. Calcul des tailles des joints quadruples
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Joints quadruples ; codret = ', codret
#endif
c
      if ( nbhejq.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MMAG43', nompro
#endif
        call mmag43 ( coonoe, somare,
     >                famhex, cfahex,
     >                nbvojm, nbhejq,
     >                nbjois, nbjoiq,
     >                tbau41,
     >                nbfmed, numfam,
     >                grfmpo, grfmtl, grfmtb,
     >                nbgrfm, nomgro, lgnogr,
     >                famnum, famval,
     >                lifagr,
     >                ulbila,
     >                ulsort, langue, codret )
c
      endif
c
c====
c 5. la fin
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

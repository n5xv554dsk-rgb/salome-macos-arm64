      subroutine mmag42 ( coonoe, somare,
     >                    fampen, cfapen,
     >                    nbvojm, nbpejt, nbpejs, nbjois, nbjoit,
     >                    tbau41,
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
c    Modification de Maillage - AGRegat - phase 4.2
c    -               -          --              - -
c    Taille des joints triples
c ______________________________________________________________________
c
c Remarque : ce programme est une copie de utb13d
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . fampen . e   . nbpeto . famille des pentaedres                     .
c . cfapen . e   . nctfpe*. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . nbvojm . e   .   1    . nombre de volumes de joints multiples      .
c . nbpejt . e   .   1    . nombre de pentaedres de joints triples     .
c . nbpejs . e   .   1    . nombre de pentaedres de joints simples     .
c . nbjois . e   .   1    . nombre de joints simples                   .
c . nbjoit . e   .   1    . nombre de joints triples                   .
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
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'MMAG42' )
c
#include "nblang.h"
#include "coftex.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombno.h"
#include "nombar.h"
#include "nombpe.h"
#include "envca1.h"
#include "dicfen.h"
#include "nbfami.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      double precision coonoe(nbnoto,sdim)
c
      integer nbvojm, nbpejt, nbpejs, nbjois, nbjoit
      integer somare(2,nbarto)
      integer fampen(nbpeto), cfapen(nctfpe,nbfpen)
      integer tbau41(4,nbvojm)
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
      integer iaux, jaux
      integer numpen
      integer larete
c
      double precision vn(3)
      double precision daux
c
      integer nbmess
      parameter (nbmess = 30 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. messages
c====
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
#include "impr03.h"
c
      codret = 0
c
c====
c 2. calcul des longueurs
c====
c
c 2.1. ==> initialisation
c
      do 21 , iaux = 1 , nbjoit
        famval(iaux) = 0.d0
   21 continue
c
c 2.2. ==> calcul
c
      do 22 , numpen = 1 , nbpejt
c
        larete = tbau41(1,numpen)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,1), larete
      write (ulsort,texte(langue,18)) ' ',mess14(langue,1,7),
     >                                tbau41(2,numpen)
#endif
c
c 2.2.1. ==> calcul de la longueur
c
        vn(1) = coonoe(somare(2,larete),1) - coonoe(somare(1,larete),1)
        vn(2) = coonoe(somare(2,larete),2) - coonoe(somare(1,larete),2)
        vn(3) = coonoe(somare(2,larete),3) - coonoe(somare(1,larete),3)
c
        daux = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
c 2.2.3. ==> stockage dans le bon joint
c
        iaux = tbau41(2,numpen) - nbjois
        famnum(iaux) = cfapen(cofamd,fampen(numpen+nbpejs))
        famval(iaux) = famval(iaux) + daux
cgn      if ( iaux.ge.1 ) then
cgn      write (ulsort,92010) '==> longueur =', daux
cgn      write (ulsort,90002) 'iaux, fampen, fammed', iaux,
cgn     >  fampen(numpen+nbpejs),cfapen(cofamd,fampen(numpen+nbpejs))
cgn      write (ulsort,92010) '==> cumul =',famval(iaux)
cgn      endif
c
   22 continue
c
c====
c 3. impression
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. impression ; codret =', codret
      write (ulsort,91010) (famnum(iaux),iaux=1,nbjoit)
      write (ulsort,92010) (famval(iaux),iaux=1,nbjoit)
#endif
c
      iaux = 3
      jaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB13E_j_triple', nompro
#endif
      call utb13e ( jaux, iaux,
     >              nbfmed, numfam,
     >              grfmpo, grfmtl, grfmtb,
     >              nbgrfm, nomgro, lgnogr,
     >              nbjoit, famnum, famval,
     >              lifagr,
     >              ulbila,
     >              ulsort, langue, codret )
c
c====
c 4. la fin
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
c
      end

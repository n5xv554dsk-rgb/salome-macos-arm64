      subroutine mmag41 ( coonoe, somare, aretri,
     >                    fampen, cfapen,
     >                    nbpejs, nbjois,
     >                    tbaux1,
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
c    Modification de Maillage - AGRegat - phase 4.1
c    -               -          --              - -
c    Taille des joints simples
c ______________________________________________________________________
c
c Remarque : ce programme est une copie de utb13c
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . coonoe . e   . nbnoto . coordonnees des noeuds                     .
c .        .     . * sdim .                                            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . fampen . e   . nbpeto . famille des pentaedres                     .
c . cfapen . e   . nctfpe*. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . nbpejs . e   .   1    . nombre de pentaedres de joints simples     .
c . nbjois . e   .   1    . nombre de joints simples                   .
c . tbaux1 . e   .4*nbpejs. Pour le i-eme pentaedre de joint simple :  .
c .        .     .        . (1,i) : numero du triangle a dupliquer     .
c .        .     .        . (2,i) : numero du joint simple cree        .
c .        .     .        . (3,i) : tetraedre du cote min(fammed)      .
c .        .     .        . (4,i) : tetraedre du cote max(fammed)      .
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
      parameter ( nompro = 'MMAG41' )
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
#include "nombtr.h"
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
      integer nbpejs, nbjois
      integer somare(2,nbarto), aretri(nbtrto,3)
      integer fampen(nbpeto), cfapen(nctfpe,nbfpen)
      integer tbaux1(4,nbpejs)
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
      integer iaux, jaux, kaux
      integer numpen
      integer sa1a2, sa2a3, sa3a1
      integer letria
c
      double precision v2(3), v3(3), vn(3)
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbjois', nbjois
      write (ulsort,90002) 'nbpejs', nbpejs
#endif
c
      codret = 0
c
c====
c 2. calcul des surfaces
c====
c
c 2.1. ==> initialisation
c
      do 21 , iaux = 1 , nbjois
        famval(iaux) = 0.d0
   21 continue
c
c 2.2. ==> calcul
c
      do 22 , numpen = 1 , nbpejs
c
        letria = tbaux1(1,numpen)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'numpen', numpen
      write (ulsort,texte(langue,4)) ' ', mess14(langue,1,2), letria
      write (ulsort,texte(langue,18)) ' ',mess14(langue,1,7),
     >                                    tbaux1(2,numpen)
#endif
c
c 2.2.1. ==> les aretes et les noeuds du triangle
c
        iaux = aretri(letria,1)
        jaux = aretri(letria,2)
        kaux = aretri(letria,3)
c
        call utsotr ( somare, iaux, jaux, kaux,
     >                sa1a2, sa2a3, sa3a1 )
c
c 2.2.2. ==> calcul de la surface
c            on rappelle que la surface d'un triangle est egale
c            a la moitie de la norme du produit vectoriel de deux
c            des vecteurs representant les aretes.
c
        v2(1) = coonoe(sa2a3,1) - coonoe(sa1a2,1)
        v2(2) = coonoe(sa2a3,2) - coonoe(sa1a2,2)
        v2(3) = coonoe(sa2a3,3) - coonoe(sa1a2,3)
c
        v3(1) = coonoe(sa3a1,1) - coonoe(sa1a2,1)
        v3(2) = coonoe(sa3a1,2) - coonoe(sa1a2,2)
        v3(3) = coonoe(sa3a1,3) - coonoe(sa1a2,3)
c
        vn(1) = v2(2)*v3(3) - v2(3)*v3(2)
        vn(2) = v2(3)*v3(1) - v2(1)*v3(3)
        vn(3) = v2(1)*v3(2) - v2(2)*v3(1)
c
        daux = sqrt ( vn(1)*vn(1) + vn(2)*vn(2) + vn(3)*vn(3) )
c
        daux = 0.5d0 * daux
c
c 2.2.3. ==> stockage dans le bon joint
c
        iaux = tbaux1(2,numpen)
        famnum(iaux) = cfapen(cofamd,fampen(numpen))
        famval(iaux) = famval(iaux) + daux
cgn      if ( iaux.ge.1 ) then
cgn      write (ulsort,90002) 'noeuds', sa1a2, sa2a3, sa3a1
cgn      write (ulsort,92010) '==> surface =', daux
cgn      write (ulsort,90002) 'iaux, fampen, fammed', iaux,
cgn     >  fampen(numpen),cfapen(cofamd,fampen(numpen))
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
      write (ulsort,91010) (famnum(iaux),iaux=1,nbjois)
      write (ulsort,92010) (famval(iaux),iaux=1,nbjois)
#endif
c
      iaux = 2
      kaux = 2
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB13E_j_simple', nompro
#endif
      call utb13e ( kaux, iaux,
     >              nbfmed, numfam,
     >              grfmpo, grfmtl, grfmtb,
     >              nbgrfm, nomgro, lgnogr,
     >              nbjois, famnum, famval,
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

      subroutine vcmexa ( lgopti, taopti, lgopts, taopts,
     >                    lgetco, taetco,
     >                    ulsort, langue, codret)
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
c    aVant adaptation - Conversion de Maillage EXtrude - phase A
c     -                 -             -        --              -
c    Pour un maillage non initial
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lgopti . e   .   1    . longueur du tableau des options            .
c . taopti . e   . lgopti . tableau des options                        .
c . lgopts . e   .   1    . longueur du tableau des options caracteres .
c . taopts . e   . lgopts . tableau des options caracteres             .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'VCMEXA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "gmreel.h"
c
#include "envex1.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer lgopti
      integer taopti(lgopti)
c
      integer lgopts
      character*8 taopts(lgopts)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nretap, nrsset
      integer iaux
      integer tbiaux(1)
      integer codre1, codre2, codre3, codre4
      integer codre0
      integer ptrav5, ptrav6, ptrav7, ptrav8
      integer pcoono, pareno, phetno, adcocs
      integer psomar, phetar, pfilar, pmerar, pnp2ar
      integer paretr, phettr, pfiltr, ppertr, pnivtr, adnmtr, adpetr
      integer parequ, phetqu, pfilqu, pperqu, pnivqu, adnmqu, adhequ
      integer phethe, pquahe, pcoquh
      integer phetpe, pfacpe, pcofap
      integer pposif, pfacar
c
      integer adnohn, adnocn
      integer adtrhn, adtrcn
      integer adquhn, adqucn
c
      integer pfamno, pcfano
      integer pfammp, pcfamp
      integer pfamar, pcfaar
      integer pfamtr, pcfatr
      integer pfamqu, pcfaqu
      integer pfamhe, pcfahe
      integer pfampe, pcfape
      integer nbqure
      integer nbtrre
      integer nbarre
      integer nbnore
      integer nbp2re, nbimre
      integer adhono, adhoar, adhotr, adhoqu
c
      character*6 saux
      character*9 saux09
      character*8 nomail
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhhexa, nhpent
      character*8 norenu
      character*8 ntrav5, ntrav6, ntrav7, ntrav8
c
      integer nbmess
      parameter ( nbmess = 10 )
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
      if ( taopti(11).eq.26 ) then
        saux09 = 'SATURNE  '
      elseif ( taopti(11).eq.46 ) then
        saux09 = 'NEPTUNE  '
      else
        if ( langue.eq.1 ) then
          saux09 = 'EXTRUSION'
        else
          saux09 = 'EXTRUSION'
        endif
      endif
c
      texte(1,4) =
     > '(/,a6,1x,'''//saux09//' - PASSAGE DU MAILLAGE 3D EN 2D'')'
      texte(1,5) = '(47(''=''),/)'
c
      texte(2,4) = '(/,a6,1x,'''//saux09//' - FROM 3D MESH TO 2D'')'
      texte(2,5) = '(37(''=''),/)'
c
c 1.4. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.5 ==> le titre
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
      codret = 0
c
#include "impr03.h"
c
c====
c 2. les structures de base
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. structures de base ; codret', codret
#endif
c
c 2.1. ==> Le maillage 3D au format HOMARD
c
      nomail = taopts(3)
c
c 2.2. ==> Les adresses
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. adresses ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = taopti(39)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMEXB', nompro
#endif
      call vcmexb ( nomail,   iaux,
     >              phetno,
     >              pcoono, pareno, adhono, adcocs,
     >              adnohn, adnocn,
     >              phetar, psomar, pfilar, pmerar,
     >              pnp2ar, adhoar,
     >              phettr, paretr, pfiltr, ppertr,
     >              pnivtr, adnmtr, adhotr, adpetr,
     >              adtrhn, adtrcn,
     >              phetqu, parequ, pfilqu, pperqu,
     >              pnivqu, adnmqu, adhoqu, adhequ,
     >              adquhn, adqucn,
     >              phethe, pquahe, pcoquh,
     >              phetpe, pfacpe, pcofap,
     >              pfamno, pcfano,
     >              pfammp, pcfamp,
     >              pfamar, pcfaar,
     >              pfamtr, pcfatr,
     >              pfamqu, pcfaqu,
     >              pfamhe, pcfahe,
     >              pfampe, pcfape,
     >              pposif, pfacar,
     >              nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >              nhhexa, nhpent, norenu,
     >              ulsort, langue, codret)
c
      endif
c
c 2.3. ==> Tableaux de travail
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. Tableaux de travail ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav5, 'entier  ', nbnoto, ptrav5, codre1 )
      call gmalot ( ntrav6, 'entier  ', nbarto, ptrav6, codre2 )
      call gmalot ( ntrav7, 'entier  ', nbtrto, ptrav7, codre3 )
      call gmalot ( ntrav8, 'entier  ', nbquto, ptrav8, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c====
c 3. Reperage du positionnement des entites
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. reperage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMEX0', nompro
#endif
      call vcmex0 ( iaux,
     >              rmem(adcocs),
     >              rmem(pcoono), imem(ptrav5),
     >              imem(psomar), imem(ptrav6),
     >              imem(paretr), imem(ptrav7),
     >              imem(parequ), imem(ptrav8), tbiaux,
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx ('Position des noeuds :', ntrav5)
      call gmprsx ('Position des aretes :', ntrav6)
      call gmprsx ('Position des triangles :', ntrav7)
      call gmprsx ('Position des quadrangles :', ntrav8)
#endif
c
      endif
c
c====
c 4. Destruction des entites inutiles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. destruction ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMEXD', nompro
#endif
      call vcmexd ( nomail,
     >           nhnoeu, nharet, nhtria, nhquad,
     >           nhhexa, nhpent, norenu,
     >           imem(ptrav5), nbnore, nbp2re, nbimre,
     >           imem(phetno), rmem(pcoono),
     >           imem(pareno), imem(adhono),
     >           imem(adnocn), imem(adnohn),
     >           imem(ptrav6), nbarre,
     >           imem(phetar), imem(psomar), imem(pmerar), imem(pfilar),
     >           imem(pnp2ar), imem(adhoar),
     >           imem(pposif), imem(pfacar),
     >           imem(ptrav7), nbtrre,
     >           imem(phettr), imem(paretr), imem(ppertr), imem(pfiltr),
     >           imem(pnivtr), imem(adpetr), imem(adnmtr), imem(adhotr),
     >           imem(adtrcn), imem(adtrhn),
     >           imem(ptrav8), nbqure,
     >           imem(phetqu), imem(parequ), imem(pperqu), imem(pfilqu),
     >           imem(pnivqu), imem(adhequ), imem(adnmqu),
     >           imem(adqucn), imem(adquhn),
     >           rmem(adcocs),
     >           imem(pfamno), imem(pcfano),
     >           imem(pfammp), imem(pcfamp),
     >           imem(pfamar), imem(pcfaar),
     >           imem(pfamtr), imem(pcfatr),
     >           imem(pfamqu), imem(pcfaqu),
     >           imem(pcfahe),
     >           imem(pcfape),
     >           ulsort, langue, codret)
c
      endif
c
c====
c 5. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav5 , codre1  )
      call gmlboj ( ntrav6 , codre2  )
      call gmlboj ( ntrav7 , codre3  )
      call gmlboj ( ntrav8 , codre4  )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c====
c 11. la fin
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

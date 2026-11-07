      subroutine vcmext ( lgopti, taopti, lgopts, taopts,
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
c    aVant adaptation - Conversion de Maillage EXTrude
c     -                 -             -        ---
c    Pour un maillage initial
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
      parameter ( nompro = 'VCMEXT' )
c
#include "nblang.h"
#include "consts.h"
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
#include "nbfami.h"
#include "dicfen.h"
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
      integer iaux, jaux, kaux
      integer codre1, codre2, codre3, codre4
      integer codre0
      integer ptrav1, ptrav2, ptrav3, ptrav4
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
      integer pfamno, pcfano, pcofno
      integer pfammp, pcfamp
      integer pfamar, pcfaar, pcofar
      integer pfamtr, pcfatr, pcoftr
      integer pfamqu, pcfaqu, pcofqu
      integer pfamhe, pcfahe
      integer pfampe, pcfape
      integer nbqure
      integer nbtrre
      integer nbarre
      integer nbnore
      integer nbp2re, nbimre
      integer nbfent
      integer adhono, adhoar, adhotr, adhoqu
      integer notfno, notfar, notftr, notfqu
      integer nofano, nofaar, nofatr, nofaqu
c
      character*6 saux
      character*9 saux09
      character*8 nomail
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhhexa, nhpent
      character*8 norenu
      character*8 nhnofa, nharfa, nhtrfa, nhqufa
      character*8 nhpefa
      character*8 nhenti, nhenfa
      character*8 ntrav1, ntrav2, ntrav3, ntrav4
      character*8 ntrav5, ntrav6, ntrav7, ntrav8
      character*8 nforfa(-1:4)
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
      iaux = 0
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
c 2.3. ==> Sauvegarde des familles d'origine
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. Sauvegarde familles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      do 23 , iaux = -1, 4
c
        if ( codret.eq.0 ) then
c
        if ( iaux.eq.-1 ) then
          nhenti = nhnoeu
          nbfent = nbfnoe
        elseif ( iaux.eq.1 ) then
          nhenti = nharet
          nbfent = nbfare
        elseif ( iaux.eq.2 ) then
          nhenti = nhtria
          nbfent = nbftri
        elseif ( iaux.eq.4 ) then
          nhenti = nhquad
          nbfent = nbfqua
        else
          nforfa(iaux) = blan08
          goto 23
        endif
c
        call gmnomc ( nhenti//'.Famille', nhenfa, codre0 )
        codret = max ( abs(codre0), codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        if ( iaux.eq.-1 ) then
          nhnofa = nhenfa
        elseif ( iaux.eq.1 ) then
          nharfa = nhenfa
        elseif ( iaux.eq.2 ) then
          nhtrfa = nhenfa
        elseif ( iaux.eq.4 ) then
          nhqufa = nhenfa
        endif
c
        jaux = 0
        call gmcpal ( nhenfa//'.Codes',
     >                nforfa(iaux), jaux, kaux, codre0 )
c
        codret = max ( abs(codre0), codret )
c
        endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90012) '.. codre0123 apres phase',
     >                     iaux, codre0, codre1, codre2, codre3
cgn      call gmprsx ( nompro, nforfa(iaux) )
#endif
c
        if ( codret.eq.0 ) then
c
        if ( iaux.eq.-1 ) then
          pcofno = kaux
        elseif ( iaux.eq.1 ) then
          pcofar = kaux
        elseif ( iaux.eq.2 ) then
          pcoftr = kaux
        elseif ( iaux.eq.4 ) then
          pcofqu = kaux
        endif
c
        endif
c
   23 continue
c
      endif
c
c 2.4. ==> Tableaux de travail
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.4. Tableaux de travail ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 2*nbnoto
      call gmalot ( ntrav1, 'entier  ',   iaux, ptrav1, codre1 )
      iaux = 4*nbarto
      call gmalot ( ntrav2, 'entier  ',   iaux, ptrav2, codre2 )
      iaux = 3*nbtrto
      call gmalot ( ntrav3, 'entier  ',   iaux, ptrav3, codre3 )
      iaux = 3*nbquto
      call gmalot ( ntrav4, 'entier  ',   iaux, ptrav4, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
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
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMEX0', nompro
#endif
      call vcmex0 ( iaux,
     >              rmem(adcocs),
     >              rmem(pcoono), imem(ptrav5),
     >              imem(psomar), imem(ptrav6),
     >              imem(paretr), imem(ptrav7),
     >              imem(parequ), imem(ptrav8), imem(ptrav4),
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
c 4. Memorisation des informations pour l'extrusion
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Memorisation extrusion ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMEX1', nompro
#endif
      call vcmex1 (               imem(pfamno),
     >              imem(ptrav5), imem(ptrav1),
     >              imem(psomar), imem(pfamar),
     >              imem(ptrav6), imem(ptrav2),
     >                            imem(pfamtr),
     >              imem(ptrav7), imem(ptrav3), imem(adpetr),
     >              imem(parequ), imem(pfamqu),
     >              imem(ptrav8), imem(ptrav4), imem(adhequ),
     >              imem(pquahe), imem(pcoquh), imem(pfamhe),
     >              imem(pfacpe), imem(pcofap), imem(pfampe),
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      call gmprsx ('inxnoe - noeuds :', ntrav1)
      call gmprsx ('inxare - aretes :', ntrav2)
      call gmprsx ('inxtri - triangles :', ntrav3)
      call gmprsx ('inxqua - quadrangles :', ntrav4)
#endif
c
      endif
c
c====
c 5. Creation des tableaux de memorisation des familles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. creation tableaux ; codret', codret
#endif
c 5.1. ==> Les familles des pentaedres
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nhpent//'.Famille', nhpefa, codre0 )
      codret = max ( abs(codre0), codret )
c
      endif
c
c 5.2. ==> La creation
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.2. creation ; codret', codret
#endif
      if ( codret.eq.0 ) then
c
      notfno = nctfno
      notfar = nctfar
      notftr = nctftr
      notfqu = nctfqu
c
      nofano = nbfnoe
      nofaar = nbfare
      nofatr = nbftri
      nofaqu = nbfqua
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMEX2', nompro
#endif
      call vcmex2 (
     >        taopti(30),
     >        nhnofa, imem(pfamno), notfno, nofano, imem(pcofno),
     >        imem(ptrav5), imem(ptrav1), pcfano,
     >        nharfa, imem(pfamar), notfar, nofaar, imem(pcofar),
     >        imem(ptrav6), imem(ptrav2), pcfaar,
     >        nhtrfa, imem(pfamtr), notftr, nofatr, imem(pcoftr),
     >        imem(ptrav7), imem(ptrav3), pcfatr,
     >        nhqufa, imem(pfamqu), notfqu, nofaqu, imem(pcofqu),
     >        imem(ptrav8), imem(ptrav4), pcfaqu,
     >        pcfahe,
     >        nhpefa, pcfape,
     >        ulsort, langue, codret )
c
      endif
c
c====
c 6. Destruction des entites inutiles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. destruction ; codret', codret
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
c 7. Menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codre1  )
      call gmlboj ( ntrav2 , codre2  )
      call gmlboj ( ntrav3 , codre3  )
      call gmlboj ( ntrav4 , codre4  )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
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
      do 71 , iaux = -1, 4
c
        if ( nforfa(iaux).ne.blan08 ) then
          call gmlboj ( nforfa(iaux) , codre0 )
          codret = max ( abs(codre0), codret )
        endif
c
   71   continue
c
      endif
c
cgn      call gmprsx ( nompro, nhtria//'.InfoSupp' )
cgn      call gmprsx ( nompro, norenu//'.TrCalcul' )
cgn      call gmprsx ( nompro, norenu//'.TrHOMARD' )
cgn      call gmprsx ( nompro, norenu//'.PeCalcul' )
cgn      call gmprsx ( nompro, norenu//'.PeHOMARD' )
cgn      call gmprsx ( nompro, nhquad//'.InfoSupp' )
cgn      call gmprsx ( nompro, norenu//'.QuCalcul' )
cgn      call gmprsx ( nompro, norenu//'.QuHOMARD' )
cgn      call gmprsx ( nompro, norenu//'.HeCalcul' )
cgn      call gmprsx ( nompro, norenu//'.HeHOMARD' )
c
c====
c 8. la fin
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

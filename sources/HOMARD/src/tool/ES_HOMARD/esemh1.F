      subroutine esemh1 ( nomail, nomfic, lnomfi,
     >                    optecr,
     >                    nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    nhelig,
     >                    nhsups,
     >                    suifro, nocdfr,
     >                    ulsort, langue, codret)
c
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
c  Entree-Sortie : Ecriture du Maillage Homard - 1
c  -      -        -           -        -        -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nomail . e   . char*8 . nom du maillage a ecrire                   .
c . nomfic . e   .char*(*). nom du fichier                             .
c . lnomfi . e   .   1    . longueur du nom du fichier                 .
c . optecr . e   .   1    . option d'ecriture                          .
c .        .     .        . >0 : on ecrit la frontiere discrete        .
c .        .     .        . <0 : on n'ecrit pas la frontiere discrete  .
c . nhsups . e   . char*8 . informations supplementaires caracteres 8  .
c . suifro . e   .   1    . 1 : pas de suivi de frontiere              .
c .        .     .        . 2x : frontiere discrete                    .
c .        .     .        . 3x : frontiere analytique                  .
c .        .     .        . 5x : frontiere cao                         .
c . nocdfr . e   . char8  . nom de l'objet description de la frontiere .
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
      parameter ( nompro = 'ESEMH1' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "dicfen.h"
#include "envex1.h"
#include "envca1.h"
#include "nbutil.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombno.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
c
c 0.3. ==> arguments
c
      integer lnomfi
      integer optecr
      integer suifro
c
      character*8 nomail, nhsups
      character*(*) nomfic
c
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent, nhelig
      character*8 nocdfr
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux, kaux
      integer codre0
      integer codre1, codre2, codre3
      integer*8 idfmed
      integer ltrav1, ltrav2
      integer ptrav1, ptrav2
      integer dimcst, lgnoig, nbnoco
      integer adcocs
      integer infmgl(0:30)
      integer nbpqt
      integer adinss
      integer numdt, numit
      integer sfnbso
c
      character*8 ntrav1, ntrav2
      character*64 nomamd
      character*80 saux80
      character*200 sau200
c
      double precision instan
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
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
      texte(1,4) = '(''Ecriture complete.'')'
      texte(1,5) = '(''Ecriture sans les frontieres.'')'
c
      texte(2,4) = '(''Full writings.'')'
      texte(2,5) = '(''Writings without any boundary.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      if ( optecr.gt.0 ) then
        iaux = 4
      else
        iaux = 5
      endif
      write (ulsort,texte(langue,iaux))
#endif
c
#include "esimpr.h"
c
c 1.2. ==> tableaux de travail
c
      jaux = 0
      do 12 , iaux = 1 , 10
        call gmliat ( nhsups, iaux, kaux, codre0 )
        if ( codre0.eq.0 ) then
          jaux = max(jaux,kaux)
        else
          codret = codre0
        endif
   12 continue
c
      if ( codret.eq.0 ) then
c
      if ( mod(suifro,2).eq.0 ) then
        call gmliat ( nocdfr, 3, sfnbso, codret )
      else
        sfnbso = 0
        codre2 = 0
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'Nombre elements ignores', nbelig
      write (ulsort,90002) 'Noeuds de la frontiere ', sfnbso
#endif
c
      if ( codret.eq.0 ) then
c
      ltrav1 = max ( 4*nbnoto,
     >             nbmpto, 5*nbarto, 5*nbtrto, 6*nbteto, 5*nbquto,
     >             7*nbpyto, 8*nbheto, 5*nbpeto, 14*nbelig+1,
     >             sfnbso )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '==> ltrav1', ltrav1
#endif
      call gmalot ( ntrav1, 'entier  ', ltrav1   , ptrav1, codre1 )
c
c   A TRAITER pas clair le +11 ...
      ltrav2 = 25*( max ( nctfno, nctfmp, nctfar, nctftr, nctfqu,
     >                    nctfte, nctfpy, nctfhe, nctfpe, 40 ) + 11 )
      ltrav2 = max ( ltrav2, jaux+11 )
      call gmalot ( ntrav2, 'chaine  ', ltrav2   , ptrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 1.2. ==> Instants d'enregistrement du maillage
c
      if ( codret.eq.0 ) then
c
      numdt = ednodt
      numit = ednoit
      instan = edundt
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90003) 'fichier', nomfic(1:lnomfi)
      write (ulsort,90003) 'nomail',nomail
      write (ulsort,90002) 'numdt ',numdt
      write (ulsort,90002) 'numit ',numit
      write (ulsort,90004) 'dt    ',instan
#endif
c
      endif
c
c====
c 2. ouverture en mode d'ecrasement
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. ouverture ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFIOPE', nompro
#endif
      call mfiope ( idfmed, nomfic(1:lnomfi), edcrea, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,9))
      endif
c
      endif
c
c====
c 3. description du fichier
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. description fichier ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      saux80 = blan80
      saux80(1:54) =
     > 'Maillage au format HOMARD avec gestion des historiques'
c       123456789012345678901234567890123456789012345678901234
c       12345678901234567890
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESDESC', nompro
#endif
      call esdesc ( idfmed, saux80, sau200,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. creation du maillage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. creation maillage ; codret', codret
      write (ulsort,90002) 'sdim', sdim
      write (ulsort,90002) 'mdim', mdim
#endif
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( nhsups//'.Tab3', adinss, iaux, codre1 )
      call gmliat ( nhsups, 1, iaux, codre2 )
      nbpqt = iaux - 1
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      nomamd = blan64
      nomamd(1:8) = nomail
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMM0', nompro
#endif
      call esemm0 ( idfmed, nomamd,
     >                sdim,   mdim, sau200,
     >               nbpqt, smem(adinss),
     >              ulsort, langue, codret)
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,78)) 'ESEMM0', codret
      endif
c
      endif
c
c====
c 5. Ecriture des noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Ecriture des noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECNO', nompro
#endif
      call esecno ( idfmed, nomamd,
     >              nhnoeu,
     >              numdt, numit, instan,
     >              ltrav1, imem(ptrav1),
     >              ulsort, langue, codret)
c
      endif
c
c====
c 6. Ecriture des entites mailles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Ecriture des mailles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECEN', nompro
#endif
      call esecen ( idfmed, nomamd,
     >              nhmapo, nharet, nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              numdt, numit, instan,
     >              ltrav1, imem(ptrav1),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 7. Ecriture des familles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. Ecriture des familles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMH2', nompro
#endif
      call esemh2 ( idfmed, nomamd,
     >              nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhsups,
     >              ltrav1, imem(ptrav1), ltrav2, smem(ptrav2),
     >              ulsort, langue, codret)
c
      endif
c
c====
c 8. Ecriture des informations supplementaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. Informations supp ; codret', codret
#endif
c 8.1. ==> informations globales au maillage
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhnoeu, 2, dimcst, codre1 )
      call gmliat ( nhnoeu, 3, lgnoig, codre2 )
      call gmliat ( nhnoeu, 4, nbnoco, codre3)
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
      if ( codret.eq.0 ) then
c
c envca1 + divers
      infmgl( 1) = sdim
      infmgl( 2) = mdim
      infmgl( 3) = degre
      infmgl( 4) = maconf
      infmgl( 5) = homolo
      infmgl( 6) = hierar
      infmgl( 7) = rafdef
      infmgl( 8) = nbmane
      infmgl( 9) = typcca
      infmgl(10) = typsfr
      infmgl(11) = maextr
      infmgl(12) = mailet
      infmgl(13) = dimcst
      infmgl(14) = lgnoig
      infmgl(15) = nbnoco
c nbutil
      infmgl(16) = sdimca
      infmgl(17) = mdimca
c
      infmgl(0) = 17
c
      endif
c
c 8.2. ==> Une coordonnee constante ?
c
      if ( codret.eq.0 ) then
c
      if ( dimcst.gt.0 ) then
c
        call gmadoj ( nhnoeu//'.CoorCons', adcocs, iaux, codre0 )
c
        codret = max ( abs(codre0), codret )
c
      endif
c
      endif
c
c 8.3 ==> ecriture
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECSU', nompro
#endif
      call esecsu ( idfmed,
     >              nomail,
     >              nhnoeu,
     >              nhmapo, nharet, nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              infmgl,
     >              dimcst, rmem(adcocs),
     >              numdt, numit, instan,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 9. Ecriture des eventuels elements ignores
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. Elements ignores ; codret', codret
#endif
c
      if ( nbelig.ne.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECIG', nompro
#endif
        call esecig ( idfmed,
     >                nhelig,
     >                imem(ptrav1),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 10. Ecriture de l'eventuelle frontiere discrete
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. Frontiere discrete ; codret', codret
#endif
c
      if ( mod(suifro,2).eq.0 .and. optecr.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECFD', nompro
#endif
        call esecfd ( idfmed,
     >                nocdfr,
     >                ltrav1, imem(ptrav1), ltrav2, smem(ptrav2),
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 11. fermeture du fichier
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '11. fermeture du fichier ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFICLO', nompro
#endif
      call mficlo ( idfmed, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,10))
      endif
c
      endif
c
c====
c 12. menage
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '12. menage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1 , codre1 )
      call gmlboj ( ntrav2 , codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 13. la fin
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

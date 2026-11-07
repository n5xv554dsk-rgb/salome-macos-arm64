      subroutine ututso ( nocsol, nocmai,
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
c    UTilitaire - UTilitaire sur une SOlution
c    --           --                 --
c    C'est un programme qui offre un canevas.
c    A modifier selon les usages
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocsol . e   . char8  . nom de l'objet solution                    .
c . nocmai . e   . char*8 . nom de l'objet maillage calcul             .
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
      parameter ( nompro = 'UTUTSO' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "esutil.h"
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      character*8 nocsol, nocmai
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux
      integer ideb , ifin
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7
      integer codre0
c
      integer sdim, mdim
      integer degre, mailet, maconf, homolo, hierar, nbnomb
      integer nbmapo, nbsegm, nbtria, nbtetr,
     >        nbquad, nbhexa, nbpent, nbpyra
      integer typnoe, typpoi, typseg, typtri, typtet
      integer typqua, typhex, typpyr, typpen
      integer nbcham, nbpafo, nbprof, nblopg
      integer adinch, adinpf, adinpr, adinlg
      integer typgeo, ngauss, nbenmx, nbtyas
      integer carsup, nbtafo, typint
      integer adnomb
      integer advale, advalr, adobch, adprpg, adtyas
      integer typcha, nbcomp, nbvapr, nbtvch
      integer adnocp, adcaen, adcare, adcaca
c
      integer nbmaae, nbmafe, nbmnei
      integer numano, numael
      integer nbma2d, nbma3d
      integer nbfmed, nbfmen, ngrouc
      integer nbequi, nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu
c
      character*8 nopafo, nocham
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
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
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nocsol )
      call gmprsx (nompro, nocsol//'.InfoCham' )
      call gmprsx (nompro, nocsol//'.InfoPaFo' )
      call gmprsx (nompro, nocsol//'.InfoProf' )
#endif
c
c====
c 2. preliminaires
c====
c 2.1. ==> les caracteristiques du maillage
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMC', nompro
#endif
      call utnomc ( nocmai,
     >                sdim,   mdim,
     >               degre, mailet, maconf, homolo, hierar,
     >              nbnomb,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccoex, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret)
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( ncnomb, adnomb, iaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNBMC', nompro
#endif
      call utnbmc ( imem(adnomb),
     >              nbmaae, nbmafe, nbmnei,
     >              numano, numael,
     >              nbma2d, nbma3d,
     >              nbmapo, nbsegm, nbtria, nbtetr,
     >              nbquad, nbhexa, nbpent, nbpyra,
     >              nbfmed, nbfmen, ngrouc,
     >              nbequi,
     >              nbeqno, nbeqmp, nbeqar, nbeqtr, nbeqqu,
     >              ulsort, langue, codret )
c
      endif
c
c 2.2. ==> grandeurs de base
c
      typnoe = 0
      typpoi = edpoi1
      if ( degre.eq.1 ) then
        typseg = edseg2
        typtri = edtri3
        typtet = edtet4
        typqua = edqua4
        typhex = edhex8
        typpyr = edpyr5
        typpen = edpen6
      else
        typseg = edseg3
        typtri = edtri6
        typtet = edte10
        typqua = edqua8
        typhex = edhe20
        typpyr = edpy13
        typpen = edpe15
      endif
c
c====
c 3. Creation d'un couple champ/fonction
c====
c
c 3.1. ==> la fonction
c
c 3.1.1. ==> la structure d'accueil
c
      if ( codret.eq.0 ) then
c
      iaux = 1
      typgeo = typtet
      ngauss = ednopg
      nbenmx = nbtetr
      nbvapr = -1
      nbtyas = 0
      carsup = 0
      nbtafo = 1
      typint = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTALFO', nompro
#endif
      call utalfo ( nopafo, iaux,
     >              typgeo, ngauss, nbenmx, nbvapr, nbtyas,
     >              carsup, nbtafo, typint,
     >              advale, advalr, adobch, adprpg, adtyas,
     >              ulsort, langue, codret )
c
      endif
c
c 3.1.2. ==> les valeurs
c
      if ( codret.eq.0 ) then
c
      ideb = advalr
      ifin = advalr + nbenmx - 1
      do 3121 , iaux = ideb , ifin
        rmem(iaux) = 100.d0
 3121 continue
      rmem(advalr+0) = 200.d0
      rmem(advalr+2) = 200.d0
      rmem(advalr+9) = 200.d0
      rmem(advalr+15) = 200.d0
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nopafo )
      call gmprsx (nompro, nopafo//'.ValeursR' )
#endif
c
c 3.2. ==> le champ
c
c 3.2.1. ==> la structure d'accueil
c
      if ( codret.eq.0 ) then
c
      call gmalot ( nocham, 'InfoCham', 0, iaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      nbcomp = 1
      nbtvch = 1
      typcha = edint
      typcha = edfl64
      call gmecat ( nocham, 1, nbcomp, codre1 )
      call gmecat ( nocham, 2, nbtvch, codre2 )
      call gmecat ( nocham, 3, typcha, codre3 )
      iaux = 4 + 2*nbcomp
      call gmaloj ( nocham//'.Nom_Comp', ' ', iaux, adnocp, codre4 )
      iaux = nbinec * nbtvch
      call gmaloj ( nocham//'.Cham_Ent', ' ', iaux, adcaen, codre5 )
      call gmaloj ( nocham//'.Cham_Ree', ' ', nbtvch, adcare, codre6 )
      iaux = 5 * nbtvch
      call gmaloj ( nocham//'.Cham_Car', ' ', iaux, adcaca, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      endif
c
c 3.2.2. ==> les valeurs
c
      if ( codret.eq.0 ) then
c
c                       12345678
      smem(adnocp+0) = 'INDICATE'
      smem(adnocp+1) = 'UR_D_ERR'
      smem(adnocp+2) = 'EUR_1   '
      smem(adnocp+3) = '        '
      smem(adnocp+4) = 'ERREUR  '
      smem(adnocp+5) = '        '
c          Rappel :
c       1. type de support au sens MED
c       2. numero du pas de temps
c       3. numero d'ordre
c       4. nombre de points de Gauss
c       5. nombre d'entites support
c       6. nombre de valeurs du profil eventuel
c       7. nombre de supports associes
c       8. noeuds par elements/points de Gauss/autre
c       9. numero du 1er tableau dans la fonction
c       10. -1 ou champ elga/champ elno
c       11. type interpolation
c
      imem(adcaen+0) = typgeo
      imem(adcaen+1) = ednodt
      imem(adcaen+2) = ednonr
      imem(adcaen+3) = ednopg
      imem(adcaen+4) = nbenmx
      imem(adcaen+5) = -1
      imem(adcaen+6) = 0
      imem(adcaen+7) = 01
      imem(adcaen+8) = 1
      imem(adcaen+9) = -1
      imem(adcaen+10) = 0
c
      rmem(adcare) = 1792.d0
c
c                       12345678
      smem(adcaca+0) = '        '
      smem(adcaca+1) = nopafo
      smem(adcaca+2) = '        '
      smem(adcaca+3) = '        '
      smem(adcaca+4) = '        '
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nocham )
      call gmprsx (nompro, nocham//'.Nom_Comp' )
      call gmprsx (nompro, nocham//'.Cham_Ent' )
      call gmprsx (nompro, nocham//'.Cham_Ree' )
      call gmprsx (nompro, nocham//'.Cham_Car' )
#endif
c
c====
c 4. mise en place dans la solution
c====
c
c 4.1. ==> caracteristiques de depart
c
      if ( codret.eq.0 ) then
c
      call utcaso ( nocsol,
     >              nbcham, nbpafo, nbprof, nblopg,
     >              adinch, adinpf, adinpr, adinlg,
     >              ulsort, langue, codret )
c
      endif
c
c 4.2. ==> ajout
c
      if ( codret.eq.0 ) then
c
      call gmmod ( nocsol//'.InfoPaFo',
     >             adinpf, nbpafo, nbpafo+1, 1, 1, codre1 )
      call gmmod ( nocsol//'.InfoCham',
     >             adinch, nbcham, nbcham+1, 1, 1, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      smem(adinch+nbcham) = nocham
      smem(adinpf+nbpafo) = nopafo
c
      nbcham = nbcham + 1
      nbpafo = nbpafo + 1
      call gmecat ( nocsol, 1, nbcham, codre1 )
      call gmecat ( nocsol, 2, nbpafo, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nocsol )
      call gmprsx (nompro, nocsol//'.InfoCham' )
      call gmprsx (nompro, nocsol//'.InfoPaFo' )
      call gmprsx (nompro, nocsol//'.InfoProf' )
#endif
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

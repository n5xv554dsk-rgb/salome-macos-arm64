      subroutine vcms20 ( nocman, maext0,
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
c    aVant adaptation - Conversion de Maillage -
c     -                 -             -
c                       Saturne 2D - phase 0 - Neptune 2D
c                       -       -          -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocman . e   . char*8 . nom de l'objet maillage calcul iteration n .
c . maext0 . e   .   1    . maillage extrude                           .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : selon X                                .
c .        .     .        . 2 : selon Y                                .
c .        .     .        . 3 : selon Z (cas de Saturne ou Neptune)    .
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
      parameter ( nompro = 'VCMS20' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "envca1.h"
c
#include "nbutil.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      character*8 nocman
c
      integer maext0
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbele2, nbman2, nbmaa2, nbmaf2
      integer nbse2d, nbtr2d, nbqu2d
      integer nbno2d
      integer nbno3d
c
      integer pfamen, pfamee, pnoeel, ptypel, pcoonc, adcocs
      integer pnuele, pnunoe
      integer pinfpt, pinftl, pinftb
      integer nbnomb, adnomb
      integer lgpoin, lgtabl
c
      integer ptrav1, ptrav2
      integer pfano2, pcono2
      integer pfame2, ptype2, pnoee2
      integer famaux(3)
c
      integer iaux, jaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
c
      character*8 saux08
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
      character*8 ntrav1, ntrav2
      character*8 nfano2, ncono2
      character*8 nfame2, ntype2, nnoee2
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
      texte(1,4) = '(''Maillage'',i2,''D'')'
      texte(1,5) = '(''. Nombre de '',a,'' :'',i10)'
      texte(1,6) =
     >'(''Le nombre de noeuds,'',i10,'' devrait etre pair.'')'
c
      texte(2,4) = '(i1,''D mesh'')'
      texte(2,5) = '(''. Number of '',a,'' :'',i10)'
      texte(2,6) = '(''The number of nodes,'',i10,'' should be pair.'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'maext0', maext0
#endif
c
      maextr = maext0
c
c====
c 2. recuperation des donnees du maillage a modifier
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. recuperation donnees ; codret', codret
#endif
c
c 2.1. ==> les noms des structures
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMC', nompro
#endif
      call utnomc ( nocman,
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
c 2.2. ==> les principales constantes
c
      if ( codret.eq.0 ) then
c
      call gmliat ( ncnoeu, 1, nbno3d, codre1 )
      call gmliat ( nccono, 1, nbelem, codre2 )
      call gmadoj ( ncnomb, adnomb, iaux, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) 3
      write (ulsort,texte(langue,5)) mess14(langue,3,2), nbtria
      write (ulsort,texte(langue,5)) mess14(langue,3,4), nbquad
      write (ulsort,texte(langue,5)) mess14(langue,3,6), nbhexa
      write (ulsort,texte(langue,5)) mess14(langue,3,7), nbpent
#endif
c
      endif
c
c 2.3. ==> les adresses
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD11', nompro
#endif
      iaux = 114114
      call utad11 ( iaux, ncnoeu, nccono,
     >              pcoonc, pfamen,   jaux, adcocs,
     >              ptypel, pfamee, pnoeel,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. traitement des noeuds
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. traitement des noeuds ; codret', codret
#endif
c
c 3.1. ==> nombre de noeuds du futur maillage
c
      if ( codret.eq.0 ) then
c
      if ( mod(nbno3d,2).eq.0 ) then
c
        nbno2d = nbno3d/2 + 1
c
      else
c
        write (ulsort,texte(langue,6)) nbno3d
        codret = 1
c
      endif
c
      endif
c
c 3.2. ==> allocation des tableaux
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'entier  ', nbno2d, ptrav1, codre1 )
      call gmalot ( ntrav2, 'entier  ', nbno3d, ptrav2, codre2 )
      call gmalot ( nfano2, 'entier  ', nbno2d, pfano2, codre3 )
      iaux = nbno2d*2
      call gmalot ( ncono2, 'reel    ', iaux  , pcono2, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c 3.3. ==> traitement
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMS21', nompro
cgn      call gmprsx (nompro,ncnoeu//'.Coor')
#endif
      call vcms21 ( nbno3d, imem(pfamen), rmem(pcoonc), rmem(adcocs),
     >              nbno2d, imem(ptrav1), imem(ptrav2),
     >              imem(pfano2), rmem(pcono2), famaux(3),
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx (nompro//' - NUSTNO', ntrav1)
      call gmprsx (nompro//' - NU2DNO', ntrav2)
      call gmprsx (nompro//' - COON2D', ncono2)
      call dmflsh (iaux)
      endif
#endif
c
c====
c 4. traitement des mailles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. traitement des mailles ; codret', codret
#endif
c
c 4.1. ==> preliminaires
c          nombre de mailles du futur maillage :
c          1 hexaedre donne 1 quadrangle
c              --> nbhexa quadrangles
c          1 pentaedre donne 1 triangle
c              --> nbpent triangles
c          1 quadrangle sur la face superieure est ignore
c          1 quadrangle sur la face inferieure est ignore
c          1 quadrangle sur les faces laterales donne 1 segment
c              --> nbquad - 2*nbhexa segments
c
      if ( codret.eq.0 ) then
c
      nbse2d = nbquad - 2*nbhexa
      nbtr2d = nbpent
      nbqu2d = nbhexa
      nbele2 = nbtr2d + nbqu2d + nbse2d
      if ( nbtr2d.eq.0 .and. nbqu2d.eq.0 ) then
        nbman2 = 2
        nbmaa2 = 2
      elseif ( nbqu2d.eq.0 ) then
        nbman2 = 3
        nbmaa2 = 3
      else
        nbman2 = 4
        nbmaa2 = 4
      endif
      nbmaf2 = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) 2
      write (ulsort,texte(langue,5)) mess14(langue,3,1), nbse2d
      write (ulsort,texte(langue,5)) mess14(langue,3,2), nbtr2d
      write (ulsort,texte(langue,5)) mess14(langue,3,4), nbqu2d
#endif
c
      endif
c
c 4.2. ==> allocation des tableaux
c
      if ( codret.eq.0 ) then
c
      call gmalot ( nfame2, 'entier  ', nbele2, pfame2, codre1 )
      call gmalot ( ntype2, 'entier  ', nbele2, ptype2, codre2 )
      iaux = nbele2*nbman2
      call gmalot ( nnoee2, 'entier  ', iaux  , pnoee2, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c 4.3. ==> traitement
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCMS22', nompro
ccc      call gmprsx (nompro,nccono//'.FamilMED')
ccc      call gmprsx (nompro,nccono//'.Type')
ccc      call gmprsx (nompro,nccono//'.Noeuds')
#endif
      call vcms22 ( maextr,
     >              nbno3d, nbelem,
     >              nbse2d, nbtr2d, nbqu2d, nbele2,
     >              imem(ptrav2), rmem(pcoonc),
     >              imem(pfamee), imem(ptypel), imem(pnoeel),
     >              imem(pfame2), imem(ptype2), imem(pnoee2),
     >              famaux(1), famaux(2),
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx (nompro//' - Familles', nfame2)
      call gmprsx (nompro//' - Types des mailles', ntype2)
      call gmprsx (nompro//' - Connectivites', nnoee2)
      call dmflsh(iaux)
      endif
#endif
c
c====
c 5. Les informations generales
c    On ajoute 3 informations : familles des faces inf et sup,
c                               famille du noeud supplementaire
c    La longueur du tableau "Pointeur" evolue : + 3
c    Les nom et unite sont en char*16 alors que les numeros des
c    familles seront codes sur des char*8 :
c    . la longueur du tableau "Taille" evolue : + 3
c    . la longueur du tableau "Table" evolue  : + 3
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Informations generales ; codret', codret
#endif
c
c 5.1. ==> Caracteristiques de la structure et allongement du tableau
c          des pointeurs et des tables
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,ncinfo)
      call gmprsx (nompro,ncinfo//'.Pointeur')
      call gmprsx (nompro,ncinfo//'.Taille')
      call gmprsx (nompro,ncinfo//'.Table')
      call dmflsh(iaux)
#endif
c
      call gmliat ( ncinfo, 1, lgpoin, codre1 )
      call gmliat ( ncinfo, 2, lgtabl, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'lgpoin', lgpoin
      write (ulsort,90002) 'lgtabl', lgtabl
#endif
c
      iaux = lgpoin + 1
      call gmecat ( ncinfo, 1, iaux, codre1 )
      call gmmod ( ncinfo//'.Pointeur',
     >             pinfpt, lgpoin, iaux, 1, 1, codre2 )
      iaux = lgtabl + 10
      call gmecat ( ncinfo, 2, iaux, codre3 )
      call gmmod ( ncinfo//'.Taille',
     >             pinftl, lgtabl, iaux, 1, 1, codre4 )
      call gmmod ( ncinfo//'.Table',
     >             pinftb, lgtabl, iaux, 1, 1, codre5 )
      lgpoin = lgpoin + 1
      lgtabl = lgtabl + 10
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,90002) 'lgpoin', lgpoin
      write (ulsort,90002) 'lgtabl', lgtabl
      call gmprsx (nompro,ncinfo)
      call gmprsx (nompro,ncinfo//'.Pointeur')
      call gmprsx (nompro,ncinfo//'.Taille')
      call gmprsx (nompro,ncinfo//'.Table')
      endif
#endif
c
c 5.2. ==> Mise a jour du contenu : ajout des numeros de familles des
c          faces inf et sup et du noeud complementaire
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5.2. Maj contenu ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      imem(pinfpt+lgpoin-1) = imem(pinfpt+lgpoin-2) + 10
      imem(pinftl+lgtabl-10) = 8
      smem(pinftb+lgtabl-10) = 'SATURNE '
c
      do 521 , iaux = 1 , 3
c
      if ( codret.eq.0 ) then
c
        call utench ( famaux(iaux), 'd', jaux, saux08,
     >                ulsort, langue, codret )
        imem(pinftl+lgtabl-10+iaux) = 8
        smem(pinftb+lgtabl-10+iaux) = saux08
c
      endif
c
  521 continue
c
      do 522 , iaux = 4, 9
c
        imem(pinftl+lgtabl-10+iaux) = 0
c
  522 continue
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,ncinfo)
      call gmprsx (nompro,ncinfo//'.Pointeur')
      call gmprsx (nompro,ncinfo//'.Taille')
      call gmprsx (nompro,ncinfo//'.Table')
#endif
c
      endif
c
c====
c 6. Rangement dans la structure du maillage de calcul
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Rangement structure ; codret', codret
ccc      call gmprsx (nompro,nocman)
#endif
c
c 6.1. ==> Generalites
c
      if ( codret.eq.0 ) then
c
      sdim = 2
      call gmecat ( nocman, 1, sdim, codre1 )
      mdim = 2
      call gmecat ( nocman, 2, mdim, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 6.2. ==> Les noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.2. Les noeuds ; codret', codret
#endif
c
c 6.2.1. ==> Suppression des structures obsoletes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6.2.1. ncnoeu avant :'
      call gmprsx (nompro,ncnoeu)
#endif
c
      call gmlboj ( ncnoeu//'.Coor', codre1 )
      call gmlboj ( ncnoeu//'.FamilMED', codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 6.2.2. ==> Mise a jour
c
      if ( codret.eq.0 ) then
c
      call gmecat ( ncnoeu, 1, nbno2d, codre1 )
      call gmatoj ( ncnoeu//'.Coor', ncono2, codre2 )
      call gmatoj ( ncnoeu//'.FamilMED' , nfano2, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c 6.2.3. ==> Les numerotations externes
c
      if ( codret.eq.0 ) then
c
      call gmobal ( ncnoeu//'.NumeExte', codret )
      if ( codret.eq.2 ) then
        call gmmod ( ncnoeu//'.NumeExte',
     >               pnunoe, nbno3d, nbno2d, 1, 1, codret )
      elseif ( codret.eq.0 ) then
        call gmaloj ( ncnoeu//'.NumeExte', ' ', nbno2d, pnunoe, codret )
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      do 623 , iaux = 1 , nbno2d
        imem(pnunoe-1+iaux) = iaux
  623 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6.2.3. ncnoeu apres :'
      call gmprsx (nompro,ncnoeu)
#endif
c
      endif
c
c 6.3. ==> Les mailles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.3. Les mailles ; codret', codret
#endif
c
c 6.3.1. ==> Suppression des structures obsoletes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6.3.1. nccono avant :'
      call gmprsx (nompro,nccono)
#endif
c
      call gmlboj ( nccono//'.FamilMED', codre1 )
      call gmlboj ( nccono//'.Type', codre2 )
      call gmlboj ( nccono//'.Noeuds', codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c 6.3.2. ==> Mise a jour
c
      if ( codret.eq.0 ) then
c
      call gmatoj ( nccono//'.FamilMED', nfame2, codre1 )
      call gmatoj ( nccono//'.Type', ntype2, codre2 )
      call gmatoj ( nccono//'.Noeuds' , nnoee2, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nccono, 1, nbele2, codre1 )
      call gmecat ( nccono, 2, nbman2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 6.3.3. ==> Les numerotations externes
c
      if ( codret.eq.0 ) then
c
      call gmobal ( nccono//'.NumeExte', codret )
      if ( codret.eq.2 ) then
        call gmmod ( nccono//'.NumeExte',
     >               pnuele, nbelem, nbele2, 1, 1, codret )
      elseif ( codret.eq.0 ) then
        call gmaloj ( nccono//'.NumeExte', ' ', nbele2, pnuele, codret )
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      do 633 , iaux = 1 , nbele2
        imem(pnuele-1+iaux) = iaux
  633 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6.2.3. nccono apres :'
      call gmprsx (nompro,nccono)
#endif
c
      endif
c
c 6.4. ==> Les generalites
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.4. Les generalites ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6.4. ncnomb avant :'
      call gmprsx (nompro,ncnomb)
#endif
c
      imem(adnomb)    = nbmaa2
      imem(adnomb+1)  = nbmaf2
      imem(adnomb+3)  = nbno2d
      imem(adnomb+4)  = nbele2
      imem(adnomb+5)  = nbtr2d + nbqu2d
      imem(adnomb+6)  = 0
      imem(adnomb+12) = nbse2d
      imem(adnomb+13) = nbtr2d
      imem(adnomb+15) = 0
      imem(adnomb+16) = nbqu2d
      imem(adnomb+17) = 0
      imem(adnomb+18) = 0
      imem(adnomb+47) = famaux(1)
      imem(adnomb+48) = famaux(2)
      imem(adnomb+49) = famaux(3)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6.4. ncnomb apres :'
      call gmprsx (nompro,ncnomb)
#endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,nocman)
#endif
c
      endif
c
c====
c 7. menage
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. menage ; codret', codret
      call dmflsh(iaux)
#endif
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 8. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. fin ; codret', codret
#endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

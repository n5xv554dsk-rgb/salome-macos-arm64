      subroutine pcma23 ( nocmap,
     >                    choixz, deltaz, nospec,
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
c    aPres adaptation - Conversion de MAillage - 2D vers 3D
c     -                 -             --         -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nocmap . e   . char8  . nom de l'objet maillage de calcul n+1      .
c . choixz . e   .   1    . choix sur le calcul de delta z :           .
c .        .     .        . 1 : coordonnees initiales (defaut)         .
c .        .     .        . 2 : valeur imposee                         .
c .        .     .        . 3 : moyenne arithmetique des mini/maxi en  .
c .        .     .        .     (x,y) des mailles                      .
c .        .     .        . 4 : moyenne geometrique des mini/maxi en   .
c .        .     .        .     (x,y) des mailles                      .
c .        .     .        . 5 : ecart initial, divise par 2**nivsup    .
c . deltaz . e   .   1    . valeur de delta z si impose (choixz=1)     .
c . nospec . es  . char8  . objet memorisant les specificites          .
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
      parameter ( nompro = 'PCMA23' )
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
#include "nombno.h"
#include "nombar.h"
c
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      character*8 nocmap
      character*8 nospec
c
      integer choixz
c
      double precision deltaz
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nbele3, nbman3, nbmaa3, nbmaf3
      integer nbtr3d, nbqu3d, nbhe3d, nbpe3d
      integer nbno3d
c
      integer pfamen, pfamee, pnoeel, ptypel, pcoonc
      integer pnuele, pnunoe
      integer pinfpt, pinftl, pinftb
      integer nbnomb, adnomb
      integer lgpoin, lgtabl
c
      integer ptrav1, ptrav2
      integer pfano3, pcono3
      integer pfame3, ptype3, pnoee3
      integer famaux(3)
      integer nbpqt
c
      integer iaux, jaux, kaux
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
c
      integer nparrc, nptrrc, npqurc
      integer npterc, npherc, npperc, nppyrc
      integer adarrc, adtrrc, adqurc
      integer adterc, adherc, adperc, adpyrc
c
      logical cforme
c
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccoex, ncfami
      character*8 ncequi, ncfron, ncnomb
      character*8 ntrav1, ntrav2
      character*8 nfano3, ncono3
      character*8 nfame3, ntype3, nnoee3
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
#endif
c
      texte(1,4) = '(''. Passage du maillage 2D en 3D'')'
c
      texte(2,4) = '(''. From 2D mesh to 3D'')'
c
#include "impr03.h"
c
      write (ulsort,texte(langue,4))
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
      call utnomc ( nocmap,
     >              sdimca, mdimca,
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
      call gmliat ( ncnoeu, 1, nbnoto, codre1 )
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
      call gmprsx (nompro,ncnomb)
#endif
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
c 2.3. ==> les adresses
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD11', nompro
#endif
      iaux = 6006
      call utad11 ( iaux, ncnoeu, nccono,
     >              pcoonc, pfamen,   jaux,   jaux,
     >              ptypel, pfamee, pnoeel,   jaux,
     >              ulsort, langue, codret )
c
      endif
c
c 2.4. ==> les recollements pour le non conforme
c
      if ( codret.eq.0 ) then
c
      if ( maconf.eq.-1 .or. maconf.eq.0 ) then
        cforme = .true.
      else
        cforme = .false.
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,99001) 'cforme', cforme
#endif
c
      if ( .not. cforme ) then
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro,nospec)
        call gmprsx (nompro,nospec//'.Tab1')
        call gmprsx (nompro,nospec//'.Tab3')
#endif
c
c 2.4.1. ==> caracteristiques initiales
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD41', nompro
#endif
        call utad41 ( nospec,
     >                nparrc, nptrrc, npqurc,
     >                npterc, npherc, npperc, nppyrc,
     >                adarrc, adtrrc, adqurc,
     >                adterc, adherc, adperc, adpyrc,
     >                ulsort, langue, codret)
c
        endif
c
c 2.4.2. ==> il faut allonger le tableau pour les quadrangles
c
        if ( codret.eq.0 ) then
c
        call gmalot ( ntrav2, 'entier  ', nbarto, ptrav2, codre1 )
        call gmmod ( nospec//'.Tab3', adqurc,
     >               2, 2, npqurc, nparrc, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
      else
c
        nparrc = 0
        npqurc = 0
c
      endif
c
      endif
cgn      write (ulsort,90002) 'nparrc', nparrc
cgn      write (ulsort,90002) 'npqurc', npqurc
c
c====
c 3. Les informations generales
c    On enleve 3 informations : familles des faces inf et sup,
c                               famille du noeud supplementaire
c    La longueur du tableau "Pointeur" evolue : - 3
c    Les nom et unite sont en char*16 alors que les numeros des
c    familles seront codes sur des char*8 :
c    . la longueur du tableau "Taille" evolue : - 3
c    . la longueur du tableau "Table" evolue  : - 3
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. informations generales ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,*) 'Avant traitement de ncinfo'
      call gmprsx (nompro,ncinfo)
      call gmprsx (nompro,ncinfo//'.Pointeur')
      call gmprsx (nompro,ncinfo//'.Taille')
      call gmprsx (nompro,ncinfo//'.Table')
      endif
      call dmflsh (iaux)
#endif
c
c 3.1. ==> Caracteristiques de la structure
c
      if ( codret.eq.0 ) then
c
      call gmliat ( ncinfo, 1, lgpoin, codre1 )
      call gmliat ( ncinfo, 2, lgtabl, codre2 )
      call gmadoj ( ncinfo//'.Pointeur', pinfpt, iaux, codre3 )
      call gmadoj ( ncinfo//'.Table', pinftb, iaux, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c 3.2. ==> Recuperation des numeros de familles des faces inf et sup et
c          du noeud memorisant zinf et zsup
c
      if ( codret.eq.0 ) then
c
      nbpqt = lgpoin - 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbpqt', nbpqt
#endif
c
      do 32 , iaux = 1, nbpqt
c
        jaux = pinftb+10*(iaux-1)
cgn        write (ulsort,90064) iaux, '%'//smem(jaux)//'%'
c
        if ( smem(jaux).eq.'SATURNE ' ) then
c
          do 211 , kaux = 1 , 3
            jaux = jaux + 1
          read ( smem(jaux), '(i8)', err=32000, end=32000 ) famaux(kaux)
cgn            write (ulsort,90002) 'famaux(kaux)', famaux(kaux)
  211     continue
c
          goto 32
c
32000     continue
          codret = 1
c
        endif
c
   32 continue
c
      endif
c
c 3.3. ==> Attributs et raccourcissement des tables
c          Suppose que l'info sur SATURNE est a la fin ...
c
      if ( codret.eq.0 ) then
c
      iaux = lgpoin - 1
      call gmecat ( ncinfo, 1, iaux, codre1 )
      call gmmod ( ncinfo//'.Pointeur',
     >             pinfpt, lgpoin, iaux, 1, 1, codre2 )
      iaux = lgtabl - 10
      call gmecat ( ncinfo, 2, iaux, codre3 )
      call gmmod ( ncinfo//'.Taille',
     >             pinftl, lgtabl, iaux, 1, 1, codre4 )
      call gmmod ( ncinfo//'.Table',
     >             pinftb, lgtabl, iaux, 1, 1, codre5 )
      lgpoin = lgpoin - 1
      lgtabl = lgtabl - 10
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      write (ulsort,*) 'Apres traitement de ncinfo'
      call gmprsx (nompro,ncinfo)
      call gmprsx (nompro,ncinfo//'.Pointeur')
      call gmprsx (nompro,ncinfo//'.Taille')
      call gmprsx (nompro,ncinfo//'.Table')
      endif
#endif
c
c====
c 4. traitement des noeuds
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. traitement des noeuds ; codret', codret
      call dmflsh(iaux)
#endif
c
c 4.1. ==> nombre de noeuds du futur maillage
c
      if ( codret.eq.0 ) then
c
      nbno3d = 2*(nbnoto-1)
c
      endif
c
c 4.2. ==> allocation des tableaux
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'entier  ', nbnoto, ptrav1, codre1 )
      call gmalot ( nfano3, 'entier  ', nbno3d, pfano3, codre2 )
      iaux = nbno3d*3
      call gmalot ( ncono3, 'reel    ', iaux  , pcono3, codre3 )
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
      write (ulsort,texte(langue,3)) 'PCMA21', nompro
cgn      call gmprsx (nompro,ncnoeu//'.Coor')
      call dmflsh(iaux)
#endif
      call pcma21 ( choixz, deltaz,
     >              nbnoto, nbelem, imem(pfamen), rmem(pcoonc),
     >              famaux(3), nbno3d,
     >              imem(ptypel), imem(pnoeel),
     >              imem(ptrav1), imem(pfano3), rmem(pcono3),
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx (nompro,ntrav1)
      call gmprsx (nompro,ncono3)
      call dmflsh(iaux)
      endif
#endif
c
c====
c 5. traitement des mailles
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. traitement des mailles ; codret', codret
#endif
c
c 5.1. ==> preliminaires
c          nombre de mailles du futur maillage :
c          1 quadrangle donne 1 hexaedre
c              --> nbquad hexaedres
c          1 triangle donne 1 pentaedre
c              --> nbtria pentaedres
c          1 segment donne un quadrangle lateral
c          1 quadrangle donne 1 quadrangle sur la face inferieure
c          1 quadrangle donne 1 quadrangle sur la face superieure
c              --> nbsegm + 2*nbquad quadrangles
c
      if ( codret.eq.0 ) then
c
      nbtr3d = 0
      nbqu3d = 2*nbquad + nbsegm
      nbhe3d = nbquad
      nbpe3d = nbtria
      nbele3 = nbhe3d + nbpe3d + nbqu3d + nbtr3d
      if ( nbhe3d.eq.0 ) then
        nbman3 = 6
        nbmaa3 = 9
        nbmaf3 = 5
      else
        nbman3 = 8
        nbmaa3 = 12
        nbmaf3 = 6
      endif
c
      endif
c
c 5.2. ==> allocation des tableaux
c
      if ( codret.eq.0 ) then
c
      call gmalot ( nfame3, 'entier  ', nbele3, pfame3, codre1 )
      call gmalot ( ntype3, 'entier  ', nbele3, ptype3, codre2 )
      iaux = nbele3*nbman3
      call gmalot ( nnoee3, 'entier  ', iaux  , pnoee3, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c 5.3. ==> traitement
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'PCMA22', nompro
cgn      call gmprsx (nompro,nccono//'.FamilMED')
cgn      call gmprsx (nompro,nccono//'.Type')
cgn      call gmprsx (nompro,nccono//'.Noeuds')
#endif
c
      call pcma22 ( nbnoto, nbelem,
     >              nbtr3d, nbqu3d, nbhe3d, nbpe3d, nbele3,
     >              imem(pfamee), imem(ptypel), imem(pnoeel),
     >              imem(pfame3), imem(ptype3), imem(pnoee3),
     >              famaux(1), famaux(2), imem(ptrav1),
     >              nparrc, npqurc,
     >              imem(adarrc), imem(adqurc), imem(ptrav2),
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx (nompro,nfame3)
      call gmprsx (nompro,ntype3)
      call gmprsx (nompro,nnoee3)
      call dmflsh(iaux)
      endif
#endif
c
c====
c 6. Rangement dans la structure du maillage de calcul
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. Rangement dans structure ; codret',codret
#endif
c
c 6.1. ==> Le recollement
c
      if ( .not. cforme ) then
c
        if ( codret.eq.0 ) then
c
        call gmecat ( nospec, 1, nparrc, codre1 )
        call gmecat ( nospec, 3, npqurc, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
cgn      call gmprsx (nompro,nospec)
cgn      call gmprot (nompro,nospec//'.Tab1',1,2*nparrc)
cgn      call gmprot (nompro,nospec//'.Tab3',1,2*npqurc)
c
        endif
c
      endif
c
c 6.2. ==> Les noeuds
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.2. Les noeuds ; codret',codret
#endif
c
c 6.2.1. ==> Suppression des structures obsoletes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro//' - ncnoeu', ncnoeu)
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
      call gmecat ( ncnoeu, 1, nbno3d, codre1 )
      call gmatoj ( ncnoeu//'.Coor', ncono3, codre2 )
      call gmatoj ( ncnoeu//'.FamilMED' , nfano3, codre3 )
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
     >               pnunoe, nbnoto, nbno3d, 1, 1, codret )
      elseif ( codret.eq.0 ) then
        call gmaloj ( ncnoeu//'.NumeExte', ' ', nbno3d, pnunoe, codret )
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      do 623 , iaux = 1 , nbno3d
        imem(pnunoe-1+iaux) = iaux
  623 continue
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro//' - ncnoeu', ncnoeu)
#endif
c
      endif
c
c 6.3. ==> Les mailles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.3. Les mailles ; codret',codret
#endif
c
c 6.3.1. ==> Suppression des structures obsoletes
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro//' - nccono',nccono)
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
      call gmatoj ( nccono//'.FamilMED', nfame3, codre1 )
      call gmatoj ( nccono//'.Type', ntype3, codre2 )
      call gmatoj ( nccono//'.Noeuds' , nnoee3, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nccono, 1, nbele3, codre1 )
      call gmecat ( nccono, 2, nbman3, codre2 )
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
     >               pnuele, nbelem, nbele3, 1, 1, codret )
      elseif ( codret.eq.0 ) then
        call gmaloj ( nccono//'.NumeExte', ' ', nbele3, pnuele, codret )
      endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      do 633 , iaux = 1 , nbele3
        imem(pnuele-1+iaux) = iaux
  633 continue
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro//' - nccono',nccono)
#endif
c
      endif
c
c 6.4. ==> Les generalites
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.4. Les generalites ; codret',codret
#endif
c
      if ( codret.eq.0 ) then
c
      sdimca = 3
      call gmecat ( nocmap, 1, sdimca, codre1 )
      mdimca = 3
      call gmecat ( nocmap, 2, mdimca, codre2 )
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
      call gmprsx (nompro//' - ncnomb', ncnomb)
#endif
c
      imem(adnomb)    = nbmaa3
      imem(adnomb+1)  = nbmaf3
      imem(adnomb+3)  = nbno3d
      imem(adnomb+4)  = nbele3
      imem(adnomb+5)  = nbtr3d + nbqu3d
      imem(adnomb+6)  = nbhe3d + nbpe3d
      imem(adnomb+12) = 0
      imem(adnomb+13) = nbtr3d
      imem(adnomb+15) = 0
      imem(adnomb+16) = nbqu3d
      imem(adnomb+17) = nbhe3d
      imem(adnomb+18) = nbpe3d
      imem(adnomb+41) = famaux(1)
      imem(adnomb+48) = famaux(2)
      imem(adnomb+49) = famaux(3)
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro//' - ncnomb', ncnomb)
#endif
c
      nbelem = nbele3
      nbtria = nbtr3d
      nbquad = nbqu3d
      nbhexa = nbhe3d
      nbpent = nbpe3d
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro//' - nocmap', nocmap)
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
      if ( .not. cforme ) then
        call gmlboj ( ntrav2, codre2 )
      else
        codre2 = 0
      endif
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
      write (ulsort,90002) '8. la fin ; codret', codret
#endif
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

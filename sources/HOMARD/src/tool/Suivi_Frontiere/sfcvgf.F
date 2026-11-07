      subroutine sfcvgf ( nohman, mafrmd, nocdfr, ncafdg,
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
c   Suivi de Frontiere - ConVersion de la Geometrie de la Frontiere
c   -        -           -  -             -               -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nohman . e   . char*8 . nom de l'objet maillage homard iteration n .
c . mafrmd . e   . char*8 . maillage de la frontiere au format med     .
c . nocdfr .   s . char*8 . maillage de la frontiere a format C        .
c . ncafdg . es  . char*8 . nom de l'objet groupes frontiere           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme avec la memoire               .
c .        .     .        . 3 : probleme avec le fichier               .
c .        .     .        . 5 : contenu incorrect                      .
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
      parameter ( nompro = 'SFCVGF' )
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
#include "front1.h"
c
c 0.3. ==> arguments
c
      character*8 nohman
      character*8 mafrmd, nocdfr, ncafdg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer   sdim,   mdim
      integer  degre, maconf, homolo, hierar
      integer rafdef, nbmane, typcca, typsfr, maextr
      integer mailet
      integer ptypel, pnoeel, nbnoto,nbelem, nvosom, pcoonc
      integer sdimca, mdimca, dimcst
      integer pgeoco, psomse, pnumli, ptypli, psegli, adabsc
      integer pnumfa, pnomfa, pfamee
      integer nbnomb
      integer ptngrf, pointe, pligfa
      integer pttgrl, ptngrl, pointl
      integer ppovos, pvoiso
      integer laligd, nbfd00, nblign, nbf
      integer ptrav2
      integer lalign, noelig, arelig
c
      integer iaux, jaux, nsomli
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6, codre7
      integer codre0
c
      character*8 ntrav1, ntrav2
      character*8 ncinfo, ncnoeu, nccono, nccode
      character*8 nccocl, ncfami
      character*8 ncequi, ncfron, ncnomb
c
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
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
#include "impr03.h"
c
c====
c 2. recuperation des donnees du maillage HOMARD
c    Le seul but est de recuperer dimcst. Il faut le dimcst du maillage
c    de calcul et pas celui de la frontiere car ils peuvent etre
c    differents : le maillage de calcul est 3D alors que la frontiere
c    est dans un plan.
c
c====
c 2.1. ==> nom interne des branches
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nohman,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              norenu,
     >              nhnoeu, nhmapo, nharet,
     >              nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhvois, nhsupe, nhsups,
     >              ulsort, langue, codret )
c
      endif
c
c 2.2. ==> recuperation de la caracteristique des dimensions
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhnoeu, 2, dimcst, codre0 )
      codret = abs(codre0)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'dimcst', dimcst
#endif
c
      endif
c
c====
c 3. recuperation des donnees du maillage de la frontiere
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. recuperation ; codret', codret
#endif
c
c 3.1. ==> nom interne des branches
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMC - Frontiere', nompro
#endif
      call utnomc ( mafrmd,
     >              sdimca, mdimca,
     >               degre, mailet, maconf, homolo, hierar,
     >              nbnomb,
     >              ncinfo, ncnoeu, nccono, nccode,
     >              nccocl, ncfami,
     >              ncequi, ncfron, ncnomb,
     >              ulsort, langue, codret)
c
      endif
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro, nccono )
#endif
c
c 3.2. ==> recuperation des pointeurs
c
      if ( codret.eq.0 ) then
c
      call gmliat ( ncnoeu, 1, nbnoto, codre1 )
      call gmliat ( nccono, 1, nbelem, codre2 )
      call gmliat ( nccono, 2, nbmane, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD11', nompro
#endif
      iaux = 2002
      call utad11 ( iaux, ncnoeu, nccono,
     >              pcoonc, jaux, jaux, jaux,
     >              ptypel, pfamee, pnoeel, jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( ncfami, 1, nbf, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD13', nompro
#endif
      iaux = 30
      call utad13 ( iaux, ncfami,
     >              pnumfa, pnomfa,
     >              pointe,  jaux, ptngrf,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( ncfron, pligfa, iaux, codret )
c
      endif
c
c====
c 4. correspondance entre les familles du maillage de calcul et
c    les lignes dont on demande le suivi
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. correspondance ; codret', codret
#endif
c
c 4.1. ==> Enregistrement des groupes du suivi
c
      if ( codret.eq.0 ) then
c
      iaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
      call utadpt ( ncafdg, iaux,
     >              nbfd00,   jaux,
     >              pointl, pttgrl, ptngrl,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCSFLG', nompro
#endif
      call vcsflg ( nbfd00, nbf,
     >              imem(pointl), imem(pttgrl), smem(ptngrl),
     >              imem(pointe), smem(ptngrf),
     >              imem(pnumfa), smem(pnomfa),
     >              imem(pligfa), iaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. Allocation de la tete du maillage au format C
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. tete du maillage ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmalot ( nocdfr, 'Cal_Fron', 0, iaux, codre1 )
      call gmaloj ( nocdfr//'.TypeLign', ' ', nbfd00, ptypli, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      do 50 , iaux = 1 , nbfd00
        imem(ptypli+iaux-1) = 0
   50 continue
c
      endif
c
c====
c 6. Examen des lignes jusqu'a ne plus avoir de ligne fermee
c====
c
      laligd = 1
c
   60 continue
c
c 6.1. ==>  determination des elements voisins des sommets
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.1. elements voisins ; codret', codret
#endif
c
c 6.1.1. ==> comptage du nombre d'elements pour chaque sommet
c            et determination des pointeurs par sommets sur "voisom",
c            ranges dans la structure "povoso"
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'PtTabEnt', 0, iaux, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = nbnoto + 1
      call gmaloj ( ntrav1//'.Pointeur', ' ', iaux, ppovos, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCVOS1', nompro
#endif
      call vcvos1 ( imem(pnoeel), imem(ptypel), imem(ppovos),
     >              nvosom, nbelem, nbmane, nbnoto )
c
      endif
c
c 6.1.2. ==> reperage des voisins : la structure voisom contient la
c            liste des elements 1d, 2d ou 3d voisins de chaque sommet
c            (allocation du tableau des voisins a une taille egale
c             au nombre cumule de voisins des sommets)
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( ntrav1//'.Table', ' ', nvosom, pvoiso, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCVOS2', nompro
#endif
      call vcvos2 ( imem(pnoeel), imem(ptypel), imem(ppovos),
     >              imem(pvoiso), nvosom, nbelem, nbmane, nbnoto )
c
      endif
c
c 6.2. ==> Recherche d'eventuelles lignes fermees
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.2. lignes fermees ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCSFL0', nompro
#endif
      call vcsfl0 ( sdimca, nbelem, nvosom, nbnoto, nbf,
     >              rmem(pcoonc),
     >              imem(ptypel), imem(pfamee),
     >              imem(ppovos), imem(pvoiso),
     >              imem(pnumfa), smem(pnomfa), imem(pligfa),
     >              laligd, nbfd00,
     >              lalign, noelig, arelig,
     >              ulsort, langue, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'lalign', lalign
#endif
c
c 6.3. ==> Si on a une ligne fermee, on l'ouvre par duplication du noeud
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6.3. ligne fermee ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( lalign.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'noelig, arelig', noelig, arelig
        write (ulsort,92010)
     > (rmem(pcoonc+noelig-1+nbnoto*(iaux-1)), iaux=1,sdimca)
#endif
c
        imem(ptypli+lalign-1) = 1
c
c 6.3.1. ==> Ajout d'un noeud
c
        if ( codret.eq.0 ) then
c
        iaux = nbnoto+1
        call gmmod ( ncnoeu//'.Coor',
     >               pcoonc, nbnoto, iaux, sdimca, sdimca, codre0 )
        codret = abs(codre0)
c
        endif
c
        if ( codret.eq.0 ) then
c
        nbnoto = nbnoto + 1
        do 631 , iaux = 1 , sdimca
          rmem(pcoonc+nbnoto-1+nbnoto*(iaux-1)) =
     >    rmem(pcoonc+noelig-1+nbnoto*(iaux-1))
  631   continue
c
        endif
c
c 6.3.2. ==> Modification de la description de l'arete terminale
c
        if ( codret.eq.0 ) then
c
        if ( imem(pnoeel+arelig-1).eq.noelig ) then
          imem(pnoeel+arelig-1) = nbnoto
        elseif ( imem(pnoeel+arelig-1+nbelem).eq.noelig ) then
          imem(pnoeel+arelig-1+nbelem) = nbnoto
        else
          codret = 632
        endif
c
        endif
c
c 6.3.3. ==> Menage
c
        if ( codret.eq.0 ) then
c
        call gmsgoj ( ntrav1, codre0 )
        codret = abs(codre0)
c
        endif
c
c 6.3.4. ==> Maintenant que la ligne est ouverte, on recommence.
c
        laligd = lalign
c
        goto 60
c
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx(nompro, nocdfr//'.TypeLign')
#endif
  700 continue
c
c====
c 7. Les coordonnees
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. coordonnees ; codret', codret
#endif
c 7.1. ==> La dimension
c
      sfnbso = nbnoto
      if ( dimcst.eq.0 ) then
        sfsdim = sdimca
      else
        sfsdim = sdimca - 1
      endif
      sfmdim = mdim
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'dimcst', dimcst
      write (ulsort,90002) 'sdimca, sfsdim', sdimca, sfsdim
      write (ulsort,90002) 'sfmdim', sfmdim
#endif
c
c 7.2. ==> Memoire
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nocdfr, 1, sfsdim, codre1 )
      call gmecat ( nocdfr, 2, sfmdim, codre2 )
      call gmecat ( nocdfr, 3, sfnbso, codre3 )
      iaux = sfsdim*sfnbso
      call gmaloj ( nocdfr//'.CoorNoeu', ' ', iaux, pgeoco, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c 7.3. ==> Transfert
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCVCO', nompro
#endif
      call sfcvco ( dimcst, nbnoto, sfsdim,
     >              rmem(pcoonc), rmem(pgeoco),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 8. conversion du format MED au format C
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. Conversion MED C ; codret', codret
#endif
c
c 8.1. ==> Allocation : on surdimensionne
c
      sfnbli = nbfd00
      sfnbse = 2*(nbnoto+nbfd00)
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nocdfr, 4, sfnbli, codre1 )
      call gmecat ( nocdfr, 5, sfnbse, codre2 )
      call gmaloj ( nocdfr//'.NumeLign', ' ', sfnbli, pnumli, codre3 )
      call gmaloj ( nocdfr//'.PtrSomLi', ' ', sfnbli+1, psegli, codre4 )
      call gmaloj ( nocdfr//'.SommSegm', ' ', sfnbse, psomse, codre5 )
      call gmaloj ( nocdfr//'.AbsCurvi', ' ', sfnbse, adabsc, codre6 )
      call gmalot ( ntrav2, 'entier', nbelem, ptrav2, codre7 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6, codre7 )
c
      endif
c
c 8.2. ==> Conversion
c
      if ( codret.eq.0 ) then
c
      imem(psegli) = 0
      imem(psegli+1) = nbnoto+1
cgn      print *,'appel de vcsfli'
cgn      print *,'nbfd00 = ', nbfd00
cgn      print *,'nbelem, nbmane, nvosom, nbnoto, nbf = ',
cgn     >         nbelem, nbmane, nvosom, nbnoto, nbf
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'VCSFLI', nompro
#endif
      call vcsfli ( sdimca, nbelem, nbmane, nvosom, nbnoto, nbf,
     >              rmem(pcoonc),
     >              imem(pnoeel), imem(ptypel), imem(pfamee),
     >              imem(ppovos), imem(pvoiso),
     >              imem(pnumfa), smem(pnomfa), imem(pligfa),
     >              nbfd00, nblign, nsomli,
     >              imem(pnumli), imem(psegli), imem(psomse),
     >              rmem(adabsc), imem(ptrav2),
     >              ulsort, langue, codret )
c
      endif
c
c 8.3. ==> Redimensionnement en tenant compte du vrai nombre de lignes
c          et de sommets decrivant les lignes
c
      if ( codret.eq.0 ) then
c
      sfnbli = nblign
c
      call gmmod ( nocdfr//'.NumeLign',
     >             pnumli, nbfd00, sfnbli, 1, 1, codre1 )
      call gmmod ( nocdfr//'.TypeLign',
     >             ptypli, nbfd00, sfnbli, 1, 1, codre2 )
      call gmmod ( nocdfr//'.PtrSomLi',
     >             pnumli, nbfd00+1, sfnbli+1, 1, 1, codre3 )
      call gmmod ( nocdfr//'.SommSegm',
     >             psomse, sfnbse, nsomli, 1, 1, codre4 )
      call gmmod ( nocdfr//'.AbsCurvi',
     >             adabsc, sfnbse, nsomli, 1, 1, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      sfnbse = nsomli
c
      call gmecat ( nocdfr, 4, sfnbli, codre1 )
      call gmecat ( nocdfr, 5, sfnbse, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmsgoj ( ntrav1, codre1 )
      call gmlboj ( ntrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 8.4. ==> Enregistrement des groupes du suivi
c
      if ( codret.eq.0 ) then
c
      call gmatoj ( nocdfr//'.Groupes', ncafdg, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx (nompro, nocdfr )
      call gmprot (nompro, nocdfr//'.CoorNoeu', 1 , 20 )
      call gmprot (nompro, nocdfr//'.CoorNoeu', sfnbso-20 , sfnbso )
      call gmprsx (nompro, nocdfr//'.NumeLign' )
      call gmprsx (nompro, nocdfr//'.PtrSomLi' )
      call gmprot (nompro, nocdfr//'.SommSegm', 1 , 20 )
      call gmprot (nompro, nocdfr//'.SommSegm', sfnbse-20 , sfnbse )
      call gmprot (nompro, nocdfr//'.AbsCurvi', 1 , 20 )
      call gmprot (nompro, nocdfr//'.AbsCurvi', sfnbse-20 , sfnbse )
      call gmprsx (nompro, nocdfr//'.Groupes')
      endif
#endif
c
c====
c 9. controle des intersections
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. controle intersections ; codret', codret
#endif
c
c 9.1. ==> Allocation : on surdimensionne
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav2, 'entier', sfnbso, ptrav2, codre0 )
      codret = abs(codre0)
c
      endif
c
c 9.2. ==> Controle
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFCTRI', nompro
#endif
      call sfctri ( imem(psomse), imem(psegli),
     >              imem(ptrav2),
     >              ulsort, langue, codret)
c
      endif
c
c 9.3. ==> menage
c
      if ( codret.eq.0 ) then
c
      call gmlboj ( ntrav2, codre0 )
      codret = abs(codre0)
c
      endif
c
c====
c 10. la fin
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

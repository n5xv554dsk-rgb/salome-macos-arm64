      subroutine utad04 ( option, nhvois,
     >                    ppovos, pvoiso, pposif, pfacar,
     >                    advotr, advoqu,
     >                    lgpptr, lgppqu, adpptr, adppqu,
     >                    lgtate, adptte, adtate,
     >                    lgtahe, adpthe, adtahe,
     >                    lgtapy, adptpy, adtapy,
     >                    lgtape, adptpe, adtape,
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
c    UTilitaire - ADresses - phase 04
c    --           --               --
c ______________________________________________________________________
c   Recuperation des adresses des tableaux pour une entite Voisins
c   Remarque : le code de retour en entree ne doit pas etre ecrase
c              brutalement ; il doit etre cumule avec les operations
c              de ce programme
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . option de pilotage des adresses a recuperer.
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .  2 : ppovos, pvoiso                        .
c .        .     .        .  3 : pposif, pfacar                        .
c .        .     .        .  5 : voltri                                .
c .        .     .        .  7 : volqua                                .
c .        .     .        . 11 : lgpptr, lgppqu                        .
c .        .     .        . 13 : pypetr                                .
c .        .     .        . 17 : pypequ                                .
c .        .     .        . 19 : lgtate, adptte, adtate                .
c .        .     .        . 23 : lgtahe, adpthe, adtahe                .
c .        .     .        . 29 : lgtapy, adptpy, adtapy                .
c .        .     .        . 31 : lgtape, adptpe, adtape                .
c . nhvois . e   . char8  . nom de la branche Voisins                  .
c . ppovos .   s .   1    . adresse du pointeur des vois. des sommets  .
c . pvoiso .   s .   1    . adresse des voisins des sommets            .
c . pposif .   s .   1    . adresse du pointeur des vois. des aretes   .
c . pfacar .   s .   1    . adresse des voisins des aretes             .
c . advotr .   s  .  1    . numeros des 2 volumes par triangle         .
c . advoqu .   s  .  1    . numeros des 2 volumes par quadrangle       .
c . lgpptr .   s  .  1    . longueur du tableau PyPe/Tri               .
c . lgppqu .   s  .  1    . longueur du tableau PyPe/Qua               .
c . adpptr .   s  .  1    . adresse du tableau PyPe/Tri                .
c . adppqu .   s  .  1    . adresse du tableau PyPe/Qua                .
c . lgtate .   s  .  1    . longueur du tableau Tet/Are.Table          .
c . adptte .   s .   1    . adresse du pointeur des tetras/aretes      .
c . adtate .   s .   1    . adresse de la table des tetras/aretes      .
c . lgtahe .   s  .  1    . longueur du tableau Hex/Are.Table          .
c . adpthe .   s .   1    . adresse du pointeur des hexas/aretes       .
c . adtahe .   s .   1    . adresse de la table des hexas/aretes       .
c . lgtapy .   s  .  1    . longueur du tableau Pyr/Are.Table          .
c . adptpy .   s .   1    . adresse du pointeur des pyras/aretes       .
c . adtapy .   s .   1    . adresse de la table des pyras/aretes       .
c . lgtape .   s  .  1    . longueur du tableau Pen/Are.Table          .
c . adptpe .   s .   1    . adresse du pointeur des pentas/aretes      .
c . adtape .   s .   1    . adresse de la table des pentas/aretes      .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
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
      parameter ( nompro = 'UTAD04' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      character*8 nhvois
c
      integer option
      integer ppovos, pvoiso
      integer pposif, pfacar
      integer advotr, advoqu
      integer lgpptr, lgppqu, adpptr, adppqu
      integer lgtate, adptte, adtate
      integer lgtahe, adpthe, adtahe
      integer lgtapy, adptpy, adtapy
      integer lgtape, adptpe, adtape
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre0
      integer codre1, codre2, codre3
c
      character*8 saux08
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
      texte(1,4) = '(''Adresses relatives aux voisins'')'
c
      texte(2,4) = '(''Adresses for neighbours'')'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      write (ulsort,90002) 'Option', option
      call dmflsh (iaux)
#endif
c
c====
c 2. recuperation des adresses
c====
c
      if ( option.gt.0 ) then
c
c 2.1. ==> Aretes voisines des noeuds
c
      if ( mod(option,2).eq.0 ) then
c
        call gmadoj ( nhvois//'.0D/1D.Pointeur', ppovos, iaux, codre1 )
        call gmadoj ( nhvois//'.0D/1D.Table', pvoiso, iaux, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.1. aretes/noeuds ; codret', codret
#endif
c
      endif
c
c 2.2. ==> Faces voisines des aretes
c
      if ( mod(option,3).eq.0 ) then
c
        call gmadoj ( nhvois//'.1D/2D.Pointeur', pposif, iaux, codre1 )
        call gmadoj ( nhvois//'.1D/2D.Table', pfacar, iaux, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. faces/aretes ; codret', codret
#endif
c
      endif
c
c 2.3. ==> Volumes voisins des triangles
c
      if ( mod(option,5).eq.0 ) then
c
        call gmadoj ( nhvois//'.Vol/Tri', advotr, iaux, codre0 )
c
        codret = max ( abs(codre0), codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. volumes/triangles ; codret', codret
#endif
c
      endif
c
c 2.4. ==> Volumes voisins des quadrangles
c
      if ( mod(option,7).eq.0 ) then
c
        call gmadoj ( nhvois//'.Vol/Qua', advoqu, iaux, codre0 )
c
        codret = max ( abs(codre0), codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.4. volumes/quadrangles ; codret', codret
#endif
c
      endif
c
c 2.5. ==> Longueurs des PyPe
c
      if ( mod(option,11).eq.0 ) then
c
        call gmliat ( nhvois , 1, lgpptr, codre1 )
        call gmliat ( nhvois , 2, lgppqu, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.5. Longueurs des PyPe ; codret', codret
#endif
c
      endif
c
c 2.6. ==> Pyramides/Pentaedres voisins des triangles
c
      if ( mod(option,13).eq.0 ) then
c
        call gmadoj ( nhvois//'.PyPe/Tri', adpptr, iaux, codre0 )
c
        codret = max ( abs(codre0), codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.6. Pyra+Pent/Tria ; codret', codret
#endif
c
      endif
c
c 2.7. ==> Pyramides/Pentaedres voisins des quadrangles
c
      if ( mod(option,17).eq.0 ) then
c
        call gmadoj ( nhvois//'.PyPe/Qua', adppqu, iaux, codre0 )
c
        codret = max ( abs(codre0), codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.7. Pyra+Pent/Quad ; codret', codret
#endif
c
      endif
c
c 2.8. ==> Tetraedres voisins des aretes
c
      if ( mod(option,19).eq.0 ) then
c
        saux08 = '.Tet/Are'
        call gmliat ( nhvois//saux08 , 2, lgtate, codre1 )
        call gmadoj ( nhvois//saux08//'.Pointeur',
     >                adptte, iaux, codre2 )
        call gmadoj ( nhvois//saux08//'.Table',
     >                adtate, iaux, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.8. Tetraedres/Aretes ; codret', codret
#endif
c
      endif
c
c 2.9. ==> Hexaedres voisins des aretes
c
      if ( mod(option,23).eq.0 ) then
c
        saux08 = '.Hex/Are'
        call gmliat ( nhvois//saux08 , 2, lgtahe, codre1 )
        call gmadoj ( nhvois//saux08//'.Pointeur',
     >                adpthe, iaux, codre2 )
        call gmadoj ( nhvois//saux08//'.Table',
     >                adtahe, iaux, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.9. Hexaedres/Aretes ; codret', codret
#endif
c
      endif
c
c 2.10. ==> Pyramides voisines des aretes
c
      if ( mod(option,29).eq.0 ) then
c
        saux08 = '.Pyr/Are'
        call gmliat ( nhvois//saux08 , 2, lgtapy, codre1 )
        call gmadoj ( nhvois//saux08//'.Pointeur',
     >                adptpy, iaux, codre2 )
        call gmadoj ( nhvois//saux08//'.Table',
     >                adtapy, iaux, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.10. Pyramides/Aretes ; codret', codret
#endif
c
      endif
c
c 2.11. ==> Pentaedres voisins des aretes
c
      if ( mod(option,31).eq.0 ) then
c
        saux08 = '.Pen/Are'
        call gmliat ( nhvois//saux08 , 2, lgtape, codre1 )
        call gmadoj ( nhvois//saux08//'.Pointeur',
     >                adptpe, iaux, codre2 )
        call gmadoj ( nhvois//saux08//'.Table',
     >                adtape, iaux, codre3 )
c
        codre0 = min ( codre1, codre2, codre3 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3 )
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.11. Pentaedres/Aretes ; codret', codret
#endif
c
      endif
c
      endif
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
      write (ulsort,texte(langue,4))
      write (ulsort,90002) 'Option', option
      call gmprsx ( nompro, nhvois )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

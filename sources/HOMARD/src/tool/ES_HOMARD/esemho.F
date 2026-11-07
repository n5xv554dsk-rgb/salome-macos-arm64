      subroutine esemho ( typobs, nrosec, nretap, nrsset,
     >                    optecr,
     >                    suifro, nocdfr,
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
c  Entree-Sortie : Ecriture du Maillage HOmard
c  -      -        -           -        --
c ______________________________________________________________________
c   tant que rien n'a change, on a archive des informations dans
c    les sous-tableaux des branches InfoSupE et InfoSupS
c    Entiers de InfoSupE :
c       Tab1 : communs entiers
c       Tab2 : type des elements
c       Tab3, Tab4, Tab5 et Tab6 sont reserves au transfert
c       d'informations du maillage au format MED.
c       Tab10 : activation des groupes des frontieres a suivre
c    Chaines de InfoSupS :
c       Tab3, Tab4 et Tab5 sont reserves au transfert
c       d'informations du maillage au format MED.
c       Tab10 : nom des groupes des frontieres a suivre
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typobs . e   . char*8 . mot-cle correspondant a l'objet a ecrire   .
c . nrosec . e   .   1    . numero de section pour les mesures de temps.
c . nretap . e   .   1    . numero d'etape                             .
c . nrsset . e   .   1    . numero de sous-etape                       .
c . optecr . e   .   1    . option d'ecriture                          .
c .        .     .        . >0 : on ecrit la frontiere discrete        .
c .        .     .        . <0 : on n'ecrit pas la frontiere discrete  .
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
      parameter ( nompro = 'ESEMHO' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envca1.h"
c
c 0.3. ==> arguments
c
      character*8 typobs
c
      integer nrosec, nretap, nrsset
      integer optecr
      integer suifro
c
      character*8 nocdfr
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codava
c
      integer lnomfi
c
      integer iaux, jaux
c
      character*8 nomail
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
c
      character*6 saux
      character*200 nomfic
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. les initialisations
c====
c
      codava = codret
c
c=======================================================================
      if ( codava.eq.0 ) then
c=======================================================================
c
c 1.1. ==> le debut des mesures de temps
c
      if ( nrosec.gt.0 ) then
        call gtdems (nrosec)
      endif
c
c 1.2. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(//,a6,'' SAUVEGARDE DU MAILLAGE HOMARD'')'
      texte(1,5) = '(36(''=''),/)'
      texte(1,6) =
     > '(/,5x,''Ecriture du maillage '',a,'' sur le fichier'')'
      texte(1,7) = '(/,1x,''Mot-cle : '',a8)'
c
      texte(2,4) = '(//,a6,'' RECORDING OF HOMARD MESH'')'
      texte(2,5) = '(31(''=''),/)'
      texte(2,6) = '(/,5x,''Writing of mesh '',a,'' on file'')'
      texte(2,7) = '(/,1x,''Keyword : '',a8)'
c
#include "impr03.h"
c
c 1.3. ==> le titre
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
      write (ulsort,texte(langue,4)) saux
      write (ulsort,texte(langue,5))
c
c====
c 2. nom du maillage et du fichier
c====
c
      iaux = 0
      jaux = 1
      call utfino ( typobs, iaux, nomfic, lnomfi,
     >              jaux,
     >              ulsort, langue, codret )
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTOSNO', nompro
#endif
      iaux = 0
      call utosno ( typobs, nomail, iaux, ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,6)) nomail
      write (ulsort,*) '    '//nomfic(1:lnomfi)
c
      endif
c
c====
c 3. Branche des informations entieres
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Branche des entiers ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMH0', nompro
#endif
      call esemh0 ( nomail,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 4. recuperation des donnees du maillage d'entree
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. recuperation entree ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTNOMH', nompro
#endif
      call utnomh ( nomail,
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
     >              ulsort, langue, codret)
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'sdim', sdim
      write (ulsort,90002) 'mdim', mdim
#endif
c      call gmprsx(nompro, nhelig)
c      call gmprsx(nompro, nhelig//'.Numero')
c      call gmprsx(nompro, nhelig//'.ConnNoeu')
c      call gmprsx(nompro, nhelig//'.Type')
c      call gmprsx(nompro, nhelig//'.FamilMED')
c
c====
c 5. appel du programme utilitaire
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. appel de esemh1 ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMH1', nompro
#endif
      call esemh1 ( nomail, nomfic, lnomfi,
     >              optecr,
     >              nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhelig,
     >              nhsups,
     >              suifro, nocdfr,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 6. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. La fin ; codret', codret
#endif
c
c 6.1. ==> message si erreur
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,7)) typobs
      codret = 7
c
      endif
c
c 6.2. ==> fin des mesures de temps de la section
c
      if ( nrosec.gt.0 ) then
        call gtfims (nrosec)
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c=======================================================================
      endif
c=======================================================================
c
      end

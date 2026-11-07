      subroutine esecfd ( idfmed,
     >                    nocdfr,
     >                    ltbiau, tbiaux, ltbsau, tbsaux,
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
c  Entree-Sortie : ECriture des Frontieres Discretes
c  -      -        --           -          -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nocdfr . e   . char8  . nom de l'objet description de la frontiere .
c . ltbiau . e   .    1   . longueur allouee a tbiaux                  .
c . tbiaux .     .    *   . tableau tampon entier                      .
c . ltbsau . e   .    1   . longueur allouee a tbsaux                  .
c . tbsaux .     .    *   . tableau tampon caracteres                  .
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
      parameter ( nompro = 'ESECFD' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "motcle.h"
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer ltbiau, tbiaux(ltbiau)
      integer ltbsau
c
      character*8 nocdfr
      character*8 tbsaux(ltbsau)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer lnomaf
      integer adabsc, psomse, psegli, pnumli, ptypli, pgeoco
      integer lgpttg, lgtabl
      integer pttgrl, ptngrl, pointl
      integer sfsdim, sfmdim, sfnbso, sfnbli, sfnbse
      integer ngro
c
      character*8 typobs
      character*64 saux64
      character*64 nomamd
      character*64 nomafr
      character*64 noprof
      character*200 sau200
c
      integer codre0
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisation
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Ecriture des frontieres discretes.'')'
      texte(1,5) = '(5x,''Ecriture de la frontiere discrete '',a)'
c
      texte(2,4) = '(''. Writings of discrete boundaries.'')'
      texte(2,5) = '(5x,''Writing of the discrete boundary '',a)'
c
#include "impr03.h"
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
      codret = 0
c
cgn      call gmprsx (nompro, nocdfr )
cgn      call gmprsx (nompro, nocdfr//'.CoorNoeu' )
cgn      call gmprsx (nompro, nocdfr//'.NumeLign' )
cgn      call gmprsx (nompro, nocdfr//'.PtrSomLi' )
cgn      call gmprsx (nompro, nocdfr//'.SommSegm' )
cgn      call gmprsx (nompro, nocdfr//'.AbsCurvi' )
cgn      call gmprsx (nompro, nocdfr//'.Groupes' )
c
c====
c 2. Caracteristique de la frontiere
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. nom de la frontiere ; codret', codret
#endif
c
c 2.1. ==> Recuperation du nom du maillage de la frontiere
c
      typobs = mccnmf
      iaux = 0
      jaux = 0
      call utfino ( typobs, iaux, nomafr, lnomaf,
     >              jaux,
     >              ulsort, langue, codret )
c
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,5)) nomafr(1:lnomaf)
c
      endif
c
c 2.2. ==> Adresses
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nocdfr, 1, sfsdim, codre1 )
      call gmliat ( nocdfr, 2, sfmdim, codre2 )
      call gmliat ( nocdfr, 3, sfnbso, codre3 )
      call gmliat ( nocdfr, 4, sfnbli, codre4 )
      call gmliat ( nocdfr, 5, sfnbse, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'sfsdim', sfsdim
      write (ulsort,90002) 'sfmdim', sfmdim
      write (ulsort,90002) 'sfnbso', sfnbso
      write (ulsort,90002) 'sfnbli', sfnbli
      write (ulsort,90002) 'sfnbse', sfnbse
#endif
c
      if ( codret.eq.0 ) then
c
      call gmadoj ( nocdfr//'.CoorNoeu', pgeoco, iaux, codre1 )
      call gmadoj ( nocdfr//'.NumeLign', pnumli, iaux, codre2 )
      call gmadoj ( nocdfr//'.TypeLign', ptypli, iaux, codre3 )
      call gmadoj ( nocdfr//'.PtrSomLi', psegli, iaux, codre4 )
      call gmadoj ( nocdfr//'.SommSegm', psomse, iaux, codre5 )
      call gmadoj ( nocdfr//'.AbsCurvi', adabsc, iaux, codre6 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 6
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTADPT', nompro
#endif
      call utadpt ( nocdfr//'.Groupes', iaux,
     >              lgpttg, lgtabl,
     >              pointl, pttgrl, ptngrl,
     >              ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'lgpttg', lgpttg
      write (ulsort,90002) 'lgtabl', lgtabl
#endif
c
c====
c 3. Creation d'un maillage pour les coordonnees des noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. coordonnees des noeuds ; codret', codret
#endif
c
c 3.1. ==> Creation du maillage
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.1. Creation maillage 1 ; codret', codret
#endif
c
c               123456789012345678901
      sau200 = 'La frontiere discrete'
      do 31 , iaux = 1 , 40
        tbsaux(iaux) = blan08
   31 continue
      tbsaux( 1)      = 'NomCo   '
      tbsaux(10)(8:8) = '0'
      tbsaux(11)      = 'UniteCo '
      tbsaux(21)      = sau200(01:08)
      tbsaux(22)      = sau200(09:16)
      tbsaux(23)      = sau200(17:24)
      tbsaux(31)      = 'NOMAMD  '
      call utchs8 ( nomafr, lnomaf, tbsaux(32),
     >              ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMM0', nompro
#endif
      call esemm0 ( idfmed, nomafr,
     >              sfsdim, sfmdim, sau200,
     >                   4, tbsaux,
     >              ulsort, langue, codret)
c
      endif
c
c 3.2. ==> Ecriture des coordonnees et des familles
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. Coordonnees ; codret', codret
#endif
c
c 3.2.1. ==> Familles des noeuds
c            Le tableau sert a stocker la description des lignes
c
      if ( codret.eq.0 ) then
c
      do 321 , iaux = 1 , sfnbso
        tbiaux(iaux) = 0
  321 continue
      tbiaux(1) = sfnbli
      do 322 , iaux = 0 , sfnbli-1
        tbiaux(iaux+2) = imem(pnumli+iaux)
  322 continue
      do 323 , iaux = 0 , sfnbli-1
        tbiaux(iaux+sfnbli+2) = imem(ptypli+iaux)
  323 continue
      do 324 , iaux = 0 , sfnbli
        tbiaux(iaux+2*sfnbli+2) = imem(psegli+iaux)
  324 continue
cgn      write(ulsort,*) (tbiaux(iaux), iaux=1, 3*(sfnbli+1))
c
c 3.2.2. ==> Ecriture
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMNO', nompro
#endif
      call esemno ( idfmed, nomafr,
     >              sfnbso, sfsdim, rmem(pgeoco), tbiaux,
     >              ednodt, ednoit, edundt,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. Creation d'un maillage pour les abscisses curvilignes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Abscisses curvilignes ; codret', codret
#endif
c
c 4.1. ==> Creation d'un pseudo-maillage
c          Le nom doit etre coherent avec eslmh2
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1. Creation maillage 2 ; codret', codret
#endif
c
      nomamd = blan64
      nomamd(1:8) = 'AbsCurvi'
c
      sau200 = 'Abscisses curvilignes'
c               12345678901234567890123
      do 41 , iaux = 1 , 40
        tbsaux(iaux) = blan08
   41 continue
      tbsaux( 1)      = 'NomCo   '
      tbsaux(10)(8:8) = '0'
      tbsaux(11)      = 'UniteCo '
      tbsaux(21)      = sau200(01:08)
      tbsaux(22)      = sau200(09:16)
      tbsaux(23)      = sau200(17:24)
      tbsaux(31)      = 'NOMAMD  '
      tbsaux(32)      = nomamd(1:8)
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMM0', nompro
#endif
      call esemm0 ( idfmed, nomamd,
     >                iaux,   iaux, sau200,
     >                   4, tbsaux,
     >              ulsort, langue, codret)
c
      endif
c
c 4.2. ==> Ecriture des coordonnees et des familles
c          La famille sert a stocker le lien sommet/segment
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.2. Coordonnees ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESEMNO', nompro
#endif
      call esemno ( idfmed, nomamd,
     >              sfnbse, iaux, rmem(adabsc), imem(psomse),
     >              ednodt, ednoit, edundt,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. Les groupes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Groupes ; codret', codret
#endif
c
c 5.1. ==> Creation d'un profil pour les valeurs entieres
c
      if ( codret.eq.0 ) then
c
      tbiaux(1) = lgpttg
      tbiaux(2) = lgtabl
      do 511 , iaux = 0 , lgpttg
        tbiaux(iaux+3) = imem(pointl+iaux)
  511 continue
      jaux = lgpttg+3
      do 512 , iaux = 1 , lgtabl
        tbiaux(jaux+iaux) = imem(pttgrl+iaux-1)
  512 continue
#ifdef _DEBUG_HOMARD_
      write(ulsort,*) (tbiaux(iaux),iaux=1,3+lgpttg+lgtabl)
#endif
c
      noprof = blan64
c                     1234567890123456789012
      noprof(1:22) = 'Groupes_des_frontieres'
c
      iaux = 3 + lgpttg + lgtabl
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
      write (ulsort,texte(langue,62)) iaux
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW', nompro
#endif
      call mpfprw ( idfmed, noprof, iaux, tbiaux, codret )
c
      endif
c
c 5.2. ==> Creation d'une famille pour les noms des groupes
c
      if ( codret.eq.0 ) then
c
      jaux = mod(lgtabl,10)
      if ( jaux.eq.0 ) then
        iaux = lgtabl/10
      else
        iaux = (lgtabl-jaux)/10 + 1
      endif
      ngro = iaux + 1
c
      do 521 , iaux = 1 , lgtabl
        tbsaux(iaux) = smem(ptngrl+iaux-1)
  521 continue
c
      do  522 , iaux = lgtabl+1 , 10*ngro
        tbsaux(iaux) = blan08
  522 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'ngro', ngro
      do 524 , iaux = 1 , ngro
        write(ulsort,*) (tbsaux(10*(iaux-1)+jaux)//'+',jaux=1,10)
  524 continue
#endif
c
      iaux = 1
      saux64 = blan64
c                    1234567
      saux64(1:7) = 'Groupes'
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFACRE', nompro
#endif
      call mfacre ( idfmed, nomafr, saux64, iaux,
     >              ngro, tbsaux, codret )
c
      endif
c
c====
c 6. la fin
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

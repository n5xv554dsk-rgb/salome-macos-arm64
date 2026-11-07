      subroutine eslmh7 ( idfmed,
     >                    nocdfr, ncafdg,
     >                    ltbiau, tbiaux, ltbsau, tbsaux,
     >                    nomafr, lnomaf,
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
c  Entree-Sortie : Lecture du Maillage Homard - phase 7
c  -      -        -          -        -              -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nocdfr .  s  . char8  . nom de l'objet description de la frontiere .
c . ncafdg .  s  . char*8 . nom de l'objet groupes frontiere           .
c . ltbiau . e   .    1   . longueur allouee a tbiaux                  .
c . tbiaux . e   .   *    . tableau de travail                         .
c . ltbsau . e   .    1   . longueur allouee a tbsaux                  .
c . tbsaux .     .    *   . tableau tampon caracteres                  .
c . nomafr . e   . char64 . nom du maillage MED de la frontiere        .
c . lnomaf . e   .   1    . longueur du nom du maillage de la frontiere.
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
      parameter ( nompro = 'ESLMH7' )
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
#include "front1.h"
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer ltbiau, tbiaux(ltbiau)
      integer ltbsau
      integer lnomaf
c
      character*8 tbsaux(ltbsau)
      character*8 nocdfr, ncafdg
      character*64 nomafr
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer codre0
      integer codre1, codre2, codre3, codre4, codre5
c
      integer pgeoco, psomse, pnumli, ptypli, psegli, adabsc
      integer lgpttg, lgtabl
      integer pttgrl, ptngrl, pointl
      integer ngro
c
      character*64 noprof
      character*64 saux64
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. intialisations
c====
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(5x,''Recuperation de la frontiere discrete '',a)'
c
      texte(2,4) = '(5x,''Readings of the discrete boundary '',a)'
c
#include "impr03.h"
c
#include "esimpr.h"
c
      write (ulsort,texte(langue,4)) nomafr(1:lnomaf)
c
      codret = 0
c
c====
c 2. Allocation de l'objet frontiere discrete
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. Allocations frontiere ; codret', codret
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'sfsdim', sfsdim
      write (ulsort,90002) 'sfmdim', sfmdim
      write (ulsort,90002) 'sfnbso', sfnbso
      write (ulsort,90002) 'sfnbse', sfnbse
#endif
c
      if ( codret.eq.0 ) then
c
      call gmalot ( nocdfr, 'Cal_Fron', 0, iaux, codre1 )
      call gmecat ( nocdfr, 1, sfsdim, codre2 )
      call gmecat ( nocdfr, 2, sfmdim, codre3 )
      call gmecat ( nocdfr, 3, sfnbso, codre4 )
      call gmecat ( nocdfr, 5, sfnbse, codre5 )
c
      codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4, codre5 )
c
      iaux = sfsdim*sfnbso
      call gmaloj ( nocdfr//'.CoorNoeu', ' ', iaux, pgeoco, codre1 )
      call gmaloj ( nocdfr//'.SommSegm', ' ', sfnbse, psomse, codre2 )
      call gmaloj ( nocdfr//'.AbsCurvi', ' ', sfnbse, adabsc, codre3 )
c
      codre0 = min ( codre1, codre2, codre3 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3 )
c
      endif
c
c====
c 3. Lecture des coordonnes des noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Lecture ; codret', codret
#endif
c
c 3.1. ==> Lecture des coordonnees et des familles des noeuds
c
      if ( codret.eq.0 ) then
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMNO-'//nomafr(1:lnomaf), nompro
#endif
      call eslmno ( idfmed, nomafr,
     >                iaux,
     >              sfnbso, sfsdim, rmem(pgeoco), tbiaux,
     >              ulsort, langue, codret )
c
      endif
c
c 3.2. ==> Description des lignes
c
      if ( codret.eq.0 ) then
c
      sfnbli = tbiaux(1)
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'sfnbli', sfnbli
      write(ulsort,*) (tbiaux(iaux), iaux=1, 2*(sfnbli+1)+1)
#endif
      call gmecat ( nocdfr, 4, sfnbli, codre1 )
      call gmaloj ( nocdfr//'.NumeLign', ' ', sfnbli, pnumli, codre2 )
      call gmaloj ( nocdfr//'.TypeLign', ' ', sfnbli, ptypli, codre3 )
      call gmaloj ( nocdfr//'.PtrSomLi', ' ', sfnbli+1, psegli, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
      if ( codret.eq.0 ) then
c
      do 321 , iaux = 0 , sfnbli-1
        imem(pnumli+iaux) = tbiaux(iaux+2)
  321 continue
      do 322 , iaux = 0 , sfnbli-1
        imem(ptypli+iaux) = tbiaux(iaux+sfnbli+2)
  322 continue
      do 323 , iaux = 0 , sfnbli
        imem(psegli+iaux) = tbiaux(iaux+2*sfnbli+2)
  323 continue
c
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro, nocdfr )
      call gmprsx ( nompro, nocdfr//'.NumeLign' )
      call gmprsx ( nompro, nocdfr//'.TypeLign' )
      call gmprsx ( nompro, nocdfr//'.PtrSomLi' )
#endif
c
      endif
c
c====
c 4. Lecture des abscisses curvilignes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. Abscisses curvilignes ; codret', codret
#endif
c      Le nom doit etre coherent avec eslmh2
c
      if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4.1. Creation maillage 2 ; codret', codret
#endif
c
      saux64 = blan64
      saux64(1:8) = 'AbsCurvi'
c
      iaux = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMNO-'//saux64(1:8), nompro
#endif
      call eslmno ( idfmed, saux64,
     >                iaux,
     >              sfnbse, iaux, rmem(adabsc), imem(psomse),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 5. Lecture des groupes
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Groupes ; codret', codret
#endif
c
c 5.1. ==> Lecture des valeurs entieres
c
      if ( codret.eq.0 ) then
c
      noprof = blan64
c                     1234567890123456789012
      noprof(1:22) = 'Groupes_des_frontieres'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRR', nompro
#endif
      call mpfprr ( idfmed, noprof, tbiaux, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,61)) noprof
#endif
c
c 5.2. ==> Memoire
c
      if ( codret.eq.0 ) then
c
      lgpttg = tbiaux(1)
      lgtabl = tbiaux(2)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'lgpttg', lgpttg
      write (ulsort,90002) 'lgtabl', lgtabl
      write(ulsort,*) (tbiaux(iaux),iaux=1,3+lgpttg+lgtabl)
#endif
c
      iaux = 1
      jaux = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAPTC', nompro
#endif
      call utaptc ( nocdfr//'.Groupes', iaux, jaux,
     >              lgpttg, lgtabl,
     >              pointl, pttgrl, ptngrl,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nocdfr//'.Groupes', ncafdg, codret )
c
      endif
c
c 5.3. ==> Lecture des caracteres
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFAFAI', nompro
#endif
      iaux = 2
      call mfafai ( idfmed, nomafr, iaux, saux64, jaux,
     >              tbsaux, codret )
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '... Famille ', saux64
      write (ulsort,90002) 'numfam', jaux
      do 5353 , iaux = 1 , ngro
        write(ulsort,*) (tbsaux(10*(iaux-1)+jaux)//'+',jaux=1,10)
 5353 continue
#endif
c
      endif
c
c 5.4. ==> Transfert
c
      if ( codret.eq.0 ) then
c
      do 541 , iaux = 0 , lgpttg
        imem(pointl+iaux) = tbiaux(iaux+3)
  541 continue
c
      jaux = lgpttg+3
      do 542 , iaux = 1 , lgtabl
        imem(pttgrl+iaux-1) = tbiaux(jaux+iaux)
  542 continue
c
      do 543 , iaux = 1 , lgtabl
        smem(ptngrl+iaux-1) = tbsaux(iaux)
  543 continue
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
      call gmprsx (nompro, nocdfr//'.Groupes' )
      endif
#endif
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

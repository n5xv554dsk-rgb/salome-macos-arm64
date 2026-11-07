      subroutine eslmh1 ( typobs, nomail,
     >                    suifro, nocdfr, ncafdg,
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
c  Entree-Sortie : Lecture du Maillage Homard - phase 1
c  -      -        -          -        -              -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typobs . e   . char*8 . mot-cle correspondant a l'objet a lire     .
c . nomail .  s  . char*8 . nom du maillage a lire                     .
c . suifro . es  .   1    . 1 : pas de suivi de frontiere              .
c .        .     .        . 2x : frontiere discrete                    .
c .        .     .        . 3x : frontiere analytique                  .
c .        .     .        . 5x : frontiere cao                         .
c .        .     .        . <0 : le maillage est absent du fichier     .
c . nocdfr .  s  . char*8 . nom de l'objet description de la frontiere .
c . ncafdg .  s  . char*8 . nom de l'objet groupes frontiere           .
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
      parameter ( nompro = 'ESLMH1' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "gmenti.h"
#include "gmstri.h"
c
#include "dicfen.h"
#include "envex1.h"
#include "envca1.h"
#include "nombmp.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombno.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombhe.h"
#include "nombpe.h"
#include "front1.h"
#include "nbutil.h"
c
c 0.3. ==> arguments
c
      integer suifro
c
      character*8 typobs
      character*(*) nomail
      character*8 nocdfr, ncafdg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux
      integer codre0
      integer codre1, codre2
      integer lnomai, lnomfi
      integer*8 idfmed
      integer typnom
      integer dimcst, lgnoig, nbnoco
      integer natmax, ngrmax
      integer lgpeli
      integer lnomaf
      integer ltrav1, ltrav2
      integer ptrav1, ptrav2
c
      character*8 ntrav1, ntrav2
      character*8 norenu
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhelig
      character*8 nhvois, nhsupe, nhsups
      character*64 nomamd
      character*64 nomafr
      character*200 nomfic
c
      logical exiren
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
      texte(1,4) = '(5x,''Lecture du maillage '',a,'' sur le fichier'')'
c
      texte(2,4) = '(5x,''Readings of mesh '',a,'' on file'')'
c
#include "impr03.h"
c
#include "esimpr.h"
c
      codret = 0
c
c====
c 2. nom du maillage et du fichier
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. maillage/fichier ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      jaux = 1
      call utfino ( typobs, iaux, nomfic, lnomfi,
     >              jaux,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      iaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTOSNO', nompro
#endif
      call utosno ( typobs, nomail, iaux, ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call utlgut ( lnomai, nomail,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
      write (ulsort,texte(langue,4)) nomail(1:lnomai)
      write (ulsort,*) '    '//nomfic(1:lnomfi)
      endif
c
c====
c 3. ouverture du fichier et lectures preliminaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. ouverture du fichier ; codret', codret
#endif
c
c 3.1. ==> Ouverture du fichier
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      iaux = 3
#else
      iaux = 1
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESOUVL', nompro
#endif
      call esouvl ( idfmed, nomfic(1:lnomfi), iaux,
     >              ulsort, langue, codret )
      if ( codret.ne.0 ) then
        codret = 1
      endif
c
      endif
c
c 3.2. ==> Lectures de base
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH2', nompro
#endif
      call eslmh2 ( idfmed,
     >              nomail, lnomai,
     >                sdim,   mdim,
     >               degre, maconf, homolo, hierar,
     >              rafdef, nbmane, typcca, typsfr, maextr,
     >              mailet,
     >              dimcst, lgnoig, nbnoco,
     >              sdimca, mdimca,
     >              exiren, lgpeli,
     >              suifro, nomafr, lnomaf,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 4. allocation de la tete du maillage HOMARD
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. allocation de la tete ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( exiren ) then
        iaux = 1
      else
        iaux = 2
      endif
      typnom = 1
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAHMA', nompro
#endif
      call utahma ( nomail, typnom, iaux,
     >                sdim,   mdim,  degre, mailet, maconf,
     >              homolo, hierar, rafdef,
     >              nbmane, typcca, typsfr, maextr,
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
c====
c 5. Recuperation des communs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '5. Recuperation communs ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      nomamd = blan64
      nomamd(1:8) = nomail
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH3', nompro
#endif
      call eslmh3 ( idfmed, nomamd,
     >              nhsupe,
     >              nbfmed, natmax, ngrmax,
     >              ulsort, langue, codret)
c
      endif
c
c====
c 6. tableaux de travail
c    On doit tenir compte des caracteristiques des familles pour
c    le dimensionnement du tableau tbsaux
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '6. tableaux de travail ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbnoto', nbnoto
      write (ulsort,90002) 'nbmpto', nbmpto
      write (ulsort,90002) 'nbarto', nbarto
      write (ulsort,90002) 'nbtrto', nbtrto
      write (ulsort,90002) 'nbquto', nbquto
      write (ulsort,90002) 'nbteto, nbtecf, nbteca',
     >                      nbteto, nbtecf, nbteca
      write (ulsort,90002) 'nbheto, nbhecf, nbheca',
     >                      nbheto, nbhecf, nbheca
      write (ulsort,90002) 'nbpyto, nbpycf, nbpyca',
     >                      nbpyto, nbpycf, nbpyca
      write (ulsort,90002) 'nbpeto, nbpecf, nbpeca',
     >                      nbpeto, nbpecf, nbpeca
      write (ulsort,90002) 'nbfmed', nbfmed
      write (ulsort,90002) 'ngrmax', ngrmax
      write (ulsort,90002) 'lgpeli', lgpeli
      write (ulsort,90002) 'sfsdim', sfsdim
      write (ulsort,90002) 'sfnbso', sfnbso
      write (ulsort,90002) 'sfnbse', sfnbse
#endif
c
      ltrav1 = max ( 4*nbnoto,
     >               nbmpto, 5*nbarto, 5*nbtrto, 5*nbquto,
     >               6*nbteto, 2*nbteca,
     >               7*nbpyto, 3*nbpyca,
     >               8*nbheto, 6*nbheca,
     >               5*nbpeto, 4*nbpeca,
     >               lgpeli,
     >               sfnbso )
      call gmalot ( ntrav1, 'entier  ', ltrav1   , ptrav1, codre1 )
      ltrav2 = 25*( max ( nctfno, nctfmp, nctfar, nctftr, nctfqu,
     >                    nctfte, nctfpy, nctfhe, nctfpe, 30 ) + 1 )
      ltrav2 = max ( ltrav2, 25*natmax+10*ngrmax )
      call gmalot ( ntrav2, 'chaine  ', ltrav2   , ptrav2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 7. Lecture des noeuds
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '7. Lecture des noeuds ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLENO', nompro
#endif
      call esleno ( idfmed, nomamd,
     >              nhnoeu,
     >              dimcst, lgnoig, nbnoco,
     >              ltrav1, imem(ptrav1),
     >              ulsort, langue, codret)
c
      endif
c
c====
c 8. Lecture des entites mailles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '8. Lecture des mailles ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLEEN', nompro
#endif
      call esleen ( idfmed, nomamd,
     >              nhmapo, nharet, nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              ltrav1, imem(ptrav1),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 9. Les renumerotations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '9. Les renumerotations ; codret', codret
#endif
c
      if ( exiren ) then
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH4', nompro
#endif
      call eslmh4 ( idfmed,
     >              nomail,
     >              ulsort, langue, codret)
c
      endif
c
      endif
c
c====
c 10. Lecture des familles
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. les familles ; codret', codret
#endif
c
      if ( codret.eq.0) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLEFE', nompro
#endif
      call eslefe ( idfmed, nomamd,
     >              nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              nhsups,
     >              ltrav2, smem(ptrav2),
     >              ulsort, langue, codret )
c
      endif
c
c====
c 11. Lecture des elements ignores
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '10. Elements ignores ; codret', codret
#endif
c
      if ( lgpeli.gt.0 ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH6', nompro
#endif
        call eslmh6 ( idfmed,
     >                nhelig,
     >                imem(ptrav1),
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
c====
c 11. Lecture de l'eventuelle frontiere discrete
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '11. Frontiere discrete ; codret', codret
#endif
c
      if ( mod(suifro,2).eq.0 ) then
c
        if ( lnomaf.gt.0 ) then
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESLMH7', nompro
#endif
          call eslmh7 ( idfmed,
     >                  nocdfr, ncafdg,
     >                  ltrav1, imem(ptrav1), ltrav2, smem(ptrav2),
     >                  nomafr, lnomaf,
     >                  ulsort, langue, codret )
c
          endif
c
        else
c
          suifro = -abs(suifro)
c
        endif
c
      endif
c
c====
c 12. Fermeture du fichier
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '12. Fermeture du fichier ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFICLO', nompro
#endif
      call mficlo ( idfmed, codret )
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,8)) nomfic(1:lnomfi)
        write (ulsort,texte(langue,10))
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      call gmprsx ( nompro, nomail )
      endif
#endif
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
      write (ulsort,texte(langue,8)) nomfic(1:lnomfi)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

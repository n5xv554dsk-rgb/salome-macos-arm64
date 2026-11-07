      subroutine esemh2 ( idfmed, nomamd,
     >                    nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >                    nhtetr, nhhexa, nhpyra, nhpent,
     >                    nhsups,
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
c  Entree-Sortie : Ecriture du Maillage Homard - 2
c  -      -        -           -        -        -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   .char64  . nom du maillage MED voulu                  .
c . nhsups . e   . char*8 . informations supplementaires caracteres 8  .
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
      parameter ( nompro = 'ESEMH2' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca2.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer ltbiau, tbiaux(ltbiau)
      integer ltbsau
c
      character*8 tbsaux(*)
      character*8 nhnoeu, nhmapo, nharet, nhtria, nhquad
      character*8 nhtetr, nhhexa, nhpyra, nhpent
      character*8 nhsups
c
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux
      integer ngro, numfam
c
      character*64 saux64
      character*80 saux80(2)
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''. Ecriture des familles'')'
c
      texte(2,4) = '(''. Writings of families'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
#endif
c
#include "esimpr.h"
c
c====
c 2. La famille nulle
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. famille nulle ; codret = ', codret
#endif
c
      if ( codret.eq.0) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '. La famille nulle'
#endif
      saux64 = blan64
c                     1234567890123
      saux64(1:13) = 'famille_nulle'
      numfam = 0
      ngro = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFACRE', nompro
#endif
      call mfacre ( idfmed, nomamd, saux64, numfam,
     >              ngro, saux80, codret )
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,78)) 'mfacre', codret
      endif
c
      endif
c
c====
c 3. Les familles des entites
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. entites ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECFE', nompro
#endif
      call esecfe ( idfmed, nomamd,
     >              nhnoeu, nhmapo, nharet, nhtria, nhquad,
     >              nhtetr, nhhexa, nhpyra, nhpent,
     >              numfam,
     >              tbiaux,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 4. La famille de la date et du titre
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. date et titre ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '. La famille de la date et du titre'
#endif
      saux64 = blan64
c                     1234567890123
      saux64(1:13) = 'date_et_titre'
      numfam = numfam - 1
      ngro = 2
c                          90123456789012345678901234567890
      saux80(1) = ladate//'                                '
      saux80(2) = titre
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFACRE', nompro
#endif
      call mfacre ( idfmed, nomamd, saux64, numfam,
     >              ngro, saux80, codret )
c
      if ( codret.ne.0 ) then
        write(ulsort,texte(langue,78)) 'mfacre', codret
      endif
c
      endif
c
c====
c 5. Les familles des informations complementaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Info supp ; codret = ', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '. Familles des informations complementaires'
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECFS', nompro
#endif
      call esecfs ( idfmed, nomamd,
     >              nhsups,
     >              numfam,
     >              ltbsau, tbsaux,
     >              ulsort, langue, codret)
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

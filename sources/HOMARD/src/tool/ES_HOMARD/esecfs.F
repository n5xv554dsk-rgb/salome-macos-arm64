      subroutine esecfs ( idfmed, nomamd,
     >                    nhsups,
     >                    numfam,
     >                    ltbsau, tbsaux,
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
c  Entree-Sortie : ECriture des Familles Supplementaires
c  -      -        --           -        -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . nhsups . e   . char*8 . informations supplementaires caracteres 8  .
c . numfam . es  .   1    . numero de famille                          .
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
      parameter ( nompro = 'ESECFS' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer numfam
      integer ltbsau
c
      character*8 nhsups
      character*64 nomamd
      character*8 tbsaux(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer iaux, jaux, kaux
      integer codre1, codre2
      integer codre0
      integer adress, nbval
      integer ngro
c
      character*2 saux02
      character*32 saux32
      character*64 saux64
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
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
#include "esimpr.h"
c
      texte(1,4) = '(''. Ecriture des familles supplementaires'')'
      texte(1,5) = '(''... InfoSupS.Tab'',i2)'
      texte(1,81) = '(''Longueur allouee pour tbsaux    : '',i10)'
      texte(1,82) = '(''Longueur necessaire pour tbsaux : '',i10)'
c
      texte(2,4) = '(''. Writings of aditional families'')'
      texte(2,5) = '(''... InfoSupS.Tab'',i2)'
      texte(2,81) = '(''Allocated length for tbsaux    : '',i10)'
      texte(2,82) = '(''Used length for tbsaux : '',i10)'
c
#include "impr03.h"
c
 1002 format(10(a8,'+'))
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4))
      call gmprsx ( nompro, nhsups )
      call gmprsx ( nompro, nhsups//'.Tab2' )
      call gmprsx ( nompro, nhsups//'.Tab3' )
      call gmprsx ( nompro, nhsups//'.Tab4' )
      call gmprsx ( nompro, nhsups//'.Tab10' )
c
#endif
c
c====
c 2. Ecriture
c====
c
      do 21 , iaux = 1 , 10
c
c 2.1. ==> decodage des caracteristiques
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.1. ==> decodage ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) iaux
#endif
c
        jaux = iaux
        call utench ( jaux, 'g', kaux, saux02,
     >                ulsort, langue, codret )
c
        endif
c
        if ( codret.eq.0 ) then
c
        call gmobal ( nhsups//'.Tab'//saux02(1:kaux), codre0 )
c
        if ( codre0.eq.2 ) then
c
          call gmliat ( nhsups, jaux, nbval, codre1 )
          call gmadoj ( nhsups//'.Tab'//saux02(1:kaux),
     >                  adress, kaux, codre2 )
c
          codre0 = min ( codre1, codre2 )
          codret = max ( abs(codre0), codret,
     >                   codre1, codre2 )
c
        else
          goto 21
        endif
c
        endif
c
c 2.2. ==> creation de la famille eventuelle
c          La convention MED veut que le nom d'un groupe soit
c          de taille 80
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. ==> creation ; codret', codret
#endif
cgn        call gmprsx ( nompro, nhsups//'.Tab'//saux02 )
c
        if ( nbval.gt.0 ) then
c
c 2.2.1. ==> controle
c
          if ( codret.eq.0 ) then
#ifdef _DEBUG_HOMARD_
          write (ulsort,90002) 'nbval', nbval
#endif
c
          if ( (nbval+11).gt.ltbsau ) then
            call gmprsx ( nompro, nhsups )
            write (ulsort,texte(langue,81)) ltbsau
            write (ulsort,texte(langue,82)) nbval+11
            write (ulsort,*) 'Probleme pour Tab', saux02
            codret = 7
          endif
c
          endif
c
c 2.2.2. ==> un premier groupe : le nombre de valeurs
c
          if ( codret.eq.0 ) then
c
          call utench ( nbval, 'd', jaux, saux32,
     >                  ulsort, langue, codret )
c
          tbsaux(1) = 'Nombre d'
          tbsaux(2) = 'e valeur'
          tbsaux(3) = 's :     '
          tbsaux(4) = saux32( 1: 8)
          tbsaux(5) = saux32( 9:16)
          tbsaux(6) = saux32(17:24)
          tbsaux(7) = saux32(25:32)
          do 222 , jaux = 8, 10
            tbsaux(jaux) = blan08
  222     continue
c
          endif
c
c 2.2.3. ==> les groupes suivants : le texte
c
          if ( codret.eq.0 ) then
c
          kaux = mod(nbval,10)
          if ( kaux.eq.0 ) then
            jaux = nbval/10
          else
            jaux = (nbval-kaux)/10 + 1
          endif
          ngro = jaux + 1
c
          do 2231 , jaux = 1 , nbval
            tbsaux(10+jaux) = smem(adress+jaux-1)
 2231     continue
c
          do 2232 , jaux = 10+nbval+1 , 10*ngro
            tbsaux(jaux) = blan08
 2232     continue
c
          endif
c
c 2.2.4. ==> ecriture
c
          if ( codret.eq.0 ) then
c
          numfam = numfam - 1
          saux64 = blan64
c                          123456789012
          saux64( 1:12) = 'InfoSupS_Tab'
          saux64(13:14) = saux02
c
#ifdef _DEBUG_HOMARD_
          write (ulsort,*) 'Famille ', saux64
          write (ulsort,90002) 'ngro', ngro
          do 224 , jaux = 1 , ngro
            write (ulsort,1002)
     >         (tbsaux(kaux),kaux=10*(jaux-1)+1,10*jaux)
  224     continue
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFACRE', nompro
#endif
          call mfacre ( idfmed, nomamd, saux64, numfam,
     >                  ngro, tbsaux, codret )
c
          endif
c
        endif
c
   21 continue
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

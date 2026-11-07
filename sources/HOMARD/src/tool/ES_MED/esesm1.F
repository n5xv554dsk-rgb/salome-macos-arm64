      subroutine esesm1 ( idfmed, nomamd,
     >                    nbcham, noobch, nbprof, noobpr,
     >                    nblopg, noobpg,
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
c  Entree-Sortie - Ecriture d'une Solution au format MED - phase 1
c  -      -        -              -                  -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identifiant du fichier med en sortie       .
c . nomamd . e   . char64 . nom du maillage MED                        .
c . nbcham . e   .   1    . nombre de champs a ecrire                  .
c . noobch . e   . nbcham . nom des objets qui contiennent la          .
c .        .     .        . description de chaque champ                .
c . nbprof . e   .   1    . nombre de profils a ecrire                 .
c . noobpr . e   . nbprof . nom des objets qui contiennent la          .
c .        .     .        . description de chaque profil               .
c . nblopg . e   .   1    . nombre de localisations de points de Gauss .
c . noobpg . e   . nblopg . nom des objets qui contiennent la          .
c .        .     .        . description de chaque localisation         .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c ______________________________________________________________________
c
c  ESESM1 --> ESES11
c         --> ESECH1 --> ESECH2
c         --> ESES12
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
      parameter ( nompro = 'ESESM1' )
c
#include "nblang.h"
#include "consts.h"
c
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer nbcham, nbprof, nblopg
c
      character*8 noobch(nbcham)
      character*8 noobpr(*)
      character*8 noobpg(*)
      character*64 nomamd
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer adnocp, adcaen, adcare, adcaca
      integer adlipr
      integer nbcomp, nbtvch, typcha
      integer nbvapr
      integer typgeo, ngauss, dimcpg
      integer adcono, adcopg, adpopg
      integer nrcham, nrprof, nrlopg
      integer iaux
c
      character*16 dtunit
      character*64 nomcha, noprof, nolopg
      character*64 saux64
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. initialisations
c====
c
#include "impr01.h"
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,5) = '(/,''Ecriture du profil : '',a)'
      texte(1,6) =
     > '(/,''Ecriture de la localisation de points de Gauss : '',a)'
      texte(1,7)   = '(''... Premiere(s) valeur(s) :'',10i6)'
      texte(1,100) = '(''... Dernieres valeurs     :'',10i6)'
c
      texte(2,5) = '(/,''Writing of profile: '',a)'
      texte(2,6) =
     > '(/,''Writing of localization of Gauss points: '',a)'
      texte(2,7) = '(''First values: '',10i6)'
      texte(2,100) = '(''Last values: '',10i6)'
c
#include "esimpr.h"
c
c====
c 2. ecriture des eventuels profils
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. profils ; codret', codret
      write (ulsort,90002) 'nbprof', nbprof
#endif
c
      if ( codret.eq.0 ) then
c
      do 20 , nrprof = 1 , nbprof
c
c 2.1. ==> informations generales sur le profil
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPR', nompro
#endif
        call utcapr ( noobpr(nrprof),
     >                nbvapr, noprof, adlipr,
     >                ulsort, langue, codret )
c
        endif
c
c 2.2. ==> ecriture du profil
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,5)) noprof
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,62)) nbvapr
        write (ulsort,texte(langue,7))
     > (imem(iaux), iaux = adlipr, adlipr+min(9,nbvapr-1))
        if ( nbvapr.gt.10 ) then
        write (ulsort,texte(langue,100))
     > (imem(iaux), iaux = adlipr+nbvapr-10, adlipr+nbvapr-1)
        endif
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW', nompro
#endif
        call mpfprw ( idfmed, noprof, nbvapr, imem(adlipr), codret )
c
        endif
c
   20 continue
c
      endif
c
c====
c 3. ecriture des eventuelles localisations
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. localisations ; codret', codret
      write (ulsort,90002) 'nblopg', nblopg
#endif
c
      if ( codret.eq.0 ) then
c
      do 30 , nrlopg = 1 , nblopg
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nrlopg', nrlopg
      write (ulsort,90003) 'noobpg(nrlopg)', noobpg(nrlopg)//'EEE'
#endif

        if ( noobpg(nrlopg).ne.blan08 ) then
c
c 3.1. ==> informations generales sur la localisation
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPG', nompro
#endif
c
        call utcapg ( noobpg(nrlopg),
     >                nolopg, typgeo, ngauss, dimcpg,
     >                adcono, adcopg, adpopg,
     >                ulsort, langue, codret )
c
        endif
c
c 3.2. ==> ecriture de la localisation
c
        if ( codret.eq.0 ) then
c
        write (ulsort,texte(langue,6)) nolopg
c
        saux64 = blan64
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MLCLOW', nompro
#endif
c
        call mlclow ( idfmed, nolopg, typgeo, dimcpg,
     >                rmem(adcono), edfuin,
     >                ngauss, rmem(adcopg), rmem(adpopg),
     >                saux64, saux64,
     >                codret )
c
        endif
c
        endif
c
   30 continue
c
      endif
c
c====
c 4. ecriture des valeurs, champ par champ
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. valeurs ; codret', codret
      write (ulsort,90002) 'nbcham', nbcham
#endif
c
      if ( codret.eq.0 ) then
c
      do 40 , nrcham = 1 , nbcham
c
c 4.1. ==> informations generales sur le champ
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, noobch(nrcham))
cgn      call gmprsx (nompro, noobch(nrcham)//'.Nom_Comp')
cgn      call gmprsx (nompro, noobch(nrcham)//'.Cham_Ent')
cgn      call gmprsx (nompro, noobch(nrcham)//'.Cham_Ree')
      call gmprsx ('  Fonction      Profil        LocaPG',
     >             noobch(nrcham)//'.Cham_Car')
#endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCACH', nompro
#endif
        call utcach ( noobch(nrcham),
     >                nomcha,
     >                nbcomp, nbtvch, typcha,
     >                adnocp, adcaen, adcare, adcaca,
     >                ulsort, langue, codret )
c
        endif
c
c 4.2. ==> creation du champ
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,32)) nomcha
        write (ulsort,90002) 'typcha', typcha
        write (ulsort,texte(langue,111)) nbtvch
#endif
c
        dtunit = smem(adnocp+8+4*nbcomp)//smem(adnocp+8+4*nbcomp+1)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESES11', nompro
#endif
        call eses11 ( idfmed, nomcha,
     >                nbcomp, typcha,
     >                smem(adnocp+8), smem(adnocp+8+2*nbcomp),
     >                dtunit, nomamd,
     >                ulsort, langue, codret )
c
        endif
c
c 4.3. ==> ecriture des tableaux lies au champ
c
        if ( codret.eq.0 ) then
c
        if ( nbtvch.ne.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECH1', nompro
#endif
          call esech1 ( idfmed, nomcha,
     >                  nbcomp, nbtvch,
     >                  imem(adcaen), rmem(adcare), smem(adcaca),
     >                  ulsort, langue, codret )
c
        endif
c
        endif
c
   40 continue
c
      endif
c
c====
c 5. la fin
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

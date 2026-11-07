      subroutine esech1 ( idfmed, nomcha,
     >                    nbcomp, nbtvch,
     >                    caraen, carare, caraca,
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
c  Entree-Sortie - Ecriture d'un CHamp au format MED - phase 1
c  -      -        -             --                          -
c  remarque : on n'ecrit que les champs reels
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identifiant du fichier med en sortie       .
c . nomcha . e   . char64 . nom du champ                               .
c . nbcomp . e   .   1    . nombre de composantes                      .
c . nbtvch . e   .   1    . nombre de tableaux associes                .
c . caraen . e   . nbinec*. caracteristiques entieres des tableaux du  .
c .        .     . nbtvch . champ en cours d'examen                    .
c .        .     .        . 1. type de support au sens MED             .
c .        .     .        .  -1, si on prend tous les supports         .
c .        .     .        . 2. numero du pas de temps                  .
c .        .     .        . 3. numero d'ordre                          .
c .        .     .        . 4. nombre de points de Gauss               .
c .        .     .        . 5. nombre d'entites support                .
c .        .     .        . 6. nombre de valeurs du profil eventuel    .
c .        .     .        . 7. nombre de supports associes             .
c .        .     .        . 8. 1, si aux noeuds par elements           .
c .        .     .        .    2, si aux points de Gauss, associe avec .
c .        .     .        .       un champ aux noeuds par elements     .
c .        .     .        .    3, si aux points de Gauss autonome      .
c .        .     .        .    0, sinon                                .
c .        .     .        . 9. numero du 1er tableau dans la fonction  .
c .        .     .        . 10. si champ elga, numero du champ elno    .
c .        .     .        .     si champ elno, numero du champ elga si .
c .        .     .        .     il existe, sinon -1                    .
c .        .     .        . 11. type interpolation                     .
c .        .     .        .       0, si automatique                    .
c .        .     .        .       1 si degre 1, 2 si degre 2,          .
c .        .     .        .       3 si iso-P2                          .
c .        .     .        . 12. type de champ edfl64/edin64            .
c .        .     .        . 21-nbinec. type des supports associes      .
c . carare . e   . nbtvch . caracteristiques reelles du champ          .
c .        .     .        . 1. valeur du pas de temps                  .
c . caraca . e   . nbincc*. caracteristiques caracteres des tableaux   .
c .        .     . nbsqch . du champ en cours d'examen                 .
c .        .     .        . 1. nom de l'objet fonction                 .
c .        .     .        . 2. nom de l'objet profil, blanc sinon      .
c .        .     .        . 3. nom de l'objet localisation des points  .
c .        .     .        . de Gauss, blanc sinon                      .
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
      parameter ( nompro = 'ESECH1' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "esutil.h"
#include "gmenti.h"
#include "gmreel.h"
#include "gmstri.h"
c
#include "rftmed.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer nbcomp, nbtvch
      integer caraen(nbinec,nbtvch)
c
      double precision carare(nbtvch)
c
      character*8 caraca(nbincc,nbtvch)
      character*64 nomcha
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
      integer nrotv, nbpg
      integer typenh
      integer nbvalc
      integer typgeo, numdt, numit, ngauss, nbval, nbvapr
      integer nrtafo
      integer typcha
      integer typgef, ngausf, nbenmx, nbvapf, nbtyas
      integer carsup, carsuf, nbtafo
      integer typint
      integer adtra1
      integer advale, advalr, adobch, adprpg, adtyas
      integer adcono, adcopg, adpopg
c
      double precision dtval
c
      character*6 saux06
      character*8 nomfon, obprof, oblopg
      character*8 ntrav1
      character*64 nolopg
      character*64 noprof
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c
c====
c 1. initialisations
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
      texte(1,4) = '(/,''Tableau numero '',i6,/,21(''-''))'
      texte(1,5) =
     > '(''. Ecriture sur les '',a,'' au pas de temps : '',i6)'
      texte(1,6) =
     > '(''. Ecriture sur les '',a,'' sans pas de temps'')'
      texte(1,7) = '(''. Profil : '',a)'
      texte(1,8) = '(''. Localisation des points de Gauss : '',a)'
      texte(1,13) = '(''... Premiere valeur : '',g14.7)'
      texte(1,14) = '(''... Derniere valeur : '',g14.7)'
c
      texte(2,4) = '(/,''Table # '',i6,/,14(''-''))'
      texte(2,5) =
     > '(''. Writings over the '',a,'' at time step # '',i6)'
      texte(2,6) = '(''. Writings over the '',a,'' without time step'')'
      texte(2,7) = '(''. Profile: '',a)'
      texte(2,8) = '(''. Localization of points of Gauss: '',a)'
      texte(2,13) = '(''... First value: '',g14.7)'
      texte(2,14) = '(''... Last value : '',g14.7)'
c
#include "impr03.h"
c
c====
c 2. on parcourt tous les tableaux
c====
c
      codret = 0
cgn      write (ulsort,90002) 'nbtvch', nbtvch
c
      do 20 , nrotv = 1 , nbtvch
c
c 2.1. ==> caracteristiques du tableau courant
c
        if ( codret.eq.0 ) then
c
        typgeo = caraen(1,nrotv)
        numdt  = caraen(2,nrotv)
        numit  = caraen(3,nrotv)
        ngauss = caraen(4,nrotv)
        nbval  = caraen(5,nrotv)
        nbvapr = caraen(6,nrotv)
        nbtyas = caraen(7,nrotv)
        carsup = caraen(8,nrotv)
        nrtafo = caraen(9,nrotv)
        dtval = carare(nrotv)
        nomfon = caraca(1,nrotv)
        obprof = caraca(2,nrotv)
        oblopg = caraca(3,nrotv)
        if ( typgeo.eq.0 ) then
          typenh = ednoeu
        elseif ( carsup.eq.1 ) then
          typenh = ednoma
        else
          typenh = edmail
        endif
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,4)) nrotv
        write (ulsort,90002) 'typenh', typenh
        write (ulsort,90002) 'typgeo', typgeo
        write (ulsort,90002) 'numdt ', numdt
        write (ulsort,90002) 'numit ', numit
        write (ulsort,90002) 'ngauss', ngauss
        write (ulsort,90002) 'nbval ', nbval
        write (ulsort,90002) 'nbvapr', nbvapr
        if ( nbvapr.gt.0 ) then
          write (ulsort,90003) 'obprof', obprof
        endif
        write (ulsort,90002) 'nbtyas', nbtyas
        if ( nbtyas.gt.0 ) then
          write (ulsort,90002)
     >   'typass', (caraen(20+iaux,nrotv),iaux=1,nbtyas)
        endif
        write (ulsort,90002) 'carsup', carsup
        write (ulsort,90002) 'nrtafo', nrtafo
        if ( numdt.ne.ednodt ) then
          write (ulsort,90004) 'dtval ', dtval
        endif
        if ( oblopg.ne.blan08 ) then
          write (ulsort,90003) 'oblopg', oblopg
        endif
#endif
c
        endif
c
c 2.2. ==> en l'absence de valeurs, on passe au tableau suivant
c
        if ( codret.eq.0 ) then
c
        if ( nbval.eq.0 ) then
          goto 20
        endif
c
        endif
c
c 2.3. ==> recuperation de la fonction
c          on controle que les caracterisations sont bien les memes
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro,nomfon)
        call gmprot (nompro,nomfon//'.ValeursR', 1, 10)
        call gmprot (nompro,nomfon//'.ValeursR', nbval-9, nbval)
        call gmprot (nompro,nomfon//'.ValeursE', 1, 10)
        call gmprot (nompro,nomfon//'.ValeursE', nbval-9, nbval)
        call gmprsx (nompro,nomfon//'.InfoPrPG' )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAFO', nompro
#endif
        call utcafo ( nomfon,
     >                typcha,
     >                typgef, ngausf, nbenmx, nbvapf, nbtyas,
     >                carsuf, nbtafo, typint,
     >                advale, advalr, adobch, adprpg, adtyas,
     >                ulsort, langue, codret )
c
        endif
c
#ifdef _DEBUG_HOMARD_
        if ( codret.eq.0 ) then
        write (ulsort,90002) 'typcha', typcha
        if ( typcha.eq.edfl64 ) then
          write (ulsort,texte(langue,13)) rmem(advalr)
          write (ulsort,texte(langue,14)) rmem(advalr+nbval*nbtafo-1)
        else
          write (ulsort,texte(langue,13)) imem(advale)
          write (ulsort,texte(langue,14)) imem(advale+nbval*nbtafo-1)
        endif
        endif
#endif
c
        if ( codret.eq.0 ) then
          if ( typgef.ne.typgeo ) then
            saux06 = 'typgeo'
            codret = 1
            iaux = typgef
            jaux = typgeo
          elseif ( ngausf.ne.ngauss ) then
            saux06 = 'ngauss'
            codret = 2
            iaux = ngausf
            jaux = ngauss
          elseif ( nbenmx.ne.nbval ) then
            saux06 = 'nbval '
            codret = 3
            iaux = nbenmx
            jaux = nbval
          elseif ( nbvapf.ne.nbvapr ) then
            saux06 = 'nbvapr'
            codret = 4
            iaux = nbvapf
            jaux = nbvapr
          elseif ( carsuf.ne.carsup ) then
            saux06 = 'carsup'
            codret = 5
            iaux = carsuf
            jaux = carsup
          endif
          if ( codret.ne.0 ) then
            write (ulsort,texte(langue,36)) saux06, iaux
            write (ulsort,texte(langue,37)) saux06, jaux
          endif
        endif
c
c 2.4. ==> le profil eventuel
c
        if ( codret.eq.0 ) then
c
        if ( nbvapr.gt.0 ) then
c
          if ( obprof.eq.smem(adprpg) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPR', nompro
#endif
            call utcapr ( obprof,
     >                    iaux, noprof, jaux,
     >                    ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
            if ( codret.eq.0 ) then
            write (ulsort,texte(langue,61)) noprof
            endif
#endif
c
          else
            codret = 5
          endif
c
        else
c
          noprof = ednopl
c
        endif
c
        endif
c
c 2.5. ==> les eventuelles localisations de points de Gauss
c
        if ( codret.eq.0 ) then
c
        if ( oblopg.eq.blan08 ) then
          nolopg = ednoga
        else
          if ( oblopg.eq.smem(adprpg+1) ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPG', nompro
#endif
            call utcapg ( oblopg,
     >                    nolopg, iaux, jaux, kaux,
     >                    adcono, adcopg, adpopg,
     >                    ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
            if ( codret.eq.0 ) then
            write (ulsort,texte(langue,81)) nolopg
            endif
#endif
c
          else
            codret = 6
          endif
        endif
c
        endif
c
c 2.6. ==> allocation d'un tableau de travail
c
        if ( codret.eq.0 ) then
c
        if ( ngauss.eq.ednopg ) then
          nbpg = 1
        else
          nbpg = ngauss
        endif
        jaux = nbpg*nbval*nbcomp
cgn      write (ulsort,*)'allocation a nbpg*nbval*nbcomp = ', jaux
        if ( typcha.eq.edfl64 ) then
          call gmalot ( ntrav1, 'reel    ', jaux, adtra1, codret )
        else
          call gmalot ( ntrav1, 'entier  ', jaux, adtra1, codret )
        endif
c
        endif
c
c 2.7. ==> transfert des valeurs dans le tableau de travail
c
        if ( codret.eq.0 ) then
c
        if ( nbvapr.gt.0 ) then
          nbvalc = nbvapr
        else
          nbvalc = nbenmx
        endif
c
        if ( typcha.eq.edfl64 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECH2', nompro
#endif
          call esech2 ( nrtafo,
     >                  nbtafo, nbpg, nbvalc, nbcomp,
     >                  rmem(advalr), rmem(adtra1),
     >                  ulsort, langue, codret )
cgn        print *,(rmem(adtra1+iaux),iaux=0,nbval*nbcomp-1)
        else
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'ESECH3', nompro
#endif
          call esech3 ( nrtafo,
     >                  nbtafo, nbpg, nbvalc, nbcomp,
     >                  imem(advale), imem(adtra1),
     >                  ulsort, langue, codret )
cgn          print *,(imem(adtra1+iaux),iaux=0,nbval*nbcomp-
        endif
c
        endif
c
c 2.8. ==> ecriture MED
c          Le tableau a ete converti dans le mode MED non entrelace.
c
        if ( codret.eq.0 ) then
c
        jaux = medtrf(typgeo)
        if ( jaux.ge.1 ) then
          jaux = ( jaux + mod(jaux,2) ) / 2
        endif
        if ( numdt.ne.ednodt ) then
          write (ulsort,texte(langue,5)) mess14(langue,3,jaux), numdt
        else
          write (ulsort,texte(langue,6)) mess14(langue,3,jaux)
        endif
        if ( nbvapr.gt.0 ) then
          write (ulsort,texte(langue,7)) noprof
        endif
        if ( carsup.gt.1 ) then
          write (ulsort,texte(langue,8)) nolopg
        endif
cgn        print *,(rmem(adtra1+iaux),iaux=0,nbval*nbcomp-1)
cgn        write (ulsort,90003)'Pour nomcha', nomcha
cgn        write (ulsort,90002)'numdt, numit', numdt, numit
cgn        write (ulsort,90004)'instant', dtval
cgn        write (ulsort,90002)'mailles(0)/noeuds(3)/elno(4)', typenh
cgn        write (ulsort,90002)'type MED', typgeo
cgn        write (ulsort,90003)'Profil', noprof
cgn        write (ulsort,90003)'Localisation des points de Gauss', nolopg
cgn        write (ulsort,90002)'Nombre de valeurs', nbval
cgn        write (ulsort,90002) 'ngauss', ngauss
cgn        write (ulsort,90004)'1ere et derniere valeurs',
cgn     >                      rmem(adtra1),rmem(adtra1-1+nbval)
c
        if ( ngauss.eq.ednopg ) then
          jaux = nbval
        else
          jaux = nbpg*nbval
        endif
c
        if ( typcha.eq.edfl64 ) then
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDRPW', nompro
#endif
          call mfdrpw ( idfmed, nomcha, numdt, numit, dtval,
     >                  typenh, typgeo,
     >                  edstco, noprof, nolopg, ednoin, edall,
     >                  nbval, rmem(adtra1), codret )
cgn          write (ulsort,*)(imem(adtra1+iaux),iaux=0,nbval*nbcomp-1)
        else
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDIPW', nompro
#endif
          call mfdipw ( idfmed, nomcha, numdt, numit, dtval,
     >                  typenh, typgeo,
     >                  edstco, noprof, nolopg, ednoin, edall,
     >                  nbval, imem(adtra1), codret )
        endif
c
        if ( codret.ne.0 ) then
          write (ulsort,texte(langue,19)) nomcha
        endif
c
        endif
c
c 2.9. ==> liberation du tableau d'ecriture
c
        if ( codret.eq.0 ) then
          call gmlboj ( ntrav1, codret )
        endif
c
   20 continue
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

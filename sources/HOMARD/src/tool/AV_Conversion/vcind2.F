      subroutine vcind2 ( nrfonc,
     >                    caraca,
     >                    advalr, nbtafo, nbenmx, nbpg, tyelho,
     >                    adlipr, nbvapr,
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
c    aVant adaptation - Conversion d'INDicateur - phase 2
c     -                 -            ---                -
c recuperation des caracteristiques du n-eme tableau de valeurs
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nrfonc . e   .   1    . numero de la fonction en cours             .
c . caraca . e   . nbincc*. caracteristiques caracteres des tableaux   .
c .        .     . nbsqch . du champ en cours d'examen                 .
c .        .     .        . 1. nom de l'objet fonction                 .
c .        .     .        . 2. nom de l'objet profil, blanc sinon      .
c .        .     .        . 3. nom de l'objet localisation des points  .
c .        .     .        . de Gauss, blanc sinon                      .
c . advalr .   s .   1    . adresse des valeurs reelles                .
c . nbtafo .   s .   1    . nombre de tableaux dans la fonction        .
c . nbenmx .   s .   1    . nombre d'entites maximum                   .
c . nbpg   .   s .   1    . nombre de points de Gauss                  .
c . tyelho .   s .   1    . type d'element au sens HOMARD              .
c . nbvapr .   s .   1    . nombre de valeurs du profil                .
c .        .     .        . -1, si pas de profil                       .
c . adlipr .   s .   1    . adresse de la liste du profil              .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'VCIND2' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
#include "esutil.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "rftmed.h"
c
c 0.3. ==> arguments
c
      integer nrfonc
      integer advalr, nbtafo, nbenmx, nbpg
      integer adlipr, nbvapr
      integer tyelho
c
      character*8 caraca(nbincc,*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer typgeo, ngauss, nbtyas, carsup, typint
      integer iaux, jaux
      integer advale, adobch, adprpg, adtyas
c
      character*8 nofonc, noprof
      character*200 profil
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
      texte(1,4) = '(''Nombre de points de Gauss : '',i5)'
      texte(1,5) = '(''On ne sait pas faire.'')'
      texte(1,6) = '(/,''Type d''''element HOMARD associe :'',i3)'
      texte(1,7) = '(''Pas de profil associe.'')'
      texte(1,8) = '(''Nombre de valeurs du profil :'',i10)'
c
      texte(2,4) = '(''Number of Gauss points : '',i5)'
      texte(2,5) = '(''We cannot do it.'')'
      texte(2,6) = '(/,''HOMARD element :'',i3)'
      texte(2,7) = '(''No profile connected to the field.'')'
      texte(2,8) = '(''Number of values in profile :'',i10)'
c
c====
c 2. caracteristiques de la fonction associee
c====
c
      if ( codret.eq.0 ) then
c
      nofonc = caraca(1,nrfonc)
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nofonc )
cgn      call gmprsx (nompro, nofonc//'.ValeursR' )
      call gmprot (nompro, nofonc//'.ValeursR', 1, 30 )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAFO', nompro
#endif
      call utcafo ( nofonc,
     >              iaux,
     >              typgeo, ngauss, nbenmx, jaux, nbtyas,
     >              carsup, nbtafo, typint,
     >              advale, advalr, adobch, adprpg, adtyas,
     >              ulsort, langue, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( ngauss.eq.ednopg ) then
        nbpg = 1
      elseif ( ngauss.gt.0 ) then
        nbpg = ngauss
      else
        write (ulsort,texte(langue,4)) ngauss
        write (ulsort,texte(langue,5))
        codret = 2
      endif
c
      tyelho = medtrf(typgeo)
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) tyelho
#endif
c
      endif
cgn      print *,medtrf(102),medtrf(103)
cgn      print *,medtrf(203),medtrf(206)
cgn      print *,medtrf(304),medtrf(310)
cgn      print *,'nrfonc, typgeo, tyelho = ',nrfonc, typgeo, tyelho
c
c====
c 3. caracteristiques du profil associe
c====
c
      if ( codret.eq.0 ) then
c
      noprof = caraca(2,nrfonc)
cgn      print *,'noprof = ',noprof
c
      if ( noprof.eq.'        ' ) then
c
        nbvapr = -1
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,7))
#endif
c
      else
c
#ifdef _DEBUG_HOMARD_
        call gmprsx (nompro, noprof )
        call gmprsx (nompro, noprof//'.NomProfi' )
        call gmprot (nompro, noprof//'.ListEnti', 1, 10 )
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTCAPR', nompro
#endif
        call utcapr ( noprof,
     >                nbvapr, profil, adlipr,
     >                ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,8)) nbvapr
#endif
c
      endif
c
      endif
cgn      print *,'nbvapr = ',nbvapr
c
c====
c 4. la fin
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

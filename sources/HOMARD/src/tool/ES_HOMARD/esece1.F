      subroutine esece1 ( idfmed, nomamd,
     >                    typenh, typgeo, typent,
     >                    nbenti, nbencf, nbenca,
     >                    adfami, adhist,
     >                    adnivo, admere,
     >                    adenho,
     >                    adinsu, lginsu,
     >                    adins2, lgins2,
     >                    adnoim,
     >                    addera,
     >                    numdt, numit, instan,
     >                    ltbiau, tbiaux,
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
c  Entree-Sortie : ECriture d'une Entite - 1
c  -      -        --             -        -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identificateur du fichier MED              .
c . nomamd . e   . char64 . nom du maillage MED voulu                  .
c . typenh . e   .   1    . code des entites                           .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . typgeo . e   .   1    . type geometrique au sens MED               .
c . typent . e   .   1    . type d'entite au sens MED                  .
c . nbenti . e   .   1    . nombre d'entites                           .
c . nbencf . e   .   1    . nombre d'entites decrites par faces        .
c . nbenca . e   .   1    . nombre d'entites decrites par aretes       .
c . adfami . e   .   1    . famille                                    .
c . adhist . e   .   1    . historique de l'etat                       .
c . adnivo . e   .   1    . niveau des entites                         .
c . admere . e   .   1    . mere des entites                           .
c . adinsu . e   .   1    . informations supplementaires               .
c . lginsu . e   .   1    . longueur des informations supplementaires  .
c . adins2 . e   .   1    . informations supplementaires numero 2      .
c . lgins2 . e   .   1    . longueur des informations supplementaires 2.
c . adnoim .  s  .   1    . noeud interne a la maille                  .
c . numdt  . e   .   1    . numero du pas de temps                     .
c . numit  . e   .   1    . numero d'iteration                         .
c . instan . e   .   1    . pas de temps                               .
c . ltbiau . e   .    1   . longueur allouee a tbiaux                  .
c . tbiaux .     .    *   . tableau tampon entier                      .
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
      parameter ( nompro = 'ESECE1' )
c
#include "nblang.h"
#include "consts.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
#include "impr02.h"
#include "enti01.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer typenh, typgeo, typent
      integer nbenti, nbencf, nbenca
      integer adfami, adhist
      integer adnivo, admere
      integer adenho
      integer adinsu, lginsu
      integer adins2, lgins2
      integer adnoim
      integer addera
      integer numdt, numit
      integer ltbiau, tbiaux(*)
c
      character*64 nomamd
c
      double precision instan
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "meddc0.h"
c
      integer nbcmax
      parameter ( nbcmax = 20 )
c
      integer iaux, jaux, kaux, laux
      integer nbinsu
      integer adress(nbcmax)
      integer typcom(nbcmax)
      integer nbcomp
c
      character*16 dtunit
      character*16 nomcmp(nbcmax), unicmp(nbcmax)
      character*64 nomcha
      character*64 noprof
c
      logical prem
c
      integer nbmess
      parameter ( nbmess = 150 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisation
c
      data prem / .true. /
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
      texte(1,4) =
     > '(''... Ecriture des complements pour les '',i10,1x,a)'
c
      texte(2,4) =
     > '(''... Writings of additional terms for the '',i10,1x,a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nbenti, mess14(langue,3,typenh)
#endif
c
#include "esimpr.h"
c
      texte(1,4) = '(/,''Creation du champ : '',a64)'
      texte(1,5) = '(''Type du champ : '',i2)'
      texte(1,6) =
     > '(''Numero !     Composante     !       Unite'',/,49(''-''))'
      texte(1,7) = '(i6,'' !  '',a16,''  !  '',a16)'
      texte(1,81) = '(''Longueur allouee pour tbiaux    : '',i10)'
      texte(1,82) = '(''Longueur necessaire pour tbiaux : '',i10)'
c
      texte(2,4) = '(/,''Creation of field : '',a64)'
      texte(2,5) = '(''Type of field : '',i2)'
      texte(2,6) =
     > '(''  #    !     Component      !       Unit'',/,49(''-''))'
      texte(2,7) = '(i6,'' !  '',a16,''  !  '',a16)'
      texte(2,81) = '(''Allocated length for tbiaux    : '',i10)'
      texte(2,82) = '(''Used length for tbiaux : '',i10)'
c
c 1.2. ==> unites : non definies
c
      if ( prem ) then
c
        do 12 , iaux = 1 , nbcmax
          unicmp(iaux) = blan16
   12   continue
        prem = .false.
c
      endif
c
c====
c 2. Reperage des composantes en fonction de la presence des tableaux
c====
c
      if ( codret.eq.0 ) then
c
      nbcomp = 0
c
c 2.1. ==> Pour economiser, si HistEtat et Niveau sont presents, on les
c          rassemble dans la premiere composante
c
      if ( adhist.ne.0 ) then
        nbcomp = nbcomp + 1
        typcom(nbcomp) = 1
        adress(nbcomp) = adhist
        nomcmp(nbcomp) = 'HistEtat        '
c                         1234567890123456
      endif
c
      if ( adnivo.ne.0 ) then
        if ( adhist.eq.0 ) then
          nbcomp = nbcomp + 1
          typcom(nbcomp) = 1
          adress(nbcomp) = adnivo
          nomcmp(nbcomp) = 'Niveau          '
        else
          typcom(nbcomp) = 0
          nomcmp(nbcomp) = 'HistEtatNiveau  '
c                           1234567890123456
        endif
      endif
c
c 2.2. ==> Composantes standard
c
      nbcomp = nbcomp + 1
      typcom(nbcomp) = 1
      adress(nbcomp) = adfami
      nomcmp(nbcomp) = 'Famille         '
c                       1234567890123456
c
      if ( admere.ne.0 ) then
        nbcomp = nbcomp + 1
        typcom(nbcomp) = 1
        adress(nbcomp) = admere
        nomcmp(nbcomp) = 'Mere            '
      endif
c
      if ( adenho.ne.0 ) then
        nbcomp = nbcomp + 1
        typcom(nbcomp) = 1
        adress(nbcomp) = adenho
        nomcmp(nbcomp) = 'Homologu        '
      endif
c
      if ( addera.ne.0 ) then
        nbcomp = nbcomp + 1
        typcom(nbcomp) = 1
        adress(nbcomp) = addera
        nomcmp(nbcomp) = 'Deraffin        '
      endif
c
      if ( adnoim.ne.0 ) then
        nbcomp = nbcomp + 1
        typcom(nbcomp) = 1
        adress(nbcomp) = adnoim
        nomcmp(nbcomp) = 'NoeuInMa        '
      endif
c
c 2.3. ==> Pour economiser, on rassemble les termes de InfoSupp dans
c          la derniere composante
c
      if ( adinsu.ne.0 ) then
        nbcomp = nbcomp + 1
        typcom(nbcomp) = 0
        adress(nbcomp) = adinsu
        nomcmp(nbcomp) = 'InfoSupp        '
        nbinsu = lginsu/nbencf
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbinsu', nbinsu
#endif
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,85)) nbcomp
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbencf*nbcomp.gt.ltbiau ) then
        write (ulsort,texte(langue,85)) nbcomp
        write (ulsort,texte(langue,81)) ltbiau
        write (ulsort,texte(langue,82)) nbencf*nbcomp
        codret = 7
      endif
c
      endif
c
c====
c 3. Ecriture sous forme de champ pour les tableaux a une valeur
c    par entite
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. pseudo-champ ; codret', codret
#endif
c
      if ( nbcomp.gt.0 ) then
c
c 3.1. ==> Creation du champ
c
      if ( codret.eq.0 ) then
c
      nomcha = blan64
      nomcha(1:8) = suffix(3,typenh)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nomcha
      write (ulsort,texte(langue,5)) edint
      write (ulsort,texte(langue,6))
      do 31 , iaux = 1 , nbcomp
        write (ulsort,texte(langue,7)) iaux, nomcmp(iaux), unicmp(iaux)
   31 continue
#endif
c
      iaux = edint
      dtunit = blan16
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDCRE', nompro
#endif
      call mfdcre ( idfmed, nomcha, iaux,
     >              nbcomp, nomcmp, unicmp, dtunit, nomamd, codret )
c
      endif
c
      endif
c
c 3.2. ==> Le tableau des valeurs du champ, en mode non entrelace.
c    En fortran, cela correspond au stockage memoire suivant :
c    tbiaux(1,1), tbiaux(2,1), tbiaux(3,1), ..., tbiaux(nbenti,1),
c    tbiaux(1,2), tbiaux(2,2), tbiaux(3,2), ..., tbiaux(nbenti,2),
c    ...
c    tbiaux(1,nbcomp), tbiaux(2,nbcomp), ..., tbiaux(nbenti,nbcomp)
c    on a ainsi toutes les valeurs pour la premiere composante, puis
c    toutes les valeurs pour la seconde composante, etc.
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2. tableau ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
c 3.2.1. ==> Les composantes standard
c
      do 321 , iaux = 1 , nbcomp
c
        if ( typcom(iaux).ne.0 ) then
c
          kaux = nbenti*(iaux-1)
          laux = adress(iaux)-1
          do 3211 , jaux = 1 , nbenti
            tbiaux(kaux+jaux) = imem(laux+jaux)
 3211     continue
c
        endif
c
  321 continue
c
c 3.2.2. ==> Historique et niveau dans la premiere composante
c            L'historique est un nombre entre 0 et 999, donc il faut
c            decaler de 6 chiffres
c
      if ( typcom(1).eq.0 ) then
c
        kaux = adhist - 1
        laux = adnivo - 1
        do 322 , jaux = 1 , nbenti
          tbiaux(jaux) = imem(kaux+jaux) + 1000000*imem(laux+jaux)
  322   continue
c
      endif
c
      endif
c
c 3.2.3. ==> Informations Supplementaires dans la derniere composante
c            On sait que ce sont des valeurs entre 1 et 8, donc < 10
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.2.3. adinsu', adinsu
#endif
c
      if ( adinsu.ne.0 ) then
c
c 3.2.3.1. ==> Premiere valeur pour initialiser le tableau
c
        kaux = nbenti*(nbcomp-1)
        laux = adress(nbcomp)-1
cgn      write (ulsort,90002) 'nbenti*(nbcomp-1)', kaux
cgn      write (ulsort,90002) 'laux', laux
        do 32311 , jaux = 1 , nbencf
          tbiaux(kaux+jaux) = imem(laux+jaux)
32311   continue
c
        do 32312 , jaux = nbencf+1, nbenti
          tbiaux(kaux+jaux) = 0
32312   continue
c
c 3.2.3.2. ==> Valeurs suivantes
c
        do 323 , iaux = 2 , nbinsu
c
          laux = laux + nbencf
          do 3232 , jaux = 1 , nbencf
            tbiaux(kaux+jaux) = 10*tbiaux(kaux+jaux) + imem(laux+jaux)
 3232     continue
c
  323   continue
c
      endif
c
c 3.3. ==> Ecriture des valeurs du champ
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3.3. Ecriture des valeurs ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MFDIVW', nompro
#endif
      call mfdivw ( idfmed, nomcha,
     >              numdt, numit, instan,
     >              typent, typgeo, ednoin, edall,
     >              nbenti, tbiaux, codret )
c
      if ( codret.ne.0 ) then
        write (ulsort,texte(langue,19)) nomcha
      endif
c
      endif
c
c====
c 4. Ecriture sous forme de profil pour les informations supplementaires
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. info supp ; codret', codret
      write (ulsort,90002) 'lgins2', lgins2
#endif
c
      if ( lgins2.gt.0 ) then
c
      if ( codret.eq.0 ) then
c
      noprof = blan64
c                    12                      34567890
      noprof(1:10) = suffix(3,typenh)(1:2)//'InfoSup2'
#ifdef _DEBUG_HOMARD_
      write (ulsort,90003) 'Ecriture du profil', noprof
      write (ulsort,90002) 'Valeurs',
     >      (imem(adins2+iaux),iaux=0,min(lgins2-1,9))
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MPFPRW', nompro
#endif
      call mpfprw ( idfmed, noprof, lgins2, imem(adins2), codret )
c
      endif
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
      write (ulsort,*) mess14(langue,4,typenh)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

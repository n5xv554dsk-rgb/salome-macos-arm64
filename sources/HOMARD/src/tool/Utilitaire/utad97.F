      subroutine utad97 ( typenh, option, deraff, extrus,
     >                    nhenti, norenu, norenn, nosvmn,
     >                    adhist, adcode, adcoar, adfill, admere,
     >                    adfami, adcofa, adinsu, adins2,
     >                    nbanen, pancen,
     >                    adafen, adaeen, adafae, adaien,
     >                    rsento, adencp,
     >                    nbenac, nbento, adenho, adenca,
     >                    lgenin, adenin,
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
c    UTilitaire - ADresses - phase 97
c    --           --               --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : segments                             .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . option . e   .   1    . 1 : rien de special                        .
c .        .     .        . 2 : recherche des fils py/te des hexa/penta.
c . deraff . e   . logic  . vrai/faux selon deraffinement              .
c . extrus . e   .    1   . prise en compte d'extrusion                .
c . nhenti . e   . char*8 . nom de l'objet de l'entite                 .
c . norenu . e   . char*8 . nom de l'objet renumerotation iteration n+1.
c . norenn . e   . char8  . nom de l'objet renumerotation iteration n  .
c . nosvmn . e   . char8  . nom de l'objet contenant les sauvegardes   .
c .        .     .        . du maillage n                              .
c . adhist .   s  .  1    . historique de l'etat                       .
c . adcode .   s  .  1    . connectivite descendante                   .
c . adcoar .   s  .  1    . connectivite par aretes                    .
c . adfill .   s  .  1    . fille des entites                          .
c . admere .   s  .  1    . mere des entites                           .
c . adfami .   s  .  1    . famille des entites                        .
c . adcofa .   s  .  1    . code des familles des entites              .
c . adinsu.    s  .  1    . informations supplementaires               .
c . adins2.    s  .  1    . informations supplementaires numero 2      .
c . adnoim .   s  .  1    . noeud interne a la maille                  .
c . nbanen .  s  .   1    . nombre ancien d'entites                    .
c . pancen .  s  .   1    . adresse des anciens numeros                .
c . adafen .  s  .   1    . adresse des anciennes filles               .
c . adaeen .  s  .   1    . adresse des anciens historiques d'etat     .
c . adafae .  s  .   1    . adresse des anciennes familles             .
c . adaien .  s  .   1    . adresse des anciennes informations         .
c . rsento .   s .    1   . nombre d'entites                           .
c . adencp .   s .    1   . adresse de la numerotation dans le calcul  .
c . nbenac .   s .    1   . nombre d'entites actives iteration n       .
c . nbento .   s .    1   . nombre d'entites iteration n               .
c . adenho .   s .    1   . adresse de la numerotation dans HOMARD it n.
c . adenca .   s .    1   . adresse de la numerotation dans le calcul n.
c . lgenin .   s .    1   . longueur de la numer. init dans le calcul n.
c . adenin .   s .    1   . adresse de la numer. init dans le calcul n .
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
      parameter ( nompro = 'UTAD97' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
#include "enti01.h"
c
#include "envca1.h"
c
c 0.3. ==> arguments
c
      integer typenh, option
      integer adhist, adcode, adcoar, adfill, admere
      integer adfami, adcofa, adinsu, adins2
      integer adnoim, adhomo
      integer nbanen, pancen
      integer adafen, adaeen, adafae, adaien
      integer rsento, adencp
      integer nbenac, nbento, adenho, adenca
      integer lgenin, adenin
c
      character*8 nhenti, norenu, norenn, nosvmn
c
      logical deraff
      logical extrus
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer codre1, codre2
      integer codre0
c
      character*2 saux02
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
      texte(1,4) = '(''Adresses relatives aux '',a)'
c
      texte(2,4) = '(''Adresses for '',a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#endif
c
      saux02 = suffix(3,typenh)(1:2)
c
c====
c 2. structure generale
c====
c 2.1. ==> Grandeurs generales
c
      if ( typenh.eq.1 ) then
        iaux = 6
        if ( degre.eq.2 ) then
          iaux = iaux*13
        endif
      else
        iaux = 7770
        if ( typenh.eq.2 .or. typenh.eq.4 ) then
          if ( extrus ) then
            iaux = iaux*13
          endif
        else
          iaux = iaux*13
          if ( typenh.ge.6 ) then
            if ( mod(option,2).eq.0 ) then
              iaux = iaux*17
            endif
          endif
        endif
      endif
c
c 2.2. ==> Pour les volumes, a-t-on des descriptions par aretes ?
c
      if ( typenh.eq.3 .or. typenh.ge.5 ) then
c
        call gmliat ( nhenti, 2, jaux, codret )
c
        if ( codret.eq.0 ) then
c
        if ( jaux.gt.0 ) then
          iaux = iaux*31
        endif
c
        endif
c
      endif
c
c 2.3. ==> Les adresses
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAD02_'//saux02, nompro
#endif
      call utad02 (   iaux, nhenti,
     >              adhist, adcode, adfill, admere,
     >              adfami, adcofa,   jaux,
     >                jaux, adinsu, adins2,
     >              adnoim, adhomo, adcoar,
     >              ulsort, langue, codret )
c
      endif
c
c====
c 3. ancienne structure si deraffinement
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)'3. ancienne structure ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      if ( deraff ) then
c
        if ( codret.eq.0 ) then
cgn        call gmprsx ( nompro,nhenti)
cgn        call gmprsx ( nompro,nhenti//'.Deraffin')
        call gmadoj ( nhenti//'.Deraffin', pancen, iaux, codret )
        endif
c
      endif
c
      endif
c
c====
c 4. caracteristiques de l'etape precedente
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)'4. precedente ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nosvmn, typenh, nbanen, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      if ( nbanen.gt.0 ) then
c
        call gmadoj ( nosvmn//'.Fille_'//saux02, adafen, iaux, codre1 )
        call gmadoj ( nosvmn//'.HEtat_'//saux02, adaeen, iaux, codre2 )
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        if ( typenh.eq.2 ) then
          call gmadoj ( nosvmn//'.Famil_'//saux02, adafae, iaux, codre0)
          codret = max ( abs(codre0), codret )
        endif
c
        if ( ( typenh.eq.6 .or. typenh.eq.7 ) .and.
     >        mod(option,2).eq.0) then
c
          call gmobal ( nosvmn//'.Insu2_'//saux02, codre1 )
c
          if ( codre1.eq.0 ) then
            codre0 = 0
          elseif ( codre1.eq.2 ) then
            call gmadoj ( nosvmn//'.Insu2_'//saux02,
     >                    adaien, iaux, codre0 )
          else
            codre0 = 1
          endif
c
          codret = max ( abs(codre0), codret )
c
        endif
c
      endif
c
      endif
c
c====
c 5. Renumerotations
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002)'5. Renumerotations ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRE03_'//saux02//'_new', nompro
#endif
      iaux = -21
      call utre03 ( typenh, iaux, norenu,
     >                jaux, rsento,   jaux, adencp,
     >              ulsort, langue, codret)
c
      endif
c
      if ( nbanen.gt.0 .or. extrus ) then
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTRE03_'//saux02//'_anc', nompro
#endif
        iaux = -2310
        call utre03 ( typenh, iaux, norenn,
     >                nbenac, nbento, adenho, adenca,
     >                ulsort, langue, codret)
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'UTRE04_'//saux02//'_anc', nompro
#endif
        iaux = -11
        call utre04 ( typenh, iaux, norenn,
     >                lgenin, adenin,
     >                ulsort, langue, codret)
c
        endif
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

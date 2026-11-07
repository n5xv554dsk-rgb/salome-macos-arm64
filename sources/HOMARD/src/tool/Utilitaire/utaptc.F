      subroutine utaptc ( nobjet, typnom, choix,
     >                    nombre, lgtabl,
     >                    adpoin, adtail, adtabl,
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
c     UTilitaire : Allocation d'un objet de type PtTabC08
c     --           -                             - -  -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nobjet . es  . char8  . nom de l'objet PtTabC08                    .
c . typnom . e   .    1   . type du nom de l'objet PtTabC08            .
c .        .     .        . 0 : le nom est a creer automatiquement     .
c .        .     .        . 1 : le nom est impose par l'appel          .
c . choix  . e   .    1   . option de la recherche :                   .
c .        .     .        . 0 : on alloue tete et branches             .
c .        .     .        . 1 : on n'alloue que la tete                .
c .        .     .        . 2 : on n'alloue que les branches           .
c .        .     .        . 3 : on modifie les longueurs               .
c .        .     .        . 4 : on enregistre les attributs            .
c .        .     .        . 5 : on recupere attributs et adresses      .
c . nombre . es  .    1   . nombre d'entrees ; le tableau Pointeur est .
c .        .     .        . dimensionne a (0:nombre)                   .
c . lgtabl . es  .    1   . longueur commune a Taille et Table         .
c . adpoin .  s  .    1   . adresse de Pointeur                        .
c . adtail .  s  .    1   . adresse de Taille                          .
c . adtabl .  s .    1    . adresse de Table                           .
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
      parameter ( nompro = 'UTAPTC' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
c
c 0.3. ==> arguments
c
      character*(*) nobjet
c
      integer typnom
      integer choix
      integer nombre, lgtabl
      integer adpoin, adtail, adtabl
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre0
      integer iaux, jaux, kaux
c
      character*8 nomobj
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
c 1.1. ==> tout va bien
c
      codret = 0
c
c 1.2. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Mauvaise demande de type de nom :'',i6)'
      texte(1,5) = '(''Probleme pour allouer l''''objet '',a8)'
      texte(1,6) = '(''choix = '',i3)'
      texte(1,7) = '(''typnom = '',i3)'
      texte(1,8) = '(''nombre = '',i3,'', lgtabl = '',i3)'
      texte(1,9) = '(''Avant modification de tailles :'')'
c
      texte(2,4) = '(''Bad request for the type of the name :'',i6)'
      texte(2,5) = '(''Problem while allocating object '',a8)'
      texte(2,6) = texte(1,6)
      texte(2,7) = texte(1,7)
      texte(2,8) = '(''nombre = '',i3,'', lgtabl = '',i3)'
      texte(2,9) = '(''Before size modification :'')'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,6)) choix
      if ( choix.le.1 ) then
        write (ulsort,texte(langue,7)) typnom
      endif
      if ( choix.ne.1 .and. choix.ne.5 ) then
        write (ulsort,texte(langue,8)) nombre, lgtabl
      endif
#endif
c
c====
c 2. Allocation de l'objet de tete
c====
c
      if ( choix.eq.0 .or. choix.eq.1 ) then
c
        if ( typnom.eq.0 ) then
c
          call gmalot ( nobjet, 'PtTabC08', 0, iaux, codre1 )
          codret = abs(codre1)
c
        elseif ( typnom.eq.1 ) then
c
          call gmaloj ( nobjet, 'PtTabC08', 0, iaux, codre1 )
          codret = abs(codre1)
c
        else
c
          codret = -1
c
        endif
c
      else
c
        codret = 0
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( nobjet, nomobj, codret )
c
      endif
c
c====
c 3. Allocation des branches
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Les branches ; codret =', codret
#endif
c
      if ( choix.eq.0 .or. choix.eq.2 ) then
c
        if ( codret.eq.0 ) then
c
        call gmecat ( nomobj, 1, nombre, codre1 )
        iaux = nombre + 1
        call gmaloj ( nomobj//'.Pointeur', ' ', iaux, adpoin, codre2 )
        call gmecat ( nomobj, 2, lgtabl, codre3 )
        call gmaloj ( nomobj//'.Taille', ' ', lgtabl, adtail, codre4 )
        call gmaloj ( nomobj//'.Table' , ' ', lgtabl, adtabl, codre5 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        endif
c
        if ( codret.eq.0 ) then
c
        imem(adpoin) = 0
c
        endif
c
      endif
c
c====
c 4. Modifications
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '4. Modifications ; codret =', codret
#endif
c
      if ( choix.eq.3 ) then
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nomobj, 1, iaux, codre1 )
        call gmliat ( nomobj, 2, jaux, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,9))
        call gmprsx (nompro, nomobj )
        call gmprsx (nompro, nomobj//'.Pointeur' )
        call gmprsx (nompro, nomobj//'.Taille' )
        call gmprsx (nompro, nomobj//'.Table' )
#endif
c
        call gmecat ( nomobj, 1, nombre, codre1 )
        call gmecat ( nomobj, 2, lgtabl, codre2 )
        call gmmod ( nomobj//'.Pointeur', adpoin,
     >               iaux+1, nombre+1, 1, 1, codre3 )
        call gmmod ( nomobj//'.Taille', adtail,
     >               jaux, lgtabl, 1, 1, codre4 )
        call gmmod ( nomobj//'.Table', adtabl,
     >               jaux, lgtabl, 1, 1, codre5 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        endif
c
      endif
c
c====
c 5. Enregistrement des attributs
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '5. Les attributs ; codret =', codret
#endif
c
      if ( choix.eq.4 ) then
c
        if ( codret.eq.0 ) then
c
        call gmecat ( nomobj, 1, nombre, codre1 )
        call gmecat ( nomobj, 2, lgtabl, codre2 )
c
        codre0 = min ( codre1, codre2 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2 )
c
        endif
c
      endif
c
c====
c 6. Recuperation des attributs et des adresses
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '6. Recuperation ; codret =', codret
#endif
c
      if ( choix.eq.5 ) then
c
        if ( codret.eq.0 ) then
c
        call gmliat ( nomobj, 1, nombre, codre1 )
        call gmliat ( nomobj, 2, lgtabl, codre2 )
        call gmadoj ( nomobj//'.Pointeur', adpoin, iaux, codre3 )
        call gmadoj ( nomobj//'.Taille',   adtail, jaux, codre4 )
        call gmadoj ( nomobj//'.Table' ,   adtabl, kaux, codre5 )
c
        codre0 = min ( codre1, codre2, codre3, codre4, codre5 )
        codret = max ( abs(codre0), codret,
     >                 codre1, codre2, codre3, codre4, codre5 )
c
        endif
c
      endif
c
c====
c 7. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, nomobj )
      call gmprsx (nompro, nomobj//'.Pointeur' )
      call gmprsx (nompro, nomobj//'.Taille' )
      call gmprsx (nompro, nomobj//'.Table' )
#endif
c
      if ( codret.ne.0 ) then
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      if ( choix.le.1 ) then
        write (ulsort,texte(langue,4)) typnom
      else
        write (ulsort,texte(langue,5)) nomobj
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

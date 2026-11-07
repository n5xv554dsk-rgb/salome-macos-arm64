      subroutine utmcls ( motcle, choix, oblist, nombre,
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
c     UTilitaire : Mot-Cle - Liste des Strings associee
c     --           -   -     -         -
c ______________________________________________________________________
c
c but : creer une structure de type PtTabC08 qui contient une liste
c       d'options reperees par le meme mot-cle
c       a priori, on suppose que les options sont de taille maximale 200
c       on complete par des blancs au-dela des caracteres utiles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . motcle . e   . char*8 . mot-cle a decoder                          .
c . choix  . e   .    1   . option de la recherche :                   .
c .        .     .        . 0 : si le mot-cle est indefini, erreur     .
c .        .     .        . 1 : si le mot-cle est indefini, on alloue  .
c .        .     .        .     une structure vide                     .
c . oblist . es  . char*8 . nom de l'objet de type PtTabC08 qui        .
c .        .     .        . definit la liste                           .
c . nombre .   s .    1   . nombre d'options enregistrees              .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : le mot-cle n'a pas ete defini          .
c .        .     .        . 3 : Le numero voulu est impossible         .
c .        .     .        . 8 : Allocation impossible                  .
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
      parameter ( nompro = 'UTMCLS' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "gmenti.h"
#include "gmstri.h"
c
c 0.3. ==> arguments
c
      character*8 motcle
c
      character*8 oblist
      integer choix
      integer nombre
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer codre0
      integer iaux, jaux, kaux, laux
      integer loptio
      integer numero
      integer adpoin, adtail, adtabl
c
      character*200 option
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
      texte(1,4) = '(''Mot-cle symbolique : '',a8)'
      texte(1,5) = '(''La configuration est perdue ?'')'
      texte(1,6) =
     > '(''Ce mot-cle est inconnu dans la configuration.'')'
      texte(1,7) = '(''Le numero voulu est impossible.'')'
      texte(1,8) =
     >'(''Impossible d''''allouer la structure memorisant les choix.'')'
c
      texte(2,4) = '(''Symbolic keyword : '',a8)'
      texte(2,5) = '(''Configuration is lost ?'')'
      texte(2,6) = '(''This keyword is unknown in configuration.'')'
      texte(2,7) = '(''The wanted rank is impossible.'')'
      texte(2,8) = '(''Structure of choices cannot be allocated.'')'
c
#include "impr03.h"
c
c====
c 2. recherche du nombre d'occurence du mot-cle
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) motcle
#endif
c
      if ( codret.eq.0 ) then
c
c 2.1. ==> on recherche la premiere occurence associe au mot-cle
c
      numero = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFIN1_0', nompro
#endif
      call utfin1 ( motcle, numero,
     >              nombre, option, loptio,
     >              ulsort, langue, codre0 )
c
c 2.2. ==> aucune option n'a ete precisee
c
      if ( codre0.eq.2 ) then
c
        if ( choix.eq.0 ) then
          codret = 2
        else
          nombre = 0
          codret = 0
        endif
c
c 2.3. ==> probleme de lecture
c
      elseif ( codre0.ne.0 ) then
c
        codret = 1
c
c 2.4. ==> on peut y aller
c
      else
c
        codret = 0
c
      endif
c
      endif
c
c====
c 3. on alloue le receptacle des options
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Allocation ; codret =', codret
#endif
c
      if ( codret.eq.0 ) then
c
c     nom automatique
      iaux = 0
c     on alloue tete et branches
      jaux = 0
c     longueur de la table
      kaux = 25*nombre
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAPTC', nompro
      write (ulsort,90002) 'nombre', nombre
      write (ulsort,90002) 'iaux', iaux
      write (ulsort,90002) 'jaux', jaux
      write (ulsort,90002) 'kaux', kaux
#endif
      call utaptc ( oblist, iaux, jaux,
     >              nombre, kaux,
     >              adpoin, adtail, adtabl,
     >              ulsort, langue, codret )
c
      if ( codret.ne.0 ) then
        codret = 3
      endif
c
      endif
c
c====
c 4. on parcourt toutes les occurences du mot-cle
c====
c
      if ( codret.eq.0 ) then
c
      do 41 , iaux = 1 , nombre
c
        if ( codret.eq.0 ) then
c
c 4.1. ==> on recherche l'occurence iaux associe au mot-cle
c
        numero = iaux
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTFIN1', nompro
#endif
        call utfin1 ( motcle, numero,
     >                nombre, option, loptio,
     >                ulsort, langue, codre0 )
c
c 4.2. ==> probleme de lecture
c
        if ( codre0.ne.0 ) then
c
          codret = 1
c
c 4.3. ==> on stocke
c
        else
c
          jaux = imem(adpoin+iaux-1)
c
          call utchs8 ( option, loptio, smem(adtabl+jaux),
     >                  ulsort, langue, codret )
c
          laux = (loptio-mod(loptio,8)) / 8
          do 431 , kaux = 1 , laux
            imem(adtail+jaux+kaux-1) = 8
  431     continue
c
          if ( mod(loptio,8).ne.0 ) then
            imem(adtail+jaux+laux) = mod(loptio,8)
            laux = laux + 1
          endif
c
          laux = laux + 1
          do 432 , kaux = laux , 25
            imem(adtail+jaux+kaux-1) = 0
            smem(adtabl+jaux+kaux-1) = '        '
c                                       12345678
  432     continue
c
          imem(adpoin+iaux) = 25*iaux
c
        endif
c
      endif
c
   41 continue
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro, oblist )
      call gmprsx (nompro, oblist//'.Pointeur' )
      call gmprsx (nompro, oblist//'.Taille' )
      call gmprsx (nompro, oblist//'.Table' )
#endif
c
c====
c 5. la fin
c====
c
#ifdef _DEBUG_HOMARD_
      if ( codret.ne.0 ) then
#else
      if ( codret.eq.2 ) then
#endif
c
#include "envex2.h"
c
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4)) motcle
      write (ulsort,texte(langue,5+codret))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

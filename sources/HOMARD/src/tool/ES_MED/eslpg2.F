      subroutine eslpg2 ( idfmed,
     >                    nolopg, typgeo, ngauss, dimcpg,
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
c  Entree-Sortie - Lecture des localisations des Points de Gauss
c  -      -        -                             -         -
c                  au format MED - phase 2
c                                        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . idfmed . e   .   1    . identifiant du fichier med                 .
c . nolopg . e   . char64 . nom de la localisation a lire              .
c . typgeo .  s  .   1    . type geometrique associe a la localisation .
c . ngauss .  s  .   1    . nombre de points de Gauss de la localis.   .
c . dimcpg . e   .   1    . dimension des coordonnees des pts de Gauss .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme dans la lecture               .
c .        .     .        . -1 : la localisation n'est pas enregistree .
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
      parameter ( nompro = 'ESLPG2' )
c
#include "nblang.h"
#include "consts.h"
#include "meddc0.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer*8 idfmed
      integer typgeo, ngauss, dimcpg
c
      character*64 nolopg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nrolpg, nbrlpg
      integer nsmc, sgtype
c
      character*64 giname, isname
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''Recherche de la localisation des points de Gauss : '',a)'
      texte(1,5) = '(''.. Reperage de la localisation : '',a)'
      texte(1,6) =
     > '(''Elle n''''est pas enregistree dans le fichier.'')'
c
      texte(2,4) = '(''Research of Gauss points localization : '',a)'
      texte(2,5) = '(''.. This localization is found : '',a)'
      texte(2,6) = '(''It is not stored inthe file.'')'
c
#include "esimpr.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) nolopg
#endif
c  A TRAITER : utiliser directepent mlclni
c====
c 2. Combien de localisations enregistrees ?
c====
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MLCNLC', nompro
#endif
c
      call mlcnlc ( idfmed, nbrlpg, codret )
      if ( codret.ne.0 ) then
      write (ulsort,texte(langue,4))
      write (ulsort,texte(langue,79))
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,82)) nbrlpg
#endif
c
      endif
c
c====
c 3. Lecture de chacune des localisations
c====
c
      do 31 , nrolpg = 1 , nbrlpg
c
c 3.1. ==> caracterisation de la localisation numero nrolpg
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'MLCLCI', nompro
#endif
c
        call mlclci ( idfmed, nrolpg,
     >                saux64, typgeo, dimcpg, ngauss,
     >                giname, isname, nsmc, sgtype,
     >                codret )
        if ( codret.ne.0 ) then
        write (ulsort,texte(langue,4))
        write (ulsort,texte(langue,79))
        endif
c
        endif
c
c 3.2. ==> Si c'est la bonne, on sort
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,5)) saux64
#endif
c
        if ( nolopg.eq.saux64 ) then
        goto 39
        endif
c
        endif
c
   31 continue
c
c 3.2. ==> si on arrive ici, c'est qu'on n'a pas trouve la
c          localisation recherchee
c
      if ( codret.eq.0 ) then
c
      write (ulsort,texte(langue,4)) nolopg
      write (ulsort,texte(langue,6))
      codret = -1
c
      endif
c
   39 continue
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

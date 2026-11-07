      subroutine utmcf0 ( nombre, nomobj,
     >                    adcpoi, adctai, adctab,
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
c     UTilitaire : Mot-Cle - caracterisation des Frontieres - 0
c     --           -   -                         -            -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nombre . e   .    1   . nombre d'entrees ; le tableau Pointeur est .
c .        .     .        . dimensionne a (0:nombre)                  .
c . nomobj . es  . char8  . nom de l'objet PtTabC08                    .
c . ncafar . es  . char*8 . nom de l'objet des frontieres analytiques :.
c .        .     .        . valeurs reelles                            .
c . adpoin .  s  .    1   . adresse de Pointeur                        .
c . adtail .  s  .    1   . adresse de Taille                          .
c . adtabl .  s .    1    . adresse de Table                           .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : la configuration est perdue            .
c .        .     .        . 2 : probleme de lecture                    .
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
      parameter ( nompro = 'UTMCF0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nombre
      integer adcpoi, adctai, adctab
c
      character*8 nomobj
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux, kaux
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
      texte(1,4) =
     >'(''Impossible d''''allouer la structure memorisant les choix.'')'
c
      texte(2,4) = '(''Structure of choices cannot be allocated.'')'
c
c====
c 2. on alloue le receptacle des caracteristiques
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Allocation ; codret = ', codret
#endif
c
c 2.1. ==> Allocation de la tete et/ou des branches
c
      if ( codret.eq.0 ) then
c
      iaux = 0
      kaux = 10*nombre
      if ( nombre.eq.0 ) then
        jaux = 1
      else
        jaux = 0
      endif
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAPTC - tete', nompro
#endif
      call utaptc ( nomobj, iaux, jaux,
     >              nombre, kaux,
     >              adcpoi, adctai, adctab,
     >              ulsort, langue, codret )
c
      if ( codret.ne.0 ) then
        codret = 1
      endif
c
      endif
c
c 2.2. ==> Enregistrement des attributs
c
      if ( codret.eq.0 ) then
c
      if ( nombre.eq.0 ) then
c
        jaux = 4
        kaux = 0
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTAPTC - attributs', nompro
#endif
        call utaptc ( nomobj, iaux, jaux,
     >                nombre, kaux,
     >                adcpoi, adctai, adctab,
     >                ulsort, langue, codret )
c
      endif
c
      if ( codret.ne.0 ) then
        codret = 1
      endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx(nompro,nomobj)
#endif
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
      write (ulsort,texte(langue,4))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

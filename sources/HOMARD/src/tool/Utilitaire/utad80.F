      subroutine utad80 ( nbfich,
     >                    adnore, adlono, adpono, adnofi, adnoos,
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
c    UTilitaire - ADresses - phase 80
c    --           --               --
c ______________________________________________________________________
c   Recuperation des adresses des tableaux decrivant le fichier de
c                configuration
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfich .  s  .   1    . nombre d'objets dans le fichier            .
c . adnore .  s  .   1    . adresse                                    .
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
      parameter ( nompro = 'UTAD80' )
c
#include "nblang.h"
#include "motcle.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbfich
      integer adnore, adlono, adpono, adnofi, adnoos
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
#include "utliob.h"
c
      integer codre1, codre2, codre3, codre4, codre5
      integer codre6
      integer iaux
c
      character*8 nomaux
c
      integer nbmess
      parameter ( nbmess = 20 )
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
c====
c 2. recherche des adresses des objets GM lies aux noms des fichiers
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Recherche ; codret = ', codret
#endif
c
      nomaux = osliob
c
      call gmliat ( nomaux, 1, nbfich, codre1 )
      call gmadoj ( nomaux//'.NomRefer', adnore, iaux, codre2)
      call gmadoj ( nomaux//'.LongNomF', adlono, iaux, codre3 )
      call gmadoj ( nomaux//'.PosiNomF', adpono, iaux, codre4 )
      call gmadoj ( nomaux//'.NomUFich', adnofi, iaux, codre5 )
      call gmadoj ( nomaux//'.NomObjSt', adnoos, iaux, codre6 )
c
      codret = min ( codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
      codret = max ( abs(codret),
     >               codre1, codre2, codre3, codre4, codre5,
     >               codre6 )
c
      if ( codret.ne.0 ) then
        codret = 1
      endif
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

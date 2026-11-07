      subroutine utalfe ( typenh, nhenti,
     >                    nbento, nctfen, nbfenm,
     >                    nhenfa, pfamen, pcfaen,
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
c    UTilitaire - ALlocation pour HOMARD - Famille pour une Entite
c    --           --                       -                -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . typenh . e   .   1    . code des entites au sens homard            .
c .        .     .        .  -1 : noeuds                               .
c .        .     .        .   0 : mailles-points                       .
c .        .     .        .   1 : aretes                               .
c .        .     .        .   2 : triangles                            .
c .        .     .        .   3 : tetraedres                           .
c .        .     .        .   4 : quadrangles                          .
c .        .     .        .   5 : pyramides                            .
c .        .     .        .   6 : hexaedres                            .
c .        .     .        .   7 : pentaedres                           .
c . nhenti . e   . char*8 . nom de l'objet de l'entite                 .
c . nbento . e   .   1    . nombre d'entites                           .
c . nctfen . e   .    1   . nombre total de caracteristiques           .
c . nbfenm . e   .    1   . nombre maximum de familles                 .
c . nhenfa .  s  . char*8 . nom de l'objet de la famille de l'entite   .
c . pfamen .  s  .   1    . adresses des numeros des familles          .
c . pcfaen .  s  .   1    . adresses des codes                         .
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
      parameter ( nompro = 'UTALFE' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh
      integer nbento, nctfen, nbfenm
      integer pfamen, pcfaen
c
      character*8 nhenti, nhenfa
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer codre1, codre2
      integer codre0
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
     > '(''Allocations des structures des familles des '',a)'
c
      texte(2,4) = '(''Allocation of structures for family of '',a)'
c
#include "impr03.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
#endif
c
c====
c 2. allocation des structures
c====
c 2.1. ==> le receptacle des familles
c
      call gmnomc ( nhenti//'.Famille', nhenfa, codret )
c
c 2.2. ==> le numero de famille pour chaque entite
c            les codes des attributs associes a chaque famille
c            les noms des groupes associes a chaque famille
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.2. numero de famille ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmaloj ( nhenfa//'.EntiFamm', ' ', nbento, pfamen, codre1 )
      iaux = nctfen * nbfenm
      call gmaloj ( nhenfa//'.Codes', ' ', iaux  , pcfaen, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 2.3. ==> les attributs
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2.3. attributs ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
      call gmecat ( nhenfa, 1, nbfenm, codre1 )
      call gmecat ( nhenfa, 2, nctfen, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
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

      subroutine utsvm0 ( typenh, option, nhenti, nosvmn,
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
c    UTilitaire - creation de SauVegardes du Maillage iteration N - 0
c    --                       -  -           -                      -
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
c . option . e   .   1    . option de pilotage des sauvegardes         .
c .        .     .        . c'est un multiple des entiers suivants :   .
c .        .     .        .  2 : Fille et HistEtat                     .
c .        .     .        .  3 : EntiFamm                              .
c .        .     .        .  5 : InfoSup2                              .
c . nhenti . e   .  ch8   . nom de l'objet contenant l'entite          .
c . nosvmn .   s .  ch8   . nom de l'objet contenant les sauvegardes du.
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
      parameter ( nompro = 'UTSVM0' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "enti01.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer typenh, option
      character*8 nhenti, nosvmn
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
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
     > '(''Sauvegardes des branches relatives aux '',a)'
      texte(1,5) = '(''Option :'',i10)'
c
      texte(2,4) = '(''Saving of arrays for '',a)'
      texte(2,5) = '(''Option :'',i10)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,3,typenh)
      write (ulsort,texte(langue,5)) option
#endif
c
c 1.2. ==> types d'entites
c
      saux02 = suffix(3,typenh)(1:2)
c
      codret = 0
c
c====
c 2. Sauvegarde
c====
c
      if ( option.ne.0 ) then
c
c 2.1. ==> Fille et Etat
c
      if ( mod(option,2).eq.0 ) then
c
      call gmcpoj ( nhenti//'.Fille',
     >              nosvmn//'.Fille_'//saux02, codre1 )
      call gmcpoj ( nhenti//'.HistEtat',
     >              nosvmn//'.HEtat_'//saux02, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c 2.2. ==> Branche Famille
c
      if ( mod(option,3).eq.0 ) then
c
      call gmcpoj ( nhenti//'.Famille.EntiFamm',
     >              nosvmn//'.Famil_'//saux02, codre0 )
c
      codret = max ( abs(codre0), codret )
c
      endif
c
c 2.5. ==> Branche InfoSup2 (eventuellement)
c
      if ( mod(option,5).eq.0 ) then
c
      call gmobal ( nhenti//'.InfoSup2', codre1 )
c
      if ( codre1.eq.0 ) then
        codre0 = 0
      elseif ( codre1.eq.2 ) then
        call gmcpoj ( nhenti//'.InfoSup2',
     >                nosvmn//'.Insu2_'//saux02, codre0 )
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
      write(ulsort,texte(langue,4)) mess14(langue,3,typenh)
      call gmprsx (nompro,nhenti)
      call gmprsx (nompro,nosvmn)
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

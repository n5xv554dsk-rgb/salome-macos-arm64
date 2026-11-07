      subroutine sfdefg ( suifro,
     >                    nocman, nocmaf, ncafdg,
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
c   Suivi de Frontiere - DEFinition des Groupes
c   -        -           ---            -
c ______________________________________________________________________
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . suifro . e   .   1    . 1 : pas de suivi de frontiere              .
c .        .     .        . 2x : frontiere discrete                    .
c .        .     .        . 3x : frontiere analytique                  .
c .        .     .        . 5x : frontiere cao                         .
c . nocman . e   . char*8 . nom de l'objet maillage calcul iteration n .
c . nocmaf . e   . char*8 . nom de l'objet maillage frontiere discrete .
c . ncafdg . e   . char*8 . nom de l'objet des frontieres discretes/CAO.
c .        .     .        . nom des groupes                            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 2 : probleme avec la memoire               .
c .        .     .        . 3 : probleme avec le fichier               .
c .        .     .        . 5 : contenu incorrect                      .
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
      parameter ( nompro = 'SFDEFG' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "motcle.h"
c
c 0.3. ==> arguments
c
      integer suifro
c
      character*8 nocman, nocmaf, ncafdg
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbf, nblign, nbgrmx
c
      character*8 ncfami
      character*8 saux08
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
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'suifro', suifro
      if ( mod(suifro,2).eq.0 ) then
        call gmprsx (nompro//' - maillage frontiere', nocmaf)
      else
        call gmprsx (nompro//' - maillage calcul', nocman)
      endif
      call gmprsx (nompro//' - groupes de la frontiere', ncafdg)
      call gmprsx (nompro//' - groupes de la frontiere',
     >             ncafdg//'.Table')
#endif
c
#include "impr03.h"
c====
c 2. les structures
c====
c 2.1. ==> Allocation de la branche de la frontiere de taille egale au
c          nombre de familles MED presentes
c
      if ( mod(suifro,2).eq.0 ) then
        saux08 = nocmaf
      else
        saux08 = nocman
      endif
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro//' - saux08', saux08 )
#endif
c
c 2.3.1. ==> Caracteristiques des familles du maillage de la frontiere
c
      if ( codret.eq.0 ) then
c
      call gmnomc ( saux08//'.Famille' , ncfami, codret )
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmliat ( ncfami, 1, nbf, codret )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nbf', nbf
#endif
c
      endif
c
      if ( codret.eq.0 ) then
c
      call gmmod ( saux08//'.Frontier',
     >             iaux, 0, nbf, 1, 1, codret )
c
      endif
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro, saux08//'.Frontier' )
#endif
c
c====
c 3. Les bords sont-ils definis par des groupes dans les donnees,
c    ou par des groupes dans les familles du maillage de frontiere ?
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. Bords ; codret', codret
#endif
c
      if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFGROU', nompro
#endif
      call sfgrou ( ncfami, ncafdg,
     >              nblign, nbgrmx,
     >              ulsort, langue, codret)
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'nblign', nblign
      write (ulsort,90002) 'nbgrmx', nbgrmx
      call gmprsx ( nompro, ncafdg )
#endif
c
      endif
c
c====
c 4. Quand aucune ligne n'a ete definie dans le fichier de configuration
c    on suivra toutes celles definies dans le maillage de la frontiere
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. ; codret', codret
#endif
c
      if ( nblign.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '4. 0 ligne ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'SFGRFA', nompro
#endif
        call sfgrfa ( saux08, ncafdg,
     >                nblign, nbf, nbgrmx,
     >                ulsort, langue, codret)
c
        endif
c
c====
c 5. Quand des lignes ont ete definies dans le fichier de configuration
c    on eliminera toutes celles inconnues dans le maillage de la
c    frontiere
c====
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90015) '5.', nblign, 'lignes ; codret', codret
#endif
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,texte(langue,3)) 'SFGRFB', nompro
#endif
        call sfgrfb ( saux08, ncafdg,
     >                nblign, nbf, nbgrmx,
     >                ulsort, langue, codret)
c
        endif
c
      endif
c
#ifdef _DEBUG_HOMARD_
      call gmprsx ( nompro, ncafdg )
      call gmprsx ( nompro, ncafdg//'.Pointeur' )
      call gmprsx ( nompro, ncafdg//'.Taille' )
      call gmprsx ( nompro, ncafdg//'.Table' )
#endif
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

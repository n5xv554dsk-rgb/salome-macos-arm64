      subroutine sffaf3 ( nbfron, typefr, nogrfr,
     >                    ulsort, langue, codret)
c ______________________________________________________________________
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
c   Suivi de Frontiere - Frontieres AFfichage - 3
c   -        -           -          --          -
c remarque : sffaf1, sffaf2 et sffaf3 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfron . e   .   1    . nombre de frontieres                       .
c . typefr . e   . nbfron . type de frontiere (1:ligne/-1:surface)     .
c . nogrfr . e   .10nbfron. noms des groupes des frontieres            .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . x : probleme                               .
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
      parameter ( nompro = 'SFFAF3' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer nbfron
      integer typefr(nbfron)
c
      character*8 nogrfr(10*nbfron)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer numfro
      integer lgngro
c
      character*80 nomgro
c
      logical prem
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
      codret = 0
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''*'',33x,''Ligne frontiere'',34x,''*'')'
      texte(1,5) = '(''*'',32x,''Surface frontiere'',33x,''*'')'
c
      texte(2,4) = '(''*'',35x,''1D boundary'',36x,''*'')'
      texte(2,5) = '(''*'',35x,''2D boundary'',36x,''*'')'
c
#include "impr03.h"
c
 1000 format('* ',a80,' *')
 1001 format('*',10x,i10,14x,'*')
 1100 format(84('*'))
 1101 format(//,84('*'))
c
      lgngro = 80
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'nbfron', nbfron
#endif
c
c====
c 2. affichage des lignes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. affichage des lignes ; codret', codret
#endif
c
      prem = .true.
c
      do 21 , numfro = 1 , nbfron
cgn        write (ulsort,90112) 'typefr', numfro, typefr(numfro)
c
        if ( typefr(numfro).gt.0 ) then
c
          if ( codret.eq.0 ) then
c
c         recuperation du nom du groupe associe a la frontiere fro
          call uts8ch ( nogrfr(10*(numfro-1)+1), lgngro, nomgro,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          if ( prem ) then
            write (ulsort,1101)
            write (ulsort,texte(langue,4))
            write (ulsort,1100)
            prem = .False.
          endif
          write (ulsort,1000) nomgro
c
          endif
c
        endif
c
   21 continue
c
      if ( .not. prem ) then
        write (ulsort,1100)
      endif
c
c====
c 3. affichage des surfaces
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '3. affichage des surfaces ; codret', codret
#endif
c
      prem = .true.
c
      do 31 , numfro = 1 , nbfron
c
        if ( typefr(numfro).lt.0 ) then
c
          if ( codret.eq.0 ) then
c
c         recuperation du nom du groupe associe a la frontiere fro
          call uts8ch ( nogrfr(10*(numfro-1)+1), lgngro, nomgro,
     >                  ulsort, langue, codret )
c
          endif
c
          if ( codret.eq.0 ) then
c
          if ( prem ) then
            write (ulsort,1101)
            write (ulsort,texte(langue,5))
            write (ulsort,1100)
            prem = .False.
          endif
          write (ulsort,1000) nomgro
c
          endif
c
        endif
c
   31 continue
c
      if ( .not. prem ) then
        write (ulsort,1100)
      endif
c
c====
c 3. La fin
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

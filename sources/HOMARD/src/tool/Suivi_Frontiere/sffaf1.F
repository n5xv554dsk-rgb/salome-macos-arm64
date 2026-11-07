      subroutine sffaf1 ( nbfron, pointa, taigra, nomgra,
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
c   Suivi de Frontiere - Frontieres AFfichage - 1
c   -        -           -          --          -
c remarque : sffaf1, sffaf2 et sffaf3 sont des clones
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . nbfron . e   .   1    . nombre de frontieres                       .
c . pointa . e   .0:nbfron. pointeur sur le tableau nomgra             .
c . taigra . e   .   *    . taille des noms des groupes des frontieres .
c . nomgra . e   .   *    . noms des groupes des frontieres            .
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
      parameter ( nompro = 'SFFAF1' )
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
      integer pointa(0:nbfron), taigra(*)
c
      character*8 nomgra(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer numfro
      integer lgngro
c
      character*8 notyfr(2)
      character*80 nomgro
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
      texte(1,4) =
     >'(''*'',26x,''Groupe(s) frontiere '',a8,28x,''*'')'
c
      texte(2,4) =
     >'(''*'',28x,a8,'' boundary group(s)'',28x,''*'')'
c
#include "impr03.h"
c
 1000 format('* ',a80,' *')
 1001 format('*',10x,i10,14x,'*')
 1100 format(84('*'))
c
c====
c 2. affichage
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) '2. affichage ; codret', codret
#endif
c
      notyfr(1) = 'discrete'
      notyfr(2) = 'Discrete'
c
      write (ulsort,1100)
      write (ulsort,texte(langue,4)) notyfr(langue)
      write (ulsort,1100)
c
      do 21 , numfro = 1 , nbfron
c
c 2.1. ==> Reperage du nom du groupe
c
        if ( codret.eq.0 ) then
c
c         adresse du debut du groupe associe a la frontiere
        jaux = pointa(numfro-1) + 1
c
c         longueur utile du nom du groupe
        lgngro = 0
        do 221 , iaux = jaux , pointa(numfro)
          lgngro = lgngro + taigra(iaux)
  221   continue
c
        endif
c
        if ( codret.eq.0 ) then
c
c         recuperation du nom du groupe associe a la frontiere fro
        call uts8ch ( nomgra(jaux), lgngro, nomgro,
     >                ulsort, langue, codret )
c
        endif
c
c 2.2. ==> Affichage
c
        if ( codret.eq.0 ) then
c
        write (ulsort,1000) nomgro
c
        endif
c
   21 continue
c
      write (ulsort,1100)
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

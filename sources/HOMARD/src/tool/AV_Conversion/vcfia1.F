      subroutine vcfia1 ( lisgro, nhsupe, nhsups,
     >                    ngrofi, adgfpt, adgftb,
     >                    nbfmed, pnumfa, pgrpo, pgrtab,
     >                    ntrav1, adtra1, ntrav2, adtra2,
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
c    aVant adaptation - FIltrage de l'Adaptation - phase 1
c     -                 --            -                  -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lisgro . e   .  ch8   . nom de l'objet de type PtTabC08 qui        .
c .        .     .        . definit la liste des groupes de filtrage   .
c . nhsupe . e   . char8  . informations supplementaires entieres      .
c . nhsups . e   . char8  . informations supplementaires caracteres 8  .
c . ngrofi .  s  .    1   . nombre de groupes de filtrage              .
c . adgfpt .  s  .   1    . adresse de groupes de filtrage - pointeur  .
c . adgftb .  s  .   1    . adresse de groupes de filtrage - table     .
c . nbfmed .  s  .    1   . nombre de familles MED dans le maillage    .
c . pnumfa .  s  .   1    . adresse des numeros MED des familles       .
c . pgrpo  .  s  .   1    . adresse de groupes calcul - pointeur       .
c . pgrtab .  s  .   1    . adresse de groupes calcul - table          .
c . ntravk .  s  .   1    . nom du tableau de travail k                .
c . adtrak .  s  .   1    . adresse du tableau de travail k            .
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
      parameter ( nompro = 'VCFIA1' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer ngrofi, adgfpt, adgftb
      integer nbfmed, pnumfa, pgrpo, pgrtab
      integer adtra1, adtra2
c
      character*8 lisgro
      character*8 nhsupe, nhsups
      character*8 ntrav1, ntrav2
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
c
      integer codre0, codre1, codre2, codre3, codre4
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
c====
c 2. Decodage des adresses pour les groupes de filtrage
c====
c
#ifdef _DEBUG_HOMARD_
      call gmprsx (nompro,lisgro)
      call gmprsx (nompro,lisgro//'.Pointeur')
      call gmprsx (nompro,lisgro//'.Table')
#endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTRPTC', nompro
#endif
      call utrptc ( lisgro,
     >              ngrofi, iaux,
     >              adgfpt, jaux, adgftb,
     >              ulsort, langue, codret )
c
c====
c 3. Decodage des caracteristiques des groupes dans les familles MED
c    du maillage
c====
ccc      call gmprsx (nompro,nhsupe//'.Tab5')
ccc      call gmprsx (nompro,nhsupe//'.Tab6')
ccc      call gmprsx (nompro,nhsups//'.Tab2')
c
      if ( codret.eq.0 ) then
c
      call gmliat ( nhsupe, 9, nbfmed, codre1 )
      call gmadoj ( nhsupe//'.Tab9', pnumfa, iaux, codre2 )
      call gmadoj ( nhsupe//'.Tab5', pgrpo, iaux, codre3 )
      call gmadoj ( nhsups//'.Tab2', pgrtab, iaux, codre4 )
c
      codre0 = min ( codre1, codre2, codre3, codre4 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2, codre3, codre4 )
c
      endif
c
c====
c 4. Tableaux de travail
c====
c
      if ( codret.eq.0 ) then
c
      call gmalot ( ntrav1, 'entier  ', ngrofi, adtra1, codre1 )
      call gmalot ( ntrav2, 'entier  ', nbfmed, adtra2, codre2 )
c
      codre0 = min ( codre1, codre2 )
      codret = max ( abs(codre0), codret,
     >               codre1, codre2 )
c
      endif
c
c====
c 5. la fin
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

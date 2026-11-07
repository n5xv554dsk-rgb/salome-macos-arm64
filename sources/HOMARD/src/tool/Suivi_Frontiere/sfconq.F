      subroutine sfconq ( option, nbqufr, quafro,
     >                    hetqua, cfaqua, famqua,
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
c   Suivi de Frontiere - COntrole - Nombre de Quadrangles
c   -        -           --         -         -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . option . e   .   1    . type de recherche :                        .
c .        .     .        . 0 : tous les quadrangles actifs            .
c .        .     .        . 1 : les actifs qui viennent d'etre coupes  .
c . nbqufr . es  .   1    . si 0 : on cherche le nombre, on le renvoie .
c .        .     .        . sinon, on remplit                          .
c . quafro .  s  . nbqufr . numeros des quadrangles concernes          .
c . hetqua . e   . nbquto . historique de l'etat des aretes            .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . e   . nbquto . famille des quadrangles                    .
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
      parameter ( nompro = 'SFCONQ' )
c
#include "nblang.h"
#include "cofatq.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nombqu.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbqufr
      integer quafro(nbqufr)
      integer hetqua(nbquto)
      integer cfaqua(nctfqu,nbfqua), famqua(nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer etat01, etat02
      integer etan, etanp1
c
      integer nbmess
      parameter ( nbmess = 10 )
      character*80 texte(nblang,nbmess)
c
c 0.5. ==> initialisations
c ______________________________________________________________________
c
c====
c 1. Prealables
c====
c 1.1. ==> Les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(''Examen de toutes les entites.'')'
      texte(1,5) = '(''Examen des entites decoupees.'')'
      texte(1,6) = '(''Option incorrecte :'',i10)'
      texte(1,7) = '(''Aucun '',a,''n''''est concerne.'')'
      texte(1,8) = '(''Nombre de '',a,''concernes :'',i10)'
c
      texte(2,4) = '(''Examination of all the entities.'')'
      texte(2,5) = '(''Examination of cut entities.'')'
      texte(2,6) = '(''Non valid option :'',i10)'
      texte(2,7) = '(''No '',a,''is involved'')'
      texte(2,8) = '(''Number of involved '',a,'':'',i10)'
c
c 1.2. ==> Initialisations
c
      codret = 0
c
      if ( option.eq.0 ) then
        etat01 = 0
        etat02 = 4
      elseif ( option.eq.1 ) then
        etat01 = 4
        etat02 = 4
      else
        write (ulsort,texte(langue,6)) option
        codret = 1
      endif
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
        write (ulsort,texte(langue,4+option))
      endif
#endif
c
c====
c 2. Decompte des quadrangles
c    On ne s'interesse qu'aux quadrangles :
c    . qui font partie d'une frontiere reconnue
c    . qui viennent d'etre decoupes
c====
c
      if ( nbqufr.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Decompte quadrangles ; codret = ', codret
#endif
c
      do 21 , iaux = 1 , nbquto
c
        if ( codret.eq.0 ) then
c
        if ( cfaqua(cosfsu,famqua(iaux)).gt.0 ) then
c
          etanp1 = mod(hetqua(iaux),100)
c
          if ( etanp1.eq.etat01 .or. etanp1.eq.etat02 ) then
c
            etan = (hetqua(iaux)-etanp1) / 100
c
            if ( etan.eq.0 .or. ( etan.ge.31 .and. etan.le.34 ) ) then
c
cgn      write (ulsort,*) 'quad ',iaux,cfaqua(cosfsu,famqua(iaux))
              nbqufr = nbqufr + 1
c
            endif
c
          endif
c
        endif
c
        endif
c
   21 continue
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      if ( nbqufr.eq.0 ) then
        write (ulsort,texte(langue,7)) mess14(langue,1,4)
      else
        write (ulsort,texte(langue,8)) mess14(langue,3,4), nbqufr
      endif
      endif
#endif
c
c====
c 3. Remplissage
c====
c
      else
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Remplissage ; codret = ', codret
#endif
c
      jaux = 0
c
      do 31 , iaux = 1 , nbquto
c
        if ( codret.eq.0 ) then
c
        if ( cfaqua(cosfsu,famqua(iaux)).gt.0 ) then
c
          etanp1 = mod(hetqua(iaux),100)
c
          if ( etanp1.eq.etat01 .or. etanp1.eq.etat02 ) then
c
            etan = (hetqua(iaux)-etanp1) / 100
c
            if ( etan.eq.0 .or. ( etan.ge.31 .and. etan.le.34 ) ) then
c
cgn      write (ulsort,*) 'quad ',iaux,cfaqua(cosfsu,famqua(iaux))
              jaux = jaux + 1
              quafro(jaux) = iaux
c
            endif
c
          endif
c
        endif
c
        endif
c
   31 continue
c
c reactualisation du nombre de quadrangles concernes : certains ont
c disparus car ils sont sur des surfaces planes
c
      nbqufr = jaux
c
      endif
c
c====
c 4. La fin
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

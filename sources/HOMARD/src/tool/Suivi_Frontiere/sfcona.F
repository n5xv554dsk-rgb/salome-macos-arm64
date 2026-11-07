      subroutine sfcona ( option, nbarfr, arefro,
     >                    hetare, cfaare, famare,
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
c   Suivi de Frontiere - COntrole - Nombre d'Aretes
c   -        -           --         -        -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . otpion . e   .   1    . type de recherche :                        .
c .        .     .        . 0 : toutes les aretes actives              .
c .        .     .        . 1 : les actives qui viennent d'etre coupees.
c . nbarfr . es  .   1    . si 0 : on cherche le nombre, on le renvoie .
c .        .     .        . sinon, on remplit                          .
c . arefro .  s  . nbarfr . numeros des aretes  concernees             .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . cfaare . e   . nctfar*. codes des familles des aretes              .
c .        .     . nbfare .   1 : famille MED                          .
c .        .     .        .   2 : type de segment                      .
c .        .     .        .   3 : orientation                          .
c .        .     .        .   4 : famille d'orientation inverse        .
c .        .     .        .   5 : numero de ligne de frontiere         .
c .        .     .        .  > 0 si concernee par le suivi de frontiere.
c .        .     .        . <= 0 si non concernee                      .
c .        .     .        .   6 : famille frontiere active/inactive    .
c .        .     .        .   7 : numero de surface de frontiere       .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famare . e   . nbarto . famille des aretes                         .
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
      parameter ( nompro = 'SFCONA' )
c
#include "nblang.h"
#include "cofaar.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nombar.h"
#include "impr02.h"
c
c 0.3. ==> arguments
c
      integer option
      integer nbarfr
      integer arefro(nbarfr)
      integer hetare(nbarto)
      integer cfaare(nctfar,nbfare), famare(nbarto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux, jaux
      integer etat01, etat02
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
        etat02 = 2
      elseif ( option.eq.1 ) then
        etat01 = 2
        etat02 = 2
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
c 2. Decompte des aretes
c    On ne s'interesse qu'aux aretes :
c    . qui font partie d'une frontiere reconnue
c    . qui viennent d'etre decoupees
c====
c
      if ( nbarfr.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Decompte aretes ; codret = ', codret
#endif
c
      do 21 , iaux = 1 , nbarto
c
        if ( codret.eq.0 ) then
c
        if ( cfaare(cosfsa,famare(iaux)).gt.0 .or.
     >       cfaare(cosfli,famare(iaux)).gt.0 ) then
c
          if ( hetare(iaux).eq.etat01 .or.
     >         hetare(iaux).eq.etat02 ) then
c
cgn      write (ulsort,*) 'arete ',iaux,cfaare(cosfsa,famare(iaux)),
cgn     >         cfaare(cosfli,famare(iaux))
            nbarfr = nbarfr + 1
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
      if ( nbarfr.eq.0 ) then
        write (ulsort,texte(langue,7)) mess14(langue,1,1)
      else
        write (ulsort,texte(langue,8)) mess14(langue,3,1), nbarfr
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
      do 31 , iaux = 1 , nbarto
c
        if ( codret.eq.0 ) then
c
        if ( cfaare(cosfsa,famare(iaux)).gt.0 .or.
     >       cfaare(cosfli,famare(iaux)).gt.0 ) then
c
          if ( hetare(iaux).eq.etat01 .or.
     >         hetare(iaux).eq.etat02 ) then
c
cgn      write (ulsort,*) 'arete ',iaux,cfaare(cosfsa,famare(iaux)),
cgn     >         cfaare(cosfli,famare(iaux))
c
            jaux = jaux + 1
            arefro(jaux) = iaux
c
          endif
c
        endif
c
        endif
c
   31 continue
c
c reactualisation du nombre d'aretes concernees : certaines ont
c disparu car elles sont sur des lignes droites
c
      nbarfr = jaux
c
#ifdef _DEBUG_HOMARD_
      if ( codret.eq.0 ) then
      if ( nbarfr.eq.0 ) then
        write (ulsort,texte(langue,7)) mess14(langue,1,1)
      else
        write (ulsort,texte(langue,8)) mess14(langue,3,1), nbarfr
      endif
      endif
#endif
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

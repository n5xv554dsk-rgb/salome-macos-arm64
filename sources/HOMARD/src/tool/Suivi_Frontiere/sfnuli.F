      subroutine sfnuli ( cfaare, numlig, option,
     >                    lgetco, taetco,
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
c   Suivi de Frontiere - NUmeros de LIgne
c   -        -           --         --
c ______________________________________________________________________
c
c but : compactage ou retablissement des numeros de ligne des familles
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
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
c . numlig . e   . sfnbli . numero des lignes                          .
c . option . e   .   1    . 0 pour compactage, sinon retablissement    .
c . lgetco . e   .   1    . longueur du tableau de l'etat courant      .
c . taetco . e   . lgetco . tableau de l'etat courant                  .
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
      parameter ( nompro = 'SFNULI' )
c
#include "nblang.h"
#include "cofaar.h"
#include "cofina.h"
c
c 0.2. ==> communs
c
#include "front1.h"
#include "dicfen.h"
#include "nbfami.h"
#include "envex1.h"
c
c 0.3. ==> arguments
c
      integer option
      integer numlig(sfnbli)
      integer cfaare(nctfar,nbfare)
c
      integer lgetco
      integer taetco(lgetco)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nretap, nrsset
      integer iaux
c
      integer lig, ligv
c
      character*6 saux
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
c 1.1. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) = '(/,a6,'' COMPACTAGE DES NUMEROS DE LIGNE'')'
      texte(1,5) = '(38(''=''),/)'
      texte(1,6) = '(/,a6,'' RESTITUTION DE NUMEROS DE LIGNE'')'
      texte(1,7) =
     > '(5x,''La ligne'',i10,'' ne figure pas dans la liste :'')'
c
      texte(2,4) = '(/,a6,'' LINE NUMBERS COMPACTING'')'
      texte(2,5) = '(30(''=''),/)'
      texte(2,6) = '(/,a6,'' LINE NUMBERS RETRIEVING'')'
      texte(2,7) =
     > '(5x,''Line #'',i10,'' does not belong to list:'')'
c
#include "impr03.h"
c
c 1.2. ==> le numero de sous-etape
c
      nretap = taetco(1)
      nrsset = taetco(2) + 1
      taetco(2) = nrsset
c
      call utcvne ( nretap, nrsset, saux, iaux, codret )
c
c 1.3. ==> le titre
c
      if ( option.eq.0 ) then
        write (ulsort,texte(langue,4)) saux
      else
        write (ulsort,texte(langue,6)) saux
      endif
      write (ulsort,texte(langue,5))
c
c====
c 2. boucle sur les familles d'aretes : compacter les numeros
c====
c
      if ( option.eq.0 ) then
c
        do 21 iaux = 1 , nbfare
c
         if ( codret.eq.0 ) then
c
          lig = cfaare(cosfli,iaux)
          if ( lig.gt.0 ) then
c
            do 211 , ligv = 1 , sfnbli
              if ( lig.eq.numlig(ligv) ) then
                cfaare(cosfli,iaux) =  ligv
                cfaare(cosfli,cfaare(cosfin,iaux)) = -ligv
                goto 21
              endif
  211       continue
c
            codret = 1
c
          endif
c
         endif
c
   21   continue
c
c====
c 3. boucle sur les familles d'aretes : redonner les numeros d'origine
c====
c
      else
c
        do 31 , iaux = 1,  nbfare
c
          lig = cfaare(cosfli,iaux)
          if ( lig.gt.0 ) then
            cfaare(cosfli,iaux) =  numlig( lig)
          else if (lig.lt.0) then
            cfaare(cosfli,iaux) = -numlig(-lig)
          endif
c
   31   continue
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
      write (ulsort,texte(langue,7)) lig
      write (ulsort,91020) (numlig(ligv),ligv=1,sfnbli)
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

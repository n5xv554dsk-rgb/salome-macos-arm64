      subroutine sfnnfl ( hetare,
     >                    cfaare, famare,
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
c but : compter le nombre de noeuds du maillage de calcul qui sont sur
c       la frontiere
c ______________________________________________________________________
c
c   Suivi de Frontiere - Nombre de Noeuds sur la Frontiere - Lignes
c   -        -           -  -                    -           -
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
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
      parameter ( nompro = 'SFNNFL' )
c
#include "nblang.h"
#include "cofaar.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "envca1.h"
#include "front2.h"
#include "dicfen.h"
#include "nbfami.h"
#include "nombar.h"
c
c 0.3. ==> arguments
c
      integer hetare(nbarto)
      integer famare(nbarto), cfaare(nctfar,nbfare)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer lig
      integer nbarfr
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
c 1.3. ==> les messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      texte(1,4) =
     > '(''. Max du nombre de noeuds sur la frontiere :'',i10)'
      texte(1,5) = '(''Arete '',i10,'' de ligne'',i10)'
c
      texte(2,4) = '(''. Max of number of nodes over boundary :'',i10)'
      texte(2,5) = '(''Edge '',i10,'' in line'',i10)'
c
c====
c 2. boucle sur les aretes : situer les sommets sur la ligne
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. boucle sur les aretes ; codret = ', codret
#endif
c
      nbarfr = 0
c
      if ( codret.eq.0 ) then
c
      do 21 , iaux = 1 , nbarto
c
        lig = cfaare(cosfli,famare(iaux))
#ifdef _DEBUG_HOMARD_
        if ( lig.gt.0 ) then
          write (ulsort,texte(langue,5)) iaux, lig
        endif
#endif
c
        if ( lig.gt.0 ) then
c
          if ( hetare(iaux).ne.50 ) then
c
            nbarfr = nbarfr + 1
c
          endif
c
        endif
c
   21 continue
c
      endif
c
      if ( degre.eq.1 ) then
        mcnxnf = 2*nbarfr
      else
        mcnxnf = 3*nbarfr
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mcnxnf
#endif
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



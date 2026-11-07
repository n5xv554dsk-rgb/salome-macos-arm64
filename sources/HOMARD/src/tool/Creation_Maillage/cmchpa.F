      subroutine cmchpa ( indare, nbaret,
     >                    noefix, lesnoe, areint,
     >                    hetare, somare,
     >                    filare, merare, famare,
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
c    Creation du Maillage - Conformite - decoupage des
c    -           -          -
c                           Hexaedres ou Pentaedres - phase A
c                           -            -                  -
c    Construction des aretes internes
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indnoe . es  .   1    . indice du dernier noeud cree               .
c . indare . es  .   1    . indice de la derniere arete creee          .
c . nbaret . e   .   1    . nombre d'aretes a creer                    .
c . lesnoe . e   . nbaret . liste des noeuds pour les extremites des   .
c .        .     .        . aretes  a creer                            .
c . areint .  s  . nbaret . aretes internes creees                     .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . somare . es  .2*nouvar. numeros des extremites d'arete             .
c . filare . es  . nouvar . premiere fille des aretes                  .
c . merare . es  . nouvar . mere des aretes                            .
c . famare .     . nouvar . famille des aretes                         .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : aucune arete ne correspond             .
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
      parameter ( nompro = 'CMCHPA' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nouvnb.h"
#include "fractf.h"
c
c 0.3. ==> arguments
c
      integer indare
      integer nbaret
      integer noefix, lesnoe(nbaret), areint(nbaret)
      integer hetare(nouvar), somare(2,nouvar)
      integer filare(nouvar), merare(nouvar), famare(nouvar)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
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
c 1.1. ==> messages
c
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
#include "impr03.h"
#include "impr04.h"
c
      codret = 0
c
c====
c 2. Creation des aretes internes
c    L'arete i part du sommet i vers le noeud central
c====
c
      if ( codret.eq.0 ) then
c
      do 21 , iaux = 1 , nbaret
c
        indare = indare + 1
        areint(iaux) = indare
c
        somare(1,areint(iaux)) = min ( noefix , lesnoe(iaux) )
        somare(2,areint(iaux)) = max ( noefix , lesnoe(iaux) )
c
        famare(areint(iaux)) = 1
        hetare(areint(iaux)) = 50
        merare(areint(iaux)) = 0
        filare(areint(iaux)) = 0
#ifdef _DEBUG_HOMARD_
      write(ulsort,91002) iaux, areint(iaux),
     >                    somare(1,areint(iaux)),
     >                    somare(2,areint(iaux)), 0
#endif
c
   21 continue
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

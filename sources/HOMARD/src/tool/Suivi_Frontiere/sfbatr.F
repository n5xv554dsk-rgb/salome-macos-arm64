      subroutine sfbatr ( lenoeu, larete, letria,
     >                    somare,
     >                    facare, posifa,
     >                    hettri, aretri, filtri,
     >                    ulsort, langue, codret )
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
c   Suivi de Frontiere - Bascule d'Arete pour un TRiangle
c   -        -           -         -             --
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lenoeu . e   .    1   . noeud en cours d'examen                    .
c . larete . e   .    1   . arete en cours d'examen                    .
c . letria . e   .    1   . triangle en cours d'examen                 .
c . somare . es  .2*nbarto. numeros des extremites d'arete             .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . hettri . es  . nbtrto . historique de l'etat des triangles         .
c . aretri . es  .nbtrto*3. numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
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
      parameter ( nompro = 'SFBATR' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
#include "impr02.h"
c
#include "nombar.h"
#include "nombtr.h"
c
c 0.3. ==> arguments
c
      integer lenoeu, larete, letria
c
      integer somare(2,nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettri(nbtrto), aretri(nbtrto,3), filtri(nbtrto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer sn
      integer arep
      integer inloc,  iploc,  iqloc
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
      texte(1,4) = '(a,'':'',i10)'
      texte(1,5) = '(a,'' du triangle'',i10'' :'',3i10)'
      texte(1,7) = '(''Annulation du SF pour le noeud : '',i10)'
c
      texte(2,4) = '(a,'' # :'',i10)'
      texte(2,5) = '(a,'' of triangle #'',i10'' :'',3i10)'
      texte(2,7) = '(''Cancellation of BF for node # : '',i10)'
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,4)) mess14(langue,2,-1), lenoeu
      write (ulsort,texte(langue,4)) mess14(langue,2, 1), larete
      write (ulsort,texte(langue,4)) mess14(langue,2, 2), letria
#endif
c
      codret = 0
c
c====
c 2. Bascule
c====
c
c 2.1. ==> reperage local des aretes
c
      if ( larete.eq.aretri(letria,1) ) then
        inloc = 1
        iploc = 2
        iqloc = 3
      elseif ( larete.eq.aretri(letria,2) ) then
        inloc = 2
        iploc = 3
        iqloc = 1
      else
        inloc = 3
        iploc = 1
        iqloc = 2
      endif
c
c 2.2. ==> reperage local des sommets
c
      arep = aretri(letria,iploc)
c
      if ( somare(1,larete).eq.somare(1,arep) ) then
        sn = somare(2,arep)
      elseif ( somare(1,larete).eq.somare(2,arep) ) then
        sn = somare(1,arep)
      elseif ( somare(2,larete).eq.somare(1,arep) ) then
        sn = somare(2,arep)
      else
        sn = somare(1,arep)
      endif
c
c 2.3. ==> Programme specifique
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'SFBATT', nompro
#endif
      call sfbatt ( lenoeu, sn, letria,
     >              inloc, iploc, iqloc,
     >              somare, facare, posifa,
     >              filtri, aretri, hettri )
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

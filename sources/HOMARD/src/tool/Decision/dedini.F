      subroutine dedini ( homolo,
     >                    decare, decfac,
     >                    posifa, facare,
     >                    arehom,
     >                    hettri, aretri, filtri, nivtri,
     >                    hetqua, arequa, filqua, nivqua,
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
c traitement des DEcisions - Deraffinement : INItialisation
c                --          -               ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . homolo . e   .   1    . presence d'homologue                       .
c .        .     .        . 0 : non                                    .
c .        .     .        . 1 : il existe des noeuds homologues        .
c .        .     .        . 2 : il existe des aretes homologues        .
c .        .     .        . 3 : il existe des faces homologues         .
c . decare . e/s . nbarto . decisions des aretes                       .
c . decfac . e/s . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . arehom . e   . nbarto . ensemble des aretes homologues             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   . nbtrto . numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   . nbquto . numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . fils des quadrangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . ulsort . e   .   1    . numero d'unite logique de la liste standard.
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret . es  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 5 : mauvais type de code de calcul associe .
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
      parameter ( nompro = 'DEDINI' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
c
c 0.3. ==> arguments
c
      integer homolo
      integer decare(0:nbarto)
      integer decfac(-nbquto:nbtrto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer arehom(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer filtri(nbtrto), nivtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer filqua(nbquto), nivqua(nbquto)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter ( nbmess = 20 )
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
      codret = 0
c
c====
c 2. initialisation des decisions pour le deraffinement
c====
c
c 2.1. ==> cas sans entites homologues, sauf eventuellement des noeuds
c
      if ( homolo.le.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEDIN1', nompro
#endif
        call dedin1 ( decare, decfac,
     >                posifa, facare,
     >                hettri, aretri, filtri, nivtri,
     >                hetqua, arequa, filqua, nivqua,
     >                ulsort, langue, codret )
c
      else
c
c 2.2. ==> cas avec homologue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEDIN2', nompro
#endif
        call dedin2 ( decare, decfac,
     >                posifa, facare,
     >                arehom,
     >                hettri, aretri, filtri, nivtri,
     >                hetqua, arequa, filqua, nivqua,
     >                ulsort, langue, codret )
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

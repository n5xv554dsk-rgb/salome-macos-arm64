      subroutine dedcon ( tyconf, homolo,
     >                    decare, decfac,
     >                    posifa, facare,
     >                    hetare, merare, arehom,
     >                    hettri, aretri, nivtri,
     >                    hetqua, arequa, nivqua,
     >                    listfa,
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
c traitement des DEcisions - Deraffinement : CONtamination
c                --          -               ---
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . tyconf . e   .   1    .  0 : conforme (defaut)                     .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2 par face           .
c .        .     .        .  2 : non-conforme avec 1 seul noeud        .
c .        .     .        .      pendant par arete                     .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 (boite pour les         .
c .        .     .        .      quadrangles, hexaedres et pentaedres) .
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
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . merare . e   . nbarto . mere des aretes                            .
c . arehom . e   . nbarto . ensemble des aretes homologues             .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   . nbtrto . numeros des 3 aretes des triangles         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   . nbquto . numeros des 4 aretes des quadrangles       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . listfa . t   .   *    . liste de faces a considerer                .
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
      parameter ( nompro = 'DEDCON' )
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
      integer tyconf, homolo
      integer decare(0:nbarto)
      integer decfac(-nbquto:nbtrto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hetare(nbarto), merare(nbarto), arehom(nbarto)
      integer hettri(nbtrto), aretri(nbtrto,3), nivtri(nbtrto)
      integer hetqua(nbquto), arequa(nbquto,4), nivqua(nbquto)
      integer listfa(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux
#endif
c
      integer nbmess
      parameter ( nbmess = 30 )
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
#include "derco1.h"
#include "impr03.h"
c
      codret = 0
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'tyconf', tyconf
#endif
c
#ifdef _DEBUG_HOMARD_
cgn        do 1105 , iaux = 1 , nbquto
cgn          write (ulsort,90001) 'quadrangle', iaux,
cgn     >    arequa(iaux,1), arequa(iaux,2),
cgn     >    arequa(iaux,3), arequa(iaux,4)
cgn 1105   continue
#endif
c
#ifdef _DEBUG_HOMARD_
        do 1103 , iaux = 1 , nbarto
          if ( iaux.eq.2183 .or. iaux.eq.14556
     >   .or. iaux.eq.1658 .or. iaux.eq.1661 ) then
            write (ulsort,90001) '.. arete e/d', iaux,
     >    hetare(iaux), decare(iaux)
          endif
 1103   continue
#endif
#ifdef _DEBUG_HOMARD_
        do 1104 , iaux = 1 , nbtrto
        if ( iaux.eq.-830 .or. iaux.eq.-800) then
          write (ulsort,90001) '.triangle', iaux,
     >    aretri(iaux,1), aretri(iaux,2),
     >    aretri(iaux,3)
          write (ulsort,90002) 'niveau et decision',
     >    nivtri(iaux), decfac(iaux)
          do 11041 ,jaux=1,3
          write (ulsort,90001) 'arete e/d', aretri(iaux,jaux),
     >    hetare(aretri(iaux,jaux)), decare(aretri(iaux,jaux))
11041   continue
         endif
 1104   continue
        do 1105 , iaux = 1 , nbquto
        if ( iaux.eq.-2311 ) then
cgn        if ( iaux.eq.1160 .or. iaux.eq.1411 .or.
cgn     >       iaux.eq.333 .or. iaux.eq.1662.or.
cgn     >       iaux.eq.1658 .or. iaux.eq.1666 .or.
cgn     >       iaux.eq.729 .or. iaux.eq.721 ) then
          write (ulsort,90001) 'quadrangle', iaux,
     >    arequa(iaux,1), arequa(iaux,2),
     >    arequa(iaux,3), arequa(iaux,4)
          write (ulsort,90002) 'niveau et decision',
     >    nivqua(iaux), decfac(-iaux)
          do 11051 ,jaux=1,4
          write (ulsort,90001) 'arete e/d', arequa(iaux,jaux),
     >    hetare(arequa(iaux,jaux)), decare(arequa(iaux,jaux))
11051   continue
         endif
 1105   continue
#endif
c
c====
c 2. contamination des decisions pour le deraffinement
c====
c
c 2.1. ==> cas sans entites homologues, sauf eventuellement des noeuds
c
      if ( homolo.le.1 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEDCO1', nompro
#endif
        call dedco1 ( tyconf,
     >                decare, decfac,
     >                posifa, facare,
     >                hetare, merare,
     >                hettri, aretri, nivtri,
     >                hetqua, arequa, nivqua,
     >                listfa,
     >                ulsort, langue, codret )
c
      else
c
c 2.2. ==> cas avec homologue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'DEDCO2', nompro
#endif
        call dedco2 ( tyconf,
     >                decare, decfac,
     >                posifa, facare,
     >                hetare, merare, arehom,
     >                hettri, aretri, nivtri,
     >                hetqua, arequa, nivqua,
     >                listfa,
     >                ulsort, langue, codret )
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
        do 2103 , iaux = 1 , nbarto
          if ( iaux.eq.2183 .or. iaux.eq.14556
     >   .or. iaux.eq.1658 .or. iaux.eq.1661 ) then
            write (ulsort,90001) '.. arete e/d', iaux,
     >    hetare(iaux), decare(iaux)
          endif
 2103   continue
        do 2104 , iaux = 1 , nbtrto
        if ( iaux.eq.-830 .or. iaux.eq.-833 .or. iaux.eq.-800) then
          write (ulsort,90001) '.triangle', iaux,
     >    aretri(iaux,1), aretri(iaux,2),
     >    aretri(iaux,3)
          write (ulsort,90002) '.. niveau et decision',
     >    nivtri(iaux), decfac(iaux)
          do 21041 ,jaux=1,3
          write (ulsort,90001) '.. arete e/d', aretri(iaux,jaux),
     >    hetare(aretri(iaux,jaux)), decare(aretri(iaux,jaux))
21041   continue
          endif
 2104   continue
        do 2105 , iaux = 1 , nbquto
        if ( iaux.eq.-2311 ) then
cgn        if ( iaux.eq.1160 .or. iaux.eq.1411 .or.
cgn     >       iaux.eq.333 .or. iaux.eq.1662 .or.
cgn     >       iaux.eq.1658 .or. iaux.eq.1666 .or.
cgn     >       iaux.eq.729 .or. iaux.eq.721 ) then
          write (ulsort,90001) 'quadrangle', iaux,
     >    arequa(iaux,1), arequa(iaux,2),
     >    arequa(iaux,3), arequa(iaux,4)
          write (ulsort,90002) 'de decision', decfac(-iaux)
          do 21051 ,jaux=1,4
          write (ulsort,90001) 'arete e/d', arequa(iaux,jaux),
     >    hetare(arequa(iaux,jaux)), decare(arequa(iaux,jaux))
21051   continue
         endif
 2105   continue
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

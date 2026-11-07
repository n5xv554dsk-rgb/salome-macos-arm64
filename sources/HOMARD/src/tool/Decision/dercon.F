      subroutine dercon ( tyconf, homolo, maconf,
     >                    decare, decfac,
     >                    hetare, filare, merare, arehom,
     >                    posifa, facare,
     >                    hettri, aretri,
     >                    filtri, pertri, nivtri, homtri,
     >                    voltri, pypetr,
     >                    hetqua, arequa,
     >                    filqua, perqua, nivqua, quahom,
     >                    volqua, pypequ,
     >                    hettet, tritet,
     >                    hethex, quahex, coquhe,
     >                    hetpyr, facpyr, cofapy,
     >                    hetpen, facpen, cofape,
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
c traitement des DEcisions - Raffinement : CONtamination
c                --          -             ---
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
c . maconf . e   .    1   . conformite du maillage                     .
c .        .     .        .  0 : oui                                   .
c .        .     .        .  1 : non-conforme avec au minimum 2 aretes .
c .        .     .        .      non decoupees en 2 par face           .
c .        .     .        .  2 : non-conforme avec 1 seul noeud pendant.
c .        .     .        .      par arete                             .
c .        .     .        .  3 : non-conforme fidele a l'indicateur    .
c .        .     .        . -1 : conforme, avec des boites pour les    .
c .        .     .        .      quadrangles, hexaedres et pentaedres  .
c .        .     .        . -2 : non-conforme avec au maximum 1 arete  .
c .        .     .        .      decoupee en 2 et des boites pour les  .
c .        .     .        .       quadrangles, hexaedres et pentaedres .
c .        .     .        . 10 : non-conforme sans autre connaissance  .
c . decare . es  . nbarto . decisions des aretes                       .
c . decfac . es  . -nbquto. decision sur les faces (quad. + tri.)      .
c .        .     . :nbtrto.                                            .
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . filare . e   . nbarto . premiere fille des aretes                  .
c . merare . e   . nbarto . mere des aretes                            .
c . arehom . e   . nbarto . ensemble des aretes homologues             .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   . nbtrto . numeros des 3 aretes des triangles         .
c . filtri . e   . nbtrto . premier fils des triangles                 .
c . pertri . e   . nbtrto . pere des triangles                         .
c . nivtri . e   . nbtrto . niveau des triangles                       .
c . homtri . e   . nbtrto . ensemble des triangles homologues          .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . pypetr . e   .2*lgpype. pypetr(1,j) = numero de la pyramide voisine.
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c .        .     .        . pypetr(2,j) = numero du pentaedre voisin   .
c .        .     .        . du triangle k tel que voltri(1/2,k) = -j   .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   . nbquto . numeros des 4 aretes des quadrangles       .
c . filqua . e   . nbquto . premier fils des quadrangles               .
c . perqua . e   . nbquto . pere des quadrangles                       .
c . nivqua . e   . nbquto . niveau des quadrangles                     .
c . quahom . e   . nbquto . ensemble des quadrangles homologues        .
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . pypequ . e   .2*lgpype. pypequ(1,j) = numero de la pyramide voisine.
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c .        .     .        . pypequ(2,j) = numero du pentaedre voisin   .
c .        .     .        . du quadrangle k tel que volqua(1/2,k) = -j .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . coquhe . e   .nbhecf*6. codes des 6 quadrangles des hexaedres      .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des faces des pentaedres           .
c . cofape . e   .nbpecf*5. code des 5 faces des pentaedres            .
c . listfa . t   .   *    . liste de faces a considerer                .
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
      parameter ( nompro = 'DERCON' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "envada.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombpy.h"
#include "nombpe.h"
#include "nombhe.h"
c
c 0.3. ==> arguments
c
      integer tyconf, homolo, maconf
      integer decare(0:nbarto)
      integer decfac(-nbquto:nbtrto)
      integer hetare(nbarto), filare(nbarto), merare(nbarto)
      integer arehom(nbarto)
      integer posifa(0:nbarto), facare(nbfaar)
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer filtri(nbtrto), pertri(nbtrto), nivtri(nbtrto)
      integer homtri(nbtrto)
      integer voltri(2,nbtrto), pypetr(2,*)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer filqua(nbquto), perqua(nbquto), nivqua(nbquto)
      integer quahom(nbquto)
      integer volqua(2,nbquto), pypequ(2,*)
      integer hettet(nbteto), tritet(nbtecf,4)
      integer hethex(nbheto), quahex(nbhecf,6), coquhe(nbhecf,6)
      integer hetpyr(nbpyto), facpyr(nbpycf,5), cofapy(nbpycf,5)
      integer hetpen(nbpeto), facpen(nbpecf,5), cofape(nbpecf,5)
      integer listfa(*)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer nivdeb, nivfin
      integer niveau
      integer iaux
#ifdef _DEBUG_HOMARD_
      integer jaux, kaux
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
c 1. initialisations
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
#ifdef _DEBUG_HOMARD_
        write (ulsort,90002) 'maconf', maconf
        write (ulsort,90002) 'tyconf', tyconf
#endif
c
#ifdef _DEBUG_HOMARD_
        do 1103 , iaux = 1 , nbarto
          if ( iaux.eq.-17735 .or. iaux.eq.-1207 ) then
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
11041     continue
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
11051     continue
         endif
 1105   continue
#endif
cgn       print *,'entree de',nompro,'perqua : ',perqua
c
c====
c 2. algorithme : on regarde tous les niveaux dans l'ordre decroissant
c
c    tyconf = 1 : non-conforme avec au minimum 2 aretes non decoupees
c                 .                      ---------------
c                . .                     .             .
c               .   .                    .             .
c              .     .                   .             .
c             .       .                  .             .
c            .         .                 .             .
c           .           .                .             .
c           ------X------                --------X------
c
c          -------X-------               ---------------
c          .             .               .             .
c          .             .               .             .
c          .             .               X             .
c          .             .               .             .
c          .             .               .             .
c          .             .               .             .
c          --------X------               --------X------
c
c    Cela correspond au raffinement libre, sans appliquer le raffinement
c    de conformite final
c
c    tyconf = 2 : non-conforme avec 1 noeud pendant unique par arete
c                 .                      ---------------
c                . .                     .             .
c               .   .                    .             .
c              .     .                   .             .
c             .       .                  .             .
c            .         .                 .             .
c           .           .                .             .
c           ------X------                --------X------
c
c                 .                      ---------------
c                . .                     .             .
c               .   .                    .             .
c              X     .                   X             .
c             .       .                  .             .
c            .         .                 .             .
c           .           .                .             .
c           ------X------                --------X------
c
c          -------X-------               -------X-------
c          .             .               .             .
c          .             .               .             .
c          .             .               X             .
c          .             .               .             .
c          .             .               .             .
c          .             .               .             .
c          --------X------               --------X------
c    Cela correspond a ignorer la regle des deux voisins, mais a
c    appliquer la regle sur les differences de niveau
c====
c
      nivdeb = nivsup
      nivfin = max(nivinf-1,0)
      do 20 , niveau = nivdeb , nivfin , -1
c
#ifdef _DEBUG_HOMARD_
        write (ulsort,90000)
        write (ulsort,texte(langue,12)) niveau
#endif
c
        iaux = niveau
c
c 2.1. ==> cas sans entites homologues, sauf eventuellement des noeuds
c
        if ( homolo.le.1 ) then
c
c 2.1.1. ==> regle des ecarts de niveau
c            ==========================
c
          if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,3)) 'DERCO2', nompro
#endif
c
            call derco2 ( tyconf, iaux,
     >                    decare, decfac,
     >                    hetare, filare,
     >                    hettri, aretri, filtri, nivtri,
     >                    voltri, pypetr,
     >                    hetqua, arequa, filqua, nivqua,
     >                    volqua, pypequ,
     >                    tritet,
     >                    quahex, coquhe,
     >                    facpyr, cofapy,
     >                    facpen, cofape,
     >                    ulsort, langue, codret )
c
          endif
c
c 2.1.2. ==> regle des deux voisins
c            ======================
c            elle s'applique aux cas d'adaptation :
c    tyconf = 0 ; conforme
c    tyconf = 1 ; non-conforme avec au minimum 2 aretes non coupees
c    tyconf = -1 ; conforme avec boites
c    tyconf = -2 ; non-conforme avec au maximum 1 arete coupee
c
          if ( codret.eq.0 ) then
c
          if ( tyconf.le.1 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,3)) 'DERCO1', nompro
#endif
c
            call derco1 ( tyconf,
     >                    iaux,
     >                    decare, decfac,
     >                    hetare,
     >                    posifa, facare,
     >                    hettri, aretri, nivtri,
     >                    hetqua, arequa, nivqua,
     >                    listfa,
     >                    ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
        do 2123 , iaux = 1 , nbarto
          if ( iaux.eq.-4739 .or. iaux.eq.-1207 ) then
            write (ulsort,90001) '.. arete e/d', iaux,
     >      hetare(iaux), decare(iaux)
          endif
 2123   continue
        do 2125 , jaux = 1 , nbquto
        if ( jaux.eq.-215996 .or. jaux.eq.-66980 ) then
          write (ulsort,90001) 'quadrangle', jaux,
     >    arequa(jaux,1), arequa(jaux,2),
     >    arequa(jaux,3), arequa(jaux,4)
          write (ulsort,90002) 'de decision', decfac(-jaux)
         endif
 2125   continue
#endif
c
          endif
c
          endif
c
c 2.1.3. ==> ecarts de niveau, complements non conforme, 1 noeud pendant
c            ===========================================================
c
          if ( tyconf.eq.2 ) then
c
            if ( niveau.gt.1 ) then
c
              if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,3)) 'DERCO3', nompro
#endif
c
              call derco3 ( iaux,
     >                      decare, decfac,
     >                      merare,
     >                      posifa, facare,
     >                      hettri, aretri, pertri, nivtri,
     >                      voltri,
     >                      hetqua, arequa, perqua, nivqua,
     >                      tritet,
     >                      ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
        do 2135 , jaux = 1 , nbquto
        if ( jaux.eq.-94774 ) then
          write (ulsort,90001) 'quadrangle', jaux,
     >    arequa(jaux,1), arequa(jaux,2),
     >    arequa(jaux,3), arequa(jaux,4)
          write (ulsort,90002) 'de decision', decfac(-jaux)
         endif
 2135   continue
#endif
c
              endif
c
            endif
c
c=======================================================================
            if ( nbteto.gt.0 .or. nbheto.gt.0 .or. nbpeto.gt.0 ) then
c
              if ( codret.eq.0 ) then
c
c   ATTENTION : c'est une verrue pour imposer un rapport 1/4 sur
c                les recollements de non conformite
c                 a filtrer quand on aura ameliore le pilotage
c                      du non conforme
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,3)) 'DERCO8', nompro
#endif
c
              call derco8 ( iaux,
     >                      decare, decfac,
     >                      hetare,
     >                      hettri, aretri, pertri, nivtri,
     >                      voltri,
     >                      hetqua, arequa, perqua, nivqua,
     >                      volqua,
     >                      hettet, tritet,
     >                      hethex, quahex,
     >                      ulsort, langue, codret )
#ifdef _DEBUG_HOMARD_
        do 21351 , jaux = 1 , nbquto
        if ( jaux.eq.-94774 ) then
          write (ulsort,90001) 'quadrangle', jaux,
     >    arequa(jaux,1), arequa(jaux,2),
     >    arequa(jaux,3), arequa(jaux,4)
          write (ulsort,90002) 'de decision', decfac(-jaux)
         endif
21351   continue
#endif
c
              endif
c
            endif
c=======================================================================
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,3)) 'DERCO7', nompro
#endif
c
            call derco7 ( iaux,
     >                    decare, decfac,
     >                    hetare,
     >                    hettri, aretri, nivtri,
     >                    voltri,
     >                    hetqua, arequa, nivqua,
     >                    volqua,
     >                    ulsort, langue, codret )
c
#ifdef _DEBUG_HOMARD_
        do 21353 , iaux = 1 , nbarto
          if ( iaux.eq.-4739 .or. iaux.eq.-1207 ) then
            write (ulsort,90001) '.. arete e/d', iaux,
     >      hetare(iaux), decare(iaux)
          endif
21353   continue
        do 21352 , jaux = 1 , nbquto
        if ( jaux.eq.-94774 ) then
          write (ulsort,90001) 'quadrangle', jaux,
     >    arequa(jaux,1), arequa(jaux,2),
     >    arequa(jaux,3), arequa(jaux,4)
          write (ulsort,90002) 'de decision', decfac(-jaux)
         endif
21352   continue
#endif
            endif
c
          endif
c
c 2.2. ==> cas avec homologues
c
        else
c
c 2.2.1. ==> regle des ecarts de niveau
c            ==========================
c
          if ( codret.eq.0 ) then
c
c          if ( niveau.gt.0 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,3)) 'DERCO5', nompro
#endif
c
            call derco5 ( tyconf, iaux,
     >                    decare, decfac,
     >                    hetare, filare, arehom,
     >                    hettri, aretri, filtri, nivtri, homtri,
     >                    voltri, pypetr,
     >                    hetqua, arequa, filqua, nivqua, quahom,
     >                    volqua, pypequ,
     >                    tritet,
     >                    quahex, coquhe,
     >                    facpyr, cofapy,
     >                    facpen, cofape,
     >                    ulsort, langue, codret )
c
c          endif
c
          endif
c
c 2.2.2. ==> regle des deux voisins
c            ======================
c            elle s'applique aux cas de raffinement :
c    tyconf = 0 ; libre
c    tyconf = 1 ; non-conforme avec au miximum 2 aretes non coupees
c    tyconf = -1 ; libre avec boites
c    tyconf = -2 ; non-conforme avec au maximum 1 arete coupee
c
          if ( codret.eq.0 ) then
c
          if ( tyconf.le.1 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,3)) 'DERCO4', nompro
#endif
c
            call derco4 ( tyconf,
     >                    iaux,
     >                    decare, decfac,
     >                    hetare, arehom,
     >                    posifa, facare,
     >                    hettri, aretri, nivtri,
     >                    hetqua, arequa, nivqua,
     >                    listfa,
     >                    ulsort, langue, codret )
c
          endif
c
          endif
c
c 2.2.3. ==> ecarts de niveau, complements non conforme, 1 noeud pendant
c            ===========================================================
c
          if ( tyconf.eq.2 ) then
c
            if ( niveau.gt.1 ) then
c
              if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
              write (ulsort,texte(langue,3)) 'DERCO6', nompro
#endif
c
              call derco6 ( iaux,
     >                      decare, decfac,
     >                      merare, arehom,
     >                      posifa, facare,
     >                      hettri, aretri, pertri, nivtri,
     >                      voltri,
     >                      hetqua, arequa, perqua, nivqua,
     >                      tritet,
     >                      listfa,
     >                      ulsort, langue, codret )
c
              endif
c
            endif
c
            if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
            write (ulsort,texte(langue,3)) 'DERCO7', nompro
#endif
c
            call derco7 ( iaux,
     >                    decare, decfac,
     >                    hetare,
     >                    hettri, aretri, nivtri,
     >                    voltri,
     >                    hetqua, arequa, nivqua,
     >                    volqua,
     >                    ulsort, langue, codret )
c
            endif
c
          endif
c
        endif
cgn        print *,'fin 20, n = ',niveau,', ',decfac(5), decfac(8)
c
   20 continue
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
        do 2103 , iaux = 1 , nbarto
          if ( iaux.eq.-17735 .or. iaux.eq.-1207 ) then
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
21041     continue
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
21051     continue
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

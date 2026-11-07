      subroutine utb17a ( hetare, somare, np2are,
     >                    posifa, facare,
     >                    hettri, aretri,
     >                    hetqua, arequa,
     >                    hettet, tritet, cotrte, aretet,
     >                    hethex, quahex, coquhe, arehex,
     >                    hetpyr, facpyr, cofapy, arepyr,
     >                    hetpen, facpen, cofape, arepen,
     >                    voltri,
     >                    volqua,
     >                    famare, cfaare,
     >                    famtri, cfatri,
     >                    famqua, cfaqua,
     >                    tabaux,
     >                    ulbila,
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
c    UTilitaire - Bilan sur le maillage - option 17
c    --           -                              --
c ______________________________________________________________________
c
c diagnostic des elements du calcul
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . hetare . e   . nbarto . historique de l'etat des aretes            .
c . somare . e   .2*nbarto. numeros des extremites d'arete             .
c . np2are . e   . nbarto . numero des noeuds p2 milieux d'aretes      .
c . posifa . e   . nbarto . pointeur sur tableau facare                .
c . facare . e   . nbfaar . liste des faces contenant une arete        .
c . hettri . e   . nbtrto . historique de l'etat des triangles         .
c . aretri . e   .nbtrto*3. numeros des 3 aretes des triangles         .
c . hetqua . e   . nbquto . historique de l'etat des quadrangles       .
c . arequa . e   .nbquto*4. numeros des 4 aretes des quadrangles       .
c . hettet . e   . nbteto . historique de l'etat des tetraedres        .
c . tritet . e   .nbtecf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . e   .nbtecf*4. codes des triangles des tetraedres         .
c . hethex . e   . nbheto . historique de l'etat des hexaedres         .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . quahex . e   .nbhecf*6. numeros des 6 quadrangles des hexaedres    .
c . hetpyr . e   . nbpyto . historique de l'etat des pyramides         .
c . facpyr . e   .nbpycf*5. numeros des 5 faces des pyramides          .
c . cofapy . e   .nbpycf*5. codes des faces des pyramides              .
c . hetpen . e   . nbpeto . historique de l'etat des pentaedres        .
c . facpen . e   .nbpecf*5. numeros des 5 faces des pentaedres         .
c . cofape . e   .nbpecf*5. codes des faces des pentaedres             .
c . voltri . e   .2*nbtrto. numeros des 2 volumes par triangle         .
c .        .     .        . voltri(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : tetraedre j                          .
c .        .     .        . j<0 : pyramide/pentaedre dans pypetr(1/2,j).
c . volqua . e   .2*nbquto. numeros des 2 volumes par quadrangle       .
c .        .     .        . volqua(i,k) definit le i-eme voisin de k   .
c .        .     .        .   0 : pas de voisin                        .
c .        .     .        . j>0 : hexaedre j                           .
c .        .     .        . j<0 : pyramide/pentaedre dans pypequ(1/2,j).
c . famare . e   . nbarto . famille des aretes                         .
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
c . famtri . e   . nbtrto . famille des triangles                      .
c . cfatri . e   . nctftr*. codes des familles des triangles           .
c .        .     . nbftri .   1 : famille MED                          .
c .        .     .        .   2 : type de triangle                     .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        . + l : appartenance a l'equivalence l       .
c . famqua . e   . nbquto . famille des quadrangles                    .
c . cfaqua . e   . nctfqu*. codes des familles des quadrangles         .
c .        .     . nbfqua .   1 : famille MED                          .
c .        .     .        .   2 : type de quadrangle                   .
c .        .     .        .   3 : numero de surface de frontiere       .
c .        .     .        .   4 : famille des aretes internes apres raf.
c .        .     .        .   5 : famille des triangles de conformite  .
c .        .     .        .   6 : famille de sf active/inactive        .
c .        .     .        . + l : appartenance a l'equivalence l       .
c . tabaux . a   . nbnoto . tableau auxiliaire                         .
c . ulbila . e   .   1    . unite logique d'ecriture du bilan          .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
c . langue . e   .    1   . langue des messages                        .
c .        .     .        . 1 : francais, 2 : anglais                  .
c . codret .  s  .    1   . code de retour des modules                 .
c .        .     .        . 0 : pas de probleme                        .
c .        .     .        . 1 : probleme                               .
c .____________________________________________________________________.
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
      parameter ( nompro = 'UTB17A' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "nbfami.h"
#include "nombno.h"
#include "nombar.h"
#include "nombtr.h"
#include "nombqu.h"
#include "nombte.h"
#include "nombhe.h"
#include "nombpy.h"
#include "nombpe.h"
c
#include "dicfen.h"
c
c 0.3. ==> arguments
c
      integer hetare(nbarto), somare(2,nbarto), np2are(nbarto)
c
      integer hettri(nbtrto), aretri(nbtrto,3)
      integer hetqua(nbquto), arequa(nbquto,4)
      integer hettet(nbteto)
      integer tritet(nbtecf,4), cotrte(nbtecf,4), aretet(nbteca,6)
      integer hethex(nbheto)
      integer quahex(nbhecf,6), coquhe(nbhecf,6), arehex(nbheca,12)
      integer hetpyr(nbpyto)
      integer facpyr(nbpycf,5), cofapy(nbpycf,5), arepyr(nbpyca,8)
      integer hetpen(nbpeto)
      integer facpen(nbpecf,5), cofape(nbpecf,5), arepen(nbpeca,9)
c
      integer posifa(0:nbarto), facare(nbfaar)
      integer volqua(2,nbquto)
      integer voltri(2,nbtrto)
c
      integer famare(nbarto), cfaare(nctfar,nbfare)
      integer famtri(nbtrto), cfatri(nctftr,nbftri)
      integer famqua(nbquto), cfaqua(nctfqu,nbfqua)
c
      integer tabaux(nbnoto)
c
      integer ulbila
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
c
      integer nbmess
      parameter (nbmess = 10 )
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
      texte(1,4) =
     >'(//,3x,''DIAGNOSTICS SUR LES ELEMENTS DU CALCUL'',/,3x,38(''=''),
     >/)'
      texte(1,5) =
     > '(3x,''Un element est surcontraint si tous ses noeuds sont'')'
      texte(1,6) =
     > '(3x,''sur le bord du domaine. Cela peut poser un probleme'')'
      texte(1,7) =
     > '(3x,''selon les conditions aux limites utilisees.'')'
c
      texte(2,4) =
     > '(//,3x,''DIAGNOSIS OF CALCULATION ELEMENTS'',/,3x,33(''=''),/)'
      texte(2,5) =
     > '(3x,''An element is overstressed if all its nodes are'')'
      texte(2,6) =
     > '(3x,''located on the boundary of the domain. It may give,'')'
      texte(2,7) =
     > '(3x,''problem depending on the used boundary conditions.'')'
c
      codret = 0
c
      do 11 , iaux = 4, 7
        write (ulbila,texte(langue,iaux))
   11 continue
c
c====
c 2. Mailles surfaciques
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '2. Mailles surfaciques : codret = ', codret
#endif
c
      if ( nbtrac.gt.0 .or. nbquac.gt.0 ) then
c
c 2.1. ==> Reperage des noeuds de bord
c
        if ( codret.eq.0 ) then
c
        iaux = 1
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB17D', nompro
#endif
        call utb17d ( iaux,
     >                hetare, somare, np2are,
     >                posifa, facare,
     >                hettri, aretri, voltri,
     >                hetqua, arequa, volqua,
     >                tabaux,
     >                ulsort, langue, codret )
c
        endif
c
c 2.2. ==> Calcul
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB17C', nompro
#endif
        call utb17c ( somare, np2are,
     >                hettri, aretri,
     >                hetqua, arequa,
     >                voltri,
     >                volqua,
     >                posifa, facare,
     >                famare, cfaare,
     >                famtri, cfatri,
     >                famqua, cfaqua,
     >                tabaux,
     >                ulbila,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
c====
c 3. Mailles volumiques
c====
#ifdef _DEBUG_HOMARD_
      write (ulsort,*) '3. Mailles volumiques : codret = ', codret
#endif
c
      if ( nbteac.gt.0 .or. nbheac.gt.0 .or.
     >     nbpyac.gt.0 .or. nbpeac.gt.0 ) then
c
c 3.1. ==> Reperage des noeuds de bord
c
        if ( codret.eq.0 ) then
c
        iaux = 2
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB17D', nompro
#endif
        call utb17d ( iaux,
     >                hetare, somare, np2are,
     >                posifa, facare,
     >                hettri, aretri, voltri,
     >                hetqua, arequa, volqua,
     >                tabaux,
     >                ulsort, langue, codret )
c
        endif
c
c 3.2. ==> Calcul
c
        if ( codret.eq.0 ) then
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTB17B', nompro
#endif
        call utb17b ( somare, np2are,
     >                aretri, voltri,
     >                famtri, cfatri,
     >                arequa, volqua,
     >                famqua, cfaqua,
     >                hettet, tritet, cotrte, aretet,
     >                hethex, quahex, coquhe, arehex,
     >                hetpyr, facpyr, cofapy, arepyr,
     >                hetpen, facpen, cofape, arepen,
     >                tabaux,
     >                ulbila,
     >                ulsort, langue, codret )
c
        endif
c
      endif
c
      end

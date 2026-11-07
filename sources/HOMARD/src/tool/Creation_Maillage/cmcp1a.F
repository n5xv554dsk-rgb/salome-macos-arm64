      subroutine cmcp1a ( lepent, etapen,
     >                    indtri, indtet, indpyr,
     >                    indptp,
     >                    hetare,
     >                    hettri, aretri,
     >                    filtri, pertri, famtri,
     >                    nivtri,
     >                    arequa, filqua,
     >                    hettet, tritet, cotrte,
     >                    filtet, pertet, famtet,
     >                    hetpyr, facpyr, cofapy,
     >                    filpyr, perpyr, fampyr,
     >                    facpen, cofape,
     >                    fampen, cfapen,
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
c    Creation du Maillage - Conformite - decoupage des Pentaedres
c    -           -          -                          -
c                         - cas 1, phase A, pilotage
c                               -        -
c                         - par 1 arete de quadrangle
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . lepent . e   .   1    . pentaedre a decouper                       .
c . etapen .  s  .    1   . etat final du pentaedre                    .
c . indtri . es  .   1    . indice du dernier triangle cree            .
c . indtet . es  .   1    . indice du dernier tetraedre cree           .
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . hetare . es  . nouvar . historique de l'etat des aretes            .
c . hettri . es  . nouvtr . historique de l'etat des triangles         .
c . aretri . es  .nouvtr*3. numeros des 3 aretes des triangles         .
c . filtri . es  . nouvtr . premier fils des triangles                 .
c . pertri . es  . nouvtr . pere des triangles                         .
c . famtri . es  . nouvtr . famille des triangles                      .
c . nivtri . es  . nouvtr . niveau des triangles                       .
c . arequa . e   .nouvqu*4. numeros des 4 aretes des quadrangles       .
c . filqua . e   . nouvqu . premier fils des quadrangles               .
c . hettet . es  . nouvte . historique de l'etat des tetraedres        .
c . tritet . es  .nouvtf*4. numeros des 4 triangles des tetraedres     .
c . cotrte . es  .nouvtf*4. code des 4 triangles des tetraedres        .
c . filtet . es  . nouvte . premier fils des tetraedres                .
c . pertet . es  . nouvte . pere des tetraedres                        .
c .        .     .        . si pertet(i) > 0 : numero du tetraedre     .
c .        .     .        . si pertet(i) < 0 : -numero dans pthepe     .
c . famtet . es  . nouvte . famille des tetraedres                     .
c . hetpyr . es  . nouvpy . historique de l'etat des pyramides         .
c . facpyr . es  .nouvyf*5. numeros des 5 faces des pyramides          .
c . cofapy . es  .nouvyf*5. codes des faces des pyramides              .
c . filpyr . es  . nouvpy . premier fils des pyramides                 .
c . perpyr . es  . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . fampyr . es  . nouvpy . famille des pyramides                      .
c . facpen . e   .nouvpf*5. numeros des faces des pentaedres           .
c . cofape . e   .nouvpf*5. codes des faces des pentaedres             .
c . fampen . e   . nouvpe . famille des penaedres                      .
c . cfapen . e   . nctfpe*. codes des familles des pentaedres          .
c .        .     . nbfpen .   1 : famille MED                          .
c .        .     .        .   2 : type de pentaedres                   .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c .        .     .        .   3 : famille des tetraedres de conformite .
c .        .     .        .   4 : famille des pyramides de conformite  .
c . ulsort . e   .   1    . unite logique de la sortie generale        .
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
      parameter ( nompro = 'CMCP1A' )
c
#include "nblang.h"
c
c 0.2. ==> communs
c
#include "envex1.h"
c
#include "dicfen.h"
#include "nbfami.h"
#include "nouvnb.h"
c
c 0.3. ==> arguments
c
      integer lepent, etapen
      integer indtri, indtet, indpyr
      integer indptp
      integer hetare(nouvar)
      integer hettri(nouvtr), aretri(nouvtr,3)
      integer filtri(nouvtr), pertri(nouvtr), famtri(nouvtr)
      integer nivtri(nouvtr)
      integer arequa(nouvqu,4)
      integer filqua(nouvqu)
      integer hettet(nouvte), tritet(nouvtf,4), cotrte(nouvtf,4)
      integer filtet(nouvte), pertet(nouvte), famtet(nouvte)
      integer hetpyr(nouvpy), facpyr(nouvyf,5), cofapy(nouvyf,5)
      integer filpyr(nouvpy), perpyr(nouvpy), fampyr(nouvpy)
      integer facpen(nouvpf,5), cofape(nouvpf,5)
      integer fampen(nouvpe), cfapen(nctfpe,nbfpen)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer listar(9)
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
      texte(1,4) = '(''Aucune arete ne correspond.'')'
c
      texte(2,4) = '(''No edge is correct.'')'
c
#include "impr03.h"
#include "impr04.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,90002) 'indtri', indtri
      write (ulsort,90002) 'indtet', indtet
      write (ulsort,90002) 'indpyr', indpyr
#endif
c
      codret = 0
c
c====
c 2. Recherche des aretes
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'UTARPE', nompro
#endif
      call utarpe ( lepent,
     >              nouvqu, nouvpe,
     >              arequa, facpen, cofape,
     >              listar )
c
c====
c 3. Recherche de l'arete decoupee
c====
#ifdef _DEBUG_HOMARD_
      do 3999 , iaux = 1 , 9
        write(ulsort,91001) iaux, listar(iaux),
     >                    hetare(listar(iaux))
 3999 continue
#endif
c
      if ( codret.eq.0 ) then
c
c 3.1. ==> L'arete 7 est coupee
c
      if ( mod(hetare(listar(7)),10).eq.2 ) then
        etapen = 17
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP17', nompro
#endif
        call cmcp17 ( lepent, listar,
     >                indtri, indtet, indpyr,
     >                indptp,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                facpen, cofape,
     >                fampen, cfapen,
     >                ulsort, langue, codret )
c
c 3.2. ==> L'arete 8 est coupee
c
      elseif ( mod(hetare(listar(8)),10).eq.2 ) then
        etapen = 18
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP18', nompro
#endif
        call cmcp18 ( lepent, listar,
     >                indtri, indtet, indpyr,
     >                indptp,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                facpen, cofape,
     >                fampen, cfapen,
     >                ulsort, langue, codret )
c
c 3.3. ==> L'arete 9 est coupee
c
      elseif ( mod(hetare(listar(9)),10).eq.2 ) then
        etapen = 19
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCP19', nompro
#endif
        call cmcp19 ( lepent, listar,
     >                indtri, indtet, indpyr,
     >                indptp,
     >                hettri, aretri,
     >                filtri, pertri, famtri,
     >                nivtri,
     >                filqua,
     >                hettet, tritet, cotrte,
     >                filtet, pertet, famtet,
     >                hetpyr, facpyr, cofapy,
     >                filpyr, perpyr, fampyr,
     >                facpen, cofape,
     >                fampen, cfapen,
     >                ulsort, langue, codret )
c
c 3.4. ==> Laquelle ?
c
      else
        codret = 1
      endif
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
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      write (ulsort,texte(langue,2)) codret
      write (ulsort,texte(langue,4))
c
      endif
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Sortie', nompro
      call dmflsh (iaux)
#endif
c
      end

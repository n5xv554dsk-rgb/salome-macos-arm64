      subroutine cmcp4d ( indpyr, indptp,
     >                    lepent,
     >                    trifad, cotrvo, triint,
     >                    quafad, coface,
     >                    hetpyr, facpyr, cofapy,
     >                    filpyr, perpyr, fampyr,
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
c                         - cas 4, phase D
c                               -        -
c    Construction des pyramides
c ______________________________________________________________________
c .        .     .        .                                            .
c .  nom   . e/s . taille .           description                      .
c .____________________________________________________________________.
c . indpyr . es  .   1    . indice de la derniere pyramide creee       .
c . indptp . e   .   1    . indice du dernier pere enregistre          .
c . lepent . e   .   1    . pentaedre a decouper                       .
c . trifad . e   .(4,0:2) . triangles traces sur les faces decoupees   .
c . cotrvo . e   .(4,0:2) . code des triangles dans les volumes        .
c . triint . e   .   7    . triangles internes au pentaedre            .
c .        .     .        .  1-4 = base parallele au triangle          .
c .        .     .        .  1 = cote F1, quad suivant quad coupe en 4 .
c .        .     .        .  2 = cote F1, quad suivant                 .
c .        .     .        .  3 = cote F2, quad suivant quad coupe en 4 .
c .        .     .        .  4 = cote F2, quad suivant                 .
c .        .     .        .  5-6 = base coupant le triangle            .
c .        .     .        .  5 = cote F1                               .
c .        .     .        .  6 = cote F2                               .
c .        .     .        .  7 = s'appuyant sur la derniere non coupee .
c . quafad . e   .   4    . quadrangles traces sur les faces decoupees .
c . coface . e   .   1    . code des faces quadrangulaires             .
c . hetpyr . es  . nouvpy . historique de l'etat des pyramides         .
c . facpyr . es  .nouvyf*5. numeros des 5 faces des pyramides          .
c . cofapy . es  .nouvyf*5. codes des faces des pyramides              .
c . filpyr . es  . nouvpy . premier fils des pyramides                 .
c . perpyr . es  . nouvpy . pere des pyramides                         .
c .        .     .        . si perpyr(i) > 0 : numero de la pyramide   .
c .        .     .        . si perpyr(i) < 0 : -numero dans pphepe     .
c . fampyr . es  . nouvpy . famille des pyramides                      .
c . fampen . e   . nouvpe . famille des pentaedres                     .
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
      parameter ( nompro = 'CMCP4D' )
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
#include "cofpfp.h"
c
c 0.3. ==> arguments
c
      integer indpyr, indptp
      integer lepent
      integer trifad(4,0:2), cotrvo(4,0:2)
      integer triint(7)
      integer quafad(4), coface
      integer hetpyr(nouvpy), facpyr(nouvyf,5), cofapy(nouvyf,5)
      integer filpyr(nouvpy), perpyr(nouvpy), fampyr(nouvpy)
      integer fampen(nouvpe), cfapen(nctfpe,nbfpen)
c
      integer ulsort, langue, codret
c
c 0.4. ==> variables locales
c
      integer iaux
      integer nupere, nufami
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
#include "impr01.h"
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,1)) 'Entree', nompro
      call dmflsh (iaux)
#endif
c
      codret = 0
c
c 1.2. ==> Le pere des pyramides et leur famille
c
      nupere = -indptp
      nufami = cfapen(cofpfp,fampen(lepent))
c
c====
c 2. Pyramide
c====
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYR_1', nompro
#endif
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              trifad(3,0), cotrvo(3,0),
     >                triint(5),           1,
     >                triint(1),           2,
     >              trifad(1,1), cotrvo(1,1),
     >                quafad(1),      coface,
     >              nupere,  nufami,   indpyr )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYR_2', nompro
#endif
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              trifad(2,1), cotrvo(2,1),
     >                triint(2),           1,
     >                triint(5),           6,
     >              trifad(3,1), cotrvo(3,1),
     >                quafad(2),      coface,
     >              nupere,  nufami,   indpyr )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYR_3', nompro
#endif
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              trifad(4,1), cotrvo(4,1),
     >                triint(6),           1,
     >                triint(4),           2,
     >              trifad(2,2), cotrvo(2,2),
     >                quafad(3),      coface,
     >              nupere,  nufami,   indpyr )
c
#ifdef _DEBUG_HOMARD_
      write (ulsort,texte(langue,3)) 'CMCPYR_4', nompro
#endif
      indpyr = indpyr + 1
      call cmcpyr ( facpyr, cofapy, fampyr, hetpyr, filpyr, perpyr,
     >              trifad(1,2), cotrvo(1,2),
     >                triint(3),           1,
     >                triint(6),           6,
     >              trifad(4,0), cotrvo(4,0),
     >                quafad(4),      coface,
     >              nupere,  nufami,   indpyr )
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
